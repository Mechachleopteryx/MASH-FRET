function edit_TDPnSpl_Callback(obj, evd, h_fig)
h = guidata(h_fig);
p = h.param.TDP;
if ~isempty(p.proj)
    val = round(str2num(get(obj, 'String')));
    set(obj, 'String', num2str(val));
    if ~(numel(val)==1 && ~isnan(val) && val > 0)
        set(obj, 'BackgroundColor', [1 0.75 0.75]);
        setContPan('The number of samples must be > 0', 'error', ...
            h_fig);
    else
        proj = p.curr_proj;
        tpe = p.curr_type(proj);
        p.proj{proj}.prm{tpe}.clst_start{1}(7) = val;
        h.param.TDP = p;
        guidata(h_fig, h);
        updateFields(h_fig, 'TDP');
    end
end