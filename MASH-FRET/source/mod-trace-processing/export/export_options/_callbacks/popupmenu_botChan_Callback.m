function popupmenu_botChan_Callback(obj, evd, h_fig)
val = get(obj, 'Value');
h = guidata(h_fig);
h.param.ttPr.proj{h.param.ttPr.curr_proj}.exp.fig{2}{2}(2) = val;
guidata(h_fig, h);
ud_optExpTr('fig', h_fig);


