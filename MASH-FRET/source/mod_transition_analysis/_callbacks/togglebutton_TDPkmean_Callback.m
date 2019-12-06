function togglebutton_TDPkmean_Callback(obj, evd, h_fig)
h = guidata(h_fig);
p = h.param.TDP;
if ~isempty(p.proj)
    proj = p.curr_proj;
    tpe = p.curr_type(proj);
    p.proj{proj}.prm{tpe}.clst_start{1}(1) = 1;
    h.param.TDP = p;
    guidata(h_fig, h);
    set(h.zMenu_target, 'Enable', 'on');
    
    % reset previous clustering results if exist
    pushbutton_TDPresetClust_Callback(h.pushbutton_TDPresetClust,[],h_fig);
end