function unconverged = single_point(EXE,doMPI,U,Uold,varargin)    
%% Runs a single-point calculation given:
%
%   unconverged = runDMFT.single_point(EXE,doMPI,U,Uold,varargin)  
%
%   EXE                        : Executable driver
%   doMPI                      : Flag to activate OpenMPI
%   U                          : Input Hubbard interaction
%   Uold                       : Restart point [NaN or empty -> no restart]
%   varargin                   : Set of control parameters ['name',value]

%% Print docstring if no input is provided
if nargin < 1
   help runDMFT.single_point 
   return
end

UDIR=sprintf('U=%f',U);        % Make a folder named 'U=...', where '...'
mkdir(UDIR);                   % is the given value for Hubbard interaction
cd(UDIR);                      % Enter the U-folder

if(~exist('Uold','var'))
    Uold = [];                 % no restart
end

oldDIR=sprintf('../U=%f',Uold);      % ------------------------------------
if isfolder(oldDIR)                  % If it exist a "previous" folder: 
restartpack = [oldDIR,'/*.restart']; % Copy all the restart files from the
copyfile(restartpack,'./');          % last dmft evaluation...
end                                  % ------------------------------------

copyfile('../input*','./');  % Copy inside the **external** input file

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
out = ' | tee LOG.out';                     % Better to print this
sys_call = [mpi,EXE,HUBBARD,VAR,out]%#ok    % to STDOUT...
tic
system(sys_call);                           % Fortran-call
chrono = toc;
file_id = fopen('LOG.time','w');            % Write on time-log
fprintf(file_id,'%f\n', chrono);
fclose(file_id);

%% HERE WE CATCH A FAILED (unconverged) DMFT LOOP %%%%%%%%%%%%%%%%%%%%%%%%%
errorfile = 'ERROR.README';
unconverged = isfile(errorfile);
if(unconverged)
   fprintf(2,['\n< ',sys_call,' > point has not converged!\n\n']); beep;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd ..                           % Exit the U-folder

end
