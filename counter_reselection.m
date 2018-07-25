function [ counter ] = counter_reselection( counter, sensing_counter, s, RRI, C2, num_vehicles )
%COUNTER_RESELECTION This function is used to perform counter reselection,
%i.e., our proposed enhancement to the current standardized SPS approach
%in 3GPP Release 14.
%   Return: selected counter (it may not change).

% Flag indicating whether we consider only counters lower than the UE's
% current counter when performing counter reselection.
lower = true;

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

%% Extend the counters list with neighbouring counters (RX_counters - 1)
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
            counter = counters_candidates;
        else
            disp('No counter candidate: keep current counter')
        end
    end
end


%% TODO
% Include packet loss probability, i.e., some counters may not be
% correctly received by the UE
end
