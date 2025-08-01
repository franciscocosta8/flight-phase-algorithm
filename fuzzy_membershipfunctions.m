cfg=config();
% 1) Define the continuous axes
eta = cfg.eta;      % altitude in feet
tau = cfg.tau;   % rate of climb in ft/min
v   = cfg.v;        % speed in knots
p   = cfg.p;          % phase axis (0 to 6)

% 2) Compute each membership function
H_gnd = zmf(eta,    cfg.mf.eta.gnd);
H_lo  = gaussmf(eta, cfg.mf.eta.lo);
H_hi  = gaussmf(eta, cfg.mf.eta.hi);

RoC0 = gaussmf(tau, cfg.mf.tau.roc0);
RoCp = smf(   tau, cfg.mf.tau.rocp);
RoCm = zmf(  tau, cfg.mf.tau.rocm);

% airspeed fuzzy-sets
V_lo  = gaussmf(v, cfg.mf.v.lo);
V_mid = gaussmf(v, cfg.mf.v.mid);
V_hi  = gaussmf(v, cfg.mf.v.hi);

P_gnd = gaussmf(p,[0.2 1]);              % G(p,1,0.2)
P_clb = gaussmf(p,[0.2 2]);              % G(p,2,0.2)
P_cru = gaussmf(p,[0.2 3]);              % G(p,3,0.2)
P_des = gaussmf(p,[0.2 4]);              % G(p,4,0.2)
P_lvl = gaussmf(p,[0.2 5]);              % G(p,5,0.2)

% Choose colour palettes
cols3 = lines(3);          % three distinct colours, good for triplets
cols5 = parula(5);         % five‐colour palette, for phases or larger sets

% Parameters: width, height (in inches) and resolution (dpi)
W = 14;   % width in inches
H = 4;   % height in inches
R = 300; % resolution in dpi

%% --- Altitude ---
fig1 = figure('Units','inches','Position',[1 1 W H], ...
              'PaperUnits','inches','PaperPosition',[0 0 W H]);
set(fig1,'Color','white');
set(groot, ...
    'defaultAxesColorOrder',cols3, ...
    'defaultAxesLineStyleOrder','-|--|:');
plot(eta, H_gnd,  'LineWidth',2); hold on;
plot(eta, H_lo,   'LineWidth',2);
plot(eta, H_hi,   'LineWidth',2);
axis normal;        % ensure rectangular axes
grid on;
xlabel('Altitude (ft)','FontSize',12);
ylabel('Membership \mu','FontSize',12);
%title('Fuzzy set – Altitude','FontWeight','bold');
legend('Ground','Low','High','Location','Best');
print(fig1,'-dpng',sprintf('-r%d',R),'fuzzyset_altitude.png');


%% --- Rate of Climb ---
fig2 = figure('Units','inches','Position',[1 1 W H], ...
              'PaperUnits','inches','PaperPosition',[0 0 W H]);
set(fig2,'Color','white');
set(groot, ...
    'defaultAxesColorOrder',cols3, ...
    'defaultAxesLineStyleOrder','-|--|:');
plot(tau, RoC0, 'LineWidth',2); hold on;
plot(tau, RoCp, 'LineWidth',2);
plot(tau, RoCm, 'LineWidth',2);
axis normal;
grid on;
xlabel('RoC (ft/min)','FontSize',20);
ylabel('Membership \mu','FontSize',20);
%title('Fuzzy set – Rate of Climb','FontWeight','bold');
legend('Zero','Positive','Negative','Location','Best');
print(fig2,'-dpng',sprintf('-r%d',R),'fuzzyset_rateofclimb.png');


%% --- Ground Speed ---
fig3 = figure('Units','inches','Position',[1 1 W H], ...
              'PaperUnits','inches','PaperPosition',[0 0 W H]);
set(fig3,'Color','white');
% Reverse so that High→warm, Medium→neutral, Low→cool
plot(v, V_hi,  'Color',cols3(2,:),'LineWidth',2); hold on;
plot(v, V_mid, 'Color',cols3(1,:),'LineWidth',2);
plot(v, V_lo,  'Color',cols3(3,:),'LineWidth',2);
axis normal;
grid on;
xlabel('Ground Speed (kt)','FontSize',20);
ylabel('Membership \mu','FontSize',20);
%title('Fuzzy set – Ground Speed','FontWeight','bold');
legend('High','Medium','Low','Location','Best');
print(fig3,'-dpng',sprintf('-r%d',R),'fuzzyset_groundspeed.png');

%% --- Phase ---
% figure;
% % Use the parula(5) palette for the five discrete phase markers
% phases = 1:5;
% mk = {'s','^','v','x','o'};        % marker types
% for i = 1:5
%     plot(phases(i), ...
%          [P_gnd;P_clb;P_cru;P_des;P_lvl](i), ...
%          mk{i}, ...
%          'MarkerSize',8, ...
%          'LineWidth',2, ...
%          'MarkerFaceColor',cols5(i,:), ...
%          'MarkerEdgeColor','k'); hold on;
% end
% grid on; 
% xlim([0.5 5.5]); ylim([0 1.2]);
% set(gca, 'XTick', phases, ...
%          'XTickLabel',{'Ground','Climb','Cruise','Descent','Level'}, ...
%          'FontSize',10);
% xlabel('Phase','FontSize',12); 
% ylabel('Membership \mu','FontSize',12);
% title('Phase','FontWeight','bold');

