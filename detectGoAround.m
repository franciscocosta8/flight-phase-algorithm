function [statesOut, goSegments] = detectGoAround(time, alt, statesIn)
% DETECTGOAROUND Simplified go‐around detection for climb segments
%
%   [statesOut, goSegments] = detectGoAround(time, alt, statesIn)
%
% Inputs:
%   time      - N×1 vector of time stamps (in seconds or datenums)
%   alt       - N×1 vector of altitudes (ft)
%   statesIn  - N×1 vector of phase states (2 = Climb)
%
% Outputs:
%   statesOut   - N×1 vector of phase states with 2→6 (GoAroundClimb) applied
%   goSegments  - table listing each detected go-around:
%                 StartIdx | EndIdx | Gain(ft) | Duration(s)

    % hard-coded thresholds
    minGain = 500;    % ft
    maxGain = 3500;   % ft
    altMax  = 5000;   % ft
    maxTime = 300;    % s

    % initialize outputs
    statesOut   = statesIn;
    goSegments  = table( ...
        'Size',[0 4], ...
        'VariableTypes',{'double','double','double','double'}, ...
        'VariableNames',{'StartIdx','EndIdx','Gain','Duration'} ...
    );

    % find contiguous climb (=2) blocks
    isClimb = (statesIn == FlightPhase.Climb);
    d       = diff([0; isClimb; 0]);
    starts  = find(d ==  1);
    ends    = find(d == -1) - 1;

    % test each block against go-around criteria
    for k = 1:numel(starts)
        idx = starts(k):ends(k);
        gain = alt(idx(end)) - alt(idx(1));
        dur  = time(idx(end)) - time(idx(1));
        if gain >= minGain && gain <= maxGain ...
           && max(alt(idx)) <= altMax && dur <= maxTime
            % mark as GoAroundClimb (6)
            statesOut(idx) = FlightPhase.GoAroundClimb;
            % record segment
            goSegments(end+1,:) = {starts(k), ends(k), gain, dur}; %#ok<AGROW>
        end
    end
end
