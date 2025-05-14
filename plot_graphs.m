N = numel(cleanFlights);

% === define colormap and phase names ===
phaseallNames= {'Ground','Climb','Cruise','Descent','Level flight','Go-Around',''};
phase2color = containers.Map(phaseallNames, mat2cell(lines(numel(phaseallNames)),ones(1,numel(phaseallNames)), 3));

for k=1:10
    % === etract & filter data ===
    T      = cleanFlights(k).flightData;
    t      = T.time;
    alt    = T.h_QNH_Metar;
    roc    = T.h_dot_baro;
    gs     = T.gs;
    valid  = isfinite(alt) & isfinite(roc) & isfinite(gs);
    t      = t(valid);
    alt    = alt(valid);
    states = allStates{k}(valid);
    phaseNames = unique(states, 'stable');
    phaseNames = strtrim(phaseNames);
    cmap  = cell2mat(values(phase2color, cellstr(phaseNames)));

    % === plot altitude vs. time, colored by phase ===
    figure('Position',[100 100 800 400])
    gscatter(t, alt, states, cmap, '.', 10)
    datetick('x','HH:MM','keepticks')   % if t is datetime or datenum
    xlabel('Time')
    ylabel('Altitude (ft)')
    title(sprintf("Flight %s (idx %d)", cleanFlights(k).callsign, k))
    grid on
    
    % === legend ===
    legend(phaseNames,'Location','eastoutside')
end