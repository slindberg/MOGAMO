clear;
run('./test_functions');

for test_name = keys(test_function_map)
    test_obj = test_function_map(test_name{1});

    % Load ideal pareto front points
    filename = strcat('../data/pareto_', test_name{1}, '.mat');
    pareto = load(filename, '-ascii');
    
    figure;
    plot(pareto(:,1), pareto(:,2), ...
        'Marker', '.', ...
        'MarkerSize', 10, ...
        'LineStyle', 'none');
    xlabel('f_1');
    ylabel('f_2');
end