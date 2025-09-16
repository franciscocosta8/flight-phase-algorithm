%% Gathers GoAround data from dailySummaries
idxN = [];
idxI = [];
allF = {};
tic
% for may turn cell
%ComputeDistances_dailySummaries=ComputeDistances_dailySummaries.';
for n = 1:numel(ComputeDistances_dailySummaries)
    FP  = ComputeDistances_dailySummaries{1,n}.flightPhases;
    ops = lower(string({FP.overallPhase}));
    inRW = (([FP.everInRunway1] | [FP.everInRunway2]) == 1);
    mask = contains(ops,"goaround") & inRW;
    ii = find(mask);
    for t = 1:numel(ii)
        alt = ComputeDistances_dailySummaries{1,n}.flightPhases(ii(t)).altitude;
        if ~isempty(alt) && ~any(alt < 1400)
            idxN(end+1,1) = n;
            idxI(end+1,1) = ii(t);
            allF = union(allF, fieldnames(FP(ii(t)))', 'stable');
        end
    end
end

if isempty(idxN)
    GoAroundsData = struct([]);
else
    tmpl = cell2struct(repmat({[]},1,numel(allF)), allF, 2);
    GoAroundsData = repmat(tmpl, numel(idxN), 1);
    for r = 1:numel(idxN)
        n = idxN(r); i = idxI(r);
        f = fieldnames(ComputeDistances_dailySummaries{1,n}.flightPhases(i))';
        for j = 1:numel(f)
            GoAroundsData(r).(f{j}) = ComputeDistances_dailySummaries{1,n}.flightPhases(i).(f{j});
        end
    end
end
toc
%% Plots some Go-Arounds plus Distance between them
i = 46; % number of flight in GoAroundsData
tickFS = 18;
labelFS = 20;
titleFS = 22;
legendFS = 16;

for ii = 1:numel(GoAroundsData(i).CompareRuns) % Aircraft that interacted 
    CR = GoAroundsData(i).CompareRuns(ii);
    t  = CR.common_times(:);
    ai = CR.altitude_i(:);
    aj = CR.altitude_j(:);
    dist_nm = CR.distance3D_m(:);

    n = min([numel(t), numel(ai), numel(aj), numel(dist_nm)]);
    t = t(1:n); ai = ai(1:n); aj = aj(1:n); dist_nm = dist_nm(1:n);
    v = isfinite(dist_nm) & isfinite(ai) & isfinite(aj) & isfinite(t);
    t = t(v); ai = ai(v); aj = aj(v); dist_nm = dist_nm(v);

    acType_i = GoAroundsData(i).aircraft;
    acType_j = CR.acType_j;

    s_i = upper(string(CR.WakeTurbulence_i));
    if s_i == "SUPER_HEAVY"
        wt_i = 'Super Heavy';
    elseif s_i == "UPPER_HEAVY"
        wt_i = 'Upper Heavy';
    elseif s_i == "LOWER_HEAVY"
        wt_i = 'Lower Heavy';
    elseif s_i == "UPPER_MEDIUM"
        wt_i = 'Upper Medium';
    elseif s_i == "LOWER_MEDIUM"
        wt_i = 'Lower Medium';
    elseif s_i == "LIGHT"
        wt_i = 'Light';
    else
        wt_i = char(strrep(string(CR.WakeTurbulence_i),'_',' '));
    end

    s_j = upper(string(CR.WakeTurbulence_j));
    if s_j == "SUPER_HEAVY"
        wt_j = 'Super Heavy';
    elseif s_j == "UPPER_HEAVY"
        wt_j = 'Upper Heavy';
    elseif s_j == "LOWER_HEAVY"
        wt_j = 'Lower Heavy';
    elseif s_j == "UPPER_MEDIUM"
        wt_j = 'Upper Medium';
    elseif s_j == "LOWER_MEDIUM"
        wt_j = 'Lower Medium';
    elseif s_j == "LIGHT"
        wt_j = 'Light';
    else
        wt_j = char(strrep(string(CR.WakeTurbulence_j),'_',' '));
    end
    
    req_GA_behind_Other = getWakeSepDistance(s_j, s_i);
    req_Other_behind_GA = getWakeSepDistance(s_i, s_j);

    fig = figure('Units','pixels','Position',[100 100 1600 800],'Color','w');
    ax  = axes('Parent',fig);
    axes(ax); hold on; grid on; ax.Box = 'on';
    ax.FontSize = tickFS;

    yyaxis left
    plot(t, ai, 'LineWidth', 1.5);
    plot(t, aj, 'LineWidth', 1.5);
    ylabel('Altitude (ft)','FontSize',labelFS);

    yyaxis right
    plot(t, dist_nm, 'LineWidth', 1.5);
    ylabel('3D separation (NM)','FontSize',labelFS);

    yline(req_GA_behind_Other, '--', sprintf('GA behind Other: %.0f NM', req_GA_behind_Other), ...
        'Color', [1 0.6 0.6], 'LineWidth', 1.2, 'LabelHorizontalAlignment', 'left');
    yline(req_Other_behind_GA, ':', sprintf('Other behind GA: %.0f NM', req_Other_behind_GA), ...
        'Color', [1 0.6 0.6], 'LineWidth', 1.2, 'LabelHorizontalAlignment', 'right');

    xlabel('Time','FontSize',labelFS);
    if isdatetime(t), ax.XAxis.TickLabelFormat = 'HH:mm:ss'; end
    title('Altitude and 3D Separation','FontSize',titleFS);
    legend({sprintf('GA aircraft altitude (%s, WT:%s)', char(string(acType_i)), wt_i), ...
            sprintf('Other aircraft altitude (%s, WT:%s)', char(string(acType_j)), wt_j), ...
            '3D separation (NM)'}, 'Location','best','FontSize',legendFS);
end




%% Plots Local of Go-Around start
M   = numel(GoAroundsData);
lat = nan(M,1); lon = nan(M,1); cs = strings(M,1);

for r = 1:M
    g = GoAroundsData(r);
    k = [];
    if isfield(g,'goAroundLat') && isfield(g,'goAroundLon') && ~isempty(g.goAroundLat) && ~isempty(g.goAroundLon)
        lat(r) = g.goAroundLat; lon(r) = g.goAroundLon;
    elseif isfield(g,'goAroundTIME') && isfield(g,'time') && isfield(g,'latitude') && isfield(g,'longitude')
        dt = g.goAroundTIME; tv = g.time;
        if ~isempty(tv)
            k = find(tv==dt,1); if isempty(k), [~,k] = min(abs(tv - dt)); end
            lat(r) = g.latitude(k); lon(r) = g.longitude(k);
        end
    end
    if isfield(g,'callsign') && ~isempty(g.callsign)
        if isstring(g.callsign) || ischar(g.callsign)
            cs(r) = string(g.callsign);
        elseif iscell(g.callsign)
            if ~isempty(k) && k<=numel(g.callsign), cs(r) = string(g.callsign{k});
            else, cs(r) = string(g.callsign{1});
            end
        else
            cs(r) = string(g.callsign);
        end
    else
        cs(r) = "N/A";
    end
end

mask = isfinite(lat) & isfinite(lon);
lat = lat(mask); lon = lon(mask); cs = cs(mask);

fig = figure('Units','pixels','Position',[100 100 1200 600]);
gx  = geoaxes('Parent',fig); hold(gx,'on'); geobasemap(gx,'topographic');
s = geoscatter(gx, lat, lon, 36, 'filled', 'MarkerFaceColor','r', 'MarkerEdgeColor','k');
gx.FontSize = 16;

if exist('eddmCenter','var') && numel(eddmCenter)>=2
    geoscatter(gx, eddmCenter(1), eddmCenter(2), 80, 'p', 'filled', 'MarkerEdgeColor','k');
    legend(gx, {'Go-around start','Airport'}, 'Location','best');
else
    legend(gx, {'Go-around start'}, 'Location','best');
end

latrng = [min(lat) max(lat)]; lonrng = [min(lon) max(lon)];
dlat = max(0.01, 0.05*diff(latrng)); dlon = max(0.02, 0.05*diff(lonrng));
geolimits(gx, [latrng(1)-dlat, latrng(2)+dlat], [lonrng(1)-dlon, lonrng(2)+dlon]);

title(gx, sprintf('Go-Around Start Locations May 2024', numel(lat)), 'FontSize', 20)

row = dataTipTextRow('Callsign', cs);
s.DataTipTemplate.DataTipRows(end+1) = row;
%%
%set(gcf,'Units','pixels','Position',[100 100 1200 600])
%exportgraphics(gcf,'C:\Users\franc\Desktop\gráficos - tese\goaround_location_may_errors3.png','Resolution',300,'BackgroundColor','white')


% %% Statistic of altitudes of go around start
% alt_june = [GoAroundsData.goAroundAlt].';
% alt_june = alt_june(isfinite(alt_june));
% 
% alt_may = 1000.*[1.8965
% 1.5847
% 3.1668
% 2.4190
% 2.2152
% 2.6424
% 2.0131
% 2.3599
% 3.4407
% 2.3229
% 2.7540
% 2.9067
% 2.8080
% 3.4501
% 2.0514
% 2.5325
% 1.7542
% 3.4039
% 1.8174
% 1.6495
% 2.8076
% 1.5377
% 2.0191
% 2.4092
% 2.3288
% 2.4558
% 2.4744
% 1.6048
% 2.8996
% 1.6654
% 1.5618
% 1.6826
% 1.9275
% 2.0071
% 1.7887
% 2.4565
% 3.1704
% 2.8167
% 2.9295
% 2.7952
% 2.9948
% 1.5738
% 3.2836
% 2.3105
% 1.9334
% 2.1426
% 1.6521
% 1.6620
% 2.3993
% 1.5938
% 2.0770
% 2.2994
% 1.7527
% 2.0021
% 1.6584
% 1.7510
% 1.8560
% 1.5980
% 2.2559
% 1.6797
% 1.5324
% 1.5704
% 1.4956
% 1.9562
% 2.0138
% 2.0905
% 1.5840
% 1.5947
% 2.8537
% 2.4143
% 2.1507];
% alt_may = alt_may(isfinite(alt_may));
% 
% mu = [mean(alt_may), mean(alt_june), mean([alt_may;alt_june])];
% n  = [numel(alt_may), numel(alt_june), numel([alt_may;alt_june])];
% 
% tickFS=18; labelFS=20; titleFS=22; legendFS=16;
% 
% fig = figure('Units','pixels','Position',[100 100 900 600],'Color','w');
% ax  = axes('Parent',fig); hold(ax,'on'); grid(ax,'on'); ax.Box='on'; ax.FontSize=tickFS;
% 
% b = bar(ax, mu, 0.6);
% xticklabels(ax, {'May','June','Total'});
% ylabel(ax,'Mean go-around start altitude [ft]','FontSize',labelFS);
% title(ax,'Go-around start altitude (mean)','FontSize',titleFS);
% 
% yl = ylim(ax);
% for k=1:numel(mu)
%     text(k, mu(k), sprintf('%.0f ft\n(n=%d)', mu(k), n(k)), ...
%         'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',legendFS);
% end
% ylim(ax, [0, max(yl(2), max(mu)*1.15)]);

% exportgraphics(fig,'C:\Users\franc\Desktop\gráficos - tese\goaround_startaltitudes_barras.png','Resolution',300,'BackgroundColor','white');

%%
% alt = [GoAroundsData.goAroundAlt].';
% alt = alt(isfinite(alt));
% 
% fig2 = figure('Units','pixels','Position',[100 100 600 600]);
% ax  = axes('Parent',fig2); hold(ax,'on'); grid(ax,'on'); box(ax,'on');
% 
% boxchart(ones(numel(alt),1), alt);
% xlim(ax,[0.5 1.5]); xticks(ax,1); xticklabels(ax,["Altitudes"]);
% ylabel(ax,'Go-around start altitude [ft]','FontSize',16);
% title(ax,sprintf('Distribution Go-Around start Altitudes - June 2024', numel(alt)),'FontSize',19);
% 
% set(gcf,'Units','pixels','Position',[100 100 1200 600])
% %exportgraphics(gcf,'C:\Users\franc\Desktop\gráficos - tese\goaround_startaltitudes.png','Resolution',300,'BackgroundColor','white')

