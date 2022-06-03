function [S_list,U_list] = sig_line(suffix,U_LIST)
%% Getting a list of scattering rate values, from directories. 
%
%       [S_list,U_list] = postDMFT.sig_line(suffix,U_LIST)
%
%  U_LIST: an array of values for Hubbard interaction U (could be empty!)
%  suffix: an optional charvec, handling inequivalent filename endings
%  S_list: a float-array, forall U, giving all the scattering rate values
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
    S_list = zeros(Nu,1);
    for iU = 1:length(U_LIST)
        U = U_LIST(iU);
        UDIR= sprintf('U=%f',U);
        if ~isfolder(UDIR)
           errstr = 'U_list file appears to be inconsistent: ';
           errstr = [errstr,UDIR];
           errstr = [errstr,' folder has not been found.'];
           error(errstr);
        end
        cd(UDIR);
        if(~isempty(suffix))
            filename = ['sig_last_',suffix,'.ed'];
        else
            filename = 'sig_last.ed';
        end
        if not(isfile(filename))
            S_list(iU) = NaN;
        else
            S_list(iU) = load(filename);
        end
        cd('..');
    end
    U_list = U_LIST;
    if(~isempty(suffix))
        filename = ['sig_',suffix,'.txt'];
    else
        filename = 'sig.txt';
    end
    postDMFT.writematrix(S_list,filename,'Delimiter','tab');
end