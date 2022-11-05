function [states, probs] = get_pure_states(suffix,check)
%% Getting all information about pure states (cross-checking with the RDM)
%
%       [states, probs] = postDMFT.get_pure_states(suffix[,check])
%
%  states: a cell of pure-state vectors [states{i} is a complex array]
%  probs: an array of pure-state probabilities [probs(i) = 𝓟(states{i})]
%  suffix: a *required* charvec / string, handling inequivalent filenames
%  check: an optional boolean to activate the RDM crosscheck [default:F]
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(nargin<1)
        help postDMFT.get_pure_states
        return
    end
    if(~isempty(suffix))
        filename_p = ['probabilities_',suffix,'.dat'];
        filename_s = ['pure-states_',suffix,'.dat'];
    else
        filename_p = 'probabilities.dat';
        filename_s = 'pure-states.dat';
    end
    probs = load(filename_p);
    psmat = load(filename_s);
    if(nargin<2)
        check = false; 
    end
    Npure = length(probs);
    if(check)
        filename_rdm = sprintf('reduced_density_matrix_rank%d.dat',Npure);
        try
            RDM = postDMFT.get_Hloc(filename_rdm);
        catch
            RDM = load(filename_rdm); % imag part may be omitted if zero
        end
        %% ACHTUNG: our convention [probs(i) = 𝓟(states{i})] implies that
        %%          the matrix of states does not follow the convention of
        %%          linear algebra, i.e. usually the eigenvector matrix is
        %%          defined such that A=V*D*V', but for us A=V'*D*V [!🚨!]
        RDM_check = psmat' * diag(probs) * psmat;
        if any(abs(RDM-RDM_check)>1e-6)
           error('Saved pure-states do not reconstruct the RDM!');
        end
    end
    %% Reshape to cell
    states = cell(Npure,1);
    for i = 1:Npure
       states{i} = psmat(i,:);
    end
end


