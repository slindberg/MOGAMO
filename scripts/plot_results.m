clear;
run('./test_functions');

for test_name = keys(test_function_map)
    test_obj = test_function_map(test_name{1});

    % Load ideal result files
    filename = strcat('../results/', test_name{1}, '.mat');
    results = load(filename, '-ascii');
    
    x_frac = 0:100; l_frac = length(x_frac);
    x_fnc = 1:6; l_fnc = length(x_fnc);
    y_max = mean(results(:,3)) + 3*std(results(:,3));
    figure('Name', test_name{1});

    for i_fnc = x_fnc
        i_r = (i_fnc-1)*l_frac + 1;
        fnc_range = i_r:(i_r+l_frac-1);
        X = results(fnc_range,1);
        Y = results(fnc_range,3);

        subplot(3, 2, i_fnc);
        plot(X, Y, ...
            'Marker', '.', ...
            'MarkerSize', 10, ...
            'LineStyle', 'none');
        title(crossover_fnc_label(i_fnc));
        xlabel('Crossover Fraction');
        ylabel('f_{meta}');
        ylim([0 y_max]);
        pbaspect([3 1 1])
    end
end

function label = crossover_fnc_label(x)
    switch x
        case 1
            label = 'Scattered';
        case 2
            label = 'Single Point';
        case 3
            label = 'Two Point';
        case 4
            label = 'Intermediate';
        case 5
            label = 'Heuristic';
        case 6
            label = 'Arithmetic';
    end

end