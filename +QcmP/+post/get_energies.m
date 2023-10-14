function [names, energies] = get_energies()
%% Getting all information from energy_last.ed and energy_info.ed
%
%       [names, energies] = QcmP.post.get_energies()
%
%  names: a cell of strings, the QcmPlab names for the pot-energy terms
%  energies: an array of float values, corresponding to the names above
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    energies = load('energy_last.ed');
    try % MATLAB >= R2019a
        names = readcell('energy_info.ed','FileType','fixedwidth');
        names(strcmp(names,'#'))=[];
        for i = 1:length(names)
            tempstr = names{i};                 % Temporary string variable
            tempstr  = erase(tempstr,'<');      % Deletes the thermal-average
            tempstr  = erase(tempstr,'>');      % brakets from the names...
            head = sscanf(tempstr,'%d');        % Extracts the initial integer
            head = int2str(head);               % Int to Str conversion
            names{i} = erase(tempstr,head);     % Proper beheading ;D
        end
    catch
        names = cell(length(energies),1);
        for i=1:length(energies)
            names{i} = sprintf('energy#%d',i);
        end
        warning('Could not read energy_info.ed, you might want to look at it yourself.')
    end
end




