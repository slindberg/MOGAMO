function y = fonsecafleming(x)
%FONSECAFLEMING n >= 1, -4 <= x <= 4
    [m,n] = size(x);
    k = 1/ sqrt(n);
    
    s = zeros(m, 1);
    for index = 1:n
        s = s + (x(:,index) - k).^2;
    end
    y(:,1) = 1 - exp(-s);

    s = zeros(m, 1);
    for index = 1:n
        s = s + (x(:,index) + k).^2;
    end
    y(:,2) = 1 - exp(-s);
end
