function check_energies()
%% Loads all impurity energy values in a U-line and builds a stacked-plot
%  >> plotDMFT.check_energies()
    [ids,E_cell,U_list] = postDMFT.energy_line();
    E_matrix = [cell2mat(E_cell)];
    try
        Kin_vect = postDMFT.kinetic_line(U_list);
        E_matrix = [E_matrix,Kin_vect];
    catch
        disp("No kinetic energy available, skipping it.")
    end
    s = stackedplot(U_list,E_matrix);
    xlabel("Hubbard U")
    try
        s.DisplayLabels = [ids,"Kin"];
    catch
        s.DisplayLabels = [ids];
    end
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.4, 0, 0.2, 1]);
end