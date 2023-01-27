function [uncert_m, uncert_b] = Uncertainty(x, y, err_lux, err_volt)
    arguments
        x {mustBeNumeric,mustBeReal}
        y {mustBeNumeric,mustBeReal}
        err_lux {mustBeNumeric, mustBeReal}
        err_volt {mustBeNumeric, mustBeReal}
    end
    
    x_size = size(x);
    [p, S] = polyfit(x,y,1);   
    m = p(1);
    b = p(2);
    N = x_size(2);
    
    g = sum((x-mean(x)).*(y-mean(y)));
    h = sum((x-mean(x)).^2);
    
    % M
    deriv_x_m = (((y-mean(y)).*h) - (g.*(2.*(x-mean(x)))))/(h^2);
    deriv_y_m = ((x-mean(x)).*h)/(h^2);
    
    uncert_m_lux = sqrt(sum(deriv_x_m.^2 .* (err_lux/sqrt(3)).^2));
    uncert_m_volt = sqrt(sum(deriv_y_m.^2 .* (err_volt/sqrt(3)).^2));
    uncert_m = sqrt(sum(deriv_x_m.^2 .* (err_lux/sqrt(3)).^2) + sum(deriv_y_m.^2 .* (err_volt/sqrt(3)).^2));
    
    fprintf("uc(m) = %.4f\n",uncert_m)
    fprintf("uc(m)(SO LUX) = %.4f\nuc(m)(SO VOLT) = %.4f\n", uncert_m_lux, uncert_m_volt)
    fprintf("Emax(m)(95%%) = %f\nIntervalo(95%%) = [%f ; %f]\n", uncert_m*1.96, m-uncert_m*1.96, m+uncert_m*1.96)
    
    % B
    deriv_x_b = (-deriv_x_m.*mean(x) - m/N);
    deriv_y_b = ((1/N) - (deriv_y_m.*mean(x)));
    
    uncert_b_lux = sqrt(sum(deriv_x_b.^2 .* (err_lux/sqrt(3)).^2));
    uncert_b_volt = sqrt(sum(deriv_y_b.^2 .* (err_volt/sqrt(3)).^2));
    uncert_b = sqrt(sum(deriv_x_b.^2 .* (err_lux/sqrt(3)).^2) + sum(deriv_y_b.^2 .* (err_volt/sqrt(3)).^2));
    
    
    fprintf("\n\nuc(b) = %.4f\n",uncert_b)
    fprintf("uc(b)(SO LUX) = %.4f\nuc(b)(SO VOLT) = %.4f\n", uncert_b_lux, uncert_b_volt)
    fprintf("Emax(b)(95%%) = %f\nIntervalo(95%%) = [%f ; %f]\n", uncert_b*1.96, b-uncert_b*1.96, b+uncert_b*1.96)
    
end
