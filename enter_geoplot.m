%% See errors in go around identification
% Enter for different geoplot
if exist('GoAroundData','var')
    G = GoAroundData;
elseif exist('GoAroundsData','var')
    G = GoAroundsData;
else
    error('Variável GoAroundData(s) não encontrada.')
end

idx = [];
for i = 1:numel(G)
    if isfield(G(i),'latitude') && isfield(G(i),'longitude') ...
            && ~isempty(G(i).latitude) && ~isempty(G(i).longitude)
        idx(end+1) = i; 
    end
end
if isempty(idx), disp('Sem voos válidos.'); return; end

f = figure('Color','w');
gx = geoaxes(f); geobasemap(gx,'streets');

for k = 1:numel(idx)
    i = idx(k);
    lat = G(i).latitude(:);
    lon = G(i).longitude(:);
    v = isfinite(lat) & isfinite(lon);
    lat = lat(v); lon = lon(v);
    n = min(numel(lat),numel(lon));
    lat = lat(1:n); lon = lon(1:n);
    cla(gx);
    geoplot(gx, lat, lon, '-', 'LineWidth', 1.4);
    if ~isempty(lat)
        dlat = max(lat)-min(lat); dlon = max(lon)-min(lon);
        mlat = max(0.01, 0.1*dlat); mlon = max(0.01, 0.1*dlon);
        geolimits(gx, [min(lat)-mlat, max(lat)+mlat], [min(lon)-mlon, max(lon)+mlon]);
    end
    title(gx, sprintf('Voo %d de %d (i=%d)', k, numel(idx), i));
    drawnow;
    if k < numel(idx)
        while true
            w = waitforbuttonpress;
            if w == 1
                ch = get(gcf,'CurrentCharacter');
                if any(double(ch) == [13 10])
                    break
                end
            end
        end
    end
end
