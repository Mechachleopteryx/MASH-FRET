function pushbutton_thm_rmProj_Callback(obj, evd, h_fig)

h = guidata(h_fig);
p = h.param.thm;
if isempty(p.proj)
    return
end
    
% collect selected project
slct = get(h.listbox_thm_projLst, 'Value');

% build confirmation message box
if h.mute_actions
    del = 'Yes';
else
    str_proj = ['"' p.proj{slct(1)}.exp_parameters{1,2} '"'];
    for pj = 2:numel(slct)
        str_proj = [str_proj ', "' p.proj{slct(pj)}.exp_parameters{1,2} ...
            '"'];
    end
    del = questdlg(['Remove project ' str_proj ' from the list?'], ...
        'Remove project', 'Yes', 'No', 'No');
end

if ~strcmp(del, 'Yes')
    return
end

% build action
list_str = get(h.listbox_thm_projLst, 'String');
str_act = '';
for i = slct
    str_act = cat(2,str_act,'"',list_str{i},'" (',...
        p.proj{i}.proj_file,')\n');
end
str_act = str_act(1:end-2);

% delete projects and reorganize project and current data 
% structures
p.proj(slct) = [];
p.curr_tpe(slct) = [];
p.curr_tag(slct) = [];

% set new current project
if size(p.proj,2) <= 1
    p.curr_proj = 1;
elseif slct(end) < size(p.proj,2)
    p.curr_proj = slct(end)-numel(slct) + 1;
else
    p.curr_proj = slct(end)-numel(slct);
end

% update project list
p = ud_projLst(p, h.listbox_thm_projLst);
h.param.thm = p;
guidata(h_fig, h);

% clear axes
cla(h.axes_hist1);
cla(h.axes_hist2);

% update calculations and GUI
updateFields(h_fig, 'thm');

% display action
if numel(slct)>1
    str_act = cat(2,'Project has been sucessfully removed form ',...
        'the list: ',str_act);
else
    str_act = cat(2,'Projects have been sucessfully removed form ',...
        'the list:\n',str_act);
end
setContPan(str_act,'none',h_fig);
