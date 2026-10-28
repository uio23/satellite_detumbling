% Plots configuration
show_last = n_orbits; % Show full timeseries

t_start = simulation.Time(end) - (show_last * sat.Period);
after_start = simulation.Time >= t_start;
t_end = simulation.Time(end);

% ---
figure(Name="Attitude TS", NumberTitle="off", WindowStyle="docked")

qx_ts = timeseries(simulation{after_start, "Q1"}, simulation.Time(after_start));
qy_ts = timeseries(simulation{after_start, "Q2"}, simulation.Time(after_start));
qz_ts = timeseries(simulation{after_start, "Q3"}, simulation.Time(after_start));

ax1 = subplot(3, 1, 1);
plot(qx_ts);
title('X-axis');
ylabel('q')
xlabel('Time [s]');
xline(orbital_periods, '--', 'T');
xlim([t_start t_end]);

ax2 = subplot(3, 1, 2);
plot(qy_ts);
title('Y-axis');
ylabel('q')
xlabel('Time [s]');
xline(orbital_periods, '--', 'T');
xlim([t_start t_end]);

ax3 = subplot(3, 1, 3);
plot(qz_ts);
title('Z-axis');
ylabel('q')
xlabel('Time [s]');
xline(orbital_periods, '--', 'T');
xlim([t_start t_end]);

linkaxes([ax1, ax2, ax3], 'y')
sgtitle("Attitude components over time")


% ---
figure(Name="Angular Vel TS", NumberTitle="off", WindowStyle="docked")

wx_ts = timeseries(simulation{after_start, "WX"}, simulation.Time(after_start));
wy_ts = timeseries(simulation{after_start, "WY"}, simulation.Time(after_start));
wz_ts = timeseries(simulation{after_start, "WZ"}, simulation.Time(after_start));

ax4 = subplot(3, 1, 1);
plot(wx_ts);
title('X-axis');
ylabel('w [rad/s]');
xlabel('Time [s]');
xline(orbital_periods, '--', 'T');
xlim([t_start t_end]);

ax5 = subplot(3, 1, 2);
plot(wy_ts);
title('Y-axis');
ylabel('w [rad/s]');
xlabel('Time [s]');
xline(orbital_periods, '--', 'T');
xlim([t_start t_end]);

ax6 = subplot(3, 1, 3);
plot(wz_ts);
title('Z-axis');
ylabel('w [rad/s]');
xlabel('Time [s]');
xline(orbital_periods, '--', 'T');
xlim([t_start t_end]);

linkaxes([ax4, ax5, ax6], 'y')
sgtitle('Angular velocity components over time');


% ---
figure(Name="Other TS", NumberTitle="off", WindowStyle="docked")

l_ts = timeseries(simulation{after_start, "L"}, simulation.Time(after_start));
k_ts = timeseries(simulation{after_start, "K"}, simulation.Time(after_start));
w_ts = timeseries(simulation{after_start, "w"}, simulation.Time(after_start));

subplot(2, 2, 1)
plot(l_ts);
title('Angular momentum magnitude');
xlabel('Time [s]');
ylabel('L [kg m^2/s]');
xline(orbital_periods, '--', 'T');
xlim([t_start t_end]);

subplot(2, 2, 2)
plot(k_ts)
title('Rotational kinetic energy');
xlabel('Time [s]');
ylabel('E [J]');
xline(orbital_periods,"--",'T');
xlim([t_start t_end]);


subplot(2, 2, [3 4]);
plot(w_ts);
title('Angular velocity magnitude');
xlabel('Time [s]');
ylabel('|w| [rad/s]');
xline(orbital_periods,"--",'T');
xlim([t_start t_end]);

% Condition of detumble is an angular velocity of the same order of
% magnitude as the orbital rate
detumbled = find(floor(log10(abs(w_ts.Data))) == floor(log10(sat.Mean_Motion)), 1, 'first');
yline(sat.Mean_Motion, 'b--', 'Orbital Rate');

% Show when the satellite detumbled, if it did
if ~isempty(detumbled)
    xline(k_ts.Time(detumbled), 'r-', "Detumbled");
end

sgtitle('Other attitude plots over time');

