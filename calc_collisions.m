function [ collisions ] = calc_collisions( num_subchannels, L_sbch, sensing )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

collisions = 0;
if (num_subchannels == 1)
    if numel(sensing) == 0 || numel(sensing) == 1
        collisions = 0;
    else
        collisions = numel(sensing);
    end
else
    if (L_sbch == 1)
        subch_sensing = zeros(num_subchannels,1);
        for subch_s = 1:length(sensing)
            subch_sensing(sensing(subch_s)) = subch_sensing(sensing(subch_s)) + 1;
        end
        for subch_s = 1:num_subchannels
            if (subch_sensing(subch_s) > 1)
                collisions = collisions + subch_sensing(subch_s);
            end
        end
    elseif (L_sbch == 2)
        if (isempty(sensing))
            collisions = 0;
        else
            sensing = sensing(:)';
            sensing_aux = zeros(num_subchannels, 1);
            for subch_s = sensing
                sensing_aux(subch_s) = sensing_aux(subch_s) + 1;
            end

            subch_aux = zeros(num_subchannels-1,1);
            for i = 1:(length(sensing_aux)-1)
                subch_aux(i) = min(sensing_aux(i), sensing_aux(i+1));
                sensing_aux(i+1) = sensing_aux(i+1) - subch_aux(i);
            end
            for i = 1:length(subch_aux)
                if (i == 1)
                    if (subch_aux(i) ~= 1 || subch_aux(i+1) ~= 0)
                        collisions = collisions + subch_aux(i);
                    end
                elseif (i == length(subch_aux))
                    if (subch_aux(i) ~= 1 || subch_aux(i-1) ~= 0)
                        collisions = collisions + subch_aux(i);
                    end
                else
                    if (subch_aux(i) ~= 1 || subch_aux(i-1) ~= 0 || subch_aux(i+1) ~= 0)
                        collisions = collisions + subch_aux(i);
                    end
                end
            end
        end
    end
end
end

