function dists = nearest_distances(x, x_ref)
%NEAREST_POINTS find the distance to the nearest point in a reference set
%   Assumes x_ref is sorted
    n_ref = length(x_ref);
    n_vals = length(x);
    dists = zeros(n_vals, 1);
    
    for i_cur = 1:n_vals
        for i_ref = 1:n_ref
            dist = norm(x(i_cur,:) - x_ref(i_ref,:));
            if dists(i_cur) == 0 || dist < dists(i_cur)
                dists(i_cur) = dist;
            else
                break;
            end
        end
    end
end

