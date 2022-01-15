function [ids,ens,U_list]  = energy_line(U_LIST)
%% Getting a list of energy values, from directories.
%  U_LIST: an array of values for Hubbard interaction U (could be empty!)
%  ids: a cell of strings, the QcmPlab names for the pot-energy terms 
%  ens: a cell of float-arrays, corresponding to the names above
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
    cellEn = cell(Nu,1);
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
        [ids, cellEn{iU}] = postDMFT.get_energies();
        cd('..');
    end
    % We need some proper reshaping
    Nids = length(ids);
    ens = cell(1,Nids);
    for jEn = 1:Nids
        ens{jEn} = zeros(Nu,1);
        for iU = 1:Nu
           ens{jEn}(iU) = cellEn{iU}(jEn);
        end
        filename = [ids{jEn},'.txt'];
        writematrix(ens{jEn},filename,'Delimiter','tab');
    end
    U_list = U_LIST;
end

