function updateTAplots(h_fig,varargin)
% updateTAplots(h_fig)
% updateTAplots(h_fig,'all')
% updateTAplots(h_fig,'tdp')
% updateTAplots(h_fig,'kin')
%
% Refresh plots in Transition analysis
%
% h_fig: handle to main figure
% 'all': refresh all plots
% 'tdp': refresh TDP plot only
% 'kin': refresh dwell time histogram only

opt = 'all';
if ~isempty(varargin)
    opt = varargin{1};
end

h = guidata(h_fig);
p = h.param.TDP;
if isempty(p.proj)
    cla(h.axes_TDPplot1);
    cla(h.axes_tdp_BIC);
    cla(h.axes_TDPplot2);
    return
end

proj = p.curr_proj;

tag = p.curr_tag(proj);
tpe = p.curr_type(proj);
curr = p.proj{proj}.curr{tag,tpe};
prm = p.proj{proj}.prm{tag,tpe};
curr_k = curr.kin_start{2}(2);

if strcmp(opt,'all') || strcmp(opt,'tdp')
    plotTDP([h.axes_TDPplot1,h.colorbar_TA,h.axes_tdp_BIC], curr, prm);
end
if strcmp(opt,'all') || strcmp(opt,'kin')
    plotKinFit(h.axes_TDPplot2, p, prm, tag, tpe, curr_k,...
        get(h.pushbutton_TDPfit_log, 'String'))
end
