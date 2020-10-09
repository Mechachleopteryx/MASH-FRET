function edit_TDPfit_decUp_Callback(obj, evd, h_fig)
h = guidata(h_fig);
p = h.param.TDP;
if ~isempty(p.proj)
    val = str2num(get(obj, 'String'));
    set(obj, 'String', num2str(val));
    if ~(numel(val)==1 && ~isnan(val) && val >= 0)
        set(obj, 'BackgroundColor', [1 0.75 0.75]);
        setContPan('Exp. time decay must be >= 0', 'error', h_fig);
        return;
    else
        proj = p.curr_proj;
        tpe = p.curr_type(proj);
        prm = p.proj{proj}.prm{tpe};
        trs = prm.clst_start{1}(4);
        strch = prm.kin_start{trs,1}(1);
        if strch
            n = 1;
        else
            n = p.proj{proj}.prm{tpe}.kin_start{trs,1}(3);
        end
        p.proj{proj}.prm{tpe}.kin_start{trs,2}(n,6) = val;
        h.param.TDP = p;
        guidata(h_fig, h);
        updateFields(h_fig, 'TDP');
    end
end