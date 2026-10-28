classdef Constants
    properties (Constant)
        mu0 = 4*pi*1e-7;
        G = 6.674e-11; % Gravitational constant

        planet_mass = 5.972e24; % kg
        planet_rad = 6371e3; % m
        planet_name = "Earth";
        gravitational_parameter = Constants.G * Constants.planet_mass;

        b0 =  3.12e-5; % T, reference surface polar field
        dipole_moment_mag = (4 * pi * Constants.b0 * Constants.planet_rad^3) / Constants.mu0;

        % [x, y, z] where up is positive
        dipole_moment = [0, 0, Constants.dipole_moment_mag];
    end
end