% Display the magnetic field measured by satellite vs actual magnetic field
% along the orbit
figure(Name="Magnetic Field TS", NumberTitle="off", WindowStyle="docked")

magnetic_magnitude = vecnorm(simulation{:, ["BX", "BY", "BZ"]}, 2, 2);
magnetic_magnitude_ts = timeseries(magnetic_magnitude, simulation.Time);
magnetic_magnitude_n = vecnorm(simulation{:, ["BX_noise", "BY_noise", "BZ_noise"]}, 2, 2);
magnetic_magnitude_ts_n = timeseries(magnetic_magnitude_n, simulation.Time);

plot(magnetic_magnitude_ts_n, 'LineWidth', 0.8)
hold on
plot(magnetic_magnitude_ts, 'LineWidth', 2)

title('Measured vs Theoretical magnetic field over time')
xlabel('Time [s]')
ylabel('Magnetic Field [T]')
legend('Measured','Theoretical')