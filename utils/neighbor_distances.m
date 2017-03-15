function dists = neighbor_distances(x)
%NEIGHBOR_DISTANCES Calculate distance between adjacent points in the array
    dists = sqrt(sum((x(2:end,:) - x(1:end-1,:)).^2, 2));
end

