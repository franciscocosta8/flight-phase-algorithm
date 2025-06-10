function summaryPhases = summarizePhases(allOverallPhase)
% summarizePhases    Conta e retorna índices e quantidades de cada fase "global" de um conjunto de voos
%   Input:
%       allOverallPhase - vetor de strings (1xN) contendo as fases globais de cada voo
%                         Os valores esperados são:
%                         "Landing", "Takeoff", "Cruise", "LandingWithGoAround"
%   Output:
%       summaryPhases - struct com os campos:
%           nLandings       - número de voos classificados como Landing
%           landingIndices  - índices dos voos Landing
%           nTakeoffs       - número de voos classificados como Takeoff
%           takeoffIndices  - índices dos voos Takeoff
%           nCruises        - número de voos classificados como Cruise
%           cruiseIndices   - índices dos voos Cruise
%           nGoArounds      - número de voos classificados como LandingWithGoAround
%           goAroundIndices - índices dos voos LandingWithGoAround

    % Encontrar índices para cada fase
    landingIdx    = find(allOverallPhase == "Landing");
    nLandings     = numel(landingIdx);

    takeoffIdx    = find(allOverallPhase == "Takeoff");
    nTakeoffs     = numel(takeoffIdx);

    cruiseIdx     = find(allOverallPhase == "Cruise");
    nCruises      = numel(cruiseIdx);

    goAroundIdx   = find(allOverallPhase == "LandingWithGoAround");
    nGoArounds    = numel(goAroundIdx);

    % Montar struct de saída
    summaryPhases.nLandings       = nLandings;
    summaryPhases.landingIndices  = landingIdx;
    summaryPhases.nTakeoffs       = nTakeoffs;
    summaryPhases.takeoffIndices  = takeoffIdx;
    summaryPhases.nCruises        = nCruises;
    summaryPhases.cruiseIndices   = cruiseIdx;
    summaryPhases.nGoArounds      = nGoArounds;
    summaryPhases.goAroundIndices = goAroundIdx;
end
