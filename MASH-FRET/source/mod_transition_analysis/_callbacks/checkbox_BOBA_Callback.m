function checkbox_BOBA_Callback(obj, evd, h_fig)
h = guidata(h_fig);
p = h.param.TDP;
if ~isempty(p.proj)
    proj = p.curr_proj;
    tpe = p.curr_type(proj);
    tag = p.curr_tag(proj);
    trs = p.proj{proj}.prm{tag,tpe}.clst_start{1}(4);
    p.proj{proj}.prm{tag,tpe}.kin_start{trs,1}(4) = get(obj, 'Value');
    h.param.TDP = p;
    guidata(h_fig, h);
    updateFields(h_fig, 'TDP');
end