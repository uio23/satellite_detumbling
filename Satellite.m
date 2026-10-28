classdef Satellite
    properties
        Semi_Major
        Inclination
        Attitude
        Angular_Velocity
        Inertia_Tensor
        
        Position
        Velocity
        Torque

        Period
        Mean_Motion

        K

        M_cmd

        Ode_opts
    end

    methods
        function sat = Satellite(semi_major, inclination, attitude, angular_velocity, inertia_tensor)
        % SATELLITE Create an instance of a satellite, calculating its
        %           stats from the specified parameters
        % 
        % @param semi_major       Max distance in meters from planet centre
        % @param inclination      Angle in radians of the orbit's tilt
        %                         from the equator
        % @param attitude         Starting orientation
        % @param angular_velocity Starting angular velocity
        % @param inertia_tensor   3x3 mass distribution matrix

            sat.Semi_Major = semi_major;
            sat.Inclination = inclination;
            sat.Attitude = attitude;
            sat.Angular_Velocity = angular_velocity;
            sat.Inertia_Tensor = inertia_tensor;

            % Position sat on the equatorial plane
            sat.Position = [sat.Semi_Major 0 0];

            % Circular orbit speed
            sat.Velocity = sqrt(Constants.gravitational_parameter / norm(sat.Position));
            % Apply inclination relative to equatorial plane
            sat.Velocity = sat.Velocity * [0 cos(sat.Inclination) sin(sat.Inclination)];

            sat.Torque = [0 0 0];

            % Calculate period and mean motion
            sat.Period = (2*pi) * sqrt(sat.Semi_Major^3 / Constants.gravitational_parameter);
            sat.Mean_Motion = (2*pi) / sat.Period;

            % Calculate control value K for magentotorquer
            j_min = min(vecnorm(sat.Inertia_Tensor, 2, 2));
            sat.K = (2*sat.Mean_Motion) * (1 + sin(sat.Inclination)) * j_min;

            sat.M_cmd = [0 0 0];

            sat.Ode_opts = odeset('Reltol',1e-13,'AbsTol',1e-14);
        end

        function simulation = performOrbit(sat, orbits, dt, integrate_between, apply_noise)
        % PERFORMORBIT Simulate orbit and detubbling, for some number of orbits,
        %              and produce the simulation data from that. Integration can be done
        %              between time increments, but this is much more computationally
        %              intensive.
        %
        % @param orbits            Number of orbits to perform
        % @param dt                Time step for controller
        % @param integrate_between true for ode integration between steps

            duration = orbits * sat.Period;

            y0 = [sat.Position';
                  sat.Velocity';
                  sat.Attitude';
                  sat.Angular_Velocity'];

            ticks = ceil(duration / dt);
            tick = 1;
            if (~integrate_between)
                t = zeros(ticks,1);
                y = zeros(ticks,height(y0));
            end
            t(1) = 0;
            y(1, :) = y0';


            B_hat_prev = [0 0 0];

            t_seg = [];
            y_seg = [];

            last_log = 0;

            while (t(tick) < duration)
                step = t(tick) + dt;

                position = y(tick, 1:3);
                attitude_q = y(tick, 7:10);

                B_field = dipoleField(position, Constants.dipole_moment);
                B_body = quatrotate(attitude_q, B_field);

                if (apply_noise)
                    B_body = quatrotate(attitude_q, B_field) + sat.getNoise(B_field)*10;
                end
                
                % Derivative of the magnetic field direction
                B_hat = B_body / norm(B_body);
                B_hat_dot = (B_hat - B_hat_prev) / dt;

                % Required an angular velocity reading for perfect*
                % detumbling
                % sat.M_cmd = -(sat.K/norm(B_body)) * cross(B_hat, angular_velocity);

                sat.M_cmd = -(sat.K/norm(B_body)) * B_hat_dot;

                if (integrate_between)
                    [t_seg, y_seg] = ode113(@(t, y) orbitStep(t, y, sat), [t(tick) step], y(tick, :)', sat.Ode_opts);
                    t = [t; t_seg(2:end)];
                    y = [y; y_seg(2:end,:)];
                    tick = height(t);
                else
                    y_step = orbitStepDiscrete(y(tick, :)', dt, sat);
                    tick = tick + 1;
                    t(tick) = step;
                    y(tick, :) = y_step';
                end

                B_hat_prev = B_hat;

                % Log every 10%, remove to increase speed more
                
                if (t(tick)/duration - last_log >= 0.10)
                    last_log = t(tick)/duration;
                    fprintf('%3.2f%%\n', t(tick)/duration * 100);
                end
            end

            angular_velocities = y(:,11:13);

            kinetic_energy       = 0.5 * dot(angular_velocities', sat.Inertia_Tensor * angular_velocities')';
            angular_momentum_mag = vecnorm(sat.Inertia_Tensor * angular_velocities')';
            angular_speed_mag    = vecnorm(angular_velocities, 2, 2);

            simulation = array2table([t y kinetic_energy angular_momentum_mag, angular_speed_mag], ...
                VariableNames = [ ...
                    "Time", ...
                    "X", "Y", "Z", ...
                    "VX", "VY", "VZ", ...
                    "Q0", "Q1", "Q2", "Q3", ...
                    "WX", "WY", "WZ", ...
                    "K", "L", "w"...
                ] ...
            );
        end

        function simulation = performObserverOrbit(sat, orbits, measure_b)
        % PERFORMOBSERVERORBIT Simulate orbiting with ode solver, optionally recording the
        %                      magnetic field
        %
        % @param orbits    Number of orbits to perform
        % @param measure_b true to make actual and noisy measurements of 
        %                  the magnetic field that the satellite passes through

            duration = orbits * sat.Period;

            y0 = [sat.Position';
                  sat.Velocity';
                  sat.Attitude';
                  sat.Angular_Velocity'];

            [t, y] = ode113(@(t, y) orbitStep(t, y, sat), [0 duration], y0, sat.Ode_opts);

            positions = y(:,1:3);
            angular_velocities = y(:,11:13);

            kinetic_energy       = 0.5 * dot(angular_velocities', sat.Inertia_Tensor * angular_velocities')';
            angular_momentum_mag = vecnorm(sat.Inertia_Tensor * angular_velocities')';
            angular_speed_mag    = vecnorm(angular_velocities, 2, 2);

            if (measure_b)
                magnetic_sense = zeros(height(y), 3);
                magnetic_sense_noisy = zeros(size(magnetic_sense));

                for i=1:height(y)
                    magnetic_sense(i, :)       = dipoleField(positions(i,:), Constants.dipole_moment);
                    magnetic_sense_noisy(i, :) = magnetic_sense(i, :) + sat.getNoise(magnetic_sense(i, :));
                end
            end

            simulation = array2table([t y magnetic_sense magnetic_sense_noisy kinetic_energy angular_momentum_mag, angular_speed_mag], ...
                VariableNames = [...
                    "Time", ...
                    "X", "Y", "Z", ...
                    "VX", "VY", "VZ", ...
                    "Q0", "Q1", "Q2", "Q3", ...
                    "WX", "WY", "WZ", ...
                    "BX", "BY", "BZ", ...
                    "BX_noise", "BY_noise", "BZ_noise", ...
                    "K", "L", "w"...
                ] ...
            );
        end

        function noise = getNoise(sat, b_actual)
            % GETNOISE Generate a small vector to simulate the noise in
            %          the satellite's magnetic field sensor

            % Noise is 5% of the actual field,
            % pointing in a random direction
            noise_mag = norm(b_actual) * 0.05;

            noise_vector = (rand(1,3) * 2 - 1);
            noise_vector = noise_vector / sum(abs(noise_vector));

            % Distribute the noise_magnitude by the proportions of the noise_vector
            noise = noise_vector * noise_mag;
        end
    end
end
