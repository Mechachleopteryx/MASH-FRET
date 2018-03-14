function plotExample(h_fig)

% Plot one simulated trajectory and the first frame of the SMV
% Short version of exportResults.m
%
% Requires external files: 
%
% Created the 23rd of April 2014 by M�lodie C.A.S Hadzic
% Last update: 12th of December 2017 by Richard B�rner
% Last update: 7th of March 2018 by Richard B�rner
%
% Comments adapted for Boerner et al 2017
% Noise models adapted for Boerner et al 2017.
% Simulation default parameters adapted for Boerner et al 2017.

h = guidata(h_fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize all parameters

bgDec_dir = {'decrease','decrease'};

% general parameters
rate = 1/h.param.sim.rate; % frame rate (s)
bitnr = h.param.sim.bitnr;

% molecule parameters
totInt = h.param.sim.totInt; % total emitted intensity (a.u.)

% setup parameters

% EMCCD camera
res_x = h.param.sim.movDim(1); % movie with
res_y = h.param.sim.movDim(2); % movie height
psf = h.param.sim.PSF; % convolve with PSF (0/1)
o_psf = h.param.sim.PSFw/h.param.sim.pixDim; % PSF sigma (for both channels)

% Background
bgType = h.param.sim.bgType; % fluorescent background type
bgInt_don = h.param.sim.bgInt_don; % BG intensities in pc
bgInt_acc = h.param.sim.bgInt_acc; % BG intensities in pc
TIRFdim = h.param.sim.TIRFdim; % TIRF profile widths
expDec = h.param.sim.bgDec; % exponentially decreasing BG (0/1)
amp = h.param.sim.ampDec; % exponential amplitude
cst = h.param.sim.cstDec; % exponential time decay constant

% camera noise
noiseType = h.param.sim.noiseType;
switch noiseType
    case 'poiss'
        noiseCamInd = 1;
    case 'norm'
        noiseCamInd = 2;
    case 'user'
        noiseCamInd = 3;
    case 'none'
        noiseCamInd = 4;
    case 'hirsch'
        noiseCamInd = 5;
end
noisePrm = h.param.sim.camNoise(noiseCamInd,:);

% instrumental imperfections
btD = h.param.sim.btD; % bleedthrough coefficients
btA = h.param.sim.btA; % bleedthrough coefficients
deD = h.param.sim.deD; % direct excitation coefficients
deA = h.param.sim.deA; % direct excitation coefficients

% other parameters
opUnits = h.param.sim.intOpUnits;
gaussMat = h.param.sim.matGauss;

% Results from buildModel function
dat = h.results.sim.dat;
Idon = dat{1};
Iacc = dat{2};
coord = dat{3};

nbMol = size(Idon,2); % Number of simulated molecules; control 

% end of intitialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize first frame
lim_don.x = [1 round(res_x/2)]; lim_don.y = [1 res_y];
lim_acc.x = [1 res_x - round(res_x/2)]; lim_acc.y = [1 res_y];
img_don = zeros(res_y, round(res_x/2));
img_acc = zeros(res_y, res_x-round(res_x/2));
img_bg_don = img_don;
img_bg_acc = img_acc;

% Simulate first trajectory and first frame for all molecules
if nbMol % Only true, if at least one molecule was simulated.
    
    % calculate fluorescent background image (background values still im electron or image counts / frame)
    switch bgType
        case 1 % constant
            img_bg_don = bgInt_don*ones(res_y, round(res_x/2));
            img_bg_acc = bgInt_acc*ones(res_y, (res_x-round(res_x/2)));

        case 2 % TIRF profile
            p.amp = bgInt_don;
            p.mu(1) = round(res_x/4);
            p.mu(2) = round(res_y/2);
            p.sig = TIRFdim;
            [img_bg_don,o] = getImgGauss(lim_don, p, 0);

            p.amp = bgInt_acc;
            [img_bg_acc,o] = getImgGauss(lim_acc, p, 0);

        case 3 % patterned
            if isfield(h.param.sim, 'bgImg') && ~isempty(h.param.sim.bgImg)
                bgImg = h.param.sim.bgImg.frameCur;
                min_s = min([size(img_bg_don);size(bgImg)],[],1);
                h_min = min_s(1); w_min = min_s(2);
                img_bg_don(1:h_min,1:w_min) = bgImg(1:h_min,1:w_min);
                min_s = min([size(img_bg_acc);size(bgImg)],[],1);
                h_min = min_s(1); w_min = min_s(2);
                img_bg_acc(1:h_min,1:w_min) = bgImg(1:h_min,1:w_min);
            else
                updateActPan('No BG pattern loaded.', h_fig, 'error');
                return;
            end
    end
    
    % calculate first trajectory and first frame intensity for all molecules, 
    % incl. instrumental imperfections and photon shot noise
    for n = 1:nbMol
        
%         % direct excitation in % of the background
%         % comment: indeed there is direct excitation contribution of the background, but its corrected via the background itself. 
%         % I_de = I + De*bg
%         if n == 1
%             I_don_de = Idon{n}(:,1) + deD*bgInt_don; 
%             I_acc_de = Iacc{n}(:,1) + deA*bgInt_acc;
%         else
%             I_don_de = Idon{n}(1,1) + deD*bgInt_don;
%             I_acc_de = Iacc{n}(1,1) + deA*bgInt_acc;
%         end
        
        % direct excitation assuming I_Dem_Dex without FRET = I_Aem_Aex
        % comment: this value can only be correct for ALEX type
        % measurements. Therefore, direct excitation should only be
        % simulated for ALEX type simulations.
        % I_de = I + De*I_j
        if n == 1 % first trace
            I_don_de = Idon{n}(:,1); % there is no direct excitation of the Donor 
            I_acc_de = Iacc{n}(:,1) + deA*totInt;
        else % for all other traces only first frame
            I_don_de = Idon{n}(1,1); % there is no direct excitation of the Donor 
            I_acc_de = Iacc{n}(1,1) + deA*totInt;
        end
        
        % bleedthrough (missing signal in each channel will be added in the other)
        % I_bt = I_de - Bt*I_j_de
        I_don_bt = (1-btD)*I_don_de + btA*I_acc_de;
        I_acc_bt = (1-btA)*I_acc_de + btD*I_don_de;

        % add photon emission noise
        if noiseCamInd~=2 % no Poisson noise for pure Gaussian noise
            I_don_bt = random('poiss', I_don_bt);
            I_acc_bt = random('poiss', I_acc_bt);
        end
             
        % add noisy fluorescent background trace for first plotted
        % trajectory
        % I_bg = I_bt + bg 
        if n == 1
            % exp decay of background, to check
            if expDec
                if strcmp(bgDec_dir{1},'increase')
                    exp_bg_don = img_bg_don(ceil(coord(n,2)), ...
                        ceil(coord(n,1)))*(amp* ...
                        exp(-(numel(I_don_bt):-1:1)*rate/cst)+1);
                else
                    exp_bg_don = img_bg_don(ceil(coord(n,2)), ...
                        ceil(coord(n,1)))*(amp* ...
                        exp(-(1:numel(I_don_bt))*rate/cst)+1);
                end
                if strcmp(bgDec_dir{2},'increase')
                    exp_bg_acc = img_bg_acc(ceil(coord(n,4)), ...
                        ceil(coord(n,3))-round(res_x/2))*(amp* ...
                        exp(-(numel(I_acc_bt):-1:1)*rate/cst)+1);
                else
                    exp_bg_acc = img_bg_acc(ceil(coord(n,4)), ...
                        ceil(coord(n,3))-round(res_x/2))*(amp* ...
                        exp(-(1:numel(I_acc_bt))*rate/cst)+1);
                end

                img_bg_don = img_bg_don*(amp*exp(-rate/cst)+1);
                img_bg_acc = img_bg_acc*(amp*exp(-rate/cst)+1);
                
                if noiseCamInd~=2 % no Poisson noise for pure Gaussian noise
                    I_don_bg = I_don_bt + random('poiss',exp_bg_don)';
                    I_acc_bg = I_acc_bt + random('poiss',exp_bg_acc)';
                else
                    I_don_bg = I_don_bt + exp_bg_don;
                    I_acc_bg = I_acc_bt + exp_bg_acc;
                end
            % constant background pattern (constant, TIRF profile, patterned)   
            else
                if noiseCamInd~=2 % no Poisson noise for pure Gaussian noise
                    I_don_bg = I_don_bt + random('poiss', ...
                        repmat(img_bg_don(ceil(coord(n,2)), ...
                        ceil(coord(n,1))),size(I_don_bt)));
                    I_acc_bg = I_acc_bt + random('poiss', ...
                        repmat(img_bg_acc(ceil(coord(n,4)), ...
                        ceil(coord(n,3))-round(res_x/2)),size(I_acc_bt)));
                else
                    I_don_bg = I_don_bt + repmat(img_bg_don( ...
                        ceil(coord(n,2)),ceil(coord(n,1))), ...
                        size(I_don_bt));
                    I_acc_bg = I_acc_bt + repmat(img_bg_acc( ...
                        ceil(coord(n,4)),ceil(coord(n,3))- ...
                        round(res_x/2)),size(I_acc_bt));
                end
            end
            I_don_plot = I_don_bg;
            I_acc_plot = I_acc_bg;
        end
        
        % define Point-Spread-Function (PSF) for each simulated molecule
        if psf
            if size(o_psf,1)>1
                o_psf1 = o_psf(n,1); o_psf2 = o_psf(n,1);
            else
                o_psf1 = o_psf(1,1); o_psf2 = o_psf(1,2);
            end
            p_don.amp(n,1) = I_don_bt(1);
            p_don.mu(n,1) = coord(n,1);
            p_don.mu(n,2) = coord(n,2);
            p_don.sig(n,1:2) = [o_psf1 o_psf1];

            p_acc.amp(n,1) = I_acc_bt(1);
            p_acc.mu(n,1) = coord(n,3) - round(res_x/2);
            p_acc.mu(n,2) = coord(n,4);
            p_acc.sig(n,1:2) = [o_psf2 o_psf2];
        end
            
    end
    
    % add noisy fluorescent background image
    if noiseCamInd~=2 % no Poisson noise for pure Gaussian noise
        img_bg_don = random('poiss',img_bg_don);
        img_bg_acc = random('poiss',img_bg_acc);
    end
    
    % build noisy + PSF convoluted sm fluorescence image
    if psf
        [img_don, gaussMat{1}] = getImgGauss(lim_don, p_don, 1, gaussMat{1});
        [img_acc, gaussMat{2}] = getImgGauss(lim_acc, p_acc, 1, gaussMat{2});
    else
        for n = 1:nbMol
            img_don(ceil(coord(n,2)),ceil(coord(n,1))) = I_don_bt(1);
            img_acc(ceil(coord(n,4)),ceil(coord(n,3))-round(res_x/2)) = ...
                I_acc_bt(1);
        end
    end
    
    img_don = img_don + img_bg_don;
    img_acc = img_acc + img_bg_acc;
    
    img = [img_don img_acc];
end

% add camera noise
% comment: the input values are always poisson distributed pc coming from
% the fluorophors and the background!

switch noiseType
%     Propability distribution for different noise contributions.
%     Ptot = @(o,I0,q,c,f,nic,g) (1/sqrt(2*pi*o))*exp(-(I0*q+c)-((f*nic)^2)/(2*(o^2)))+(2/g)*chi2pdf(2*(I0*q+c),4.2*f*nic/g);
%     G = @(noe,nie,g) (noe^(nie-1))*exp(-noe/g)/(gamma(nie)*(g^nie));
%     P = @(nie,c) exp(-c)*(c^nie)/factorial(nie);
%     N = @(fnic,noe,r) normpdf(fnic,noe,r);
%     Pdark = @(nic,noe,nie,g,f,r) (P(nie,G(noe,nie,g))*N(f*nic,noe,r))*(f*nic);      

    case 'poiss' % Poisson or P-model from B�rner et al. 2017
        % convert camera offset in photon counts
        I_th = arb2phtn(noisePrm(1));
        eta = noisePrm(2); 
        
        % add noise for photoelectrons
        img = random('poiss', eta*img+I_th);
        I_don_plot = random('poiss', eta*I_don_plot+I_th);
        I_acc_plot = random('poiss', eta*I_acc_plot+I_th);
        
        % convert to EC (conversion yields basically wrong ec or ic as the conversion factor photons to imagecounts is only valid for N, NExpN and PGN model)
        if strcmp(opUnits, 'electron')
            img = phtn2arb(img, 1); % transfer function with eta=1, as detection efficiency already applied above
            I_don_plot = phtn2arb(I_don_plot, 1);
            I_acc_plot = phtn2arb(I_acc_plot, 1);
        end
        
    case 'norm' % Gaussian, Normal or N-model from B�rner et al. 2017
        % PC are not Poisson distributed here.
        % model parameters
        K = noisePrm(1);
        sig_d = noisePrm(2);
        mu_y_dark = noisePrm(3);
        sig_q = noisePrm(4);
        eta = noisePrm(6);
        
        % convert photon signal to EC and add dark counts, Gaussian center
        % same as arbtophtn
        mu_y_img = K*eta*img + mu_y_dark; 
        mu_y_I_don = K*eta*I_don_plot + mu_y_dark;
        mu_y_I_acc = K*eta*I_acc_plot + mu_y_dark;
        
        % calculate noise width in EC, Gaussian width
        sig_y_img = sqrt((K*sig_d)^2 + (sig_q^2) + (K^2)*eta*img);
        sig_y_Idon = sqrt((K*sig_d)^2 + (sig_q^2) + (K^2)*eta*I_don_plot);
        sig_y_Iacc = sqrt((K*sig_d)^2 + (sig_q^2) + (K^2)*eta*I_acc_plot);
        
        % add Gaussian noise
        img = random('norm', mu_y_img, sig_y_img);
        I_don_plot = random('norm', mu_y_I_don, sig_y_Idon);
        I_acc_plot = random('norm', mu_y_I_acc, sig_y_Iacc);
        
        % convert to PC
        if strcmp(opUnits, 'photon')
            img = arb2phtn(img,K,eta);
            I_don_plot = arb2phtn(I_don_plot,K,eta);
            I_acc_plot = arb2phtn(I_acc_plot,K,eta);
        end
        
    case 'user' % User defined or NExpN-model from B�rner et al. 2017
        
        % model parameters
        I_th = noisePrm(1); % Dark counts or offset
        A = noisePrm(2); % CIC contribution
        tau = noisePrm(3); % CIC decay
        sig0 = noisePrm(4); % read-out noise width
        K = noisePrm(5); % Overall system gain
        eta = noisePrm(6); % Total detection efficiency

        % convert to EC
        img = phtn2arb(img, K, eta);
        I_don_plot = phtn2arb(I_don_plot, K, eta);
        I_acc_plot = phtn2arb(I_acc_plot, K, eta);

        % calculate noise distribution and add noise
        img = rand_NexpN(img+I_th, A, tau, sig0);
        I_don_plot = rand_NexpN(I_don_plot+I_th, A, tau, sig0);
        I_acc_plot = rand_NexpN(I_acc_plot+I_th, A, tau, sig0);
        
        if strcmp(opUnits, 'photon')
            img = arb2phtn(img);
            I_don_plot = arb2phtn(I_don_plot);
            I_acc_plot = arb2phtn(I_acc_plot);
        end
        
    case 'none' % None, no camera noise but possible camera offset value
        % convert camera offset in photon counts
        I_th = arb2phtn(noisePrm(1));
        
        % no noise but offset in PC
        img = img+I_th;
        I_don_plot = I_don_plot+I_th;
        I_acc_plot = I_acc_plot+I_th;
        
        % convert to EC
        if strcmp(opUnits, 'electron')
            img = phtn2arb(img);
            I_don_plot = phtn2arb(I_don_plot);
            I_acc_plot = phtn2arb(I_acc_plot);
        end
        
    case 'hirsch' % Hirsch or PGN- Model from Hirsch et al. 2011
       
        % model parameters
        g = noisePrm(1); % change 2018-08-03
        s_d = noisePrm(2); 
        mu_y_dark = noisePrm(3);
        CIC = noisePrm(4);
        s = noisePrm(5);
        eta = noisePrm(6);
        
        % Poisson noise of photo-electrons + CIC
        img = random('poiss', eta*img+CIC);
        I_don_plot = random('poiss', eta*I_don_plot+CIC);
        I_acc_plot = random('poiss', eta*I_acc_plot+CIC);
        
        % Gamma amplification noise
        img = random('Gamma', img, g);
        I_don_plot = random('gamma', I_don_plot, g);
        I_acc_plot = random('gamma', I_acc_plot, g);
        
        % Gausian read-out noise
        img = random('norm', img/s + mu_y_dark, s_d*g/s);
        I_don_plot = random('norm', I_don_plot/s + mu_y_dark, s_d*g/s);
        I_acc_plot = random('norm', I_acc_plot/s + mu_y_dark, s_d*g/s);
        
        % Gausian read-out noise
%        img = conv(img_G,img_g)
%         % calculate noise distribution and add noise, old
%         img = rand_NexpN(img+I_th, A, wG, tau, a, sig0);
%         I_don_plot = rand_NexpN(I_don_plot+I_th, A, wG, tau, a, sig0);
%         I_acc_plot = rand_NexpN(I_acc_plot+I_th, A, wG, tau, a, sig0);
        
        % convert to PC
        if strcmp(opUnits, 'photon')
            img = arb2phtn(img);
            I_don_plot = arb2phtn(I_don_plot);
            I_acc_plot = arb2phtn(I_acc_plot);
        end
        
end

% Correction of out-of-range values.
% Due to noise calculated values out of the detection range 0 <= 0I <= bitrate. 

[~, sat] = Saturation(bitnr);
%sat = 2^bitnr-1;
% if strcmp(opUnits, 'electron')
%     sat = phtn2arb(sat);
% end

if strcmp(opUnits, 'photons')
    sat = arb2phtn(sat);
end

img(img<0) = 0;
img(img>sat) = sat;

I_don_plot(I_don_plot<0) = 0;
I_don_plot(I_don_plot>sat) = sat;

I_acc_plot(I_acc_plot<0) = 0;
I_acc_plot(I_acc_plot>sat) = sat;

% Histogram first trace

[~,edges] = histcounts([I_don_plot, I_acc_plot]);
[I_don_plot_hist,don_edges] = histcounts(I_don_plot,edges);
[I_acc_plot_hist] = histcounts(I_acc_plot,edges);

if nbMol > 0 % at least one trace must be simulated.
    % Plot first trace    
    if ~(isempty(get(get(h.axes_example, 'XLabel'), 'String')) && ...
            isempty(get(get(h.axes_example, 'YLabel'), 'String')))
        fntS_y = get(get(h.axes_example, 'YLabel'), 'FontSize');
        fntS_x = get(get(h.axes_example, 'XLabel'), 'FontSize');
    end

    plot(h.axes_example, rate*(0:size(I_don_plot,1))', [I_don_plot(1); ...
        I_don_plot], '-b', rate*(0:size(I_acc_plot,1))', ...
        [I_acc_plot(1);I_acc_plot], '-r');
    set(h.axes_example, 'XLim', [0 size(I_don_plot,1)*rate], ...
        'FontUnits', 'normalized');

    if isempty(get(get(h.axes_example, 'XLabel'), 'String')) && ...
            isempty(get(get(h.axes_example, 'YLabel'), 'String'))
        xlabel(h.axes_example, 'time (sec)', 'FontUnits', 'normalized');
        ylabel(h.axes_example, [opUnits ' counts'], 'FontUnits', ...
            'normalized');
    else
        xlabel(h.axes_example, 'time (sec)', 'FontUnits', 'normalized', ...
            'FontSize', fntS_x);
        ylabel(h.axes_example, [opUnits ' counts'], 'FontUnits', ...
            'normalized', 'FontSize', fntS_y);
    end
    legend(h.axes_example, 'donor', 'acceptor');
    grid(h.axes_example, 'on');
    ylim(h.axes_example, 'auto');
    
    % plot histogram of first trace
    if ~(isempty(get(get(h.axes_example_hist, 'XLabel'), 'String')) && ...
            isempty(get(get(h.axes_example_hist, 'YLabel'), 'String')))
        fntS_y = get(get(h.axes_example_hist, 'YLabel'), 'FontSize');
        fntS_x = get(get(h.axes_example_hist, 'XLabel'), 'FontSize');
    end

    bar(h.axes_example_hist,don_edges(1:size(don_edges,2)-1),I_don_plot_hist);
    set(h.axes_example_hist,'yscale','log'); 
    hold on;
    bar(h.axes_example_hist,don_edges(1:size(don_edges,2)-1),I_acc_plot_hist,'FaceColor','red');
    hold off;
    
    if isempty(get(get(h.axes_example_hist, 'XLabel'), 'String')) && ...
            isempty(get(get(h.axes_example_hist, 'YLabel'), 'String'))
        xlabel(h.axes_example_hist, [opUnits ' counts'], 'FontUnits', 'normalized');
        ylabel(h.axes_example_hist, 'frequency', 'FontUnits', ...
            'normalized');
    else
        xlabel(h.axes_example_hist, [opUnits ' counts'], 'FontUnits', 'normalized', ...
            'FontSize', fntS_x);
        ylabel(h.axes_example_hist, 'frequency', 'FontUnits', ...
            'normalized', 'FontSize', fntS_y);
    end
    legend(h.axes_example_hist, 'donor', 'acceptor');
    grid(h.axes_example_hist, 'on');
    ylim(h.axes_example_hist, 'auto');
end

% Plot first movie frame    
imagesc(img, 'Parent', h.axes_example_mov);
axis(h.axes_example_mov, 'image');
colorbar('delete');
h_colorbar = colorbar('peer', h.axes_example_mov);
ylabel(h_colorbar, [opUnits ' counts/time bin']);

h.param.sim.matGauss = gaussMat;
guidata(h_fig, h);




