function radiobutton_saveFig_Callback(obj, evd, h_fig)
val = get(obj, 'Value');
h = guidata(h_fig);
h.param.ttPr.proj{h.param.ttPr.curr_proj}.exp.fig{1}(1) = val;
guidata(h_fig, h);
ud_optExpTr('fig', h_fig);


