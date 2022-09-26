function check_observables(suffix)
%% Loads all observables in a U-line and builds a stacked-plot
%  >> plotDMFT.chec_observables(<suffix>)
%     suffix: an optional charvec, handling inequivalent filename endings
    if nargin < 1
        suffix = [];
    end
    [ids,O_cell,U_list] = postDMFT.observables_line(suffix);
    O_matrix = cell2mat(O_cell);
    s = stackedplot(U_list,O_matrix);
    xlabel("Hubbard U")
    s.DisplayLabels = ids;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.4, 0, 0.2, 1]);
end