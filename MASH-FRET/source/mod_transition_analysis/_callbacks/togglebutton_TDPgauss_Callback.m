function togglebutton_TDPgauss_Callback(obj, evd, h_fig)
h = guidata(h_fig);
p = h.param.TDP;
if ~isempty(p.proj)
    proj = p.curr_proj;
    tpe = p.curr_type(proj);
    tag = p.curr_tag(proj);
    p.proj{proj}.prm{tag,tpe}.clst_start{1}(1) = 2;
    h.param.TDP = p;
    guidata(h_fig, h);
    
    % deactivate selection tool if any
    tool = get(h.tooglebutton_TDPmanStart,'userdata');
    if tool>0
        tooglebutton_TDPselect_Callback(obj,evd,h_fig,5);
    end
    
    % reset previous clustering results if exist
    pushbutton_TDPresetClust_Callback(h.pushbutton_TDPresetClust,[],h_fig);
end