function cols = mapPhasesToColors(phaseStr, phaseMap)
    % recebe uma string no formato 'descent; level flight; cruise'
    % devolve um cell array de cores correspondente
    toks = strsplit(phaseStr, ';');          % quebra pelos ';'
    toks = strtrim(toks);                    % tira espaços
    % para cada token, busca no map
    cols = cellfun(@(s) phaseMap(lower(s)), ...
                   toks, ...
                   'UniformOutput', false);
end