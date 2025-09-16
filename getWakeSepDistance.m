function distNM = getWakeSepDistance(catLead, catFollow)
%GETWAKESP DISTance   Return minimum separation (NM) between two wake categories.

  % Define category order
  cats = ["SUPER_HEAVY","UPPER_HEAVY","LOWER_HEAVY", ...
          "UPPER_MEDIUM","LOWER_MEDIUM","LIGHT"];

  % Map inputs to indices
  i = find(cats == upper(string(catLead)), 1);
  j = find(cats == upper(string(catFollow)), 1);
  if isempty(i) || isempty(j)
    error("Unknown wake category: '%s' or '%s'", catLead, catFollow);
  end

  % Define separation matrix (leader row, follower column)
  sep = [
    3, 4, 5, 5, 6, 8;  ... % SUPER_HEAVY (CAT A)
    3, 3, 4, 4, 5, 7;  ... % UPPER_HEAVY (CAT B)
    3, 3, 3, 3, 4, 6;  ... % LOWER_HEAVY (CAT C)
    3, 3, 3, 3, 3, 5;  ... % UPPER_MEDIUM (CAT D)
    3, 3, 3, 3, 3, 4;  ... % LOWER_MEDIUM (CAT E)
    3, 3, 3, 3, 3, 3       % LIGHT (CAT F)
  ];

  % Fetch distance
  distNM = sep(i, j);
end