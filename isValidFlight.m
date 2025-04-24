function tf = isValidFlight(callsign, airline)
    % Returns TRUE if callsign and airline are valid identifiers.
    % Filters out empty, whitespace-only, literal '""', or placeholder strings.

    % Convert to string for uniform handling
    %cs = string(callsign);
    %al = string(airline);

    % Trim whitespace
    csTrim = strtrim(string(callsign));
    alTrim = strtrim(string(airline));

    % Conditions for invalid ID
    condEmpty   = csTrim==""   || alTrim=="";
    condPlace   = startsWith(csTrim, "@@@", "IgnoreCase", true) || ...
                  startsWith(alTrim, "@@@", "IgnoreCase", true);

    if condEmpty || condPlace
        tf = false;
    else
        tf = true;
    end
end