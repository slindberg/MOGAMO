function y = schaffer(x)
%SCHAFFER n = 1, -10 <= x <= 10
    y(:,1) = x.^2;
    y(:,2) = (x - 2).^2;
end
