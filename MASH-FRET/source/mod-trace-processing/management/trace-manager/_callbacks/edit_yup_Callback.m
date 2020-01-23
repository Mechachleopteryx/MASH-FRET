function edit_yup_Callback(obj,evd,h_fig)

% Last update: by MH, 21.1.2020
% >> calculate histogram at plot & adapt to new data format

h = guidata(h_fig);

dat1 = get(h.tm.axes_ovrAll_1,'userdata');
dat3 = get(h.tm.axes_histSort,'userdata');
indx = get(h.tm.popupmenu_selectXdata,'value');
jx = get(h.tm.popupmenu_selectXval,'value')-1;
indy = get(h.tm.popupmenu_selectYdata,'value')-1;
jy = get(h.tm.popupmenu_selectYval,'value')-1;
isTDP = (indx==indy & jx==9 & jy==9);

if indy==0 || isTDP
    return
end

if jy==0
    ylim_low = dat1.lim(indy,1);
else
    ylim_low = dat3.lim(indy,1,jy);
end

ylim_sup = str2num(get(obj,'String'));

if ~(numel(ylim_sup)==1 && ~isnan(ylim_sup) && ~isinf(ylim_sup) && ...
        ylim_sup>ylim_low)
    setContPan('Higher bound must be higher than lower bound.','error',...
        h_fig);
    return
end

if jy==0
    dat1.lim(indy,2) = ylim_sup;
else
    dat3.lim(indy,2,jy) = ylim_sup;
end

set(h.tm.axes_ovrAll_1, 'UserData', dat1);
set(h.tm.axes_histSort, 'UserData', dat3);

plotData_autoSort(h_fig);
