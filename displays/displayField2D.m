% Create 2D planet figure and 
% display quiver plot of its magnetic field in x-z axis


figure(Name=Constants.planet_name + " 2D", NumberTitle="off", WindowStyle="docked")


% Filter down magnetic field data to those rows where the position is along
% the y axis
y_bfield = bfield_data(bfield_data(:, 2) == 0, :);


q = quiver(y_bfield(:,1), y_bfield(:,3), y_bfield(:,4), y_bfield(:,6));
q.Color = "#006199";

r = rectangle(Position=[-Constants.planet_rad, -Constants.planet_rad, Constants.planet_rad * 2, Constants.planet_rad * 2], Curvature=[1 1]);
r.EdgeColor = "#A2CDCD";
r.FaceColor = "#C6D57E";
r.FaceAlpha = 0.8;


xlabel('X-axis');
zlabel('Z-axis');
title("2D " + Constants.planet_name + " Dipole")