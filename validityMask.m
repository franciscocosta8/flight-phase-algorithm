function mask = validityMask(results)
    cs = {results.callsign};
    al = {results.airline};
    ac = {results.acType};
    dp = {results.departure};
    mask = cellfun(@isValidFlight, cs, al, ac, dp);
end