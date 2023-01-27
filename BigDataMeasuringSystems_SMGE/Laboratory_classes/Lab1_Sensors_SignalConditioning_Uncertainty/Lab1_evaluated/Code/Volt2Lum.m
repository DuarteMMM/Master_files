function [lum, uncert_lum] = Volt2Lum(volt, m, uncert_m, b, uncert_b)
    arguments
        volt (1,1) {mustBeNumeric,mustBeReal}
        m (1,1) {mustBeNumeric,mustBeReal}
        uncert_m (1,1) {mustBeNumeric,mustBeReal}
        b (1,1) {mustBeNumeric,mustBeReal}
        uncert_b (1,1) {mustBeNumeric,mustBeReal}
           
    end
    
    % Volt error (FOR 4V SCALE)
    err_volt = (0.5/100)*volt + 0.0005;
    
    % Lum value
    lum = (volt - b) / m;
    if lum <0
        lum = 0;
    end
        
    % Uncertainty 
    uncert_lum = sqrt((volt^2/m^4)*uncert_m^2 + (1/m^2)*(err_volt/sqrt(3))^2 + (1/m^2)*uncert_b^2);
    
    fprintf("Lum = %.4f\nEmax(lum)(95%%) = %.4f\n", lum, uncert_lum*1.96);
    
end