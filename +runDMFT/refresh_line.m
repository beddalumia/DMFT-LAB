function refresh_line(EXE,doMPI,Nnew,mode,varargin)
%% Refreshes a pre-existent calculation by Nnew loops [whole-line]
%
%   runDMFT.refresh_line(EXE,doMPI,Nnew,mode,varargin)
%
%   EXE                 : Executable driver
%   doMPI               : Flag to activate OpenMPI
%   Nnew                : How much loops to add in the refresh
%   mode                : Optional string defining whichˆ points to refresh
%   varargin            : Set of fixed control parameters ['name',value]
%
% ˆ['all': all subfolders, 'conv': read U_conv.txt, 'nonconv': all - conv]
%  >> default mode is 'nonconv'

%% Open file to write/update converged U-values
fileID_conv = fopen('U_conv.txt','a');

%% Default behavior if no provided ignConv
if nargin <= 3
   mode = 'nonconv';
end

%% Retrieve the list of *converged* U-values
U_conv = unique(sort(load('U_conv.txt')));

%% Retrieve the list of all available U-values
U_list = postDMFT.get_list('U');

%% Define which list of U-values refresh
switch mode
    
    case 'all'
        
        U = U_list;
        
    case 'conv'
        
        U = U_conv;
        if isempty(U) 
           warning('There are no converged points!')
        end
        
    case 'nonconv'
        
        U = setdiff(U_list,U_conv);
        if isempty(U) 
           warning('There are no unconverged points!')
        end
        
    otherwise

        error('Invalide mode.')
        
end

%% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(U)

    UDIR = sprintf('U=%f',U(i));   % Define the U-folder name.

    if isfolder(UDIR)
        cd(UDIR);                  % Enter the U-folder (if it exists)
    else
        errstr = 'U_list appears to be inconsistent: ';
        errstr = [errstr,UDIR];
        errstr = [errstr,' folder has not been found.'];
        error(errstr);
    end

    unconverged = runDMFT.refresh_point(EXE,doMPI,Nnew,varargin{:});

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
    if not(unconverged) && isempty(find(U_conv == U(i),1))
        fprintf(fileID_conv,'%f\n', U(i));      % Update U_conv, only
    end                                         % if *newly* converged
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cd ..                           % Exit the U-folder

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(fileID_conv);

end



