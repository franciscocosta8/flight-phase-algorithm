%% Counts the GoArounds Aircraft and Airlines 

airlineMap  = containers.Map('KeyType','char','ValueType','double');
aircraftMap = containers.Map('KeyType','char','ValueType','double');

    FP = GoAroundsData;
    for i = 1:numel(FP)
        if isfield(FP,'airline')
            a = string(FP(i).airline);
            if ~ismissing(a) && strlength(a)>0
                k = char(strtrim(a));
                if isKey(airlineMap,k), airlineMap(k) = airlineMap(k)+1; else, airlineMap(k) = 1; end
            end
        end
        if isfield(FP,'aircraft')
            t = string(FP(i).aircraft);
            if ~ismissing(t) && strlength(t)>0
                k = char(strtrim(t));
                if isKey(aircraftMap,k), aircraftMap(k) = aircraftMap(k)+1; else, aircraftMap(k) = 1; end
            end
        end
    end

ak = airlineMap.keys; av = cell2mat(airlineMap.values(ak)); [av,ix] = sort(av,'descend'); airlineNames = string(ak(ix))'; airlineCounts = av';
tk = aircraftMap.keys; tv = cell2mat(aircraftMap.values(tk)); [tv,jx] = sort(tv,'descend'); aircraftNames = string(tk(jx))'; aircraftCounts = tv';

airlineTbl  = table(airlineNames,  airlineCounts,  'VariableNames', {'Airline','Count'});
aircraftTbl = table(aircraftNames, aircraftCounts, 'VariableNames', {'Aircraft','Count'});

disp(airlineTbl)
disp(aircraftTbl)

%%
airlineMap  = containers.Map('KeyType','char','ValueType','double');
aircraftMap = containers.Map('KeyType','char','ValueType','double');

C = ComputeDistances_dailySummaries;

if iscell(C)
    for d = 1:numel(C)
        if isempty(C{d}) || ~isfield(C{d},'flightPhases') || isempty(C{d}.flightPhases), continue, end
        FP = C{d}.flightPhases;
        for i = 1:numel(FP)
            if isfield(FP(i),'airline')
                a = string(FP(i).airline);
                if ~(ismissing(a) || strlength(a)==0)
                    k = char(strtrim(a));
                    if isKey(airlineMap,k), airlineMap(k) = airlineMap(k)+1; else, airlineMap(k) = 1; end
                end
            end
            if isfield(FP(i),'aircraft')
                t = string(FP(i).aircraft);
                if ~(ismissing(t) || strlength(t)==0)
                    k = char(strtrim(t));
                    if isKey(aircraftMap,k), aircraftMap(k) = aircraftMap(k)+1; else, aircraftMap(k) = 1; end
                end
            end
        end
    end
else
    for d = 1:numel(C)
        if isempty(C(d)) || ~isfield(C(d),'flightPhases') || isempty(C(d).flightPhases), continue, end
        FP = C(d).flightPhases;
        for i = 1:numel(FP)
            if isfield(FP(i),'airline')
                a = string(FP(i).airline);
                if ~(ismissing(a) || strlength(a)==0)
                    k = char(strtrim(a));
                    if isKey(airlineMap,k), airlineMap(k) = airlineMap(k)+1; else, airlineMap(k) = 1; end
                end
            end
            if isfield(FP(i),'aircraft')
                t = string(FP(i).aircraft);
                if ~(ismissing(t) || strlength(t)==0)
                    k = char(strtrim(t));
                    if isKey(aircraftMap,k), aircraftMap(k) = aircraftMap(k)+1; else, aircraftMap(k) = 1; end
                end
            end
        end
    end
end

ak = airlineMap.keys; av = cell2mat(airlineMap.values(ak)); [av,ix] = sort(av,'descend');
airlineNames = string(ak(ix))'; airlineCounts = av';
airlineTbl  = table(airlineNames, airlineCounts, 'VariableNames', {'Airline','Count'});

tk = aircraftMap.keys; tv = cell2mat(aircraftMap.values(tk)); [tv,jx] = sort(tv,'descend');
aircraftNames = string(tk(jx))'; aircraftCounts = tv';
aircraftTbl = table(aircraftNames, aircraftCounts, 'VariableNames', {'Aircraft','Count'});

disp(airlineTbl)
disp(aircraftTbl)
