function interactive_line(EXE,doMPI,Uold,Umin,Ustep,Umax,varargin)
%% Runs an interactive U-line 
%  if dmft does not converge the point is reiterated: time to change the inputfile!

    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Uold                : Restart option [Uold<Umin]
    %   Umin,Ustep,Umax     : Input Hubbard interaction [Umin:Ustep:Umax]

    %   varargin            : Set of fixed control parameters

    Ulist = fopen('U_list.txt','a');

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    nonconvCNT = 0;     % Convergence-fail *counter*
    nonconvMAX = 5;     % Maximum #{times} we accept DMFT to fail [hard-coded...]
                        % --> Available time to modify the inputfile on the flight

    U = Umin;
    doUpdate = true;
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
        out = ' | tee LOG_dmft.txt';
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
            nonconvCNT = nonconvCNT + 1;
            movefile('ERROR.README','../ERROR.README');
        else
            fprintf(Ulist,'%f\n', U);	            % Write on U-log
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        cd ..                       % Exit the U-folder

        if nonconvCNT > nonconvMAX
            error('DMFT not converged: phase-span stops now!');         
        elseif 0 < nonconvCNT && nonconvCNT < nonconvMAX
            % You manage the workflow manually, by modifying on-the-flight the
            % **external** input-file at runtime. Very effective when feasible.
            doUpdate = false; % ---------------> So you don't want to update...
        end

        if doUpdate
            Uold = U;
            U = U + Ustep;          % Hubbard update  
        else
            U = Uold + Ustep; 		% old-Hubbard update (if nonconverged!)
        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(Ulist);

end
