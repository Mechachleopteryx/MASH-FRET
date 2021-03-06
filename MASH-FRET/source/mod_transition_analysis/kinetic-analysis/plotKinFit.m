function plotKinFit(h_axes,p,prm,tag,tpe,curr_k,scl)

% default
markhist = '+';
lwhist = 5;
clrfit = 'r';
lwfit = 2;
stboba = '--';
clrboba = [1 0 0];
lwboba = 1.5;
ttl = 'Kinetic analysis from dwell-times';
xlbl = 'dwell-times (s)';
ylbl = 'normalised (1 - cum(P))';

% get y-axis scale
if strcmp(scl, 'y-log scale')
    scl = 'linear';
elseif strcmp(scl, 'y-linear scale')
    scl = 'log';
else
    scl = 'linear';
end

% clear axes and make visible
set(h_axes, 'Visible', 'off');
cla(h_axes);

if ~(isfield(prm,'clst_res') && ~isempty(prm.clst_res{1}))
    return
end

set(h_axes, 'Visible', 'on');

% get reference histogram
J = prm.kin_start{2}(1);
mat = prm.clst_start{1}(4);
clstDiag = prm.clst_start{1}(9);
clst = prm.clst_res{1}.clusters{J};
wght = prm.kin_start{1}{curr_k,1}(7);
excl = prm.kin_start{1}{curr_k,1}(8);
rearr = prm.kin_start{1}{curr_k,1}(9);
% re-arrange state sequences by cancelling transitions belonging to diagonal clusters
if rearr
    [mols,o,o] = unique(clst(:,4));
    dat_new = [];
    for m = mols'
        dat_m = clst(clst(:,4)==m,:);
        if isempty(dat_m)
            continue
        end
        dat_m = adjustDt(dat_m);
        if size(dat_m,1)==1
            continue
        end
        dat_new = cat(1,dat_new,dat_m);
    end
    clst = dat_new;
end
[j1,j2] = getStatesFromTransIndexes(curr_k,J,mat,clstDiag);
hist_ref = getDtHist(clst, [j1,j2], [], excl, wght);

if isempty(hist_ref)
    return
end

% collect interface parameters
proj = p.curr_proj;

% collect processing parameters and results
def = p.proj{proj}.def{tag,tpe};
kin_res = prm.kin_res(curr_k,:);
boba = prm.kin_start{1}{curr_k,1}(4);
strch = prm.kin_start{1}{curr_k,1}(1);

% plot histogram
x_data = hist_ref(hist_ref(:,end)>0,1);
y_data = hist_ref(hist_ref(:,end)>0,end);
plot(h_axes, x_data, y_data, markhist, 'linewidth', lwhist);
grid(h_axes, 'on');

if isempty(x_data)
    x_lim = [0,1];
elseif x_data(1)==x_data(end)
    x_lim = x_data(1)+[-1,1];
else
    x_lim = x_data([1,end])';
end
y_min = min(y_data);
y_max = max(y_data);
if isempty(y_data)
    y_lim = [0,1];
elseif y_min==y_max
    y_lim = y_min+[-1,1];
else
    y_lim = [y_min,y_max];
end

if isequal(kin_res,def.kin_res)
    set(h_axes,'Visible','on','YScale',scl);
    title(h_axes, ttl);
    xlim(h_axes,x_lim);
    ylim(h_axes,y_lim);
    xlabel(h_axes, xlbl);
    ylabel(h_axes, ylbl);
    return
end

set(h_axes, 'NextPlot', 'add');

% plot fits for reference and bootstrapped data
nExp = size(kin_res{2},1);

if strch % stretched exponential fit
    if boba
        A = kin_res{1}(1);
        tau = kin_res{1}(3);
        beta = kin_res{1}(5);
    else
        A = kin_res{2}(1);
        tau = kin_res{2}(2);
        beta = kin_res{2}(3);
    end

    plot_ref = A*exp(-(x_data/tau).^beta);
    
    plot(h_axes, x_data, plot_ref, clrfit, 'linewidth', lwfit);
    
    if boba
        A_inf = kin_res{3}(1);
        tau_inf = kin_res{3}(2);
        beta_inf = kin_res{3}(3);

        A_sup = kin_res{4}(1);
        tau_sup = kin_res{4}(2);
        beta_sup = kin_res{4}(3);

        plot_inf = A_inf*exp(-(x_data/tau_inf).^beta_inf);
        plot_sup = A_sup*exp(-(x_data/tau_sup).^beta_sup);
        
        plot(h_axes, x_data, plot_inf, stboba, 'Color', clrboba, ...
            'Linewidth', lwboba);
        plot(h_axes, x_data, plot_sup, stboba, 'Color', clrboba, ...
            'Linewidth', lwboba);
        
    end
    
else % single-/multiexponential fit
    plot_ref = zeros(size(x_data));
    if boba
        plot_inf = zeros(size(x_data));
        plot_sup = zeros(size(x_data));
    end

    for i = 1:nExp
        if boba && size(kin_res{1},2)>=4
            A = kin_res{1}(i,1);
            tau = kin_res{1}(i,3);
        else
            A = kin_res{2}(i,1);
            tau = kin_res{2}(i,2);
        end
        
        plot_ref = plot_ref + A*exp(-x_data/tau);
        
        if boba && size(kin_res{1},2)>=4
            A_inf = kin_res{3}(i,1);
            tau_inf = kin_res{3}(i,2);

            A_sup = kin_res{4}(i,1);
            tau_sup = kin_res{4}(i,2);
            
            plot_inf = plot_inf + A_inf*exp(-x_data/tau_inf);
            plot_sup = plot_sup + A_sup*exp(-x_data/tau_sup);
        end        
    end
    
    plot(h_axes, x_data,plot_ref, clrfit, 'linewidth', lwfit);
    if boba && size(kin_res{1},2)>=4
        plot(h_axes, x_data, plot_inf, stboba, 'Color', clrboba, ...
            'Linewidth', lwboba);
        plot(h_axes, x_data, plot_sup, stboba, 'Color', clrboba, ...
            'Linewidth', lwboba);
    end
    
end

title(h_axes, ttl);
xlabel(h_axes, xlbl);
ylabel(h_axes, ylbl);
xlim(h_axes,x_lim);
ylim(h_axes,y_lim);
lim = get(h_axes, 'YLim');

set(h_axes, 'NextPlot', 'replacechildren', 'YLim', [min(y_data) lim(2)], ...
    'YScale', scl);

