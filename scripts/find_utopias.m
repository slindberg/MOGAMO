clear;

run('./test_functions');

% Find the utopia point for each test problem
for key = keys(test_function_map)
    test_obj = test_function_map(key{1});
    utopia = find_utopia(test_obj, 2);
    fprintf('Utopia for %s:\n\t%.9f\n\t%.9f\n\n', ...
        key{1}, utopia(1), utopia(2));
end

% Use the trusty fmincon to find the minimizers for each objective
function utopia = find_utopia(test_obj, n_objs)
    options = optimoptions('fmincon', 'Display', 'off');
    utopia = zeros(n_objs, 1);
    for i_obj = 1:2
        obj_fn = @(x) pick_objective(test_obj.fn, x, i_obj);
        [~,f_val] = fmincon(obj_fn, zeros(1, test_obj.n), ...
            [], [], [], [], test_obj.lb, test_obj.ub, [], options);
        utopia(i_obj, 1) = f_val;
    end
end

function f_val = pick_objective(f, x, n)
    f_vals = f(x);
    f_val = f_vals(n);
end