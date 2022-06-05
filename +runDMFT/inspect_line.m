function [conv_ratio,tot_points,unconv_pts] = inspect_line(print_list)%#ok
%% To monitor convergence ratio and total number of points at runtime.
%
%   [conv_ratio,tot_points,unconv_pts] = runDMFT.inspect_line(print_list)
%
%   conv_ratio   : Percentage of converged points
%   tot_points   : Total number of computed points
%   unconv_pts   : List of unconverged points [U-values]
%   print_list   : Flag to activate printing of unconv_pts [default: don't]
%
%   It also logs the info to stdout, if nargout == 0 [interactive usage]

% Load files to read (un)converged U-values
U_conv = load('U_conv.txt');
U_list = load('U_list.txt');

% Compute output variables
tot_points = length(U_list); 
unconv_pts = setdiff(U_list,U_conv);
conv_ratio = length(U_conv)/tot_points*100;

% Print to standard output
if nargout == 0
   fprintf('\n\n')
   fprintf('Total number of points: %d (so far)\n', tot_points)
   fprintf('Converged points ratio: %d%% (so far)\n', round(conv_ratio))
end
% Somewhat awful, but comfy :)
if nargin > 0
  disp(unconv_pts) 
end

end