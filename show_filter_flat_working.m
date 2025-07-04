% 5) Interpolate a smooth estimate at every original timestamp
alt_est = interp1(time, alt, time_all, 'pchip');

% 6) Plot in this order:
figure; hold on

% 6a) Estimated trajectory (black line)
plot(time, alt, '-', ...
     'LineWidth',1.5, ...
     'Color',[0 0 0], ...
     'DisplayName','Estimated trajectory');

% 6b) Removed points (red crosses)
scatter(time_rem, alt_rem, 36, ...
        'Marker','x', ...
        'MarkerEdgeColor','r', ...
        'DisplayName','Removed points');

% 6c) Kept points coloured by phase
rawNames = cellstr(allStates_names{f}(:));
[grp, grpNames] = findgroups(rawNames);
cmap = cell2mat(values(cfg.phase2color, grpNames));
for g = 1:numel(grpNames)
    xi = grp == g;
    scatter(time(xi), alt(xi), 36, ...
            'Marker','.', ...
            'MarkerEdgeColor',cmap(g,:), ...
            'DisplayName',grpNames{g});
end

% 7) Final formatting
ylabel('Altitude (ft)');
datetick('x','HH:MM','keepticks');
xlabel('Time');
legend('Location','eastoutside');
grid on;
