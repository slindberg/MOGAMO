clear;
addpath('../utils');
run('./test_functions');

mm_options = optimoptions('fgoalattain', ...
    'FunctionTolerance', 1e-20, ...
    'StepTolerance', 1e-15, ...
    'MaxFunctionEvaluations', 1e4, ...
    'MaxIterations', 1e3, ...
    'Display', 'off' ...
);

% Using gamultiobj with the 'HybridFcn' gets a more exact pareto front by
% invoking fgoalattain on each solution with a good starting point,
% avoiding getting caught in local minima. Because every solution is passed
% to another optimizer, there's no need to throw out so many points, so
% 'ParetoFraction' is set to keep more points.
ga_options = gaoptimset(...
    'PopulationSize', 3000, ...
    'ParetoFraction', 0.75, ...
    'HybridFcn', {@fgoalattain,mm_options},...
    'Vectorized', 'on', ...
    'Display', 'off' ...
);

for test_name = keys(test_function_map)
    test_fn = gamultiobj_test_map(test_name{1});
    [~,pareto_full] = test_fn(ga_options);

    % Sort the criteria points acording to their arc position
    pareto_full = atan_sort(pareto_full);
    n_vals = length(pareto_full);

    % Define the maximum distance between two consecutive points in the
    % ideal pareto front to be two standard deviations above the mean
    % (this ensures a more uniform distribution)
    neighbor_dists = neighbor_distances(pareto_full);
    stats = regstats(1:length(neighbor_dists), neighbor_dists, 'linear');
    outlier_indices = find(stats.cookd > 100/length(neighbor_dists));
    neighbor_dists(outlier_indices,:) = [];
    min_dist = mean(neighbor_dists) + 2*std(neighbor_dists);

    % Initialize the final pareto front to the full size; it will be truncated
    % when the true size is known
    pareto_ideal = zeros(n_vals, 2);
    pareto_ideal(1,:) = pareto_full(1,:);
    i_p = 2;

    % Iterate through the values, comparing their neighbor's distance and
    % taking the furthest point away without exceeding the max distance
    i_f = 1;
    while i_f < n_vals
        i_d = i_f + 1;
        while i_d < n_vals && norm(pareto_full(i_d+1,:) - pareto_full(i_f,:)) < min_dist
            i_d = i_d + 1;
        end
        pareto_ideal(i_p,:) = pareto_full(i_d,:);
        i_p = i_p + 1;
        i_f = i_d;
    end

    % Truncate the pareto front to its true size
    pareto_ideal(i_p:end,:) = [];

    % Plot the pareto front
    figure;
    plot(pareto_ideal(:,1), pareto_ideal(:,2), '.');

    % Save the data to be loaded later
    filename = strcat('../data/pareto_', test_name{1}, '.mat');
    save(filename, 'pareto_ideal', '-ascii', '-double');
end
