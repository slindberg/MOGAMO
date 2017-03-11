function y = kursawe(x)
%KURSAWE n = 3, -5 <= x <= 5
    m = size(x, 1);
    
    s = zeros(m, 1);
    for index = 1:2
        s = s - 10*exp(-0.2*sqrt(x(:,index).^2 + x(:,index+1).^2));
    end
    y(:,1) = s;

    s = zeros(m, 1);
    for index = 1:3
        s = s + abs(x(:,index)).^0.8 + 5*sin(x(:,index).^3);
    end
    y(:,2) = s;
end
