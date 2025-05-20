function tf = isValidFlight(callsign, airline, departures)
    % Returns TRUE if callsign and airline are valid identifiers.
    % Filters out empty, whitespace-only, literal '""', or placeholder strings.

    % Trim whitespace
    csTrim = strtrim(string(callsign));
    alTrim = strtrim(string(airline));

    % Conditions for invalid ID
    condEmpty   = csTrim==""   || alTrim=="";
    condPlace   = startsWith(csTrim, "@@@", "IgnoreCase", true) || startsWith(alTrim, "@@@", "IgnoreCase", true);
    condNoDepartures=isempty(departures);
    
    if condEmpty || condPlace || condNoDepartures
        tf = false;
    else
        tf = true;
    end
end