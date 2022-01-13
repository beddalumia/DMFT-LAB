function refresh_line(EXE,doMPI,Nnew,ignList)
%% Refreshes a pre-existent calculation by Nnew loops

    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Nnew                : How much loops to add in the refresh
    %   ignList             : Flag to ignore the U_list.txt file

    %% Open file to write/update converged U-values
    fileID_list = fopen('U_list.txt','a');

    %% Retrieve the list of the *converged* U-values
    U_converged = unique(sort(load('U_list.txt')));

    %% Build the list of all U-values or use the converged ones only
    if isempty(U_converged) || ignList == true
       [U_list, ~] = postDMFT.get_list('U');  
    else
        U_list = U_converged;
    end

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for U = U_list'

        UDIR= sprintf('U=%f',U);       % Define the U-folder name.

        if isfolder(UDIR)
            cd(UDIR);                  % Enter the U-folder (if it exists)
        else
            errstr = 'U_list file appears to be inconsistent: ';
            errstr = [errstr,UDIR];
            errstr = [errstr,' folder has not been found.'];
            error(errstr);
        end

        %% Move used.input into input [crucial: we do not know about ctrl-vars!]
        % HOW TO DO THIS FOR A __GENERIC__ INPUTFILE <input*>
        % -> wildcards do not work in mv...

        %% Move *.used into *.restart [desirable: first new loop == last old loop!]
        usedpack = dir([pwd, '/*.used']);
        for i = 1:numel(usedpack)
            file = fullfile(pwd, usedpack(i).name);
            [tempDir, tempFile] = fileparts(file); 
            movefile(file, fullfile(tempDir, [tempFile, '.restart']));
        end

        %% Run FORTRAN code (already compiled and added to PATH!) %%%%%%%%%%%%%%%%%
        if doMPI
            mpi = 'mpirun ';                        % Control of MPI
        else                                        % boolean flag...
            mpi = [];
        end
        HUBBARD =sprintf(' uloc=%f',U);             % OVERRIDE of Uloc
        NLOOP = sprintf(' nloop=%d',Nnew);          % OVERRIDE of #{loops}
        out = ' | tee LOG_dmft.txt';                % STDOUT destination
        sys_call = [mpi,EXE,HUBBARD,NLOOP,out]
        tic
        system(sys_call);                           % Fortran-call
        chrono = toc;
        file_id = fopen('LOG_time.txt','w');        % Write on time-log
        fprintf(file_id,'%f\n', chrono);
        fclose(file_id);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        if ~isfile('ERROR.README') && isempty(find(U_converged == U,1))
            fprintf(fileID_Ulist,'%f\n', U);        % Update U-list, only
        end                                         % if *newly* converged
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        cd ..                           % Exit the U-folder
  
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(fileID_list);

end
