% ---
figure(Name="Position TS", NumberTitle="off", WindowStyle="docked")

position_ts = timeseries(simulation{:, ["X", "Y", "Z"]}, simulation.Time);

plot(position_ts)

title('Satellite position components over time');
xlabel('Time [s]');
ylabel('Position Components [m]')
xline(orbital_periods, '--', 'T');
legend('r_x','r_y','r_z')

figure(Name="Altitude TS", NumberTitle="off", WindowStyle="docked")

altitudes = vecnorm(position_ts.Data, 2, 2);
altitude_ts = timeseries(altitudes, position_ts.Time);
plot(altitude_ts)

title('Satellite altitude over time');
xlabel('Time [s]');
ylabel('Altitude [m]')
xline(orbital_periods, '--', 'T');
