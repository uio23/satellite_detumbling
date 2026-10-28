% Display quiver plot of magnetic field around planet
% by calculating the B field values at pi/18 intervals


hold on
createBField();

q = quiver3(bfield_data(:,1), bfield_data(:,2), bfield_data(:,3), bfield_data(:,4), bfield_data(:,5), bfield_data(:,6));
q.Color = "#006199";
q.AutoScaleFactor = 2;
q.LineWidth = 1;


title("3D " + Constants.planet_name + " Dipole");