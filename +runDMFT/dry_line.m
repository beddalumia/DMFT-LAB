function dry_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop,varargin)
%% Runs a U-line with no other convergence control than writing U_conv.txt
%
%   runDMFT.dry_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop,varargin)
%
%   EXE                 : Executable driver
%   doMPI               : Flag to activate OpenMPI
%   Uold                : Restart point [NaN or empty -> no restart]
%   Ustart,Ustep,Ustop  : Input Hubbard interaction [Ustart:Ustep:Ustop]
%   varargin            : Set of fixed control parameters ['name',value]

%% Print docstring if no input is provided
if nargin < 1
   help runDMFT.dry_line
   return
end

if sign(Ustop-Ustart) ~= sign(Ustep)
   Ustep = -Ustep;
   warning('Changed sign to Ustep to avoid infinite loops!');
end

Ulist = fopen('U_list.txt','a');
Uconv = fopen('U_conv.txt','a');

%% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

U = Ustart; 
while abs(U-Ustep-Ustop) > abs(Ustep)/2
%                        ≥ 0 would sometimes give precision problems

    unconverged = runDMFT.single_point(EXE,doMPI,U,Uold,varargin{:});

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
    if unconverged
       fprintf(Ulist,'%f\n', NaN); % Update Ulist with a null value
    else
       fprintf(Ulist,'%f\n', U);   % Update Ulist with actual value
       fprintf(Uconv,'%f\n', U);   % Update Uconv only if converged
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Uold = U;
    U = U + Ustep;                  % Hubbard update  

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(Ulist); fclose(Uconv);

end


