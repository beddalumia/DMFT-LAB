function colorlab_importall()
%% Imports ALL functionality from the COLORLAB
%
%  >> colorlab_importall()
%  makes available the palette namespace(s)
%
%  See also: colorlab, palette, paletteshow, paletteditor

    % Relative path building...
    path_to_plot = fileparts(mfilename('fullpath'));
    path_to_repo = erase(path_to_plot,'+plotDMFT');
    path_to_clab = [path_to_repo, 'lib/colorlab/'];

    % Add colorlab library folders to path
    addpath(path_to_clab); colorlab.enter('quiet');
    
end