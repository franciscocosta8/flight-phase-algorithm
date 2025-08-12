% --- runway corner coordinates plot---
rr1_lat = [48.3632; 48.3585; 48.3666; 48.3711;48.3632];   % closed loop
rr1_lon = [11.7375; 11.7373; 11.8382; 11.8376; 11.7375];

rr2_lat = [48.3409; 48.3380; 48.3449; 48.3477; 48.3409];
rr2_lon = [11.7339; 11.7341; 11.8218; 11.8214; 11.7339];

fig = figure('Color','w','Position',[100 100 1800 600]);
set(fig, 'DefaultAxesFontSize', 19, 'DefaultTextFontSize', 18)

gx = geoaxes(fig);
gx.FontSize = 16;
geobasemap(gx, 'satellite');
hold(gx, 'on')

if exist('geopolyshape','class')
    p1 = geopolyshape(rr1_lat, rr1_lon);
    p2 = geopolyshape(rr2_lat, rr2_lon);
    geoplot(gx, p1, 'FaceColor', 'r', 'FaceAlpha', 0.25, 'EdgeColor', 'r', 'LineWidth', 2, 'DisplayName', 'Runway 08L/26R')
    geoplot(gx, p2, 'FaceColor', 'g', 'FaceAlpha', 0.25, 'EdgeColor', 'g', 'LineWidth', 2, 'DisplayName', 'Runway 08R/26L')
else
    geoplot(gx, [rr1_lat(:); rr1_lat(1)], [rr1_lon(:); rr1_lon(1)], '-r', 'LineWidth', 2, 'DisplayName', 'Runway 08L/26R')
    geoplot(gx, [rr2_lat(:); rr2_lat(1)], [rr2_lon(:); rr2_lon(1)], '-g', 'LineWidth', 2, 'DisplayName', 'Runway 08R/26L')
end

allLat = [rr1_lat(:); rr2_lat(:)];
allLon = [rr1_lon(:); rr2_lon(:)];
latmin = min(allLat); latmax = max(allLat);
lonmin = min(allLon); lonmax = max(allLon);
dlat = latmax - latmin; if dlat == 0, dlat = 0.01; end
dlon = lonmax - lonmin; if dlon == 0, dlon = 0.01; end
pad = 0.05;
geolimits(gx, [latmin - pad*dlat, latmax + pad*dlat], [lonmin - pad*dlon, lonmax + pad*dlon])

title(gx, 'Runway Polygons — Munich Airport (EDDM)', 'FontSize', 20, 'FontWeight', 'bold')
lgd = legend(gx, 'Location', 'bestoutside');
lgd.FontSize = 15;

outDir = 'C:\Users\franc\Desktop\gráficos - tese';
if ~isfolder(outDir), mkdir(outDir); end
outFile = fullfile(outDir, 'runway_polygons_munich.png');
exportgraphics(fig, outFile, 'Resolution', 300)

