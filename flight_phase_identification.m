%% Flight Phase Identification Pipeline
% Load results and filter invalid flights
load('results.mat');

%% Stage 1 – Filter out invalid flights
validIdx = arrayfun(@(f) isValidFlight(f.callsign, f.airline), results);
cleanFlights = results(validIdx);
fprintf("Filtered to %d valid flights.\n", sum(validIdx));

%% Stage 2 – Fuzzy Phase Identification per ADS-B Sample
% Implements fuzzy rules (6a)–(6e) and defuzzifies via (7f)–(8).

N = numel(cleanFlights);
allStates = cell(1, N);
phaseNames = {'Ground','Climb','Cruise','Descent','Level flight'};

% Define lineear spaces
eta = linspace(0,40000,401);      % altitude in feet
tau = linspace(-4000,4000,801);   % rate of climb in ft/min
v   = linspace(0,700,701);        % speed in knots
p   = linspace(0,6,601);          % phase axis (0 to 6)

% Precompute phase membership values P(P)
PgndVal = gaussmf(1, [0.2 1]);
PclbVal = gaussmf(2, [0.2 2]);
PcruVal = gaussmf(3, [0.2 3]);
PdesVal = gaussmf(4, [0.2 4]);
PlvlVal = gaussmf(5, [0.2 5]);

% Define input membership functions
H_gnd = @(eta) zmf(eta, [0,   200]);         % Z(η,0,200)
H_lo  = @(eta) gaussmf(eta, [10000,10000]);   % G(η,10000,10000)
H_hi  = @(eta) gaussmf(eta, [20000,35000]);   % G(η,35000,20000)

RoC0 = @(tau) gaussmf(tau, [100,   0]);      % G(τ,0,100)
RoCp = @(tau) smf( tau, [10, 1000]);         % S(τ,10,1000)
RoCm = @(tau) zmf( tau, [-1000, -10]);       % Z(τ,-1000,-10)

V_lo  = @(v) gaussmf(v, [50,   0]);          % G(v,0,50)
V_mid = @(v) gaussmf(v, [100, 300]);         % G(v,300,100)
V_hi  = @(v) gaussmf(v, [100, 600]);         % G(v,600,100)

% Loop over flights
for f = 1:N
    T = cleanFlights(f).flightData;
    time = T.time;
    alt = T.h_QNH_Metar;     % altitude (ft)
    roc = T.h_dot_baro;      % RoC (ft/min)
    gs  = T.gs;              % ground speed (kt)
    n   = height(T);
    states = strings(n,1);

    validSamples = isfinite(alt) & isfinite(roc) & isfinite(gs);
    alt = alt(validSamples);
    roc = roc(validSamples);
    gs  = gs(validSamples);
    n   = numel(alt);

    for i = 1:n        
        % 1) Compute input memberships
        mu_gnd  = H_gnd(alt(i));
        mu_lo   = H_lo(alt(i));
        mu_hi   = H_hi(alt(i));
        mu_roc0 = RoC0(roc(i));
        mu_rocp = RoCp(roc(i));
        mu_rocm = RoCm(roc(i));
        mu_vlo  = V_lo(gs(i));
        mu_vmid = V_mid(gs(i));
        mu_vhi  = V_hi(gs(i));

        % 2) Apply rules (6a)–(6e)
        Sgnd = min([ min([mu_gnd, mu_vlo, mu_roc0]), PgndVal ]);
        Sclb = min([ min([mu_lo,   mu_vmid, mu_rocp]), PclbVal ]);
        Scru = min([ min([mu_hi,   mu_vhi,   mu_roc0]), PcruVal ]);
        Sdes = min([ min([mu_lo,   mu_vmid, mu_rocm]), PdesVal ]);
        Slvl = min([ min([mu_lo,   mu_vmid, mu_roc0]), PlvlVal ]);

        % 3) Defuzzify (7f) and round (8)
        scores = [Sgnd, Sclb, Scru, Sdes, Slvl];
        [~, idx] = max(scores);
        phaseIdx = round(idx);
        states(i) = phaseNames{phaseIdx};
    end

    allStates{f} = states;
end

% allStates{f}(i) is the fuzzy-identified phase of sample i in flight f.
