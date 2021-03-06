function h = buildPanelVPintensityIntegration(h,p)
% h = buildPanelVPintensityIntegration(h,p);
%
% Builds "Intensity integration" panel in module "Video processing"
%
% h: structure to update with handles to new UI components and that must contain fields:
%   h.figure_MASH: handle to main figure
%   h.uipanel_VP_intensityIntegration: handle to the panel "Intensity integration"
% p: structure containing default and often-used parameters which must contain fields:
%   p.posun: position units
%   p.fntun: font size units
%   p.fntsz1: regular font size
%   p.mg: margin
%   p.mgpan: top-margin in a titled panel
%   p.wbrd: cumulated pixel width of pushbutton's border
%   p.wbox: box's pixel width in checkboxes
%   p.fntclr1: text color in file/folder fields
%   p.tbl: reference table listing character's pixel dimensions

% Last update by MH, 19.3.2020: increase speed by replacing wrapStrToWidth by wrapHtmlTooltipString
% created by MH, 19.10.2019

% default
hedit0 = 20;
htxt0 = 14;
fact = 5;
wedit1 = 40;
str0 = 'Input video:';
str1 = '...';
str2 = 'Input coordinates:';
str3 = 'Options...';
str4 = 'Integrated pixels:';
str5 = 'mean intensity';
str6 = 'Create & export...';
ttstr0 = wrapHtmlTooltipString('Open browser and <b>select the video file</b> to create intensity-time traces from.');
ttstr1 = wrapHtmlTooltipString('Open browser and <b>select the coordinates file</b> that contains single moelcule coordinates in all channels.');
ttstr2 = wrapHtmlTooltipString('Open <b>import options</b> to configure coordinates import.');
ttstr3 = wrapHtmlTooltipString('<b>Integration area dimensions (in pixels)</b>: defines the size of the square area around the single molecule.');
ttstr4 = wrapHtmlTooltipString('<b>Number of brightest pixels</b> to sum up.');
ttstr5 = wrapHtmlTooltipString('<b>Average intensity</b> over the pixels: intensity-time traces written in files other than the .mash project file are not affected.');
ttstr6 = wrapHtmlTooltipString('Create and <b>export intensity-time traces:</b> opens export options.');

% parents
h_fig = h.figure_MASH;
h_pan = h.uipanel_VP_intensityIntegration;

% dimensions
pospan = get(h_pan,'position');
wtxt0 = getUItextWidth(str2,p.fntun,p.fntsz1,'normal',p.tbl);
wbut0 = getUItextWidth(str1,p.fntun,p.fntsz1,'normal',p.tbl)+p.wbrd;
wbut1 = getUItextWidth(str3,p.fntun,p.fntsz1,'normal',p.tbl)+p.wbrd;
wedit0 = pospan(3)-2*p.mg-3*p.mg/fact-wtxt0-wbut0-wbut1;
wcb0 = getUItextWidth(str5,p.fntun,p.fntsz1,'normal',p.tbl)+p.wbox;
wbut2 = getUItextWidth(str6,p.fntun,p.fntsz1,'normal',p.tbl)+p.wbrd;

% GUI
x = p.mg;
y = pospan(4)-p.mgpan-hedit0+(hedit0-htxt0)/2;

h.text_VP_inputVideo = uicontrol('style','text','parent',h_pan,'units',...
    p.posun,'fontunits',p.fntun,'fontsize',p.fntsz1,'position',...
    [x,y,wtxt0,htxt0],'string',str0,'horizontalalignment','left');

x = x+wtxt0+p.mg/fact;
y = y-(hedit0-htxt0)/2;

h.pushbutton_itg_impMov = uicontrol('style','pushbutton','parent',h_pan,...
    'units',p.posun,'fontunits',p.fntun,'fontsize',p.fntsz1,'position',...
    [x,y,wbut0,hedit0],'string',str1,'tooltipstring',ttstr0,'callback',...
    {@pushbutton_loadMov_Callback,h_fig});

x = x+wbut0+p.mg/fact;

h.edit_movItg = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz1,'position',[x,y,wedit0,hedit0],...
    'enable','inactive','foregroundcolor',p.fntclr1);

x = p.mg;
y = y-p.mg/2-hedit0+(hedit0-htxt0)/2;

h.text_TTgen_coord = uicontrol('style','text','parent',h_pan,'units',...
    p.posun,'fontunits',p.fntun,'fontsize',p.fntsz1,'position',...
    [x,y,wtxt0,htxt0],'string',str2,'horizontalalignment','left');

x = x+wtxt0+p.mg/fact;
y = y-(hedit0-htxt0)/2;

h.pushbutton_TTgen_loadCoord = uicontrol('style','pushbutton','parent',...
    h_pan,'units',p.posun,'fontunits',p.fntun,'fontsize',p.fntsz1,...
    'position',[x,y,wbut0,hedit0],'string',str1,'tooltipstring',ttstr1,...
    'callback',{@pushbutton_TTgen_loadCoord_Callback,h_fig});

x = x+wbut0+p.mg/fact;

h.edit_itg_coordFile = uicontrol('style','edit','parent',h_pan,'units',...
    p.posun,'fontunits',p.fntun,'fontsize',p.fntsz1,'position',...
    [x,y,wedit0,hedit0],'enable','inactive','foregroundcolor',p.fntclr1);

x = pospan(3)-p.mg-wbut1;

h.pushbutton_TTgen_loadOpt = uicontrol('style','pushbutton','parent',...
    h_pan,'units',p.posun,'fontunits',p.fntun,'fontsize',p.fntsz1,...
    'position',[x,y,wbut1,hedit0],'string',str3,'tooltipstring',ttstr2,...
    'callback',{@openItgOpt,h_fig});

x = p.mg;
y = y-p.mg/2-hedit0+(hedit0-htxt0)/2;

h.text_intg = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz1,'position',[x,y,wtxt0,htxt0],...
    'string',str4,'horizontalalignment','left');

x = x+wtxt0+p.mg/fact;
y = y-(hedit0-htxt0)/2;

h.edit_TTgen_dim = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz1,'position',[x,y,wedit1,hedit0],...
    'tooltipstring',ttstr3,'callback',{@edit_TTgen_dim_Callback,h_fig});

x = x+wedit1+p.mg/fact;

h.edit_intNpix = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz1,'position',[x,y,wedit1,hedit0],...
    'tooltipstring',ttstr4,'callback',{@edit_intNpix_Callback,h_fig});

x = x+wedit1+p.mg/fact;

h.checkbox_meanVal = uicontrol('style','checkbox','parent',h_pan,'units',...
    p.posun,'fontunits',p.fntun,'fontsize',p.fntsz1,'position',...
    [x,y,wcb0,hedit0],'string',str5,'tooltipstring',ttstr5,'callback',...
    {@checkbox_meanVal_Callback,h_fig});

x = pospan(3)-p.mg-wbut2;

h.pushbutton_TTgen_fileOpt = uicontrol('style','pushbutton','parent',...
    h_pan,'units',p.posun,'fontunits',p.fntun,'fontsize',p.fntsz1,...
    'position',[x,y,wbut2,hedit0],'string',str6,'tooltipstring',ttstr6,...
    'callback',{@openItgFileOpt,h_fig});
