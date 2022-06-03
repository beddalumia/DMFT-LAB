function spectral_gif(filename,style,dt,ulist,varargin)
%% SPECTRAL_GIF: Builds a GIF for the line-evolution of the spectral functions
%
%   >> plotDMFT.spectral_gif(filename,style,dt,ulist,varargin)
%
%  filename : filename of the complex spectral function to be plotted
%  style    : plotting style to be passed to plotDMFT.spectral_frame()
%  dt       : delay-time for the GIF frames, in seconds
%  ulist    : an array of values for Hubbard interaction U (could be empty!)
%  varargin : additional options passed to plotDMFT.spectral_frame()
%  ------------------------------------------------------------------------
    if ~exist('ulist','var') || isempty(ulist)
        [ulist, ~] = postDMFT.get_list('U'); 
    else
        ulist = sort(ulist);
    end

    Nu = length(ulist);

    fprintf('Start GIF building...\n\n');

    for iU = 1:Nu

        % Check for <U=%f> directory
        U = ulist(iU);
        UDIR = sprintf('U=%f',U);
        if ~isfolder(UDIR)
            errstr = 'U_list appears to be inconsistent: ';
            errstr = [errstr,UDIR];
            errstr = [errstr,' folder has not been found.'];
            error(errstr);
        end

        % Enter directory
        cd(UDIR); 

        % Pick and plot the requested filename
        plotDMFT.spectral_frame(filename,style,varargin{:});
        
        % Adjust title to highlight U value
        title(UDIR);

        % Exit directory
        cd('..');

        % Push frame to gif file
        [~,body,~] = fileparts(filename);
        plotDMFT.push_frame([body,'.gif'],iU,Nu,dt); close(gcf);

    end
    
    fprintf('...GIF has been built.\n\n');

end 
     