function keep = filterFlatClimbDescent(alt, phaseStates)
%FILTERFLATCLIMBDESCENT Retorna um vetor lógico indicando quais pontos 
% devem ser mantidos, eliminando pontos consecutivos com alt(i)==alt(i-1)
% e cujo phaseStates(i) é Climb ou Descent.
%
%   INPUTS:
%     - alt: vetor coluna (Nx1) de altitudes (em ft) já validadas
%     - phaseStates: vetor coluna (Nx1) de estados, usando o enum FlightPhase
%
%   OUTPUT:
%     - keep: vetor lógico (Nx1), true = mantém ponto, false = remove ponto
%
    n = numel(alt);
    keep = true(n,1);
    % Começamos em i=2, pois só faz sentido comparar com o ponto anterior
    for i = 2:n
        % Se a altitude não mudou e o estado atual é Climb ou Descent, remove-se i.
        if alt(i) == alt(i-1) && ...
           ( phaseStates(i) == FlightPhase.Climb || phaseStates(i) == FlightPhase.Descent )
            keep(i) = false;
        end
    end
end