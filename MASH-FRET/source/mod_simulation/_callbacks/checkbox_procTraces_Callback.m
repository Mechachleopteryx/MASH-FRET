function checkbox_procTraces_Callback(obj, evd, h_fig)
h = guidata(h_fig);
h.param.sim.export_procTraces = get(obj, 'Value');
guidata(h_fig, h);
updateFields(h_fig, 'sim');