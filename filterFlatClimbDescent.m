function [keep, phaseStates] = filterFlatClimbDescent(alt, phaseStates)
%FILTERFLATCLIMBDESCENT Retorna um vetor lógico indicando quais pontos 
% devem ser mantidos, eliminando pontos consecutivos com alt(i)==alt(i-1)
% e cujo phaseStates(i) é Climb ou Descent. Além disso, “corrige” situações
% em que exatamente três pontos seguidos (B) estão entre dois blocos iguais (A):
%   Exemplo: [2 2 2 3 3 3 2 2 2] → [2 2 2 2 2 2 2 2 2]
%
%   INPUTS:
%     - alt:          vetor coluna (Nx1) de altitudes (em ft) já validadas
%     - phaseStates:  vetor coluna (Nx1) de estados, usando o enum FlightPhase
%
%   OUTPUTS:
%     - keep:            vetor lógico (Nx1), true = mantém ponto, false = remove
%     - phaseStates:     vetor (Nx1) atualizado, com eventuais “três pontos” corrigidos
%
    n = numel(alt);
    %----------------------------------------------------
    % 1) Corrige runs de exatamente 3 pontos “B” entre dois blocos “A” iguais
    %    Percorre s = 2 até n−3, pois vamos checar [s-1], [s:s+2], [s+3]
    %
    %    Condição de “patch”:
    %      phaseStates(s   ) == phaseStates(s+1) == phaseStates(s+2) = B
    %      phaseStates(s-1 ) == phaseStates(s+3) = A
    %      A ≠ B
    %    Se for o caso, troca phaseStates(s:s+2) ← A
    %----------------------------------------------------
    keep = true(n,1);
    for s = 2:(n-3)
        % B = phaseStates(s);
        % A = phaseStates(s-1);
        % % Verifica se o ponto após a sequência de 3 também é igual a A
        % if (phaseStates(s+3) == A) && (A ~= B)
        %     phaseStates((s):(s+2)) = A;
        % end
        if alt(s)==alt(s-1) && (phaseStates(s)==FlightPhase.Climb || phaseStates(s) == FlightPhase.Descent)
            keep(s) = false;
        end
    end
    % origPhase = phaseStates;  % repeat filter to find intercalated points - 11121211 wasn't correctly filtered
    % for i = 2:(n-2)
    %     if origPhase(i-1) == origPhase(i+1) && origPhase(i) ~= origPhase(i-1)
    %         phaseStates(i) = origPhase(i-1);
    %     end
    %     if origPhase(i-1) == origPhase(i+2) && origPhase(i) ~= origPhase(i-1)
    %          phaseStates(i:(i+1)) = origPhase(i-1);
    %     end
    % end
end
