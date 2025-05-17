classdef FlightPhase < uint8
  % FlightPhase  Enumeration of all flight phases
  enumeration
    Ground    (1)
    Climb     (2)
    Cruise    (3)
    Descent   (4)
    Level     (5)
  end

  methods (Static)
    function names = list()
      % returns a cell-array of phase names, if you really need one
      names = { 'Ground','Climb','Cruise','Descent','Level flight'};
    end
  end
end
