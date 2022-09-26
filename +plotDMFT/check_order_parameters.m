function check_order_parameters(suffix)
%% Loads all order parameters in a U-line and builds a stacked-plot
%  >> plotDMFT.check_order_parameters(<suffix>)
%     suffix: an optional charvec, handling inequivalent filename endings
    if nargin < 1
        suffix = [];
    end
    [ids,O_cell,U_list] = postDMFT.order_parameter_line(suffix);
    O_matrix = cell2mat(O_cell);
    s = stackedplot(U_list,O_matrix);
    xlabel("Hubbard U")
    s.DisplayLabels = ids;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.4, 0, 0.2, 1]);
end