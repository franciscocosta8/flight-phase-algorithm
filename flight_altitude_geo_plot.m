%% Plot every flight that landed or took-off from Munich Airport
%% Just change the values from D
D = dailySummaries{1,3}.flightPhases(272);

outputDir     = 'C:\Users\franc\Desktop\gráficos - tese';

phaseNames = ["Ground","Climb","Cruise","Descent","Level","GoAroundClimb"];
phaseColors = [
  0.500 0.500 0.500;
  0.000 0.447 0.741;
  0.301 0.745 0.933;
  0.850 0.325 0.098;
  0.929 0.694 0.125;
  0.494 0.184 0.556];

fig = figure('Units','pixels','Position',[100 100 1200 600]);
ax  = axes('Parent',fig); hold(ax,'on'); grid(ax,'on'); box(ax,'on');
rs = D.rawStates;
present = intersect(1:6, unique(rs(~isnan(rs))));
hLeg = gobjects(0,1);
legTxt = strings(0,1);
for s = present(:)'
    idx = (rs == s);
    if any(idx)
        hLeg(end+1,1) = scatter(ax, D.time(idx), D.altitude(idx), 16, phaseColors(s,:), 'filled', 'MarkerEdgeColor','none');
        legTxt(end+1,1) = phaseNames(s);
    end
end

xlabel(ax,'Time','FontSize',16);
ylabel(ax,'Altitude (ft)','FontSize',16);
set(ax,'FontSize',16);

title(ax, "Airline: " + string(D.airline) + "  |  Aircraft: " + string(D.aircraft) + "  |  Overall phase: " + string(D.overallPhase), ...
      'FontSize',20,'Interpreter','none');

if ~isempty(hLeg)
    legend(ax,hLeg,legTxt,'Location','best');
end

axis(ax,'tight');
dx = diff(ax.XLim); ax.XLim = ax.XLim + [-1 1]*dx*0.05;
dy = diff(ax.YLim); ax.YLim = ax.YLim + [0 1]*dy*0.05;
%%
pngFile = fullfile(outputDir, 'PlotExample.png');
exportgraphics(gcf, pngFile, 'Resolution', 300);


%% 2D Geoplot of the flight
geoType      = "scatter";
baseMapName  = "satellite";

figG = figure('Units','pixels','Position',[150 150 1200 600]);
gax  = geoaxes('Parent',figG); hold(gax,'on');
gax.FontSize = 16;
geobasemap(gax, baseMapName);

lat = D.latitude(:);
lon = D.longitude(:);
latlim = [min(lat) max(lat)];
lonlim = [min(lon) max(lon)];
dlat = diff(latlim); if dlat==0, dlat = 0.01; end
dlon = diff(lonlim); if dlon==0, dlon = 0.01; end
geolimits(gax, latlim + [-1 1]*0.05*dlat, lonlim + [-1 1]*0.05*dlon);

hLegG  = gobjects(0,1);
legTxtG = strings(0,1);

switch lower(geoType)
    case {"line","geoplot","plot"}
        for s = present(:)'
            idx = (rs == s);
            if any(idx)
                hLegG(end+1,1) = geoplot(gax, lat(idx), lon(idx), ...
                    'LineWidth', 1.5, 'Color', phaseColors(s,:));
                legTxtG(end+1,1) = phaseNames(s);
            end
        end
    otherwise  % "scatter","geoscatter","points"
        for s = present(:)'
            idx = (rs == s);
            if any(idx)
                hLegG(end+1,1) = geoscatter(gax, lat(idx), lon(idx), 16, ...
                    phaseColors(s,:), 'filled', 'MarkerEdgeColor','none');
                legTxtG(end+1,1) = phaseNames(s);
            end
        end
end

title(gax, "Geographic path — Airline: " + string(D.airline) + ...
            " | Aircraft: " + string(D.aircraft) + ...
            " | Overall phase: " + string(D.overallPhase), 'FontSize',20, 'Interpreter','none');

if ~isempty(hLegG)
    legend(gax, hLegG, legTxtG, 'Location','bestoutside');
end

%% 
exportgraphics(fig,  fullfile(outputDir, "altitude_time.png"), 'Resolution',300);
exportgraphics(figG, fullfile(outputDir, "geopath_" + lower(baseMapName) + "_" + lower(geoType) + ".png"), 'Resolution',300);

