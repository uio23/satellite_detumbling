function dydt = orbitStep(t, y, sat) %#ok<*INUSD>
% ORBITSTEP

    position = y(1:3);
    velocity = y(4:6);

    attitude = y(7:10);
    angular_velocity = y(11:13);

    % 1. Position rate of change .r
    drdt = velocity;

    % 2. Newtonian gravitational acceleration .v
    gravitational_acceleration = -(Constants.gravitational_parameter * position) / norm(position)^3;

    % 3. Attitude rate of change .q
    % Transform values into row vector quaternions
    angular_velocity_q = [0 angular_velocity'];
    attitude_q = attitude';
    dqdt = quatmultiply(attitude_q, angular_velocity_q)' / 2;

    % 4. Euler's rotational acceleration .w

    % Transform magnetic field from space frame into body frame
    B_field = dipoleField(position', Constants.dipole_moment);
    B_body = quatrotate(attitude_q, B_field);

    % Apply torque produce by magnetorquer moment to satellite torque
    magnetorquer_torque = cross(sat.M_cmd, B_body);
    net_torque = sat.Torque + magnetorquer_torque;
   
    angular_acceleration = sat.Inertia_Tensor \ (net_torque' - cross(angular_velocity, sat.Inertia_Tensor * angular_velocity));

    % Assemble state derivatives
    dydt = [drdt;
            gravitational_acceleration;
            dqdt;
            angular_acceleration];
end
