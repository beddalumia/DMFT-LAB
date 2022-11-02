function [Z_list,U_list] = compute_zeta(filename,window,U_LIST)
%% Computing a list of Z-weight values, from self-energies on *real* axis.
%
%       [Z_list,U_list] = postDMFT.compute_zeta(filename,window,U_LIST)
%
%  Z_list: a float-array, forall U, giving all the quasiparticle weight values
%  filename: an optional charvec, specifying which self-energy term to load
%  window: an optional window for the fit, abs(w)≤window [default 0.01]
%  U_LIST: an optional array of values of Hubbard interaction: where to search
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if ~exist('U_LIST','var') || isempty(U_LIST)
       [U_LIST, ~] = postDMFT.get_list('U'); 
    else
       U_LIST = sort(U_LIST);
    end
    if ~exist('window','var') || isempty(window)
       window = 0.01; 
    end
    % Then we can proceed spanning all the U-values
    Nu = length(U_LIST);
    Z_list = zeros(Nu,1);
    for iU = 1:length(U_LIST)
        U = U_LIST(iU);
        UDIR= sprintf('U=%f',U);
        if ~isfolder(UDIR)
           errstr = 'U_list appears to be inconsistent: ';
           errstr = [errstr,UDIR];
           errstr = [errstr,' folder has not been found.'];
           error(errstr);
        end
        cd(UDIR);
        if(~exist('filename','var') || isempty(filename))
            allfiles = dir('impSigma*realw.ed');
            filename = allfiles(1).name;
        end
        if(~contains(filename,'Sigma'))
           warning('The file may not contain a self-energy.'); 
        end
        if(~contains(filename,'realw'))
           warning('This algorithm works for the real part only.'); 
        end
        SIGMA = plotDMFT.spectral_load(filename);
        Z_list(iU) = fit_Zweight(SIGMA,window);
        cd('..');
    end
    U_list = U_LIST;
    suffix = erase(erase(filename,'impSigma_'),'realw.ed');
    if(~isempty(suffix))
        filename = ['zeta_',suffix,'realw.txt'];
    else
        filename = 'zeta_realw.txt';
    end
    postDMFT.writematrix(Z_list,filename,'Delimiter','tab');
end

function Z = fit_Zweight(Sigma,w_th)
%% FIT_ZWEIGHT extracts the Landau quasiparticle weight from \Sigma(\omega)
%
%  Input:
%       Sigma : complex valued array, in the plotDMFT.spectral_load format
%       w_th  : threshold for the fit, abs(w)≤w_th
%  Output:
%       Z     : 1 / ( 1 - d/dw[Re\Sigma]@w=0 )
%
%% BSD 3-Clause License
% 
%  Copyright (c) 2020, Gabriele Bellomia [adapted from MOTTlab]
%  All rights reserved.

    w = Sigma.zeta; % Extract frequencies
    xToFit = w(abs(w)<=w_th); % Define fit window (domain)
    yToFit = real(Sigma.real(abs(w)<=w_th)); % Define fit window (codomain)
    
    LinearModel = polyfit(xToFit,yToFit,1); % Fit to linear model
    
    %% Nozieres Theorem: Re{\Sigma(w)} = A + (1-1/Z)w + O(w^3)
    Z = 1/(1-LinearModel(1)); 

end