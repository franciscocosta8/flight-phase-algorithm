function phaseStates = filterChangeOfPhase( phaseStates, FlightPhaseClimb, FlightPhaseDescent, FlightPhaseLevel)
%FILTERCHANGE0FPHASE Filtra mudanças de fase muito curtas (≤5 índices)
%
%   Versão ajustada para considerar “ruído” quando um bloco de uma fase
%   tiver no máximo 5 pontos consecutivos (em vez de duração em segundos).
%   O funcionamento geral mantém a lógica de origPhaseStates vs.
%   newPhaseStates para evitar que substituições cascata se propaguem.
%
%   Entradas:
%     • time             – vetor N×1 com instantes (s) (mantido para
%                          compatibilidade, mas não usado no critério)
%     • phaseStates      – vetor N×1 com o estado/fase de cada ponto
%     • FlightPhaseClimb – inteiro que representa “Climb”
%     • FlightPhaseDescent – inteiro que representa “Descent”
%     • FlightPhaseLevel – inteiro que representa “Level Flight”
%
%   Saída:
%     • phaseStates      – vetor N×1 sem blocos de fase com ≤5 pontos

    maxShortPoints = 3;    % número máximo de pontos consecutivos para ser considerado 6curto7
    N = numel(phaseStates);

    % Vetor original de referência (imutável)
    origPhaseStates = phaseStates;
    % Vetor de trabalho onde aplicaremos as substituições
    newPhaseStates = phaseStates;

    % Lista das fases a verificar
    phasesToCheck = [FlightPhaseClimb, FlightPhaseDescent, FlightPhaseLevel];

    for idxPhase = 1:numel(phasesToCheck)
        thisPhase = phasesToCheck(idxPhase);

        % Máscara dos pontos que pertencem a thisPhase (na referência original)
        isPhase = (origPhaseStates == thisPhase);
        if ~any(isPhase)
            continue;  % não há ocorrências dessa fase → pula
        end

        % Detecta inícios e fins de blocos contínuos desta fase
        dmask = diff([0; isPhase; 0]);
        starts = find(dmask ==  1);     % índices onde “entra” nestaPhase
        ends   = find(dmask == -1) - 1;  % índices onde “sai” destaPhase

        for k = 1:numel(starts)
            i0 = starts(k);
            i1 = ends(k);

            blockLength = i1 - i0 + 1;  % número de pontos no bloco

            if blockLength <= maxShortPoints
                % Bloco curto: substitui pela fase anterior ou posterior
                if i0 > 1 && i1 < N
                    % caso normal no meio: tem anterior e posterior
                    replacePhase = origPhaseStates(i0 - 1);

                elseif i0 == 1 && i1 < N
                    % bloco curto no início: não há anterior → usa o próximo
                    replacePhase = origPhaseStates(i1 + 1);

                elseif i0 > 1 && i1 == N
                    % bloco curto no fim: não há posterior → usa o anterior
                    replacePhase = origPhaseStates(i0 - 1);

                else
                    % bloco cobre todo o vetor (i0==1 && i1==N):
                    % não há anterior nem posterior → não altera nada
                    continue;
                end

                % Atribui a fase de substituição no vetor final
                newPhaseStates(i0:i1) = replacePhase;
            end
        end
    end

    % Retorna o vetor filtrado
    phaseStates = newPhaseStates;
end
