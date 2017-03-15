clear;
addpath('./utils');

% Create test function mappings
run('./scripts/test_functions');

outer_options = gaoptimset(...
    'Generations', 5, ...
    'PopulationSize', 10, ...
    'PlotFcn', {@gaplotscores,@gaplotdistance,@gaplotselection, ...
        @gaplotscorediversity,@gaplotgenealogy}, ...
    'Display', 'iter' ...
);

% x1: 'Generations'
% x2: 'CrossoverFraction'
lower_bound = [ 1 0 ];
upper_bound = [ 400 100 ];
integer_vars = [ 1 2 ];

% The gamultiobj_test_map var contains function handles that run the
% gamultiobj() function for the test function with the given options
for test_name = keys(gamultiobj_test_map)
    test_fn = gamultiobj_test_map(test_name{1});

    % Load ideal pareto front points
    filename = strcat('./data/pareto_', test_name{1}, '.mat');
    pareto_ideal = load(filename, '-ascii');

    fn = @(x) mogamo_objective(x, test_fn, pareto_ideal);

    x_best = ga(fn, 5, [], [], [], [], ...
        lower_bound, upper_bound, [], integer_vars, outer_options);

    fprintf('Best options for %s:\n\n', test_name{1});
    create_moga_options(x_best)
end

function fitness = mogamo_objective(x, test_fn, pareto_ideal)
    inner_options = create_moga_options(x);

    [~, f_vals] = test_fn(inner_options);

    fitness = evaluate_moga_fitness(f_vals, pareto_ideal);
end

function fitness = evaluate_moga_fitness(pareto_cur, pareto_ideal)
    pareto_cur = atan_sort(pareto_cur);

    ideal_dists = nearest_distances(pareto_cur, pareto_ideal);
    neighbor_dists = neighbor_distances(pareto_cur);

    fitness = mean(ideal_dists) + std(neighbor_dists);
end

function options = create_moga_options(x)
    options = gaoptimset(...
        'Generations', x(1)*25, ...
        'CrossoverFraction', x(2)*0.01, ...
        'Vectorized', 'on', ...
        'Display', 'off' ...
    );
end