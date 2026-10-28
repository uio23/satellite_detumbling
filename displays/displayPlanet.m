% Create 3D planet and display it


figure(Name=Constants.planet_name + " 3D", NumberTitle="off", WindowStyle="docked")


[X,Y,Z] = sphere();
X = X * Constants.planet_rad;
Y = Y * Constants.planet_rad;
Z = Z * Constants.planet_rad;


s = surf(X, Y, Z);
s.FaceColor = '#C6D57E';
s.FaceAlpha = 0.8;


xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title(Constants.planet_name);
