function edit_simRate_Callback(obj, evd, h_fig)

% Last update by MH, 19.12.2019
% >> delete previous state sequences (and associated results) when rate
%  changes

val = str2num(get(obj, 'String'));
set(obj, 'String', num2str(val));
if ~(~isempty(val) && numel(val) == 1 && ~isnan(val) && val > 0)
    set(obj, 'BackgroundColor', [1 0.75 0.75]);
    setContPan('Frame rate must be > 0', 'error', h_fig);
else
    set(obj, 'BackgroundColor', [1 1 1]);
    h = guidata(h_fig);
    h.param.sim.rate = val;
    
    % clear any results to avoid conflict
    if isfield(h,'results') && isfield(h.results,'sim')
        h.results = rmfield(h.results,'sim');
    end
    
    guidata(h_fig, h);
    updateFields(h_fig, 'sim');
end