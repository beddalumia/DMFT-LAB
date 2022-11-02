function pure_states(suffix,check)
%% Visualizing all information about pure states, for a given point.
%
%       [states, probs] = get_pure_states(suffix[,check])
%
%  suffix: a *required* charvec / string, handling inequivalent filenames
%  check: an optional boolean to activate the RDM crosscheck [default:F]
%
%  ➜ it draws a pie chart with slices corresponding to p(i)*|c{i}(j)|^2,
%    where i spans the pure states, and p(i) is the associated probability
%    and j spans the Fock-space basis, as defined in QcmPlab libraries.
%    c{i}(j) are expansion coefficients for the pure states on the basis.
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if(nargin<1)
        help plotDMFT.pure_states
        return
    end
    if(nargin<2)
        check = false;
    end
    
    [c,p] = postDMFT.get_pure_states(suffix,check);
    
    weights = zeros(length(p)^2,1);
    labels = strings(length(p)^2,1);
    Np = length(p);
    for i = 1:Np
        for j = 1:Np
            stride = j + (i-1) * Np;
            weights(stride) = p(i) * norm(c{i}(j))^2;
            labels(stride) = num2str(stride);
        end
    end
    
    exploded = false(size(weights));
    exploded(weights>0.3) = true;
    labels(weights<0.3) = "";
    
    pie(weights,exploded,labels)
    
    
















end

