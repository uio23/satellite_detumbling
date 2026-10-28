% Create a Satellite object with the specified parameters
% and then perform an orbit of specified duration


clc


semi_major = 7021e3; % Meters
inclination = deg2rad(65); % Radians

angular_velocity = [0.604 -0.760 -0.384];
inertia_tensor   = diag([0.33 0.37 0.35]);
attitude = [-0.062 0.925 -0.007 0.375];

sat = Satellite(semi_major, inclination, attitude, ...
                angular_velocity, inertia_tensor);

n_orbits = 3;
time_step = 1; % Seconds
integrate_between = true;
apply_noise = false;

simulation = sat.performOrbit(n_orbits, time_step, ...
                              integrate_between, apply_noise);

% Or, for B field measurements 
% simulation = sat.performObserverOrbit(n_orbits, true);

% Vector for plotting
orbital_periods = sat.Period:sat.Period:simulation.Time(end);


