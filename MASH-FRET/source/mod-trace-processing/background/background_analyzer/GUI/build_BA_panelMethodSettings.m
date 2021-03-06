function q = build_BA_panelMethodSettings(q,p,h_fig)
% q = build_BA_panelMethodSettings(q,p,h_fig)
%
% Build panel "Method settings" for Background analyzer
%
% q: structure to update with handles to new gaphical elements and that must contain field:
%  q.uipanel_determine_bg: handle to panel "Method settings"
% p: structure containing dfault layout settings
% h_fig: handle to main figure

% defaults
str0 = 'data';
str1 = 'method';
str2 = 'param.';
str3 = 'dim.';
str4 = 'x-dark';
str5 = 'y-dark';
str6 = 'XXXXX at 999nm';
str7 = 'Most frequent value';
str8 = 'auto';
str9 = 'Show';
str10 = 'current molecule';
str11 = 'BG value';
str12 = char(9668);
str13 = char(9658);
str14 = 'Set for all molecules';
str15 = 'Set for all channels';
ttstr0 = 'Channel';
ttstr1 = 'Background correction method';
ttstr2 = 'Sub-image dimensions';
ttstr3 = 'x-coordinates for dark trace';
ttstr4 = 'y-coordinates for dark trace';
ttstr5 = 'Determine automatically dark coordinates';
ttstr6 = 'Show background intensity-time trace';
ttstr7 = 'Go to previous molecule in the list';
ttstr8 = 'Current molecule index';
ttstr9 = 'Go to next molecule in the list';
ttstr10 = 'Background intensity';
ttstr11 = 'Apply current settings to all molecules';
ttstr12 = 'Apply current settings to all intensities in the list';

% parent
h_pan = q.uipanel_determine_bg;

% dimensions
pospan = get(h_pan,'position');
wpop0 = getUItextWidth(str6,p.fntun,p.fntsz,'normal',p.tbl) + p.warr;
wpop1 = getUItextWidth(str7,p.fntun,p.fntsz,'normal',p.tbl) + p.warr;
wcb0 = getUItextWidth(str8,p.fntun,p.fntsz,'normal',p.tbl) + p.wbox;
wbut0 = getUItextWidth(str9,p.fntun,p.fntsz,'normal',p.tbl) + p.wbrd;
wbut1 = getUItextWidth(str12,p.fntun,p.fntsz,'normal',p.tbl) + p.wbrd;
wtxt0 = 2*wbut1 + 2*p.mg/2;
wtxt1 = getUItextWidth(str11,p.fntun,p.fntsz,'normal',p.tbl);
wbut2 = getUItextWidth(str14,p.fntun,p.fntsz,'normal',p.tbl) + p.wbrd;
wbut3 = getUItextWidth(str15,p.fntun,p.fntsz,'normal',p.tbl) + p.wbrd;

% collect inetrface parameters
h = guidata(h_fig);
p_proj = h.param.ttPr.proj{h.param.ttPr.curr_proj};

% collect project parameters
labels = p_proj.labels;
exc = p_proj.excitations;
clr = p_proj.colours;

% get menu strings
str_dat = getStrPop('bg_corr',{labels,exc,clr});
str_meth = get(h.popupmenu_trBgCorr, 'String');

% build GUI
x = p.mg;
y = pospan(4)-p.mgpan-p.htxt;

q.text_data = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,wpop0,p.htxt],...
    'string',str0);

x = x+wpop0+p.mg;

q.text_meth = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,wpop1,p.htxt],...
    'string',str1);

x = x+wpop1+p.mg;

q.text_subimdim = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.htxt],...
    'string',str3);

x = x+p.wedit+p.mg;

q.text_param1 = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.htxt],...
    'string',str2);

x = x+p.wedit+p.mg;

q.text_xdark = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.htxt],...
    'string',str4);

x = x+p.wedit+p.mg;

q.text_ydark = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.htxt],...
    'string',str5);

x = p.mg;
y = y-p.hpop;

q.popupmenu_data = uicontrol('style','popup','parent',h_pan,'units',...
    p.posun,'fontunits',p.fntun,'fontsize',p.fntsz,'position',...
    [x,y,wpop0,p.hpop],'string',str_dat,'tooltipstring',ttstr0,'callback',...
    {@popupmenu_BA_data_Callback,h_fig});

x = x+wpop0+p.mg;

q.popupmenu_meth = uicontrol('style','popup','parent',h_pan,'units',...
    p.posun,'fontunits',p.fntun,'fontsize',p.fntsz,'position',...
    [x,y,wpop1,p.hpop],'string',str_meth,'tooltipstring',ttstr1,'callback',...
    {@popupmenu_BA_meth_Callback,h_fig});

