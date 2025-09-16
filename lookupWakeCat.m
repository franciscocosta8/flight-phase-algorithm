function category = lookupWakeCat(designator)
%LOOKUPWAKECAT  Return wake-turbulence category for an ICAO designator
%   category = lookupWakeCat(designator)
%   Input:
%     designator – string or char of the ICAO type code (e.g. 'A320')
%   Output:
%     category – one of:
%       'SUPER_HEAVY','UPPER_HEAVY','LOWER_HEAVY',
%       'UPPER_MEDIUM','LOWER_MEDIUM','LIGHT'

  % Ensure uppercase string
  d = upper(string(designator));

  % Define wake-turbulence lists
  SUPER_HEAVY  = ["A380","A388","A124"];
  UPPER_HEAVY  = ["B747","B748","A332","A333","A338","A339","A342","A343","A345","A346","A359","A35K", ...
                  "B741","B742","B743","B744","B74R","B74S","B74D","B772","B773","B77L","B77W","B788","B789","B78X","IL96","AN22"];
  LOWER_HEAVY  = ["A300","A306","A310","A3ST","B703","B762","B763","B764","B752","B753","DC10","DC87","IL62","IL76","MD11"];
  UPPER_MEDIUM = ["A19N","A20N","A21N","A318","A319","A320","A321","B37M","B38M","B39M","B3XM","B722","B736","B737","B738","B739","MD81","MD82","AN12","IL18"];
  LOWER_MEDIUM = ["AN72","B461","B462","B463","B712","B732","B733","B734","B735","BCS1","BCS3","CRJ1","CRJ2","CRJ7","CRJ9","CRJX", ...
                  "DC91","DC92","DC93","DC94","DC95","E135","E145","E170","E190","E195","F100","F70","J328","CRJ200","CRJ700","AT43","DH8D", ...
                  "C750","CL30","CL35","CL60","F2TH","F900","FA50","FA7X","GALX","GL5T","GLEX","GLF3","GLF4","GLF5","A748","AN24","AN26","AN30","AN32","AT45","AT72","AT75","ATP","CL2T","CN35","DH8A","DH8C","DHC7","F27","F50","SB20"];
  LIGHT        = ["C172","C525","PA46","TBM7","BE9L","ASTR","BE40","C25A","C25B","C25C","C25M","C550","C560","C56X","C650","C680","E50P","E55P","FA10","FA20", ...
                  "G150","H25A","H25B","H25C","HDJT","LJ25","LJ31","LJ35","LJ40","LJ45","LJ55","LJ60","PRM1","AN28","AN38","B190","BE99","BN2T","C212","D328","DHC6","E120","JS1","JS31","JS32","JS41","L410","L610","N262","SC7","SF34","SH33","SH36"];

  % Lookup
  if ismember(d, SUPER_HEAVY)
    category = "SUPER_HEAVY";
  elseif ismember(d, UPPER_HEAVY)
    category = "UPPER_HEAVY";
  elseif ismember(d, LOWER_HEAVY)
    category = "LOWER_HEAVY";
  elseif ismember(d, UPPER_MEDIUM)
    category = "UPPER_MEDIUM";
  elseif ismember(d, LOWER_MEDIUM)
    category = "LOWER_MEDIUM";
  elseif ismember(d, LIGHT)
    category = "LIGHT";
  else
    category = "NO CATEGORY";
  end
end


