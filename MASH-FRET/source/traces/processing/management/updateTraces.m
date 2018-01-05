function p = updateTraces(h_fig, opt1, mol, p, axes)

if ~isempty(p.proj)

    % update images
    if ~(~isempty(axes) && isfield(axes, 'axes_molImg'))
        axes_molImg = [];
    else
        axes_molImg = axes.axes_molImg;
    end
    
    % reset traces according to changes in parameters
    [p opt2] = resetMol(mol, p);
    
    p = plotSubImg(mol, p, axes_molImg);

    if strcmp(opt1, 'subImg')
        h = guidata(h_fig);
        h.param.ttPr = p;
        return;
    end
    
    proj = p.curr_proj;
    nC = p.proj{proj}.nb_channel;

    isBgCorr = ~isempty(p.proj{proj}.intensities_bgCorr) && ...
        sum(prod(prod(double(~isnan(p.proj{proj}.intensities_bgCorr(:, ...
        ((mol-1)*nC+1):mol*nC,:))),3),2),1)~= ...
        size(p.proj{proj}.intensities_bgCorr,1);
    
    if ~isBgCorr
        opt2 = 'ttBg';
    end

    if strcmp(opt2, 'ttBg') || strcmp(opt2, 'ttPr')
        p = bgCorr(mol, p);
    end
    
    if strcmp(opt2, 'corr') || strcmp(opt2, 'ttBg') || strcmp(opt2, 'ttPr')
        p = crossCorr(mol, p);
    end
    
    if strcmp(opt2, 'denoise') || strcmp(opt2, 'corr') || ...
            strcmp(opt2, 'ttBg') || strcmp(opt2, 'ttPr')
        p = denoiseTraces(mol, p);
    end

    if strcmp(opt2, 'debleach') || strcmp(opt2, 'denoise') || ...
            strcmp(opt2, 'corr') || strcmp(opt2, 'ttBg') || ...
            strcmp(opt2, 'ttPr')
        p = calcCutoff(mol, p);
    end
    
    if strcmp(opt2, 'DTA') || strcmp(opt2, 'debleach') || ...
            strcmp(opt2, 'denoise') || strcmp(opt2, 'corr') || ...
            strcmp(opt2, 'ttBg') || strcmp(opt2, 'ttPr')
        p = discrTraces(h_fig, mol, p);
    end
    
    proj = p.curr_proj;
    
    if (strcmp(opt2, 'plot') || strcmp(opt2, 'DTA') || ...
            strcmp(opt2, 'debleach') || strcmp(opt2, 'denoise') || ...
            strcmp(opt2, 'corr') || strcmp(opt2, 'ttBg') || ...
            strcmp(opt2, 'ttPr')) && ~isempty(axes)
        plotData(mol, p, axes, p.proj{proj}.prm{mol}, 1);
    end
    
    p.proj{proj}.def.mol = p.proj{proj}.prm{mol};
    p.proj{proj}.curr{mol} = p.proj{proj}.prm{mol};
end





