function pure_states(suffix,check)
%% Visualizing all information about pure states, for a given point.
%
%       >> plotDMFT.pure_states(suffix[,check])
%
%  suffix: a *required* charvec / string, handling inequivalent filenames
%  check: an optional boolean to activate the RDM crosscheck [default:F]
%
%  ➜ it draws a pie chart with slices corresponding to p(i)*|c{i}(j)|^2,
%    where i spans the pure states, and p(i) is the associated probability
%    and j spans the Fock-space basis, as defined in QcmPlab libraries.
%    The c{i}(j) are basis expansion coefficients for the pure states.
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    % Input checking
    if(nargin<1)
        help plotDMFT.pure_states
        return
    end
    if(nargin<2)
        check = false;
    end
    
    % Retrieve pure state data
    [c,p] = postDMFT.get_pure_states(suffix,check);
    
    % Dirty trick to extract number of sites from the suffix
    % [it would be improved once we standardize the suffix…]
    Nlat = sscanf(suffix,'%d');
    % Then we can determine number of local orbitals, too :)
    Nrdm = length(p);
    Norb = log2(Nrdm)/(2*Nlat); % Nrdm = 2^(2*Nlat*Norb)

    % Build the basis state weights (and labels)
    weights = zeros(Nrdm^2,1);
    labels = strings(Nrdm^2,1);
    for i = 1:Nrdm
        for j = 1:Nrdm
            stride = j + (i-1) * Nrdm;
            weights(stride) = p(i) * norm(c{i}(j))^2;
            labels(stride) = build_ket(j,c{i}(j));
        end
    end
    
    % Setup pie-chart metadata
    exploded = false(size(weights));
    exploded(weights > 0.3) = true;
    labels(weights < 0.3) = "";

    % Sort the slices
    [weights,indices] = sort(weights);
    exploded = exploded(indices);
    labels = labels(indices);
    
    % Finally plot the pie
    pie(weights,exploded,labels)

    % And set decent colors
    plotDMFT.import_colorlab
    set_palette('lines')

    %% FROM ED_SETUP:
    % |imp_up>|bath_up> * |imp_dw>|bath_dw>        <- 2*Nlat*Norb bits
    % |imp_sigma> = | (1…Norb)_1...(1…Norb)_Nlat > <--- Nlat*Norb bits
    % lso indices are: io = iorb + (ilat-1)*Norb + (ispin-1)*Norb*Nlat
    function ket = build_ket(state,coefficient)
        for ilat = 1:Nlat
            for ispin = 1:2
                shift = (ilat-1)*Norb + (ispin-1)*Norb*Nlat;
                vec(shift+(1:Norb)) = bitget(state,shift+(1:Norb));
            end
        end
        ketup = string(num2str(vec(1:Norb*Nlat)));
        ketdw = string(num2str(vec(Norb*Nlat+1:end)));
        ket = "| "+strrep(ketup,'1','↑')+" ; "+strrep(ketdw,'1','↓')+" 〉";
        ket = string(coefficient) + " × " +strrep(ket,'0',' • ');
    end
end

    
    