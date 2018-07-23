function [ counter ] = counter_reselection_advanced( counter, sensing_counter, s, RRI, C2, num_vehicles )
%COUNTER_RESELECTION Summary of this function goes here
%   Detailed explanation goes here

lower = true;

%% TODO
% Include packet loss probability, i.e., some counters may not be
% correctly received by the UE

%% Create counters list (all the counters received in the last RRI interval)
if (counter > 2)
    counters_list = zeros(num_vehicles,1);
    i = 1;
    for subfr = (s-RRI+1):(s-1)
        if subfr > 0
            for c = sensing_counter{subfr}
                counters_list(i) = c;
                i = i + 1;
            end
        end
    end

%% Extend the counters list with neighbouring counters
    extended_counters_list = unique(counters_list);
    iterable = extended_counters_list(:)';
    for n = iterable
        if n ~= 0
            extended_counters_list(end+1) = n-1;
%             extended_counters_list(end+1) = n+1;
%         else
%             extended_counters_list(end+1) = 1;
        end
    end
    extended_counters_list = unique(extended_counters_list);

%% Update current counter if necessary
    if ismember(counter, counters_list)
        
        % Generate candidates list
        if lower == true
            counters_candidates = setdiff(1:(counter-1),extended_counters_list);
        else
            counters_candidates = setdiff(1:C2,extended_counters_list);
        end
        
        % Choose one of the available counters
        if (length(counters_candidates) > 1)
            counter = randsample(counters_candidates, 1);
        elseif (length(counters_candidates) == 1)
            % Choose counter candidate with probability 0.5 or keep
            % current counter with probability 0.5
%             if rand() > 0.5
%                 counter = counters_candidates;
%             end
            
            % Choose available counter
            counter = counters_candidates;
        else
            disp('No counter candidate: keep current counter')
        end
    end
end
end
