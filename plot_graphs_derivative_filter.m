%% --- parâmetros do filtro de derivada (deve corresponder ao usado no pipeline) ---
cfg=config();
thr_acc = cfg.thr_acc;    % (ft/min)/s
W       = cfg.W;     % largura do cbridge" em amostras

% --- mapa de cores por fase, igual ao original ---
phaseLabels  = FlightPhase.list();
phase2color  = containers.Map(...
    phaseLabels, ...
    mat2cell(lines(numel(phaseLabels)), ones(1,numel(phaseLabels)), 3) ...
);

% --- plot para o voo k ---
for k=12:15
    T   = cleanFlights(k).flightData;
    
    % 1) carrega e limpa NaNs/Infs
    t0   = T.time;
    alt0 = T.h_QNH_Metar;
    roc0 = T.h_dot_baro;
    valid = isfinite(t0) & isfinite(alt0) & isfinite(roc0);
    t0    = t0(valid);
    alt0  = alt0(valid);
    roc0  = roc0(valid);

    % 2) filtra por derivada (aceleração de roc)
    dt_sec = seconds(diff(t0));
    acc    = [0; diff(roc0)./dt_sec];
    isErr  = abs(acc) > thr_acc;
    idx    = find(isErr);
    for i = 1:numel(idx)-1
        if idx(i+1)-idx(i) <= W
            isErr(idx(i):idx(i+1)) = true;
        end
    end
    keep = ~isErr;
    
    % 3) aplica máscara **só** em t, alt, roc
    t   = t0(keep);
    alt = alt0(keep);
    roc = roc0(keep);


    % 4) recupera fases já filtradas (foi gerado depois do mesmo keep no pipeline)
    rawStates = allStates_names{k};     
    rawStates = cellstr(rawStates(:));  % força N×1 cell array of char
    
    % 5) agrupa e escolhe cores
    [grp, grpNames] = findgroups(rawStates);
    cmap = cell2mat(values(phase2color, grpNames));
    
    fprintf("→ numel(t0) = %d\n",   numel(t0));
    fprintf("→ sum(keep) = %d\n",   sum(keep));
    fprintf("→ numel(t) = %d\n",    numel(t));
    fprintf("→ numel(rawStates) = %d\n", numel(rawStates));
    fprintf("→ numel(grp) = %d\n\n", numel(grp));

    N = min([numel(t), numel(rawStates), numel(grp)]);
    if numel(t) > N
        t   = t(1:N);
        alt = alt(1:N);
        roc = roc(1:N);
        grp = grp(1:N);
    end


    % 6) desenha
    figure('Position',[100 100 1000 500])
    
    yyaxis left
    gscatter(t, alt, grp, cmap, '.', 10)
    ylabel('Altitude (ft)')
    ylim([min(alt)-500, max(alt)+500])
    
    yyaxis right
    hold on
    for i = 1:max(grp)
        xi = grp==i;
        plot(t(xi), roc(xi), '.', 'Color', cmap(i,:), ...
             'Marker','o', 'HandleVisibility', 'off');
    end
    ylabel('Rate of Climb (ft/min)')
    
    datetick('x','HH:MM','keepticks')
    xlabel('Time')
    title(sprintf("Flight %s (idx %d)", cleanFlights(k).callsign, k))
    legend(grpNames, 'Location','eastoutside')
    grid on
end