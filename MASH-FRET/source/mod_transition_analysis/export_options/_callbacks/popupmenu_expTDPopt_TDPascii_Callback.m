function popupmenu_expTDPopt_TDPascii_Callback(obj, evd, h_fig)
h = guidata(h_fig);
prm = guidata(h.expTDPopt.figure_expTDPopt);
prm{2}(3) = get(obj, 'Value');
guidata(h.expTDPopt.figure_expTDPopt,prm);
ud_expTDPopt(h_fig);


