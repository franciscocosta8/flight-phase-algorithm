%% --- parâmetros do filtro de derivada (deve corresponder ao usado no pipeline) ---
cfg=config();
thr_acc = cfg.thr_acc;    % (ft/min)/s
W       = cfg.W;     % largura do cbridge" em amostras

% --- mapa de cores por fase, igual ao original ---
phaseLabels  = FlightPhase.list();
phase2color  = containers.Map(...
    phaseLabels, ...
    mat2cell(lines(numel(phaseLabels)), ones(1,numel(phaseLabels)), 3));

% --- plot para o voo k ---
for k=1:3
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
    
    t_removed=t0(~keep);
    alt_removed=alt0(~keep);
    %roc_removed=roc(~keep);

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
    
%    fprintf("→ numel(t0) = %d\n",   numel(t0));
 %   fprintf("→ sum(keep) = %d\n",   sum(keep));
  %  fprintf("→ numel(t) = %d\n",    numel(t));
   % fprintf("→ numel(rawStates) = %d\n", numel(rawStates));
    %fprintf("→ numel(grp) = %d\n\n", numel(grp));

    N = min([numel(t), numel(rawStates), numel(grp)]);
    if numel(t) > N
        t   = t(1:N);
        alt = alt(1:N);
        roc = roc(1:N);
        grp = grp(1:N);
    end


    % ... cálculo de t0, alt0, roc0, acc, keep, etc. ...

    % cria figura e ax1
    hFig = figure('Position',[100 100 1000 500]);
    ax1 = axes('Parent', hFig);
    hold(ax1, 'on');
    
    % 1) linha de altitude estimada
    %alt_est = interp1(t, alt, t0, 'pchip');
    %plot(ax1, t0, alt_est, '-', 'LineWidth',1.5, ...
    %     'Color',[0 0 0], 'DisplayName','Estimated altitude');
    
    % 2) pontos removidos
    scatter(ax1, t_removed, alt_removed, 36, 'r', 'x', ...
            'DisplayName','Pontos removidos');
    
    % 3) loop de scatter para cada fase
    for i = 1:numel(grpNames)
        xi = grp == i;
        scatter(ax1, t(xi), alt(xi), 100, ...
                'Marker', '.', ...
                'MarkerEdgeColor', cmap(i,:), ...
                'DisplayName', grpNames{i});
    end
    
    % 4) ajustes finais
    ylabel(ax1, 'Altitude (ft)');
    ylim(ax1, [min(alt)-500, max(alt)+500]);
    datetick(ax1, 'x', 'HH:MM', 'keepticks');
    xlabel(ax1, 'Time');
    title(ax1, sprintf("Flight %s (idx %d)", cleanFlights(k).callsign, k));
    legend(ax1, 'Location', 'eastoutside');
    grid(ax1, 'on');

end