classdef FlightOverallPhase < int32
    % FlightOverallPhase enumera as fases de voo “globais” (por voo inteiro)
    enumeration
        Landing               (1) % Pouso
        Takeoff               (2) % Decolagem
        Cruise                (3) % Cruzeiro
        LandingWithGoAround   (4) % Pouso com arremetida
    end
end
