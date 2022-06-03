function [C_list,U_list] = custom_line(filename,U_LIST)
%% Getting a list of values, from custom files containing a single real value.
%
%       [C_list,U_list] = postDMFT.custom_line(filename,U_LIST)
%
%  filename: a *required* str/char, to provide the custom filename to look for
%  C_list: a double-precision array, forall U, giving all the retrieved values
%  U_LIST: an optional array of values of Hubbard interaction: where to search
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if ~exist('U_LIST','var') || isempty(U_LIST)
       [U_LIST, ~] = postDMFT.get_list('U'); 
    else
       U_LIST = sort(U_LIST);
    end
    % Then we can proceed spanning all the U-values
    Nu = length(U_LIST);
    C_list = zeros(Nu,1);
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
        if not(isfile(filename))
            C_list(iU) = NaN;
        else
            C_list(iU) = load(filename);
        end
        cd('..');
    end
    U_list = U_LIST;
    [~,filename] = fileparts(filename);
    filename = filename + ".txt"; % Always use txt extension
    postDMFT.writematrix(C_list,filename,'Delimiter','tab');
end

