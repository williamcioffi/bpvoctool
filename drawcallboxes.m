function [] = drawcallboxes(callst, callen)
    f(1) = 15;
    f(2) = 30;
    
    xx = [callst' callst' callen' callen' callst'];
    yy = [f(1) f(2) f(2) f(1) f(1)];
    
    for i=1:length(callst)
        hold on;
        plot(xx(i, :), yy, 'w');
        hold off;
        t = text(callst(i), 35, num2str(i));
        t.Color = [1 1 1];
    end
end