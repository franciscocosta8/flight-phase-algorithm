%% --- Keep only GOAROUNDS and LANDINGS -------------
gaALtm=[];
gaLATm=[];
gaLONm=[];
eddmCenter  = [48.354017, 11.788711, 477]; % [lat,lon,alt_m]

%Definition of Runway Area - Munich Airport
rr1_lat = [48.3632; 48.3585; 48.3666; 48.3711;48.3632];   % 5 entries - closed loop
rr1_lon = [11.7375; 11.7373; 11.8382; 11.8376; 11.7375];

rr2_lat = [48.3409; 48.3380; 48.3449; 48.3477; 48.3409];
rr2_lon = [11.7339; 11.7341; 11.8218; 11.8214; 11.7339];

for k = 1:numel(dailySummaries)
    k
    T = dailySummaries{k}.flightPhases;      % struct array [N×1]

    excludePhases = {'Takeoff','Cruise','NonDetected'};       % phases to drop

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
        TT = timetable( T(i).time, ref_N, ref_E, ref_D, 'VariableNames', {'N','E','D'} );
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
            if ~isdatetime(gaTime) || isnat(gaTime)
                T(i).flightsToCompareDist = [];
                continue
            end

            %Creates a validity mask - true when flights contain the time of go around
            matches = cellfun(@(tv) any(tv == gaTime), timeCells);
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

    for i=1:Nf
        
    end 
    
    ComputeDistances_dailySummaries{k} = struct( ...
        'file',    dailySummaries{k}.file, ...
        'flightPhases', T);
    

end

