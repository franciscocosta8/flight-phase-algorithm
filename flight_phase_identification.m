%% Flight Phase Identification Pipeline
% Load results and filter invalid flights
%load('results.mat');
%% 
folder    = 'jan25';
fileList  = dir(fullfile(folder,'*.mat'));
Nfiles    = numel(fileList);
%results   = repmat(struct(), 1, Nfiles);  % pré-aloca um array de structs
dailySummaries = cell(1, Nfiles);

%%
tic
cfg=config();
labels = FlightPhase.list();

for k = 18%1:Nfiles
    
    k
    fn = fullfile(folder, fileList(k).name);
    load(fn); 
    validIdx = arrayfun(@(f) isValidFlight(f.callsign, f.airline,f.acType ,f.departure), results);
    cleanFlights = results(validIdx);
    notcleanFlights = results(~validIdx);
    fprintf("Filtered to %d valid flights.\n", sum(validIdx));

    N = numel(cleanFlights);
    allStates = cell(1, N);
    allOverallPhase = strings(N,1);
    allAirlines     = strings(N,1);
    allAircraft     = strings(N,1);
    allLat           = cell(1, N);
    allLon           = cell(1, N);
    allAlt           = cell(1, N);
    allGS            = cell(1, N);
    allROC           = cell(1, N);
    flightPhases = repmat(struct( ...
        'callsign',    "", ...
        'rawStates',   [], ...
        'stateNames',  string.empty, ...
        'overallPhase', "", ...
        'airline',     "", ...
        'aircraft',     "", ...
        'latitude',     [], ...      
        'longitude',    [], ...
        'altitude',     [], ...
        'groundSpeed',  [], ...
        'rateOfClimb',  [] ), N, 1); 
    
    % Loop over flights
    parfor f=1:N
    %for f=17
        T = cleanFlights(f).flightData;
    
        if all(isnan(T.h_QNH_Metar) ) || all(isnan(T.h_dot_baro)) || all(isnan(T.gs))
            continue
        end
    
        validSamples=isfinite(T.h_dot_baro) & isfinite(T.gs) & isfinite(T.h_QNH_Metar);
    
        if sum(validSamples)<25
           continue
        end
    
        alt   = T.h_QNH_Metar(validSamples);
        roc   = T.h_dot_baro(validSamples);
        gs    = T.gs(validSamples);
        isGnd = T.onGround(validSamples);
        time = T.time(validSamples);
        lat_all = T.lat(validSamples);    % extract raw latitude
        lon_all = T.lon(validSamples);   % extract raw longitude

    
        phaseStates = classifyFlightPhase(T, cfg);
        if isempty(phaseStates)
            continue;
        end
        alt=T.h_QNH_Metar (validSamples);
        roc   = T.h_dot_baro (validSamples);
        gs    = T.gs(validSamples);
        isGnd = T.onGround(validSamples); 
        time_all=T.time;
    
        descentFlags = (phaseStates == FlightPhase.Descent);
        % Identify Go Around
        if any(phaseStates == FlightPhase.Climb) && any(phaseStates == FlightPhase.Descent)
            [phaseStates] = detectGoAround(time_all, alt, phaseStates, FlightPhase.Climb, descentFlags);
        else
            allStates{f}=phaseStates;
            labels= FlightPhase.list();    
            allStates_names{f} = labels(phaseStates);
        end
    
        phaseStates = filterChangeOfPhase(phaseStates, FlightPhase.Climb, FlightPhase.Descent, FlightPhase.Level);
    
         % remove points classified with climb or descent that are not
         % changing altitude
        [keepIdx,phaseStates] = filterFlatClimbDescent(alt, phaseStates);
        t_removed=time(~keepIdx);
        alt_removed=alt(~keepIdx);
    
        % Agora refazemos todos os vetores “time, roc, alt, gs, phaseStates”
        time = time(keepIdx);
        roc  = roc(keepIdx);
        alt  = alt(keepIdx);
        gs   = gs(keepIdx);
        phaseStates = phaseStates(keepIdx);
        lat = lat_all(keepIdx);
        lon = lon_all(keepIdx);

        allLat{f} = lat;
        allLon{f} = lon;
        allAlt{f} = alt;
        allGS{f}  = gs;
        allROC{f} = roc;
    
        allStates{f}=phaseStates;
        labels= FlightPhase.list();     
        allStates_names{f} = labels(phaseStates);
    
        % Decidir fase global de voo
        
        hasGoAround = any(phaseStates == FlightPhase.GoAroundClimb);  
        if hasGoAround
            allOverallPhase(f) = string(FlightOverallPhase.GoAround);
        else
    
            % (b) Caso não haja Go-Around, contamos quantos pontos de cada fase
            nClimb  = sum(phaseStates == FlightPhase.Climb);
            nDes    = sum(phaseStates == FlightPhase.Descent);
            nLevel  = sum(phaseStates == FlightPhase.Level);
    
            altFirst = alt(1);
            altLast = mean( alt( max(end-10,1) : end ) );
    

            if (nDes > nClimb) && (altLast < 2200)
                allOverallPhase(f) = string(FlightOverallPhase.Landing);
    
            elseif (nClimb > nDes) && (altLast > 5000) && (altFirst<3500)
                allOverallPhase(f) = string(FlightOverallPhase.Takeoff);

            elseif  (altFirst > 5000) && (altLast > 5000)
                allOverallPhase(f) = string(FlightOverallPhase.Cruise);
   
            else
                allOverallPhase(f) = string(FlightOverallPhase.NonDetected); 
            end
        end

        allAirlines(f) = string(cleanFlights(f).airline);
        allAircraft(f) = string(cleanFlights(f).acType);

        flightPhases(f).callsign     = string(cleanFlights(f).callsign);
        flightPhases(f).rawStates    = allStates{f};             % numeric codes
        flightPhases(f).stateNames   = allStates_names{f};       % e.g. "Climb","Level",…
        flightPhases(f).overallPhase = allOverallPhase(f);       % e.g. "Takeoff","Cruise",…
        flightPhases(f).airline      = allAirlines(f);
        flightPhases(f).aircraft     = allAircraft(f);
        flightPhases(f).latitude     = allLat{f};    % degrees
        flightPhases(f).longitude    = allLon{f};    % degrees
        flightPhases(f).altitude     = allAlt{f};    % ft (h_QNH_Metar)
        flightPhases(f).groundSpeed  = allGS{f};     % kts
        flightPhases(f).rateOfClimb  = allROC{f};    % ft/s

    end
    summaryPhases = summarizePhases(allOverallPhase);

    % Store everything in your daily summary
    dailySummaries{k} = struct( ...
        'file',             fileList(k).name, ...
        'summary',          summaryPhases, ...
        'flightPhases', flightPhases);
end

% After loop, concatenate all per‐file summaries:
%allFilesSummary = vertcat(dailySummaries{:});

disp('Program finished.')
toc