%% Fuzzy Membership Functions according to my definitions
%   H_gnd(η) = Z(η,0,200)
%   H_lo(η)  = G(η,10000,10000)
%   H_hi(η)  = G(η,35000,20000)
%   RoC0(τ)  = G(τ,0,100)
%   RoC+(τ)  = S(τ,10,1000)
%   RoC–(τ)  = Z(τ,–1000,–10)
%   V_lo(v)  = G(v,0,50)
%   V_mid(v) = G(v,300,100)
%   V_hi(v)  = G(v,600,100)
%   P_gnd(p)= G(p,1,0.2)
%   P_clb(p)= G(p,2,0.2)
%   P_cru(p)= G(p,3,0.2)
%   P_des(p)= G(p,4,0.2)
%   P_lvl(p)= G(p,5,0.2)

% 1) Define the continuous axes
eta = linspace(0,40000,401);      % altitude in feet
tau = linspace(-4000,4000,801);   % rate of climb in ft/min
v   = linspace(0,700,701);        % speed in knots
p   = linspace(0,6,601);          % phase axis (0 to 6)

% 2) Compute each membership function
H_gnd = zmf(eta, [30 150]);               % Z(η,0,200)
H_lo  = gaussmf(eta, [10000 10000]);     % G(η,10000,10000)
H_hi  = gaussmf(eta, [20000 35000]);     % G(η,35000,20000)

RoC0 = gaussmf(tau,[100 0]);             % G(τ,0,100)
RoCp = smf(tau, [10 1000]);              % S(τ,10,1000)
RoCm = zmf(tau,[-1000 -10]);             % Z(τ,–1000,–10)

V_lo  = gaussmf(v,[50 0]);               % G(v,0,50)
V_mid = gaussmf(v,[100 300]);            % G(v,300,100)
V_hi  = gaussmf(v,[100 600]);            % G(v,600,100)

P_gnd = gaussmf(p,[0.2 1]);              % G(p,1,0.2)
P_clb = gaussmf(p,[0.2 2]);              % G(p,2,0.2)
P_cru = gaussmf(p,[0.2 3]);              % G(p,3,0.2)
P_des = gaussmf(p,[0.2 4]);              % G(p,4,0.2)
P_lvl = gaussmf(p,[0.2 5]);              % G(p,5,0.2)

% 3) Plot the four‑panel figure
figure;

% --- Altitude ---
subplot(4,1,1);
plot(eta, H_gnd, 'k-', 'LineWidth',2); hold on;
plot(eta, H_lo,  'k--','LineWidth',2);
plot(eta, H_hi,  'k:','LineWidth',2);
grid on;
xlabel('Altitude (ft)');
ylabel('Membership μ');
title('Altitude');
legend('Ground','Low','High','Location','Best');

% --- RoC ---
subplot(4,1,2);
plot(tau, RoC0, 'k-', 'LineWidth',2); hold on;
plot(tau, RoCp, 'k--','LineWidth',2);
plot(tau, RoCm, 'k:','LineWidth',2);
grid on;
xlabel('RoC (ft/min)'); 
ylabel('Membership μ');
title('RoC');
legend('Zero','Positive','Negative','Location','Best');

% --- Speed ---
subplot(4,1,3);
plot(v, V_hi,  'k-', 'LineWidth',2); hold on;
plot(v, V_mid, 'k--','LineWidth',2);
plot(v, V_lo,  'k:','LineWidth',2);
grid on;xlabel('Speed (kt)'); ylabel('Membership μ');
title('Speed');
legend('High','Medium','Low','Location','Best');

% --- Phase ---
%subplot(4,1,4);
% Plot discrete markers at integer phase points
%phases = 1:5;
%plot(phases, P_gnd(phases*100), 'ks','MarkerSize',8,'LineWidth',2); hold on;
%plot(phases, P_clb(phases*100), 'k^','MarkerSize',8,'LineWidth',2);
%plot(phases, P_des(phases*100), 'kv','MarkerSize',8,'LineWidth',2);
%plot(phases, P_cru(phases*100), 'kx','MarkerSize',8,'LineWidth',2);
%plot(phases, P_lvl(phases*100), 'ko','MarkerSize',8,'LineWidth',2);

%grid on;xlim([0.5 5.5]); ylim([0 1.2]);
%set(gca, 'XTick', phases, 'XTickLabel',{'Ground','Climb','Descent','Cruise','Level flight'});xlabel('Phase'); ylabel('Membership μ');
%title('Phase');
