function check_fit()
%% CHECK_FIT loads all fit_*.ed files in current directory and makes a plot
%  >> plotDMFT.chec_fit()
    fit_list = dir('fit_*.ed');
    for i = 1:length(fit_list)
        fit_data = load(fit_list(i).name);
        Freq = fit_data(:,1);
        ImFG = fit_data(:,2);
        ReFG = fit_data(:,4);
        ImFT = fit_data(:,3);
        ReFT = fit_data(:,5);
        figure("Name",fit_list(i).name)
        s = stackedplot(Freq,[ReFG,ReFT,ImFG,ImFT]);
        xlabel("Matsubara Frequency")
        s.DisplayLabels = {'Re FG','Re Fit','Im FG','Im Fit'};
    end
end