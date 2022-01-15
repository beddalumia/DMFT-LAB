function [ids,obs,U_list] = observables_line(suffix,U_LIST)
%% Getting a list of variable values, from directories.
%  U_LIST: an array of values for Hubbard interaction U (could be empty!)
%  suffix: an optional charvec, handling inequivalent sites filename endings
%  ids: a cell of strings, the QcmPlab names of the observables 
%  obs: a cell of float-arrays, corresponding to the names above, forall U
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
    cellobs = cell(Nu,1);
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
        [ids, cellobs{iU}] = postDMFT.get_observables(suffix);
        cd('..');
    end
    % We need some proper reshaping
    Nobs = length(ids);
    obs = cell(1,Nobs);
    for jOBS = 1:Nobs
        obs{jOBS} = zeros(Nu,1);
        for iU = 1:Nu
           obs{jOBS}(iU) = cellobs{iU}(jOBS);
        end
    end
    U_list = U_LIST;
end

