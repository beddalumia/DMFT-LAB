function [kins,U_list]  = kinetic_line(U_LIST)
%% Getting a list of kinetic energy values, from directories.
%
%     [kins,U_list] = postDMFT.kinetic_line(U_LIST)
%
%  kins: an array of values for Kinetic energies, forall U
%  U_LIST: an optional array of values of Hubbard interaction: where to search
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
           errstr = 'U_list appears to be inconsistent: ';
           errstr = [errstr,UDIR];
           errstr = [errstr,' folder has not been found.'];
           error(errstr);
        end
        cd(UDIR); 
        if not(isfile('dmft_kinetic_energy.dat'))
           kins(iU) = NaN;
           cd('..');
           continue;
        end
        % The dmft_kinetic_energy.dat file has a weird structure...
        system('head -1 dmft_kinetic_energy.dat > tmp_energia_cinetica.txt');
        tempVec = load('tmp_energia_cinetica.txt'); % this should be safe...
        kins(iU) = tempVec(1); % For sure the 1st value is the total K.E.
        system('rm tmp_energia_cinetica.txt');
        cd('..');
    end
    filename = 'kinetic_energy.txt';
    postDMFT.writematrix(kins,filename,'Delimiter','tab');
    U_list = U_LIST;
end




