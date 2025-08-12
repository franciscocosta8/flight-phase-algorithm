%% --- Keep only GOAROUNDS, LANDINGS and TAKEOFFS-------------
% Looks very huge but it olny takes about 1 sec per day of analysis
gaALtm=[];
gaLATm=[];
gaLONm=[];
eddmRef  = [48.354017, 11.788711, 477]; % [lat,lon,alt_m]
ellipsoid = wgs84Ellipsoid('meters');
%Definition of Runway Area - Munich Airport
rr1_lat = [48.3632; 48.3585; 48.3666; 48.3711;48.3632];   % 5 entries - closed loop
rr1_lon = [11.7375; 11.7373; 11.8382; 11.8376; 11.7375];

rr2_lat = [48.3409; 48.3380; 48.3449; 48.3477; 48.3409];
rr2_lon = [11.7339; 11.7341; 11.8218; 11.8214; 11.7339];

for k = 1:numel(dailySummaries)
    k
    T = dailySummaries{k}.flightPhases;      % struct array [N×1]

    excludePhases = {'Cruise','NonDetected'};       % phases to drop

    validIdx  = arrayfun(@(f) ...
                   ~any(strcmp(string(f.overallPhase), excludePhases)), ...
                   T);
    % keep only Landing and Go-Around flights
    sectorStructs    = T(validIdx);  
    Nf = numel(sectorStructs);
    T=T(validIdx);
    % Create a new strcut T with fixed timestamps of 1 second 
    for i = 1:Nf
    
        % compute logical mask of exact-second timestamps from T(i).time
        dt = datetime( sectorStructs(i).time, 'Format', 'd-MMM-y HH:mm:ss.SSS' );
        isOnSecond = mod( second(dt), 1 ) == 0;
    
        % apply that mask to every field of T(i)
        T(i).time        = sectorStructs(i).time(isOnSecond);
        T(i).altitude    = sectorStructs(i).altitude(isOnSecond);
        T(i).groundSpeed = sectorStructs(i).groundSpeed(isOnSecond);
        T(i).latitude    = sectorStructs(i).latitude(isOnSecond);
        T(i).longitude   = sectorStructs(i).longitude(isOnSecond);
        T(i).rawStates   = sectorStructs(i).rawStates(isOnSecond);
        T(i).stateNames  = sectorStructs(i).stateNames(isOnSecond);
        
        gaIdx = find( T(i).rawStates == FlightPhase.GoAroundClimb, 1, 'first' );
        if isempty(gaIdx)
            gaIdx = NaN;
            gaAlt = NaN;
            gaLAT = NaN;
            gaLON = NaN;
            gaTIME = [];
        else
            gaAlt = T(i).altitude(gaIdx);
            gaALtm(end+1)=gaAlt;
            gaLAT = T(i).latitude(gaIdx);
            gaLATm(end+1)=gaLAT;
            gaLON = T(i).longitude(gaIdx);
            gaLONm(end+1)=gaLON;
            gaTIME = T(i).time(gaIdx);
        end
    
        T(i).goAroundIdx  = gaIdx;
        T(i).goAroundAlt  = gaAlt;
        T(i).goAroundLat  = gaLAT;
        T(i).goAroundLon  = gaLON;
        T(i).goAroundTIME = gaTIME;     % Exact time when GoAround started
    
        %Compute distances algorithm
        T(i).altitude_meter = T(i).altitude * 0.3048;
        NED = lla2ned([T(i).latitude, T(i).longitude, T(i).altitude_meter], eddmRef, 'flat');
        ref_N = NED(:,1);
        ref_E = NED(:,2);
        ref_D = NED(:,3);
        
        % 3. make a timetable
        % TT = timetable( T(i).time, ref_N, ref_E, ref_D, 'VariableNames', {'N','E','D'} );
    end
    

    Nf = numel(T);
    timeCells = arrayfun(@(f) f.time, T, 'UniformOutput', false);
    
    for i = 1:Nf
        

        lat = T(i).latitude;    % N×1 vector
        lon = T(i).longitude;   % N×1 vector
    
        % 1) in‐polygon tests (vectorized over all fixes)
        inR1 = inpolygon(lon, lat, rr1_lon, rr1_lat);
        inR2 = inpolygon(lon, lat, rr2_lon, rr2_lat);
    
        % 2) did the flight ever enter each polygon?
        T(i).everInRunway1 = any(inR1);
        T(i).everInRunway2 = any(inR2);  
    end
    
    runway1Flags  = [T.everInRunway1].';   % Nfx1 so that can do the logic with matches
    runway2Flags  = [T.everInRunway2].';
    
    for i=1:Nf
        if  T(i).overallPhase=='GoAround'
            gaTime = T(i).goAroundTIME;
            gaTime_plus2min = gaTime + minutes(2);
            gaTime_minus3min = gaTime - minutes(2);
            % ********** Rever este if - porque está aqui?
            % ****************
            % if ~isdatetime(gaTime) || isnat(gaTime) || ~isdatetime(gaTime_minus3min) || isnat(gaTime_minus3min)
            %     T(i).flightsToCompareDist = [];
            %     continue
            % end

            %Creates a validity mask - true when flights contain the time of go around
            % hasGA  = cellfun(@(tv) any(tv == gaTime),    timeCells);
            % hasM3  = cellfun(@(tv) any(tv == gaTime_minus3min), timeCells);
            %matches = hasGA & hasM3;
            matches = cellfun(@(tv) any(tv >= gaTime_minus3min & tv <= gaTime_plus2min), timeCells);
            matches(i) = false; %takes out the value of the flight itself
            %T(i).flightsToCompareDist = find(matches);

            if T(i).goAroundLat<45.352
                 matches = matches & runway2Flags;
            else 
                 matches = matches & runway1Flags;
            end
            T(i).flightsToCompareDist = find(matches);
        end
    end

    goIdx = find( [T.overallPhase] == "GoAround" );
    for g = 1:numel(goIdx)
        i = goIdx(g); 
        t_i   = T(i).time;               % sampled times for flight i
        toCmp = T(i).flightsToCompareDist;    % flights to compare with i
        for m = 1:numel(toCmp)               % inner loop now uses m
            j   = toCmp(m);                  % index of comparison flight
            t_j = T(j).time;
        
            % find overlap
            [commonT, idx_i, idx_j] = intersect(t_i, t_j);
            T(i).CompareRuns(m).flightIdx = j;
            if isempty(commonT)
                disp("Warning: commonT is empty");
            else
                T(i).CompareRuns(m).common_times      = commonT;
                T(i).CompareRuns(m).flightPhase = T(j).overallPhase;
                T(i).CompareRuns(m).acType_j     = T(j).aircraft;
                T(i).CompareRuns(m).WakeTurbulence_j = lookupWakeCat(T(j).aircraft);
                T(i).CompareRuns(m).airline_j    = T(j).airline;

                T(i).CompareRuns(m).startIdx_i = idx_i(1);
                T(i).CompareRuns(m).endIdx_i   = idx_i(end);
                T(i).CompareRuns(m).WakeTurbulence_i = lookupWakeCat(T(i).aircraft);

                T(i).CompareRuns(m).startIdx_j = idx_j(1);
                T(i).CompareRuns(m).endIdx_j   = idx_j(end);

                T(i).CompareRuns(m).latitude_i   = T(i).latitude(idx_i);
                T(i).CompareRuns(m).longitude_i  = T(i).longitude(idx_i);
                T(i).CompareRuns(m).altitude_i  = T(i).altitude(idx_i);

                T(i).CompareRuns(m).latitude_j   = T(j).latitude(idx_j);
                T(i).CompareRuns(m).longitude_j  = T(j).longitude(idx_j);
                T(i).CompareRuns(m).altitude_j  = T(j).altitude(idx_j);
                
                
                lat1 = T(i).CompareRuns(m).latitude_i;    % in degrees
                lon1 = T(i).CompareRuns(m).longitude_i;  % in degrees
                h1   = T(i).CompareRuns(m).altitude_i * 0.3048;  % convert ft->m
        
                lat2 = T(i).CompareRuns(m).latitude_j;
                lon2 = T(i).CompareRuns(m).longitude_j;
                h2   = T(i).CompareRuns(m).altitude_j * 0.3048;
        
                % Convert to ECEF (X,Y,Z in metres):
                [x1, y1, z1] = geodetic2ecef(ellipsoid, lat1, lon1, h1);
                [x2, y2, z2] = geodetic2ecef(ellipsoid, lat2, lon2, h2);
        
  
                % Compute 3-D Euclidean distance (in metres):
                d3D = sqrt( (x2 - x1).^2 + (y2 - y1).^2 + (z2 - z1).^2 );
                d3D_NM = d3D*0.000539956803;
        
                % Store it back into your struct:
                T(i).CompareRuns(m).distance3D_m = d3D_NM;

                % if k==3            %Take this if out ? 
                %     % converte alturas para pés
                %     h1_ft = h1 / 0.3048;
                %     h2_ft = h2 / 0.3048;
                % 
                %     figure;
                %     hold on;
                %     grid on;
                % 
                %     % eixo esquerdo: separação em metros
                %     yyaxis left
                %     p1 = plot(commonT, d3D_NM, 'r--', 'LineWidth', 1.5);
                %     ylabel('3-D separation (NM)');
                % 
                %     % eixo direito: alturas em pés
                %     yyaxis right
                %     p2 = plot(commonT, h1_ft, 'b-', 'LineWidth', 1.2);
                %     p3 = plot(commonT, h2_ft, 'g-', 'LineWidth', 1.2);
                %     ylabel('Altitude (ft)');
                % 
                %     % linha de go-around (sem aparecer na legenda)
                %     xline(T(i).goAroundTIME, '--k', ' Go-Around start', ...
                %           'LineWidth', 1.5, ...
                %           'LabelHorizontalAlignment','left', ...
                %           'LabelVerticalAlignment','bottom', ...
                %           'HandleVisibility','off');
                % 
                %     % constrói as strings de legenda das alturas
                %     leg_h1 = sprintf('%s altitude (ft)', T(i).aircraft);
                %     leg_h2 = sprintf('%s altitude (ft)', T(i).CompareRuns(m).acType_j);
                % 
                %     % legenda só com as 3 curvas
                %     legend([p1 p2 p3], ...
                %            {'Separation (NM)', leg_h1, leg_h2}, ...
                %            'Location','bestoutside');
                % 
                %     xlabel('Time');
                %     title('Separation during Go-Around phases');
                %     datetick('x','HH:MM','keeplimits');
                %     hold off;          
                % 
                % end
            end
        end
    end

    ComputeDistances_dailySummaries{k} = struct( ...
        'file',    dailySummaries{k}.file, ...
        'flightPhases', T);

end 
