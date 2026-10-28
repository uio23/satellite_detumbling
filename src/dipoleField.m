function b = dipoleField(r, dipole_moment)
% DIPLOTEFIELD Calculate magnetic field vector at given position
%
% @param r             Vector position to calculate magnetic field at
% @param dipole_moment Dipole moment of relevant planet

    r_hat = r/norm(r);
    b_mag = Constants.mu0 / (4 * pi * norm(r)^3);
    b = b_mag * (3 * dot(dipole_moment,r_hat) * r_hat  - dipole_moment);
end