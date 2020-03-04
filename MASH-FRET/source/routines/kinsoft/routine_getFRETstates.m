function states = routine_getFRETstates(pname,fname,Js,h_fig)
% states = routine_getFRETstates(pname,fname,Js,h_fig)
%
% Analyze data of Kinsoft challenge to find FRET states and associated deviations
%
% pname: source directory
% fname: .mash source file name
% Js: [1-by-nJ] optimum number of states
% h_fig: handle to main figure
% states: {1-by-nJ} [J-by-2] FRET states and associated deviations

% initialize output
states = {};

% defauts
meth = 2; % state finding method index in list (vbFRET)
Jmin = 1; % minimum number of states to find in traces
iter = 10; % number of vbFRET iterations
trace = 1; % index in list of traces to apply state finding algorithm to (bottom traces)
deblurr = true; % activate "deblurr" option
tdp_dat = 3; % data to plot in TDP (FRET data)
tdp_tag = 1; % molecule tag to plot in TDP (all molecules)
shape = 2; % gaussian cluster shape (straight multivariate)

fname_mashIn = cat(2,fname,'_STaSI.mash');
fname_mashOut = cat(2,fname,'_vbFRET_%sstates.mash');
fname_clst = cat(2,fname,'_vbFRET_%sstates.clst');

% get default interface
h = guidata(h_fig);

disp('>> start determination of FRET states and associated deviations...');

% get default interface settings
p = getDef_kinsoft(pname,[]);

disp(cat(2,'>>>> import ',fname_mashIn,' in Trace processing...'));

% set options for ASCII file import
switchPan(h.togglebutton_TP,[],h_fig);
pushbutton_addTraces_Callback({p.dumpdir,fname_mashIn},[],h_fig);

disp('>>>> process single FRET traces with vbFRET...');

% set interface to default values
setDef_kinsoft_TP(p,h_fig);

% configure state finding algorithm to STaSI
for Jmax = Js
    fprintf('>>>>>> process with Jmax=%i...\n',Jmax);
    
    p.fsPrm(meth,1,:) = Jmin;
    p.fsPrm(meth,2,:) = Jmax;
    p.fsPrm(meth,3,:) = iter;
    p.fsPrm(meth,7,:) = deblurr;
    set_TP_findStates(meth,trace,p.fsPrm,p.fsThresh,p.nChan,p.nL,h_fig);
    pushbutton_applyAll_DTA_Callback(h.pushbutton_applyAll_DTA,[],h_fig);

    % process traces
    pushbutton_TP_updateAll_Callback(h.pushbutton_TP_updateAll,[],h_fig);

    fprintf(...
        cat(2,'>>>>>> save modificiations in file ',fname_mashOut,'...\n'),...
        Jmax);

    % save project
    pushbutton_expProj_Callback({p.dumpdir,sprintf(fname_mashOut,Jmax)},[],...
        h_fig);
end
pushbutton_remTraces_Callback(h.pushbutton_remTraces,[],h_fig);

switchPan(h.togglebutton_TA,[],h_fig);
for Jmax = Js
    fprtinf(cat(2,'>>>> import file ',fname_mashOut,...
        ' in Transition analysis...\n'),Jmax);

    % import project in TA
    pushbutton_TDPaddProj_Callback({p.dumpdir,sprintf(fname_mashOut,Jmax)},...
        [],h_fig);

    disp('>>>> build TDP...');

    % set TDP settings and update plot
    set_TA_TDP(tdp_dat,tdp_tag,p.tdpPrm,h_fig);
    pushbutton_TDPupdatePlot_Callback(h.pushbutton_TDPupdatePlot,[],h_fig);

    disp('>>>> cluster transitions with Gaussian mixtures...');

    % set clustering settings and cluster transitions
    p.clstMethPrm(1) = Jmax;
    p.clstConfig(4) = shape;
    set_TA_stateConfig(p.clstMeth,p.clstMethPrm,p.clstConfig,p.clstStart,...
        h_fig);
    pushbutton_TDPupdateClust_Callback(h.pushbutton_TDPupdateClust,[],h_fig);
    
    % recover results
    h = guidata(h_fig);
    p = h.param.TDP;
    proj = p.curr_proj;
    tpe = p.curr_type(proj);
    tag = p.curr_tag(proj);
    prm = p.proj{proj}.prm{tag,tpe};
    res = prm.clst_res;
    K = getClusterNb(Jmax,p.clstConfig(1),p.clstConfig(2));
    [j1,j2] = getStatesFromTransIndexes(1:K,Jmax,p.clstConfig(1),...
        p.clstConfig(2));
    states_J = [res{Jmax}.mu',zeros(Jmax,1)];
    for j = 1:Jmax
        states_J(j,2) = (mean(sqrt(res{Jmax}.sig(1,1,j1==j & j2~=j))) + ...
            mean(sqrt(res{Jmax}.sig(2,2,j2==j & j1~=j))))/2;
    end
    states = cat(2,states,states_J);
    
    % export gaussian mixture to .clst files
    set(h.popupmenu_tdp_model,'value',Jmax);
    popupmenu_tdp_model_Callback(h.popupmenu_tdp_model,[],h_fig);

    pushbutton_tdp_impModel_Callback(h.pushbutton_tdp_impModel,[],h_fig);

    pushbutton_TDPexport_Callback(h.pushbutton_TDPexport,[],h_fig);
    set_TA_expOpt(p.tdp_expOpt,h_fig);
    pushbutton_expTDPopt_next_Callback(...
        {p.dumpdir,sprintf(fname_clst,num2str(Jmax))},[],h_fig);
    
    % save modifications to mash file
    p.projOpt.proj_title = [fname,'_vbFRET_',num2str(Jmax),'states'];
    set_VP_projOpt(p.projOpt,p.wl(1:p.nL),h.pushbutton_editParam,h_fig);
    pushbutton_TDPsaveProj_Callback(...
        {p.dumpdir,sprintf(fname_mashOut,Jmax)},[],h_fig);
    pushbutton_TDPremProj_Callback(h.pushbutton_TDPremProj,[],h_fig);
end

