% Pre-allocate as before…
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
        else
            gaAlt = fp(f).altitude(gaIdx);
        end

        %dailySummaries{k}.flightPhases(f).goAroundIdx  = gaIdx;
        dailySummaries{k}.flightPhases(f).goAroundAlt  = gaAlt;
    end
end
