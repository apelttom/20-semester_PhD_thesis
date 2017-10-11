function [overshoot,undershoot,stime] = measure_settling_time(t,u,utol,y,ref,start_time)
    stime = 0;
    start = 0;    
    start_index = 0;         
    for i = 2:size(t,1)
        if (t(i) < start_time)
            start_index = start_index + 1;
           continue;
        end
        if (abs(u(i-1) - u(i)) > utol)
            start = t(i);
            continue;
        end                 
        if (abs(y(i)-ref) < 0.02*ref) && (abs(y(i-1)-ref) > 0.02*ref)
            stime_iter = t(i)-start;         
            stime = max(stime,stime_iter);
        end
    end
    overshoot = max(y(start_index:end))-ref;
    undershoot = min(y(start_index:end))-ref;        
end
