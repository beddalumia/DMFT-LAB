function unconverged = single_point(EXE,doMPI,var,new,old,varargin)    
%% Runs a single-point calculation given:
%
%   unconverged = QcmP.run.single_point(EXE,doMPI,var,new,old,varargin) 
%
%   > runs a new point, in a $(var)=new directory, restarting from the
%     $(var)=old directory. Default vale of $(var) used to be "U", but
%     now is mandatory to pass it to the function. The "U" alias for 
%     "Uloc" continues to be supported, to avoid corrupting old data.
%
%   EXE                        : Executable driver
%   doMPI                      : Flag to activate OpenMPI
%   var                        : ID of the "main" variable (e.g. 'Uloc')
%   new                        : Input value for the new point
%   old                        : Restart point [NaN or empty -> no restart]
%   varargin                   : Set of control parameters ['name',value]

%% Print docstring if no input is provided
if nargin < 1
   help QcmP.run.single_point 
   return
end

DIR=sprintf('%s=%f',var,new); % Make a folder named 'var=...', where '...'
mkdir(DIR);                   % is the given value for MAINVAR interaction

if(~exist('old','var'))
   old = [];                  % no restart directory, so...
   copyfile('input*',DIR);    % copy inside the **external** input file
end

oldDIR=sprintf('%s=%f',var,old);      % ------------------------------------
if isfolder(oldDIR)                   % If it exist a "previous" folder: 
restartpack = [oldDIR,'/*.restart'];  % Copy all the restart files from the
copyfile(restartpack,DIR);            % last dmft evaluation... and also
copyfile([oldDIR,'/used.*'],DIR);     % copy the used input file, so to 
usedinput  = dir([DIR, '/used.*']);   % avoid silly errors when adding point
parts = strsplit(usedinput.name,'.'); % in between an existing line.
newname = cell2mat(join(parts(2:end),'.'));
oldpath = fullfile(DIR,usedinput.name);
newpath = fullfile(DIR,newname);
copyfile(oldpath,newpath);
else                                  % Else raise an appropriate error, the
error("Restart folder not found!")    % user should know there is no oldDIR.
end                                   % ------------------------------------

cd(DIR);                      % Enter the new-folder

%% Run FORTRAN code (already compiled and added to PATH!) %%%%%%%%%%%%%%%%%
if doMPI
   mpi = 'mpirun ';                         % Control of MPI
else                                        % boolean flag...
   mpi = [];
end
if strcmp(var,"U")
   MAINVAR = sprintf(' Uloc=%f',new);       % OVERRIDE of U (to Uloc)
else
   MAINVAR = sprintf(' %s=%f',var,new);     % Regular behavior
end
VARS = [];                                  % and
for i = 1:2:(length(varargin)-1)            % ALL
    VARname = varargin{i};                  % the
    VARsval = char(string(varargin{i+1}));  % OTHER
    VARS = [VARS,' ',VARname,'=',VARsval];  % PARAMETERS
end		        
out = ' | tee LOG.out';                     % Better to print this
sys_call = [mpi,EXE,MAINVAR,VARS,out];      % to STDOUT...
disp(sys_call)
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

cd ..                           % Exit the $(var)-folder

end
