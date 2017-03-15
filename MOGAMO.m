clear;
addpath('./utils');

% Create test function mappings
run('./scripts/test_functions');

outer_options = gaoptimset(...
    'Generations', 5, ...
    'PopulationSize', 10, ...
    'PlotFcn', {@gaplotscores,@gaplotdistance,@gaplotselection, ...
        @gaplotscorediversity,@gaplotgenealogy}, ...
    'Display', 'iter', ...
    'UseParallel', true ...
);

% x1: 'Generations'
% x2: 'CrossoverFraction'
% x3: 'CrossoverFcn'
lower_bound = [ 1 0 1 ];
upper_bound = [ 400 100 6 ];
integer_vars = [ 1 2 3 ];
n_samples = 10;

% The test_function_map var contains structs that describe a test problem
for test_name = keys(test_function_map)
    test_obj = test_function_map(test_name{1});

    % Load ideal pareto front points
    filename = strcat('./data/pareto_', test_name{1}, '.mat');
    pareto_ideal = load(filename, '-ascii');

    fn = @(x) mogamo_objective(x, n_samples, test_obj, pareto_ideal);

    x_best = ga(fn, 5, [], [], [], [], ...
        lower_bound, upper_bound, [], integer_vars, outer_options);

    fprintf('Best options for %s:\n\n', test_name{1});
    create_moga_options(x_best)
end

function fitness = mogamo_objective(x, n_samples, test_obj, pareto_ideal)
    inner_options = create_moga_options(x);
    fitness_sample = zeros(n_samples, 1);

    for i_s = 1:n_samples
        [~, f_vals] = gamultiobj(test_obj.fn, test_obj.n, ...
            [], [], [], [], test_obj.lb, test_obj.ub, inner_options);

        fitness_sample(i_s) = evaluate_moga_fitness(f_vals, pareto_ideal);
    end

    fitness = mean(fitness_sample);
end

function fitness = evaluate_moga_fitness(pareto_cur, pareto_ideal)
    pareto_cur = atan_sort(pareto_cur);

    ideal_dists = nearest_distances(pareto_cur, pareto_ideal);
    neighbor_dists = neighbor_distances(pareto_cur);

    fitness = mean(ideal_dists) + std(neighbor_dists);
end

function options = create_moga_options(x)
    % Crossover method
    switch x(3)
        case 1
            crossover_fn = @crossoverscattered;
        case 2
            crossover_fn = @crossoversinglepoint;
        case 3
            crossover_fn = @crossovertwopoint;
        case 4
            crossover_fn = @crossoverintermediate;
        case 5
            crossover_fn = @crossoverheuristic;
        case 6
            crossover_fn = @crossoverarithmetic;
    end

    options = gaoptimset(...
        'Generations', x(1)*25, ...
        'CrossoverFraction', x(2)*0.01, ...
        'CrossoverFcn', crossover_fn, ...
        'Vectorized', 'on', ...
        'Display', 'off' ...
    );
end