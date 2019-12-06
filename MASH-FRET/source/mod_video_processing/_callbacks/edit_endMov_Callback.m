function edit_endMov_Callback(obj, evd, h_fig)
val = round(str2num(get(obj, 'String')));
h = guidata(h_fig);
start = h.param.movPr.mov_start;
tot = h.movie.framesTot;
set(obj, 'String', num2str(val));
if ~(~isempty(val) && numel(val) == 1 && ~isnan(val) && val >= start && ...
        val <= tot)
    set(obj, 'BackgroundColor', [1 0.75 0.75]);
    updateActPan(['Ending frame must be >= starting frame and <= ' ...
        'frame length.'], h_fig, 'error');
else
    set(obj, 'BackgroundColor', [1 1 1]);
    h.param.movPr.mov_end = val;
    guidata(h_fig, h);
end