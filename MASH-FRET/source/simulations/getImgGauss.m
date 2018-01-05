function [imgGauss,matGauss] = getImgGauss(lim, p, volume, varargin)
    
    if ~isempty(varargin) && ~isempty(varargin{1})
        isMat = 1;
        matGauss = varargin{1};
    else
        isMat = 0;
        matGauss = [];
    end
    
    imgGauss = zeros(lim.y(2)-lim.y(1)+1, lim.x(2)-lim.x(1)+1);

    % build multiple 2D gaussians function
    % A*exp(-0.5*(((X-x_0)/o_x).^2) - 0.5*(((Y-y_0)/o_y).^2))
    mltp_gauss_str = [];
    nGauss = size(p.amp,1);
    
    if ~isMat 
        n = 0;
        fprintf('\n---\n\n');
    end

    for g = 1:nGauss
        I_0 = p.amp(g,1);
        x_0 = p.mu(g,1);
        y_0 = p.mu(g,2);
        o_x = p.sig(g,1); % PSF widths mormalised to pixel units.
        o_y = p.sig(g,2);
        
        if ~isMat
            if volume
                mltp_gauss_str = [];
                A = 1/(2*pi*o_x*o_y);
            else
                A = 1;
            end

            if isempty(mltp_gauss_str)
                mltp_gauss_str = sprintf(['%d*exp(-((X-%d).^2)/(2*(%d^2))-' ...
                    '((Y-%d).^2)/(2*(%d^2)))'], A, x_0, o_x, y_0, o_y);

            else
                mltp_gauss_str = sprintf(['%s + ' ...
                    '%d*exp(-((X-%d).^2)/(2*(%d^2)) - ' ...
                    '((Y-%d).^2)/(2*(%d^2)))'], mltp_gauss_str, A, x_0, ...
                    o_x, y_0, o_y);
            end
        end

        if volume
            if (5*o_x)<1
                x_range = fix(x_0-1):ceil(x_0+1);
            else
                x_range = fix(x_0-5*o_x):ceil(x_0+5*o_x);
            end
            if (5*o_y)<1
                y_range = fix(y_0-1):ceil(y_0+1);
            else
                y_range = fix(y_0-5*o_y):ceil(y_0+5*o_y);
            end

            [x_pix y_pix] = meshgrid(x_range, y_range);
            x_pix = reshape(x_pix,[numel(x_pix) 1]);
            y_pix = reshape(y_pix,[numel(y_pix) 1]);

            excl = x_pix<lim.x(1) | x_pix>lim.x(2);
            excl = excl | y_pix<lim.y(1) | y_pix>lim.y(2);
            
            if ~isMat
                z = [];
                mltp_gauss = @(X,Y) eval(mltp_gauss_str);

                for i = 1:size(x_pix,1)
                    z(i,1) = quad2d(mltp_gauss, x_pix(i)-1, x_pix(i), ...
                        y_pix(i)-1, y_pix(i));
                end
                matGauss{g} = z/sum(z);
            end
            
            z = I_0*reshape(matGauss{g},numel(matGauss{g}),1);
            z(excl) = [];

            x_pix(excl) = []; y_pix(excl) = [];

            for i = 1:size(x_pix,1)
                imgGauss(y_pix(i),x_pix(i)) = ...
                    imgGauss(y_pix(i),x_pix(i))+z(i);
            end
        end
        if ~isMat && round(100*g/(nGauss))>n
            fprintf(['PSF numerical integration for each ' ...
                'pixel: %d%%\n'], round(100*g/(nGauss)));
            n = n+1;
        end
        
    end
    if ~volume
        mltp_gauss = @(X,Y) eval(mltp_gauss_str);
        [X_pix,Y_pix] = meshgrid(lim.x(1):lim.x(2),lim.y(1):lim.y(2));
        X_pix = reshape(X_pix,[numel(X_pix),1]) - 0.5;
        Y_pix = reshape(Y_pix,[numel(Y_pix),1]) - 0.5;
        V = mltp_gauss(X_pix,Y_pix);
        imgGauss = reshape(V,size(imgGauss));
    end
end

