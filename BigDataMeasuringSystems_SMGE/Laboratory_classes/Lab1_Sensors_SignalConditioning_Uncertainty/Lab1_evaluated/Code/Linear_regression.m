function [approx_m,approx_b] = Linear_regression(x,y)
    arguments
        x {mustBeNumeric,mustBeReal}
        y {mustBeNumeric,mustBeReal}
    end
    
    % Get linear approximation
    [p, S] = polyfit(x,y,1);
    x1 = linspace(0,x(end));
    y1= polyval(p,x1, S);
    
    approx_m = p(1);
    approx_b = p(2);
    fprintf("y = %.4f.x + %.4f\n", approx_m, approx_b);
    
    % Display graph to be sure
    plot(x,y,'o');
    hold on; grid on;
    plot(x1,y1);
end
