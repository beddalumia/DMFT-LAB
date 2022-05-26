function refresh_line(EXE,doMPI,Nnew,ignConv,varargin)
%% Refreshes a pre-existent calculation by Nnew loops [whole-line]
    %
    %   runDMFT.refresh_line(EXE,doMPI,Nnew,ignConv,varargin)
    %
    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Nnew                : How much loops to add in the refresh
    %   ignConv             : Flag to ignore the U_conv.txt file [default=1]
    %   varargin            : Set of fixed control parameters ['name',value]

    %% Open file to write/update converged U-values
    fileID_conv = fopen('U_conv.txt','a');

    %% Default behavior if no provided ignConv
    if nargin <= 3
       ignConv = true;
    end

    %% Retrieve the list of the *converged* U-values
    U_converged = unique(sort(load('U_conv.txt')));

    %% Build the list of all U-values or use the converged ones only
    if isempty(U_converged) || ignConv == true
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

        unconverged = runDMFT.refresh_point(EXE,doMPI,Nnew,varargin{:});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        if not(unconverged) && isempty(find(U_converged == U,1))
            fprintf(fileID_conv,'%f\n', U);         % Update U_conv, only
        end                                         % if *newly* converged
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        cd ..                           % Exit the U-folder
  
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(fileID_conv);

end



