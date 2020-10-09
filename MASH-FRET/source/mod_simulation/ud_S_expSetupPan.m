function ud_S_expSetupPan(h_fig)
% ud_S_expSetupPan(h_fig)
%
% Set panel Experimental setup to proper values
%
% h_fig: handle to main figure

% default
defocus = false;

% collect interface parameters
h = guidata(h_fig);
p = h.param.sim;

% set all controls on-enabled
setProp(h.uipanel_S_experimentalSetup,'enable','on');

% reset background color of edit fields
set([h.edit_psfW1 h.edit_psfW2 h.edit_simzdec h.edit_simz0_A ...
    h.edit_bgInt_don h.edit_bgInt_acc h.edit_TIRFx h.edit_TIRFy ...
    h.edit_bgExp_cst h.edit_simAmpBG ], 'BackgroundColor', [1 1 1]);

% set PSF convolution
set(h.checkbox_convPSF, 'Value', p.PSF);
if p.impPrm && isfield(p.molPrm, 'psf_width')
    set([h.text_simPSFw1 h.text_simPSFw2 h.edit_psfW1 h.edit_psfW2 ...
        h.checkbox_convPSF], 'Enable', 'off');
else
    if p.PSF
        set(h.edit_psfW1, 'String', num2str(p.PSFw(1,1)));
        set(h.edit_psfW2, 'String', num2str(p.PSFw(1,2)));
    else
        set([h.text_simPSFw1 h.edit_psfW1 h.text_simPSFw2 h.edit_psfW2], ...
            'Enable', 'off');
        set([h.edit_psfW1 h.edit_psfW2], 'String', '');
    end
end

% set background spatial distribution
set(h.popupmenu_simBg_type, 'Value', p.bgType);
if strcmp(p.intUnits, 'electron')
    [offset,K,eta] = getCamParam(p.noiseType,p.camNoise);
    p.bgInt_don = phtn2ele(p.bgInt_don,K,eta);
    p.bgInt_acc = phtn2ele(p.bgInt_acc,K,eta);
end
set(h.edit_bgInt_don, 'String', num2str(p.bgInt_don));
set(h.edit_bgInt_acc, 'String', num2str(p.bgInt_acc));
if p.bgType == 2
    set(h.edit_TIRFx, 'String', num2str(p.TIRFdim(1)));
    set(h.edit_TIRFy, 'String', num2str(p.TIRFdim(2)));
else
    set([h.edit_TIRFx h.edit_TIRFy h.text_simWTIRF], 'Enable', 'off');
    set([h.edit_TIRFx h.edit_TIRFy], 'String', '');
end

% set dynamic background
set(h.checkbox_bgExp, 'Value', p.bgDec);
if p.bgDec
    set(h.edit_bgExp_cst, 'String', num2str(p.cstDec));
    set(h.edit_simAmpBG, 'String', num2str(p.ampDec));
else
    set([h.edit_bgExp_cst h.edit_simAmpBG], 'Enable', 'off', 'String', '');
end

set(h.checkbox_defocus,'value',defocus);
if defocus
    set(h.edit_simzdec, 'String', num2str(p.zDec));
    set(h.edit_simz0_A, 'String', num2str(p.z0Dec));
else
    set([h.edit_simzdec h.edit_simz0_A], 'Enable', 'off', 'String', '');
end

