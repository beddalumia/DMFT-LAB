function [kins,U_list]  = kinetic_line(U_LIST)
%% Getting a list of energy values, from directories.
%
%     [kins,U_list]  = postDMFT.kinetic_line(U_LIST)
%
%  U_LIST: an array of values for Hubbard interaction U (could be empty!)
%  kins: an array of values for Kinetic energies, forall U
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if ~exist('U_LIST','var') || isempty(U_LIST)
       [U_LIST, ~] = postDMFT.get_list('U'); 
    else
       U_LIST = sort(U_LIST);
    end
    % Then we can proceed spanning all the U-values
    Nu = length(U_LIST);
    kins = zeros(Nu,1);
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
        
        % The dmft_kinetic_energy.dat file has a weird structure...
        strCell = readcell('dmft_kinetic_energy.dat'); % cell of strings
        tempStr = strCell{1};                          % single string
        tempVec = sscanf(tempStr,'%f');                % extract all the %f
        kins(iU) = tempVec(1); % For sure the 1st value is the total K.E.
        
        cd('..');
    end
    filename = 'kinetic_energy.txt';
    writematrix(kins,filename,'Delimiter','tab');
    U_list = U_LIST;
end

