function [L_list,U_list] = luttinger_line(suffix,U_LIST)
%% Getting a list of Z-weight values, from directories.
%
%       [L_list,U_list] = postDMFT.luttinger_line(suffix,U_LIST)
%
%  U_LIST: an array of values for Hubbard interaction U (could be empty!)
%  suffix: an optional charvec, handling inequivalent filename endings
%  L_list: a float-array, forall U, giving all the luttinger integral vals
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
    L_list = zeros(Nu,1);
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
            filename = ['luttinger_',suffix,'.dat'];
        else
            filename = 'luttinger.dat';
        end
        L_list(iU) = load(filename);
        cd('..');
    end
    U_list = U_LIST;
    if(~isempty(suffix))
        filename = ['luttinger_line_',suffix,'.txt'];
    else
        filename = 'luttinger_line.txt';
    end
    writematrix(L_list,filename,'Delimiter','tab');
end
