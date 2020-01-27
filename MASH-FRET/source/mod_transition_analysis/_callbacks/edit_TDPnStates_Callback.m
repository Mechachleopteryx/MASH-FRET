function edit_TDPnStates_Callback(obj, evd, h_fig)

h = guidata(h_fig);
p = h.param.TDP;
if isempty(p.proj)
    return
end

val = round(str2num(get(obj, 'String')));
set(obj, 'String', num2str(val));
if ~(numel(val)==1 && ~isnan(val) && val > 1)
    set(obj, 'BackgroundColor', [1 0.75 0.75]);
    setContPan('Max. number of states must be > 1', 'error', ...
        h_fig);
    return
end

proj = p.curr_proj;
tpe = p.curr_type(proj);
tag = p.curr_tag(proj);
curr = p.proj{proj}.curr{tag,tpe};
val_prev = curr.clst_start{1}(3);

% update colour list
nClr = size(p.colList,1);
if nClr < val*(val-1)
    p.colList(nClr+1:val*(val-1),:) = ...
        round(rand(val*(val-1)-nClr,3)*100)/100;
end

% update parameters
for s = 1:val
    if val_prev < s
        curr.clst_start{2}(s,:) = curr.clst_start{2}(s-1,:);
    end
end
curr.clst_start{2} = curr.clst_start{2}(1:val,:);

str_clr = get(h.popupmenu_TDPcolour, 'String');
for v = 1:val*(val-1)
    if val_prev*(val_prev-1) < v 
        curr.clst_start{3}(v,:) = p.colList(v,:);
    end
    if v > nClr
        str_clr = [str_clr;sprintf('random %i',v)];
    end
end
curr.clst_start{3} = curr.clst_start{3}(1:val*(val-1),:);
set(h.popupmenu_TDPcolour, 'String', str_clr);

curr.clst_start{1}(3) = val;

% save changes
p.proj{proj}.curr{tag,tpe} = curr;

h.param.TDP = p;
guidata(h_fig, h);

updateFields(h_fig, 'TDP');

