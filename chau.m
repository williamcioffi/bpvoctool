function [outliers c] = chau(y, threshold)
% CHAU find outliers where the chau criteria is less than threshold
%	usage: [outliers c] = chau(y, threshold);
% 		y			-- input vector.
%		threshold 	-- chau threshold.
%		
%		outliers 	++ indices of outliers.
%		c			++ chau values
%~wrc
    
    ybar = mean(y);
    sigma = std(y);
    
    %sometimes length doesn't work this is a work around.
    ny = length(y);
    
    %calculate t for each datapoint in y
    for i = 1:ny
        t_sus(i) = (y(i) - ybar) / sigma;
    end
    
    %two tailed prop
    prob = 2 * (1 - normcdf(t_sus));
    
    %multiply by number of samples (ny)
    c = ny .* prob; 
    
    %find the outliers
    outliers = find(c < threshold);
end