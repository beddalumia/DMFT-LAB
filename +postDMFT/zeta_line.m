function [Z_list,U_list] = zeta_line(suffix,U_LIST)
%% Getting a list of Z-weight values, from directories.
%
%       [Z_list,U_list] = postDMFT.zeta_line(suffix,U_LIST)
%
%  Z_list: a float-array, forall U, giving all the quasiparticle weight values
%  suffix: an optional charvec, handling inequivalent filename endings
%  U_LIST: an optional array of values of Hubbard interaction: where to search
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(~exist('suffix','var'))
      suffix = [];
    end
    if ~exist('U_LIST','var') || isempty(U_LIST)
       [U_LIST, ~] = postDMFT.get_list('U'); 
    else
       U_LIST = sort(U_LIST);
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
        if(~isempty(suffix))
            filename = ['zeta_last_',suffix,'.ed'];
        else
            filename = 'zeta_last.ed';
        end
        if not(isfile(filename))
            Z_list(iU) = NaN;
        else
            Z_list(iU) = load(filename);
        end
        cd('..');
    end
    U_list = U_LIST;
    if(~isempty(suffix))
        filename = ['zeta_',suffix,'.txt'];
    else
        filename = 'zeta.txt';
    end
    postDMFT.writematrix(Z_list,filename,'Delimiter','tab');
end