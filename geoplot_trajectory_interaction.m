%% Trajectory interaction of 2 aircrafts

f=23; %number of flight
j=2;

CR = GoAroundsData(f).CompareRuns(j);
if isempty(CR), error('No CompareRuns entries.'); end
if numel(CR) > 1
    lens = arrayfun(@(x) numel(x.common_times), CR);
    [~,k] = max(lens);
else
    k = 1;
end
S = CR(k);

lat_i = S.latitude_i(:);   lon_i = S.longitude_i(:);
lat_j = S.latitude_j(:);   lon_j = S.longitude_j(:);
t     = S.common_times(:);

aci = string(GoAroundsData(f).aircraft); if strlength(aci)==0, aci = "i"; end
acj = string(S.acType_j); if strlength(acj)==0, acj = "j"; end

fig = figure('Units','pixels','Position',[100 100 1400 700]);
gx  = geoaxes(fig); gx.FontSize = 18; geobasemap(gx,'satellite'); hold(gx,'on')

h1 = geoplot(gx, lat_i, lon_i, '-', 'LineWidth', 2.2, 'DisplayName', "Flight i ("+aci+")");
h2 = geoplot(gx, lat_j, lon_j, '-', 'LineWidth', 2.2, 'DisplayName', "Flight j ("+acj+")");

mask_i = isfinite(lat_i) & isfinite(lon_i);
mask_j = isfinite(lat_j) & isfinite(lon_j);
allLat = [lat_i(mask_i); lat_j(mask_j)];
allLon = [lon_i(mask_i); lon_j(mask_j)];
if ~isempty(allLat)
    geolimits(gx, [min(allLat) max(allLat)], [min(allLon) max(allLon)])
end

legend(gx, 'Location','best', 'FontSize', 16)

ttl = 'Simultaneous Trajectories';
if ~isempty(t)
    try
        ttl = sprintf('Simultaneous Trajectories: %s – %s', ...
            datestr(t(1),'yyyy-mm-dd HH:MM'), datestr(t(end),'yyyy-mm-dd HH:MM'));
    catch
    end
end
title(gx, ttl, 'FontSize', 18, 'FontWeight','bold')

if ~isempty(t)
    tmin  = dateshift(t(1),'start','minute');
    tmax  = dateshift(t(end),'end','minute');
    tgrid = (tmin:minutes(1):tmax).';
    ti    = interp1(datenum(t), 1:numel(t), datenum(tgrid), 'nearest','extrap');
    ti    = unique(ti(~isnan(ti) & ti>=1 & ti<=numel(t)));

    idx_i = ti(isfinite(lat_i(ti)) & isfinite(lon_i(ti)));
    idx_j = ti(isfinite(lat_j(ti)) & isfinite(lon_j(ti)));

    if ~isempty(idx_i)
        geoscatter(gx, lat_i(idx_i), lon_i(idx_i), 28, 'filled', ...
            'MarkerFaceColor', h1.Color, 'MarkerEdgeColor','none', 'HandleVisibility','off');
        li = string(1:numel(idx_i));
        text(gx, lat_i(idx_i), lon_i(idx_i), li, 'FontSize', 16, 'FontWeight','bold', ...
            'Color', h1.Color, 'BackgroundColor','w', 'Margin', 0.5, ...
            'HorizontalAlignment','center', 'VerticalAlignment','middle', 'Clipping','on')
    end
    if ~isempty(idx_j)
        geoscatter(gx, lat_j(idx_j), lon_j(idx_j), 28, 'filled', ...
            'MarkerFaceColor', h2.Color, 'MarkerEdgeColor','none', 'HandleVisibility','off');
        lj = string(1:numel(idx_j));
        text(gx, lat_j(idx_j), lon_j(idx_j), lj, 'FontSize', 16, 'FontWeight','bold', ...
            'Color', h2.Color, 'BackgroundColor','w', 'Margin', 0.5, ...
            'HorizontalAlignment','center', 'VerticalAlignment','middle', 'Clipping','on')
    end
end