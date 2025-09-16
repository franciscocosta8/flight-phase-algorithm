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
days=days+5; %For may
% --- Simple Plot ---------------------------------------------------------------
figure;
plot(days, landings,    '-o', 'DisplayName','Landings');    hold on;
plot(days, takeOffs,    '-s', 'DisplayName','Take-offs');
plot(days, cruises,     '-^', 'DisplayName','Cruises');
plot(days, goArounds,   '-d', 'DisplayName','Go-arounds');
hold off;

xlabel('Day of Month');
ylabel('Number of Flights');
title('Daily Flight Phase Counts (June 2024)');
legend('Location','best');
grid on;

%% --- Data --------------------------------------------------------------
numDays = numel(dailySummaries);
landings  = zeros(1,numDays);
takeOffs  = zeros(1,numDays);
cruises   = zeros(1,numDays);
goArounds = zeros(1,numDays);
for k = 1:numDays
    s = dailySummaries{k}.summary;
    landings(k)  = s.nLandings;
    takeOffs(k)  = s.nTakeoffs;
    cruises(k)   = s.nCruises;
    goArounds(k) = s.nGoArounds;
end
days = 1:numDays;
days=days+5; %for may
numDays=numDays+5; %for may
% --- Divided plot ---------------------------------------------
figure('Color','w','Position',[100 100 1000 520]);
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

% --- Palete default do MATLAB
co = get(groot,'defaultAxesColorOrder');  % 7x3 RGB

% Topo: Landings e Take-offs 
ax1 = nexttile; hold(ax1,'on'); grid(ax1,'on'); box(ax1,'on');
plot(ax1, days, landings, '-o', 'DisplayName','Landings', 'LineWidth',1.2, 'MarkerFaceColor','none', 'Color', co(1,:));
plot(ax1, days, takeOffs, '-s', 'DisplayName','Take-offs', 'LineWidth',1.2, 'MarkerFaceColor','none', 'Color', co(2,:));
xlim(ax1,[5.5 numDays+0.5]); ylim(ax1,[350 550]); yticks(ax1,350:50:550);
ylabel(ax1,'Flights (350–550)'); legend(ax1,'Location','northeast'); set(ax1,'FontSize',12);

% Baixo
ax2 = nexttile; hold(ax2,'on'); grid(ax2,'on'); box(ax2,'on');
%plot(ax2, days, cruises,   '-^', 'DisplayName','Cruises', 'LineWidth',1.2, 'MarkerFaceColor','none', 'Color', co(3,:));
plot(ax2, days, goArounds, '-d', 'DisplayName','Go-Arounds', 'LineWidth',1.2, 'MarkerFaceColor','none', 'Color', co(4,:));
xlim(ax2,[5.5 numDays+0.5]); ylim(ax2,[0 20]); yticks(ax2,0:3:21);
ylabel(ax2,'Flights (0–15)'); xlabel(ax2,'Day of Month (June 2024)');
legend(ax2,'Location','northeast'); set(ax2,'FontSize',12);


%% --- Export -------------------------------------------------------------
outputPath = 'C:/Users/franc/Desktop/gráficos - tese/DailyFlightPhases_June2024.png';
exportgraphics(gcf, outputPath, 'Resolution',300);
