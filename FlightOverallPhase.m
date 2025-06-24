classdef FlightOverallPhase < int32
    % FlightOverallPhase enumera as fases de voo “globais” (por voo inteiro)
    enumeration
        Landing               (1) 
        Takeoff               (2) 
        Cruise                (3) 
        GoAround              (4) 
        LandingAfterGoAround  (5)
        NonDetected           (6)
    end
end
