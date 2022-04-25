function fig = spectral_frame(filename,style,varargin)
%% SPECTRAL_GIF: Builds a GIF for the line-evolution of the spectral functions
%
%   >> plotDMFT.spectral_frame(filename,style,varargin)
%
%  filename : filename of the complex spectral function to be plotted
%  style    : plotting style to be passed to internal 1d-plotter ['line','area','scatter']
%  varargin : additional options passed to internal 1d-plotter (e.g. 'FaceColor', etc...)
%  ------------------------------------------------------------------------

    % Load complex function of real/imag frequency z
    F = load(filename);

    % Assign domain, real and imag part according to QcmPlab convention
    z  = F(:,1);
    rF = F(:,3);
    iF = F(:,2);

    % Init figure
    fig = figure("Name",filename);

    % Plot both real and imag parts of F
    if ~exist('style','var'); style = 'area'; end
    cplot(z,rF,style,varargin{:}); hold on
    cplot(z,iF,style,varargin{:});

    % Legend, Labels
    legend('Real part','Imaginary part');
    if      any(strfind(filename,'realw'))
                xlabel('$\omega$','Interpreter','latex');
    elseif  any(strfind(filename,'iw'))
                xlabel('$i\omega$','Interpreter','latex');
    end
    [~,body,~] = fileparts(filename);
    ylabel(body,'Interpreter','none');

    % Limits
    xlim([z(1),z(end)]);
    try % To deal with self-energies
    ylim([min(min(rF),min(iF)),max(max(rF),max(iF))]);
    catch
    ylim([-1,1]);
    end

end

%% Custom overloaded 1d-plotter
function cplot(x,y,style,varargin)

    if     strcmp(style,'area')

                area(x,y,'FaceAlpha',0.5,varargin{:});

    elseif strcmp(style,'scatter')

                scatter(x,y,'filled',varargin{:});

    else   % default: line-plot

                plot(x,y,varargin{:});

    end

end
