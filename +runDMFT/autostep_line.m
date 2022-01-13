function autostep_line(EXE,doMPI,Uold,Umin,Umax,varargin)
%% Runs a U-line with feedback-controlled steps: 
%  if dmft does not converge the point is discarded and the Ustep is reduced.

    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Uold                : Restart option [Uold<Umin]
    %   Umin,Umax           : Input Hubbard interaction [Umin<U<Umax]

    %   varargin            : Set of fixed control parameters

    Ulist = fopen('U_list.txt','a');

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Ustep = [.5,.25,.1,.05,.01];       % Let's keep them hard-coded...
    NUstep = length(Ustep);

    nonconvFLG = false;                % Convergence-fail *flag*
    nonconvCNT = 0;                    % Convergence-fail *counter*
    nonconvMAX = NUstep-1;             % Maximum #{times} we accept DMFT to fail

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
        for i = 1:2:(length(varargin)-1)            % ALL
            VARname = varargin{i};                  % the
            VARsval = char(string(varargin{i+1}));  % OTHER
            VAR = [VAR,' ',VARname,'=',VARsval];    % PARAMETERS
        end		        
        out = ' | tee LOG_out.txt';                 % Better to print this
        sys_call = [mpi,EXE,HUBBARD,VAR,out]        % to STDOUT...
        tic
        system(sys_call);                           % Fortran-call
        chrono = toc;
        file_id = fopen('LOG_time.txt','w');        % Write on time-log
        fprintf(file_id,'%f\n', chrono);
        fclose(file_id);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        if isfile('ERROR.README')
            nonconvFLG = true;
            nonconvCNT = nonconvCNT + 1;
            movefile('ERROR.README',sprintf('../ERROR_U=%f',U));
        else
            fprintf(Ulist,'%f\n', U);	            % Write on U-log
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        cd ..                           % Exit the U-folder

        if nonconvCNT > nonconvMAX
            error('Not converged: phase-span stops now!');         
        end 

        if nonconvFLG == true
            U = Uold; 			        % if nonconverged we don't want to update 
            nonconvFLG = false;	        % > but we want to reset the flag(!)
        else
            Uold = U; 			        % else we update Uold and proceed to...         
        end

        U = U + Ustep(notConvCount+1);  % ...Hubbard update  

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(Ulist);

end




