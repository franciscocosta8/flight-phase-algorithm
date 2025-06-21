function summaryPhases = summarizePhases(allOverallPhase)
% summarizePhases   Evaluate the amount of flights that have each phase
%   Input:
%       allOverallPhase - strings vector (1xN) 
%                         Expected values:
%                         "Landing", "Takeoff", "Cruise", "LandingWithGoAround"
%   Output:
%       summaryPhases - struct com os campos:
%           nLandings       - flights named as Landing
%           landingIndices  - flight index -> Landing
%           nTakeoffs       - flights named as Takeoff
%           takeoffIndices  - flight index -> Takeoff
%           nCruises        - flights named as Cruise
%           cruiseIndices   - flight index -> Cruise
%           nGoArounds      - flights named as LandingWithGoAround
%           goAroundIndices - flight index -> LandingWithGoAround

    % Find index to each phase
    landingIdx    = find(allOverallPhase == "Landing");
    nLandings     = numel(landingIdx);

    takeoffIdx    = find(allOverallPhase == "Takeoff");
    nTakeoffs     = numel(takeoffIdx);

    cruiseIdx     = find(allOverallPhase == "Cruise");
    nCruises      = numel(cruiseIdx);

    goAroundIdx   = find(allOverallPhase == "LandingWithGoAround");
    nGoArounds    = numel(goAroundIdx);

    % Exit strutct
    summaryPhases.nLandings       = nLandings;
    summaryPhases.landingIndices  = landingIdx;
    summaryPhases.nTakeoffs       = nTakeoffs;
    summaryPhases.takeoffIndices  = takeoffIdx;
    summaryPhases.nCruises        = nCruises;
    summaryPhases.cruiseIndices   = cruiseIdx;
    summaryPhases.nGoArounds      = nGoArounds;
    summaryPhases.goAroundIndices = goAroundIdx;
end
