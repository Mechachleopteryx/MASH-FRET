function [ES,ok,str] = getES(i,p_proj,prm,fact,h_fig)

% collect FRET dimensions
FRET = p_proj.FRET;
S = p_proj.S;
nF = size(FRET,1);

% initialize results
ES = [];
ok = false;
str = [];

% build sample for analysis
m_i = p_proj.coord_incl;
N = size(m_i,2);
insubgroup = true(nF,N);

s = find(S(:,1)==FRET(i,1) & S(:,2)==FRET(i,2),1);
if isempty(s)
    insubgroup(i,:) = false;
else
    tag = prm(i,1)-1;
    if tag>0
        insubgroup(i,:) = m_i & p_proj.molTag(:,tag)';
        if ~sum(insubgroup(i,:))
            str = cat(2,'ES histograms could not be built (no molecule in',...
                ' subgroup)');
            return
        end
    else
        insubgroup(i,:) = m_i;
    end
end

% collect project data and parameters
I_den = p_proj.intensities_denoise;
nC = p_proj.nb_channel;
exc = p_proj.excitations;
nExc = p_proj.nb_excitations;
chanExc = p_proj.chanExc;
l_i = p_proj.bool_intensities;

% sample dimensions
N = size(m_i,2);
mls = 1:N;
mls = mls(m_i & sum(insubgroup,1)); % reduce the number of molecules to process to a minimum

% build FRET and stoichiometry traces
E_AD = [];
S_AD = [];
id_m = [];
if ~isempty(fact)
    gamma = fact(1,:);
    beta = fact(2,:);
else
    gamma = ones(1,nF);
    beta = ones(1,nF);
end

lb = 0;
h = guidata(h_fig);
if ~isfield(h, 'barData')
    loading_bar('init',h_fig,numel(mls)+1,'Build ES histograms ...');
    h = guidata(h_fig);
    h.barData.prev_var = h.barData.curr_var;
    guidata(h_fig, h);
    lb = 1;
end

for m = mls
    E_AD = cat(1,E_AD,calcFRET(nC,nExc,exc,chanExc,FRET,...
        I_den(l_i(:,m),((m-1)*nC+1):m*nC,:),gamma));
    S_AD = cat(1,S_AD,calcS(exc,chanExc,S,FRET,...
        I_den(l_i(:,m),((m-1)*nC+1):m*nC,:),gamma,beta));
    id_m = cat(2,id_m,repmat(insubgroup(:,m),1,sum(l_i(:,m))));
    
    if lb
        err = loading_bar('update', h_fig);
        if err
            str = 'ES histograms could not be built (process interruption)';
            return
        end
    end
end

s = find(S(:,1)==FRET(i,1) & S(:,2)==FRET(i,2));
if isempty(s)
    ES = NaN;
else
    E = E_AD(~~id_m(i,:),i);
    St = S_AD(~~id_m(i,:),s);

    [ES,~,~,~] = hist2D([E(:),1./St(:)],[prm(i,2:4);prm(i,5:7)],'fast');

    if lb
        err = loading_bar('update', h_fig);
        if err
            str = 'ES histograms could not be built (process interruption)';
            return
        end
    end
end

if lb
    loading_bar('close', h_fig);
end

ok = true;

