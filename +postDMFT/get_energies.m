function [names, energies] = get_energies()
%% Getting all information from energy_last.ed and energy_info.ed
%  names: a cell of strings, the QcmPlab names for the pot-energy terms
%  energies: an array of float values, corresponding to the names above
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    names = readcell('energy_info.ed','FileType','fixedwidth');
    names(strcmp(names,'#'))=[];
    for i = 1:length(names)
        tempstr = names{i};                 % Temporary string variable
        head = sscanf(tempstr,'%d');        % Extracts the initial integer
        head = int2str(head);               % Int to Str conversion
        names{i} = erase(tempstr,head);     % Proper beheading ;D
    end
    energies = load('energy_last.ed');
end