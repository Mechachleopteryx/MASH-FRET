function ud_clustersPan(h_fig)
% Set cluster panel to proper values

% defaults
ttstr0{1} = {'<html><b>Square</b>-shaped clusters</html>', ...
    '<html><b>Isotropic Gaussian</b>-shaped clusters</html>', ...
    '<html><b>Square</b>-shaped clusters</html>'};
ttstr0{2} = {'<html><b>Straight ellipse</b>-shaped clusters</html>', ...
    '<html><b>Straight multivariate Gaussian</b>-shaped clusters</html>', ...
    '<html><b>Straight ellipse</b>-shaped clusters</html>'};
ttstr0{3} = {'<html><b>Diagonal ellipse</b>-shaped clusters</html>', ...
    '<html><b>Diagonal multivariate Gaussian</b>-shaped clusters</html>', ...
    '<html><b>Diagonal ellipse</b>-shaped clusters</html>'};
ttstr0{4} = {'', ...
    '<html><b>Free rotating multivariate Gaussian</b>-shaped clusters</html>', ...
    ''};

% collect interface parameters
h = guidata(h_fig);
p = h.param.TDP;
proj = p.curr_proj;
tpe = p.curr_type(proj);
tag = p.curr_tag(proj);

% collect processing parameters
curr = p.proj{proj}.curr{tag,tpe};
meth = curr.clst_start{1}(1);
shape = curr.clst_start{1}(2);
Jmax = curr.clst_start{1}(3);
mat = curr.clst_start{1}(4);
logl = curr.clst_start{1}(10);
trs_k = curr.clst_start{2};

% set all controls visible and enabled
set([h.text_TDPlike h.popupmenu_TDPlike h.text_TDPstate ...
    h.popupmenu_TDPstate h.text_TDPshape h.text_TDPiniVal h.text_TDPradius ...
    h.edit_TDPiniValX h.edit_TDPiniValY h.pushbutton_TDPautoStart ...
    h.edit_TDPradiusX h.edit_TDPradiusY h.togglebutton_TDPshape1 ...
    h.togglebutton_TDPshape2 h.togglebutton_TDPshape3 ...
    h.togglebutton_TDPshape4 h.tooglebutton_TDPmanStart ...
    h.pushbutton_TDPupdateClust],'Enable','on', 'Visible','on');
setProp(h.uipanel_TA_selectTool,'enable','on');

% reset edit field background color
set([h.edit_TDPiniValX h.edit_TDPradiusX h.edit_TDPiniValY ...
    h.edit_TDPradiusY], 'BackgroundColor', [1 1 1]);

% set button for switching pointer
tool = get(h.tooglebutton_TDPmanStart,'userdata');
if tool==2 % selection mode
    set(h.tooglebutton_TDPmanStart,'cdata',...
        get(h.tooglebutton_TDPselectCross,'cdata'));
else
    set(h.tooglebutton_TDPmanStart,'cdata',...
        get(h.tooglebutton_TDPselectZoom,'cdata'));
end

% close selection tool panel
set(h.uipanel_TA_selectTool,'visible','off');
set(h.tooglebutton_TDPmanStart,'value',0);

% update selection buttons
h_tb = [h.togglebutton_TDPshape1,h.togglebutton_TDPshape2,...
    h.togglebutton_TDPshape3,h.togglebutton_TDPshape4];
img = get(h_tb(1),'userdata');
set(h_tb(1), 'Cdata', img{meth});
set(h_tb(shape),'value',1);
set(h_tb((1:size(h_tb,2))~=shape),'value',0);
for tb = 1:size(h_tb,2)
    set(h_tb(tb),'tooltipstring',ttstr0{tb}{meth});
end

% set starting parameters
switch meth 
    case 1 % kmean clustering
        set([h.text_TDPlike,h.popupmenu_TDPlike,h_tb(4)],'Visible','off',...
            'Enable','off');
        
        if mat
            set(h.text_TDPstate, 'String', 'state');
            set([h.edit_TDPiniValY h.edit_TDPradiusY], 'Enable', 'off');
        else
            set(h.text_TDPstate, 'String', 'cluster');
        end

        k = get(h.popupmenu_TDPstate, 'Value');
        if k>Jmax
            k = Jmax;
        end
        set(h.popupmenu_TDPstate, 'Value', k, 'String', ...
            cellstr(num2str((1:Jmax)')));

        set(h.edit_TDPiniValX, 'String', num2str(trs_k(k,1)));
        set(h.edit_TDPradiusX, 'String', num2str(trs_k(k,3)));
        if mat
            set(h.edit_TDPiniValY, 'String', '');
            set(h.edit_TDPradiusY, 'String', '');
        else
            set(h.edit_TDPiniValY, 'String', num2str(trs_k(k,2)));
            set(h.edit_TDPradiusY, 'String', num2str(trs_k(k,4)));
        end
        
        ud_selectToolPan(h_fig);
    
    case 2 % GMM-based clustering
        set([h.text_TDPstate,h.popupmenu_TDPstate,h.text_TDPiniVal,...
            h.text_TDPradius,h.edit_TDPiniValX,h.edit_TDPradiusX,...
            h.edit_TDPiniValY,h.edit_TDPradiusY,h.pushbutton_TDPautoStart,...
            h.tooglebutton_TDPmanStart],'Visible','off','Enable','off');

        set(h.popupmenu_TDPlike,'value',logl);

    case 3 % manual
        set([h.text_TDPlike,h.popupmenu_TDPlike],'Visible','off','Enable',...
            'off');
        
        set(h.text_TDPstate, 'String', 'cluster');
        
        k = get(h.popupmenu_TDPstate, 'Value');
        if k>Jmax
            k = Jmax;
        end
        set(h.popupmenu_TDPstate, 'Value', k, 'String', ...
            cellstr(num2str((1:Jmax)')));

        set(h.edit_TDPiniValX, 'String', num2str(trs_k(k,1)));
        set(h.edit_TDPradiusX, 'String', num2str(trs_k(k,3)));
        set(h.edit_TDPiniValY, 'String', num2str(trs_k(k,2)));
        set(h.edit_TDPradiusY, 'String', num2str(trs_k(k,4)));

        ud_selectToolPan(h_fig);
end
