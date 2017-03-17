clear;
addpath('./utils');

% Create test function mappings
run('./scripts/test_functions');

outer_options = gaoptimset(...
    'Generations', 60, ...
    'PopulationSize', 20, ...
    'PlotFcn', {@gaplotscores,@gaplotdistance,@gaplotselection, ...
        @gaplotscorediversity,@gaplotgenealogy}, ...
    'Display', 'iter', ...
    'UseParallel', true ...
);

% x1: 'CrossoverFraction'
% x2: 'CrossoverFcn'
lower_bound = [ 0 1 ];
upper_bound = [ 100 6 ];
integer_vars = [ 1 2 ];
n_samples = 50;

% The test_function_map var contains structs that describe a test problem
for test_name = keys(test_function_map)
    test_obj = test_function_map(test_name{1});

    % Load ideal pareto front points
    filename = strcat('./data/pareto_', test_name{1}, '.mat');
    pareto_ideal = load(filename, '-ascii');

    fn = @(x) mogamo_objective(x, n_samples, test_obj, pareto_ideal);

    tic
    x_best = ga(fn, 2, [], [], [], [], ...
        lower_bound, upper_bound, [], integer_vars, outer_options);
    toc

    fprintf('\nBest options for %s:\n', test_name{1});
    decode_moga_options(x_best)
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
    options = gaoptimset(decode_moga_options(x));
    options.Vectorized = 'on';
    options.Display = 'off';
end

function options = decode_moga_options(x)
    % Crossover method
    switch x(2)
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

    options = struct(...
        'CrossoverFraction', x(1)*0.01, ...
        'CrossoverFcn', crossover_fn ...
    );
end