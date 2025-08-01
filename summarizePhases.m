function summaryPhases = summarizePhases(allOverallPhase)
% summarizePhases   Evaluate the amount of flights that have each phase
    % Find index to each phase
    landingIdx    = find(allOverallPhase == "Landing");
    nLandings     = numel(landingIdx);

    takeoffIdx    = find(allOverallPhase == "Takeoff");
    nTakeoffs     = numel(takeoffIdx);

    cruiseIdx     = find(allOverallPhase == "Cruise");
    nCruises      = numel(cruiseIdx);

    goAroundIdx   = find(allOverallPhase == "GoAround");
    nGoArounds    = numel(goAroundIdx);

    nonDetectedIdx = find(allOverallPhase == "NonDetected");
    nNonDetected   = numel(nonDetectedIdx);
    
    % Exit strutct
    summaryPhases.nLandings       = nLandings;
    summaryPhases.landingIndices  = landingIdx;
    summaryPhases.nTakeoffs       = nTakeoffs;
    summaryPhases.takeoffIndices  = takeoffIdx;
    summaryPhases.nCruises        = nCruises;
    summaryPhases.cruiseIndices   = cruiseIdx;
    summaryPhases.nGoArounds      = nGoArounds;
    summaryPhases.goAroundIndices = goAroundIdx;
    summaryPhases.nNonDetected    = nNonDetected;
    summaryPhases.nonDetectedIdx = nonDetectedIdx;

end
