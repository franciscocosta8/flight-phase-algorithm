
close all

% === pick 1 random flight ===
rng('default');              % for reproducibility
N = numel(cleanFlights);
k=  16;   % number of flight

% === define colormap and phase names ===

cmap = lines(numel(phaseNames));    % one distinct color per phase

% === extract & filter data ===
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
