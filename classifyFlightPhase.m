function phaseStates = classifyFlightPhase(T, cfg)
%CLASSIFYFLIGHTPHASE  Assigns a FlightPhase label to each valid sample.
%   phaseStates = CLASSIFYFLIGHTPHASE(T, cfg) examines the fields
%   T.h_QNH_Metar, T.h_dot_baro and T.gs, applies the fuzzy‐logic rules
%   defined in cfg.mf, and returns an n×1 vector of FlightPhase values,
%   where n is the number of valid samples. If there are fewer than 25
%   valid samples or any of the key signals are NaN, returns [].

    %–– 1) Basic sanity checks
    if all(isnan(T.h_QNH_Metar)) || all(isnan(T.h_dot_baro)) || all(isnan(T.gs))
        phaseStates = [];
        return;
    end
    valid = isfinite(T.h_dot_baro) & isfinite(T.gs) & isfinite(T.h_QNH_Metar);
    if sum(valid) < 25
        phaseStates = [];
        return;
    end

    %–– 2) Extract the trimmed signals
    alt = T.h_QNH_Metar(valid);
    roc = T.h_dot_baro(valid);
    gs  = T.gs(valid);
    n   = numel(alt);

    %–– 3) Preallocate output
    phaseStates = repmat(FlightPhase.Ground, n, 1);

    %–– 4) Define your fuzzy‐membership functions once
    H_gnd = @(eta) zmf(eta,cfg.mf.eta.gnd);
    H_lo  = @(eta) gaussmf(eta, cfg.mf.eta.lo);
    H_hi  = @(eta) gaussmf(eta, cfg.mf.eta.hi);
    
    % rate‐of‐climb fuzzy‐sets
    RoC0 = @(tau) gaussmf(tau, cfg.mf.tau.roc0);
    RoCp = @(tau) smf(tau,cfg.mf.tau.rocp);
    RoCm = @(tau) zmf( tau, cfg.mf.tau.rocm);
    
    % airspeed fuzzy‐sets
    V_lo  = @(v) gaussmf(v, cfg.mf.v.lo);
    V_mid = @(v) gaussmf(v, cfg.mf.v.mid);
    V_hi  = @(v) gaussmf(v, cfg.mf.v.hi);

    %–– 5) Loop through each sample and apply rules + defuzzify
    mu_gnd  = H_gnd(alt); 
    mu_lo   = H_lo(alt);     
    mu_hi   = H_hi(alt);     
    mu_roc0 = RoC0(roc);     
    mu_rocp = RoCp(roc);     
    mu_rocm = RoCm(roc);     
    mu_vlo  = V_lo(gs);      
    mu_vmid = V_mid(gs);     
    mu_vhi  = V_hi(gs);     

        % Apply rules 
    Sgnd = mu_gnd;
    Sclb = min([mu_lo,  mu_vmid, mu_rocp], [], 2);
    Scru = min([mu_hi,  mu_vhi,  mu_roc0], [], 2);
    Sdes = min([mu_lo,  mu_vmid, mu_rocm], [], 2);
    Slvl = min([mu_lo,  mu_vmid, mu_roc0], [], 2);

    % 3) Defuzzify 
    scores = [Sgnd, Sclb, Scru, Sdes, Slvl];
    [~, idx] = max(scores, [], 2);
    phaseStates = FlightPhase(idx);
end
