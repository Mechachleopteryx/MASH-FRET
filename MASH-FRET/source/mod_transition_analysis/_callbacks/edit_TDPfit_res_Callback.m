function edit_TDPfit_res_Callback(obj, evd, h_fig)
h = guidata(h_fig);
p = h.param.TDP;
if ~isempty(p.proj)
    updateFields(h_fig, 'TDP');
end