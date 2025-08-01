% Pre-allocate as before…
gaALtm=[];
gaLATm=[];
gaLONm=[];
for k = 1:numel(dailySummaries)
    fp = dailySummaries{k}.flightPhases;      % struct array [N×1]
    Nf = numel(fp);

    % Loop over each flight
    for f = 1:Nf
        % find first Go-Around climb sample
        gaIdx = find( fp(f).rawStates == FlightPhase.GoAroundClimb, 1, 'first' );
        if isempty(gaIdx)
            gaIdx = NaN;
            gaAlt = NaN;
            gaLAT = NaN;
            gaLON = NaN;
        else
            gaAlt = fp(f).altitude(gaIdx);
            gaALtm(end+1)=gaAlt;
            gaLAT = fp(f).latitude(gaIdx);
            gaLATm(end+1)=gaLAT;
            gaLON = fp(f).longitude(gaIdx);
            gaLONm(end+1)=gaLON;
        end

        dailySummaries{k}.flightPhases(f).goAroundIdx  = gaIdx;
        dailySummaries{k}.flightPhases(f).goAroundAlt  = gaAlt;
        dailySummaries{k}.flightPhases(f).goAroundLat  = gaLAT;
        dailySummaries{k}.flightPhases(f).goAroundLon  = gaLON;
    end
end
histogram( gaLONm(:), 10 );   
xlabel('Value');
ylabel('Frequency');
title('Histogram');

geoplot(gaLATm, gaLONm, 'o', ...
    "MarkerSize", 6, ...
    "MarkerEdgeColor", "k", ...
    "MarkerFaceColor", "r");
title( "All Flight Position Fixes");