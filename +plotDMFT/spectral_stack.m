function spectral_stack(filename,dx,dy,cmap_name,ulist,which,varargin)
%% SPECTRAL_STACK: Builds a classic stacked plot for the requested spectral
%                  tensors, reading along a computed U-driven line
%
%   >> plotDMFT.spectral_stack(filename,dx,dy,cmap_name,ulist,which,varargin)
%
%  filename : filename of the complex spectral function to be plotted
%  dx       : horizontal step for stacking, in units of U, for proper scaling
%  dy       : vertical step for stacking, in units of U, for proper scaling
%  cmap_name: name of the desired colormap as a string (optional, see colorlab)
%  ulist    : an array of values for Hubbard interaction U (could be empty!)
%  which    : which function to plot? ['real' or 'imag', if not given both]
%  varargin : additional options to be passed to plotter
%
% NOTE: this plot would convey misleading information if the ulist is not
%       evenly spaced, in such case please consider spectral_gif instead.
%
% See also get_palette palette paletteshow
%  ------------------------------------------------------------------------
    if nargin < 1
       help plotDMFT.spectral_stack
       return
    end

    if nargin < 4 || isempty(cmap_name)
        cmap_name = 'berlin';
    end

    if nargin < 5 || isempty(ulist)
        [ulist, ~] = postDMFT.get_list('U'); 
    else
        ulist = sort(ulist);
    end
    
    if nargin < 6 || isempty(which)
        figure("Name",'real')
        plotDMFT.spectral_stack(filename,dx,dy,cmap_name,ulist,'real',varargin{:})
        figure("Name",'imag')
        plotDMFT.spectral_stack(filename,dx,dy,cmap_name,ulist,'imag',varargin{:})
        return
    end

    Nu = length(ulist);

    fprintf('Start stacking %s spectra...\n\n',which);

    plotDMFT.import_colorlab();
    colorlist = get_palette(cmap_name,Nu);

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
        f = plotDMFT.spectral_load(filename);

        % Plot f(x+dx)+dy curves
        switch which
            case 'real'
            plot(f.zeta+U*dx,f.real+U*dy,'Color',colorlist(iU,:),varargin{:});
            case 'imag'
            plot(f.zeta+U*dx,f.imag+U*dy,'Color',colorlist(iU,:),varargin{:});
        end
        % We could directly use waterfall(), but it requires Z to be a
        % meshgrid or something (a matrix) and the plotting to be done
        % outside of the loop: it would be also faster... and the plot
        % actually flexible regarding the 'viewpoint'. >>>> TODO? <<<<

        % Hold the figure handle
        hold on

        % Exit directory
        cd('..');

    end
    
    % Add label on x and y axis
    [~,body,~] = fileparts(filename);
    if      any(strfind(body,'realw'))
        xlabel('$\omega$','Interpreter','latex');
    elseif  any(strfind(body,'iw'))
        xlabel('$i\omega$','Interpreter','latex');
    end
    ylabel(body,'Interpreter','none');
    
    % Adjust title to highlight U values
    title([upper(which),' PART']);
    
    % Add legend (as a colorbar... which makes sense for an evenly spaced
    %             ulist, but that's already the case for the whole plot..)
    try 
        clim([min(ulist),max(ulist)]);
    catch % ver < R2022a
        caxis([min(ulist),max(ulist)]);
    end
    colormap(colorlist);
    cbar = colorbar('Location','eastoutside');
    cbar.Label.String = 'Hubbard interaction';
    
    fprintf('...DONE.\n\n');

end 
     