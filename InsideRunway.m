% --- Your runway corner coordinates (replace with your own) ---
rr1_lat = [48.3632; 48.3585; 48.3666; 48.3711;48.3632];   % closed loop
rr1_lon = [11.7375; 11.7373; 11.8382; 11.8376; 11.7375];

rr2_lat = [48.3409; 48.3380; 48.3449; 48.3477; 48.3409];
rr2_lon = [11.7339; 11.7341; 11.8218; 11.8214; 11.7339];



for i = 1:numel(T)
    lat = T(i).latitude;    % N×1 vector
    lon = T(i).longitude;   % N×1 vector

    % 1) in‐polygon tests (vectorized over all fixes)
    inR1 = inpolygon(lon, lat, rr1_lon, rr1_lat);
    inR2 = inpolygon(lon, lat, rr2_lon, rr2_lat);

    % 2) did the flight ever enter each polygon?
    T(i).everInRunway1 = any(inR1);
    T(i).everInRunway2 = any(inR2);

end


%% --- Create a geographic axes and set a basemap ---
fig = figure;
gx  = geoaxes(fig);
geobasemap(gx, 'streets');            % or 'satellite', 'topographic', etc.
hold(gx, 'on');

% --- Plot runway polygons using geoplot ---
geoplot(gx, rr1_lat, rr1_lon, '-r', ...
    'LineWidth', 2, 'DisplayName', 'Runway 08R/26L');
geoplot(gx, rr2_lat, rr2_lon, '-g', ...
    'LineWidth', 2, 'DisplayName', 'Runway 07L/25R');

% --- Plot touchdown points using geoscatter ---
%geoscatter(gx, touchLat, touchLon, 36, 'b', 'filled', ...
 %   'DisplayName', 'Touchdown');

% --- Tidy up ---
legend(gx, 'Location', 'bestoutside');
title(gx, 'Airport Runways and Touchdown Locations');
