% --- Prepare data --------------------------------------------------------
numDays = numel(dailySummaries);

landings    = zeros(1, numDays);
takeOffs    = zeros(1, numDays);
cruises     = zeros(1, numDays);
goArounds   = zeros(1, numDays);

for k = 1:numDays
    s = dailySummaries{k}.summary;
    landings(k)  = s.nLandings;
    takeOffs(k)  = s.nTakeoffs;
    cruises(k)   = s.nCruises;
    goArounds(k) = s.nGoArounds;
end

days = 1:numDays;

% --- Plot ---------------------------------------------------------------
figure;
plot(days, landings,    '-o', 'DisplayName','Landings');    hold on;
plot(days, takeOffs,    '-s', 'DisplayName','Take-offs');
plot(days, cruises,     '-^', 'DisplayName','Cruises');
plot(days, goArounds,   '-d', 'DisplayName','Go-arounds');
hold off;

xlabel('Day of Month');
ylabel('Number of Flights');
title('Daily Flight Phase Counts (Jan 2025)');
legend('Location','best');
grid on;

% --- Export -------------------------------------------------------------
%outputPath = 'C:/Users/franc/Desktop/gráficos - tese/DailyFlightPhases_Jan2025.png';
%exportgraphics(gcf, outputPath, 'Resolution',300);
