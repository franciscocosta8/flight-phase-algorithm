function cfg = config()

  % 1a) Derivative filter parameters
  cfg.thr_acc = 125;    % limiar de aceleração (ft/min)/s
  cfg.W = 1;     % 3bridge2 de até 5 amostras
  cfg.cap=5;
  cfg.tolerance=1;

  cfg.phaseLabels = FlightPhase.list();  
  N = numel(cfg.phaseLabels);

  cfg.phaseColors = turbo(N);

  %   cfg.phaseColors = parula,hsv, autumn, winter(N);
  %  Monte o containers.Map de label → cor
  cfg.phase2color = containers.Map(cfg.phaseLabels,mat2cell(cfg.phaseColors,ones(1,N),3));
  % Fuzzy membership functions
  % Continuous axis
  cfg.eta = linspace(0,40000,401);      % altitude in feet
  cfg.tau = linspace(-4000,4000,801);   % rate of climb in ft/min
  cfg.v   = linspace(0,700,701);        % speed in knots
  cfg.p   = linspace(0,6,601);          % phase axis (0 to 6)

  %% 2) Raw membership‐function parameters
%    We group them by variable for clarity.

% — η (altitude) — 
%    • ZMF:  zmf(x, [a b])
%    • gaussmf(x,[σ μ])  (MATLAB’s convention is [σ μ])
cfg.mf.eta.gnd = [   0,    300];    % Z(η; 0,300)
cfg.mf.eta.lo  = [10000, 10000];    % G(η; 10000,10000)
cfg.mf.eta.hi  = [20000, 35000];    % G(η; 35000,20000)

% — τ (rate of climb) —
cfg.mf.tau.roc0 = [ 100,    0];     % G(τ; 0,100)
cfg.mf.tau.rocp = [  10, 1000];     % S(τ; 10,1000)
cfg.mf.tau.rocm = [-1000,  -10];    % Z(τ; –1000,–10)

% — v (airspeed) —
cfg.mf.v.lo  = [ 50,   0];           % G(v;0,50)
cfg.mf.v.mid = [100, 300];           % G(v;300,100)
cfg.mf.v.hi  = [100, 600];           % G(v;600,100)

% %% 3) Function‐handles for each MF
% %    Now you can write, in *either* file:
% %      H_gnd = cfg.func.H_gnd(eta);
% %    or even
% %      H_gnd = zmf(eta, cfg.mf.eta.gnd);
% 
% cfg.func.H_gnd = @(eta) zmf(eta,    cfg.mf.eta.gnd);
% cfg.func.H_lo  = @(eta) gaussmf(eta, cfg.mf.eta.lo);
% cfg.func.H_hi  = @(eta) gaussmf(eta, cfg.mf.eta.hi);
% 
% cfg.func.RoC0 = @(tau) gaussmf(tau, cfg.mf.tau.roc0);
% cfg.func.RoCp = @(tau) smf(tau,     cfg.mf.tau.rocp);
% cfg.func.RoCm = @(tau) zmf(tau,     cfg.mf.tau.rocm);
% 
% cfg.func.V_lo  = @(v) gaussmf(v, cfg.mf.v.lo);
% cfg.func.V_mid = @(v) gaussmf(v, cfg.mf.v.mid);
% cfg.func.V_hi  = @(v) gaussmf(v, cfg.mf.v.hi);


end
