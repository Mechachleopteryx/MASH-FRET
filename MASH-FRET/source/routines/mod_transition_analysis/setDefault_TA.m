function setDefault_TA(h_fig,p)
% setDefault_TA(h_fig,p)
%
% Set Transition analysis module to default values and update interface parameters
%
% h_fig: handle to main figure
% p: structure that must contain default parameters as generated by getDefault_TA

% get interface parameters
h = guidata(h_fig);

% empty project list
nProj = numel(get(h.listbox_TDPprojList,'string'));
proj = nProj;
while proj>0
    set(h.listbox_TDPprojList,'value',proj);
    listbox_TDPprojList_Callback(h.listbox_TDPprojList,[],h_fig);
    pushbutton_TDPremProj_Callback(h.pushbutton_TDPremProj,[],h_fig);
    proj = proj-1;
end

% import default project
pushbutton_TDPaddProj_Callback({p.annexpth,p.mash_file},[],h_fig);

% set default transition density plot parameters
set_TA_TDP(p.tdpDat,1,p.tdpPrm,h_fig);
pushbutton_TDPupdatePlot_Callback(h.pushbutton_TDPupdatePlot,[],h_fig);

% set default state configuration parameters
pushbutton_TDPresetClust_Callback(h.pushbutton_TDPresetClust,[],h_fig);
set_TA_stateConfig(p.clstMeth,p.clstMethPrm,p.clstConfig,p.clstStart,...
    h_fig);
