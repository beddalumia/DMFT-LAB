function [ids,ordpms,U_list] = order_parameter_line(U_LIST)
%% Getting a list of variable values, from directories.
%  U_LIST: an array of values for Hubbard interaction U (could be empty!)
%  ids: a cell of strings, the names of the order parameters 
%  ordpms: a cell of arrays, corresponding to the names above, for all U
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    global ignUlist
    if isempty(U_LIST) || ignUlist == true
       [U_LIST, ~] = get_list('U'); 
    else
       U_LIST = sort(U_LIST);
    end
    % Then we can proceed spanning all the U-values
    Nu = length(U_LIST);
    cellordpms = cell(Nu,1);
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
        [ids, cellordpms{iU}] = get_order_parameters();
        cd('..');
    end
    % We need some proper reshaping
    Nordpms = length(ids);
    ordpms = cell(1,Nordpms);
    for jORDPMS = 1:Nordpms
        ordpms{jORDPMS} = zeros(Nu,1);
        for iU = 1:Nu
           ordpms{jORDPMS}(iU) = cellordpms{iU}(jORDPMS);
        end
    end
    U_list = U_LIST;
end