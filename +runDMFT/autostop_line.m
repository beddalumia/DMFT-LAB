function autostop_line(EXE,doMPI,Uold,Umin,Ustep,Umax,varargin)
%% Runs a U-line with the most basic feedback: it stops when dmft does not converge

    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Uold                : Restart option [Uold<Umin]
    %   Umin,Ustep,Umax     : Input Hubbard interaction [Umin:Ustep:Umax]

    %   varargin            : Set of fixed control parameters

    Ulist = fopen('U_list.txt','a');

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    U = Umin; 
    while U <= Umax

        UDIR= sprintf('U=%f',U);       % Make a folder named 'U=...', where '...'
        mkdir(UDIR);                   % is the given value for Hubbard interaction
        cd(UDIR);                      % Enter the U-folder

        oldDIR=sprintf('../U=%f',Uold);      % ------------------------------------
        if isfolder(oldDIR)                  % If it exist a "previous" folder: 
        restartpack = [oldDIR,'/*.restart']; % Copy all the restart files from the
        copyfile(restartpack);               % last dmft evaluation...
        end                                  % ------------------------------------

        copyfile ../input*             % Copy inside the **external** input file

        %% Run FORTRAN code (already compiled and added to PATH!) %%%%%%%%%%%%%%%%%
        if doMPI
            mpi = 'mpirun ';                        % Control of MPI
        else                                        % boolean flag...
            mpi = [];
        end
        HUBBARD =sprintf(' uloc=%f',U);             % OVERRIDE of Uloc
        VAR = [];                                   % and
        for i = 1:(length(varargin)-1)              % ALL
            VARname = varargin{i};                  % the
            VARsval = char(string(varargin{i+1}));  % OTHER
            VAR = [VAR,' ',VARname,'=',VARsval];    % PARAMETERS
        end		        
        out = ' > LOG_dmft.txt';
        dmft_ed_call = [mpi,EXE,HUBBARD,VAR,out];
        tic
        system(dmft_ed_call);                       % Fortran-call
        chrono = toc;
        file_id = fopen('LOG_time.txt','w');        % Write on time-log
        fprintf(file_id,'%f\n', chrono);
        fclose(file_id);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        if isfile('ERROR.README')
            fclose(Ulist);	            % U-list stops here
            error('DMFT not converged: phase-span stops now!')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        cd ..                           % Exit the U-folder

        fprintf(Ulist,'%f\n', U);       % Write on U-log

        Uold = U;
        U = U + Ustep;                  % Hubbard update  

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(Ulist);

end



