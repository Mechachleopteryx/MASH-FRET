function radiobutton_noHist_Callback(obj, evd, h_fig)
val = get(obj, 'Value');
h = guidata(h_fig);
h.param.ttPr.proj{h.param.ttPr.curr_proj}.exp.hist{1}(1) = ~val;
guidata(h_fig, h);
ud_optExpTr('hist', h_fig);


