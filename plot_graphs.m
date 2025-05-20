% === set up once, before the k‐loop ===
phaseLabels = FlightPhase.list();           % {'Ground';'Climb';...}
Cmap         = lines(numel(phaseLabels));   % 6×3
phase2color = containers.Map(FlightPhase.list(), mat2cell(lines(numel(FlightPhase.list())),ones(1,numel(FlightPhase.list())), 3));

for k = 379
    % --- load & filter the k‐th flight ---
    T     = cleanFlights(k).flightData;
    t0    = T.time;
    alt0  = T.h_QNH_Metar;
    roc0  = ((T.h_dot_geom+T.h_dot_baro)/2);
    gs0   = T.gs;
    
    valid = isfinite(alt0) & isfinite(roc0) & isfinite(gs0);
    t     = t0(valid);
    alt   = alt0(valid);
    roc=roc0(valid);
    
    % --- grab your phase names and force a column of chars ---
    rawStates = allStates_names{k};    % might be cell or string
    rawStates = cellstr(rawStates(:));  % now an N×1 cell array of char
    
    % --- build a numeric grouping + retrieve the unique names in order ---
    [grp, grpNames] = findgroups(rawStates);
    % grp is N×1 of integers 1..M, grpNames is M×1 cell of strings
    % and grpNames{p} is exactly the p‐th unique phase in stable order

    % --- extract the colors for each of those M groups from the fixed map ---
    cmap = cell2mat( values( phase2color, grpNames ) );
    % (phase2color was your containers.Map from FlightPhase.list() → lines(6))

       figure('Position',[100 100 1000 500])
    
    % Altitude on left y-axis
    yyaxis left
    gscatter(t, alt, grp, cmap, '.', 10)
    ylabel('Altitude (ft)')
    ylim([min(alt)-500, max(alt)+500])

    % Rate of climb on right y-axis
    yyaxis right
    hold on
    for i = 1:max(grp)
        idx = grp == i;
        plot(t(idx), roc(idx), '.', 'Color', cmap(i,:), 'Marker', 'o', 'HandleVisibility','off');
    end
    ylabel('Rate of Climb (ft/min)')

    % Shared settings
    datetick('x','HH:MM','keepticks')
    xlabel('Time')
    title(sprintf("Flight %s (idx %d)", cleanFlights(k).callsign, k))
    legend(grpNames, 'Location', 'eastoutside')
    grid on

end
