function autostop_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop,varargin)
%% Runs a U-line with the most basic feedback: it stops when dmft does not converge
    %
    %   runDMFT.autostop_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop,varargin)
    %
    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Uold                : Restart point [NaN -> no restart]
    %   Ustart,Ustep,Ustop  : Input Hubbard interaction [Ustart:Ustep:Ustop]
    %   varargin            : Set of fixed control parameters ['name',value]

    if sign(Ustop-Ustart) ~= sign(Ustep)
       Ustep = -Ustep;
       warning('Changed sign to Ustep to avoid infinite loops!');
    end

    Ulist = fopen('U_list.txt','a');
    Uconv = fopen('U_conv.txt','a');

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    U = Ustart; 
    while abs(U-Ustep-Ustop) > abs(Ustep)/2
    %                  ≥ 0 would sometimes give precision problems

        unconverged = runDMFT.single_point(EXE,doMPI,U,Uold,varargin{:});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        if (unconverged)
            fprintf(Uconv,'%f\n',NaN); 
            fclose(Ulist); % U-list stops here
            error('Not converged: phase-span stops now!')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf(Uconv,'%f\n', U);    % Write on U-conv
        fprintf(Ulist,'%f\n', U);    % Write on U-list

        Uold = U;
        U = U + Ustep;               % Hubbard update  

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(Ulist); fclose(Uconv);

end




