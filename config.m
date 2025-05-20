function cfg = config()
%LOADCONFIG Carrega todos os parâmetros usados pelos pipelines

  % 1) Derivative filter parameters
  cfg.thr_acc = 100;    % limiar de aceleração (ft/min)/s
  cfg.W       = 3;     % 3bridge2 de até 5 amostras

  % 2) Parâmetros de cor / fases
  cfg.phaseLabels = FlightPhase.list();          
  cmap = lines(numel(cfg.phaseLabels));          
  cfg.phase2color = containers.Map( ...
      cfg.phaseLabels, ...
      mat2cell(cmap, ones(1,numel(cfg.phaseLabels)), 3) ...
  );

  % 3) Fuzzy membership functions
end