x = x+wpop1+p.mg;
y = y+(p.hpop-p.hedit)/2;

q.edit_subimdim = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.hedit],...
    'tooltipstring',ttstr2,'callback',{@edit_BA_subimdim_Callback,h_fig,0});

x = x+p.wedit+p.mg;

q.edit_param1 = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.hedit],...
    'callback',{@edit_BA_param1_Callback,h_fig,0});

x = x+p.wedit+p.mg;

q.edit_xdark = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.hedit],...
    'tooltipstring',ttstr3,'callback',{@edit_BA_xdark_Callback,h_fig});

x = x+p.wedit+p.mg;

q.edit_ydark = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.hedit],...
    'tooltipstring',ttstr4,'callback',{@edit_BA_ydark_Callback,h_fig});

x = x+p.wedit+p.mg;

q.checkbox_auto = uicontrol('style','checkbox','parent',h_pan,'units',...
    p.posun,'fontunits',p.fntun,'fontsize',p.fntsz,'position',...
    [x,y,wcb0,p.hcb],'string',str8,'tooltipstring',ttstr5,'callback',...
    {@checkbox_BA_auto_Callback,h_fig});

x = x+wcb0+p.mg;
y = y-(p.hbut-p.hcb)/2;

q.pushbutton_show = uicontrol('style','pushbutton','parent',h_pan,'units',...
    p.posun,'fontunits',p.fntun,'fontsize',p.fntsz,'position',...
    [x,y,wbut0,p.hbut],'string',str9,'tooltipstring',ttstr6,'callback',...
    {@pushbutton_BA_show_Callback,h_fig});

x = p.mg;
y = y-p.mg-p.htxt;

q.text_curmol = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,wtxt0,p.htxt],...
    'string',str10);

x = x+wtxt0+p.mg;

q.text_bgval = uicontrol('style','text','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,wtxt1,p.htxt],...
    'string',str11);

x = p.mg;
y = y-p.hpop;

q.pushbutton_prevmol = uicontrol('style','pushbutton','parent',h_pan,...
    'units',p.posun,'fontunits',p.fntun,'fontsize',p.fntsz,'position',...
    [x,y,wbut1,p.hbut],'string',str12,'tooltipstring',ttstr7,'callback',...
    {@pushbutton_BA_prevmol_Callback,h_fig});

x = x+wbut1+p.mg/2;
y = y+(p.hpop-p.hedit)/2;

q.edit_curmol = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,p.wedit,p.hedit],...
    'tooltipstring',ttstr8,'callback',{@edit_BA_curmol_Callback,h_fig});

x = x+p.wedit+p.mg/2;
y = y-(p.hpop-p.hedit)/2;

q.pushbutton_nextmol = uicontrol('style','pushbutton','parent',h_pan,...
    'units',p.posun,'fontunits',p.fntun,'fontsize',p.fntsz,'position',...
    [x,y,wbut1,p.hbut],'string',str13,'tooltipstring',ttstr9,'callback',...
    {@pushbutton_BA_nextmol_Callback,h_fig});

x = x+wbut1+p.mg;
y = y+(p.hpop-p.hedit)/2;

q.edit_chan = uicontrol('style','edit','parent',h_pan,'units',p.posun,...
    'fontunits',p.fntun,'fontsize',p.fntsz,'position',[x,y,wtxt1,p.hedit],...
    'tooltipstring',ttstr10,'callback',{@edit_BA_chan_Callback,h_fig});

x = pospan(3)-p.mg-wbut3;
y = y-(p.hpop-p.hedit)/2;

q.pushbutton_allChan = uicontrol('style','pushbutton','parent',h_pan,...
    'units',p.posun,'fontunits',p.fntun,'fontsize',p.fntsz,'position',...
    [x,y,wbut3,p.hbut],'string',str15,'tooltipstring',ttstr12,'callback',...
    {@pushbutton_BA_allChan_Callback,h_fig},'foregroundcolor',p.fntclr2);

x = x-p.mg-wbut2;

q.pushbutton_allMol = uicontrol('style','pushbutton','parent',h_pan,...
    'units',p.posun,'fontunits',p.fntun,'fontsize',p.fntsz,'position',...
    [x,y,wbut2,p.hbut],'string',str14,'tooltipstring',ttstr11,'callback',...
    {@pushbutton_BA_allMol_Callback,h_fig},'foregroundcolor',p.fntclr2);



