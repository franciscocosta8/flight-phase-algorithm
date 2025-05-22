%% Flight Phase Identification Pipeline
% Load results and filter invalid flights
load('results.mat');

%% Stage 1 – Filter out invalid flights
validIdx = arrayfun(@(f) isValidFlight(f.callsign, f.airline, f.departure), results);
cleanFlights = results(validIdx);
fprintf("Filtered to %d valid flights.\n", sum(validIdx));

%% Stage 2 – Fuzzy Phase Identification per ADS-B Sample
% Implements fuzzy rules (6a)–(6e) and defuzzifies via (7f)–(8).

voos = input('Intert flight index (ex: 1) or interval (ex: 1:3): ');

% Valida entrada
if isempty(voos)
    disp('No selected flight. Program is not going to show any figure.');
end

cfg=config();
N = numel(cleanFlights);
allStates = cell(1, N);
% Define lineear spaces
eta = cfg.eta;      % altitude in feet
tau = cfg.tau;   % rate of climb in ft/min
v   = cfg.v;        % speed in knots
p   = cfg.p;          % phase axis (0 to 6)

% Precompute phase membership values P(P)
PgndVal = gaussmf(1, [0.2 1]);
PclbVal = gaussmf(2, [0.2 2]);
PcruVal = gaussmf(3, [0.2 3]);
PdesVal = gaussmf(4, [0.2 4]);
PlvlVal = gaussmf(5, [0.2 5]);
PgoaVal = gaussmf(6, [0.2 6]);

% Define input membership functions
H_gnd = @(eta) zmf(eta, [30,   150]);         % Z(η,0,200)
H_lo  = @(eta) gaussmf(eta, [10000,10000]);   % G(η,10000,10000)
H_hi  = @(eta) gaussmf(eta, [20000,35000]);   % G(η,35000,20000)

RoC0 = @(tau) gaussmf(tau, [165,   0]);      % G(τ,0,100)
RoCp = @(tau) smf( tau, [10, 1000]);         % S(τ,10,1000)
RoCm = @(tau) zmf( tau, [-1000, -10]);       % Z(τ,-1000,-10)

V_lo  = @(v) gaussmf(v, [50,   0]);          % G(v,0,50)
V_mid = @(v) gaussmf(v, [100, 300]);         % G(v,300,100)
V_hi  = @(v) gaussmf(v, [100, 600]);         % G(v,600,100)

% Loop over flights
for f=1:N
    T = cleanFlights(f).flightData;
    time = T.time;
    alt = T.h_QNH_Metar;     % altitude (ft) %apply 1600 for test purposes only
    roc = T.h_dot_baro;      % RoC (ft/min)
    gs  = T.gs;              % ground speed (kt)

    validSamples = isfinite(alt) & isfinite(roc) & isfinite(gs);
    time=time(validSamples);
    roc = roc(validSamples);
    alt = alt(validSamples);
    gs  = gs(validSamples);
    
    [keep, removedIdx] = derivative_filter(time, roc, cfg.thr_acc, cfg.tolerance, cfg.cap);
    
    t_removed=time(~keep);
    alt_removed=alt(~keep);
    
    time = time(keep);
    roc  = roc(keep);
    alt  = alt(keep);
    gs   = gs(keep);
    
    n   = numel(alt);
    phaseStates = repmat( FlightPhase.Ground, n, 1 );
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

        Sgnd = min([min([mu_gnd]), PgndVal ]); %', mu_vlo, mu_roc0]' will not work since were turning down mmuch data
        Sclb = min([min([mu_lo, mu_vmid, mu_rocp]), PclbVal ]);
        Scru = min([min([mu_hi, mu_vhi,  mu_roc0]), PcruVal ]);
        Sdes = min([min([mu_lo, mu_vmid, mu_rocm]), PdesVal ]);
        Slvl = min([min([mu_lo, mu_vmid, mu_roc0]), PlvlVal ]);

        % 3) Defuzzify (7f) and round (8)
        scores = [Sgnd, Sclb, Scru, Sdes, Slvl];
        [~, idx] = max(scores);
        phaseStates(i) = FlightPhase(idx);
    end
    allStates{f}=phaseStates;
    labels= FlightPhase.list();     
    allStates_names{f} = labels(phaseStates);

    if ismember(f, voos)
    
        rawStates = allStates_names{f};     
        rawStates = cellstr(rawStates(:));  

        [grp, grpNames] = findgroups(rawStates);
        cmap = cell2mat(values(phase2color, grpNames));
        
        N = min([numel(time), numel(rawStates), numel(grp)]);
        if numel(time) > N
            t   = time(1:N);
            alt = alt(1:N);
            roc = roc(1:N);
            grp = grp(1:N);
        end
    
    
    
        % cria figura e ax1
        hFig = figure('Position',[100 100 1000 500]);
        ax1 = axes('Parent', hFig);
        hold(ax1, 'on');
        
        %  linha de altitude estimada
        %alt_est = interp1(t, alt, t0, 'pchip');
        %plot(ax1, t0, alt_est, '-', 'LineWidth',1.5, ...
        %     'Color',[0 0 0], 'DisplayName','Estimated altitude');
        
        % pontos removidos
        scatter(ax1, t_removed, alt_removed, 36, 'r', 'x', ...
                'DisplayName','Pontos removidos');
        
        %  loop de scatter para cada fase
        for i = 1:numel(grpNames)
            xi = grp == i;
            scatter(ax1, time(xi), alt(xi), 100, ...
                    'Marker', '.', ...
                    'MarkerEdgeColor', cmap(i,:), ...
                    'DisplayName', grpNames{i});
        end
        
        % 4) ajustes finais
        ylabel(ax1, 'Altitude (ft)');
        ylim(ax1, [min(alt)-500, max(alt)+500]);
        datetick(ax1, 'x', 'HH:MM', 'keepticks');
        xlabel(ax1, 'Time');
        title(ax1, sprintf("Flight %s (idx %d)", cleanFlights(k).callsign, f));
        legend(ax1, 'Location', 'eastoutside');
        grid(ax1, 'on');
    end
end
disp('Program finished.')

