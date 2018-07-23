function [ subframe, subchannels ] = reselection_advanced( s, sensing, T1, T2, RRI, num_subchannels, current_subchannels, packet_subchannels )
%SENSING_AND_RESELECTION Sense the air interface and select available resources for transmission of packets
%   Return: selected subframe and subchannels

subframe = 0;
subchannels = [];

% Create congestion map for the resource candidates ((s+T1):(s+T2))
congestion_map = zeros(num_subchannels, T2-T1+1);
i = 1;
for subfr_window = (s+T1):(s+T2)
    subfr = subfr_window - RRI;
    while (subfr > s), subfr = subfr - RRI; end
    if (subfr > 0)
        if (subfr == s) % UE transmits in this subframe
            congestion_map(:,i) = 1; 
        else
            for subch = sensing{subfr}
                congestion_map(subch,i) = 1;
            end
        end
    end
    i = i + 1;
end
                    
% Generate resource candidates based on sensing
num_candidates = (num_subchannels-(packet_subchannels-1))*(T2-T1+1);
list_candidates = zeros(num_candidates, 1);
i = 1;
for subfr = 1:(T2-T1+1)
    for subch = 1:(num_subchannels-(packet_subchannels-1))
        if congestion_map(subch,subfr) == 0 && congestion_map(subch+packet_subchannels-1,subfr) == 0
            list_candidates(i) = 1; % '1's are candidates. '0's aren't candidates
        end
        i = i + 1;
    end
end

% List of resource candidates
pos_candidates = find(list_candidates);

% if (size(pos_candidates) ~= [1 0] ) % if there is any candidate
try
    % Randomly choose one of the candidates
    if length(pos_candidates) > 1
        candidate = randsample(pos_candidates, 1);
    elseif length(pos_candidates) == 1
        candidate = pos_candidates;
    else
        error('No candidate')
    end

    % Find which subframe and subchannels this candidate belongs to and
    % transmit there
    subfr_candidate = ceil(candidate/(num_subchannels-(packet_subchannels-1)));
    subframe = subfr_candidate + s + T1 - 1;
    aux = mod(candidate,(num_subchannels-(packet_subchannels-1)));
    if aux == 0
%         subchannels = 4:5;
        subchannels = (num_subchannels-packet_subchannels+1):num_subchannels;
    else
%         subchannels = aux:(aux+1);
        subchannels = aux:(aux+packet_subchannels-1);
    end
catch
    disp('Cannot find any available resource in the Resource Selection Window')
        
    subframe = s + RRI;
    subchannels = current_subchannels;
    
%     candidate_found = false;
%     subfr_window = s + T2;
%     
%     while (candidate_found == false)
%         congestion_map = zeros(num_subchannels,1);
%         subfr_window = subfr_window + 1;
%         subfr = subfr_window - RRI;
%         while (subfr > s), subfr = subfr - RRI; end
%         if (subfr > 0)
%             if (subfr ~= s) % UE transmits in this subframe
%                 congestion_map(sensing{subfr}) = 1;
%                 
%                 num_candidates = (num_subchannels-(packet_subchannels-1));
%                 list_candidates = zeros(num_candidates, 1);
%                 i = 1;
%                 for subch = 1:(num_subchannels-(packet_subchannels-1))
%                     if congestion_map(subch) == 0 && congestion_map(subch+packet_subchannels-1) == 0
%                         list_candidates(i) = 1; % '1's are candidates. '0's aren't candidates
%                     end
%                     i = i + 1;
%                 end
%                 pos_candidates = find(list_candidates);
%                 try
%                     candidate = randsample(pos_candidates, 1);
%                     subchannels = candidate:(candidate+packet_subchannels-1);
%                     subframe = subfr_window;
%                     candidate_found = true;
%                     disp('Next candidate found')
%                 catch
%                     continue
%                 end
%             end
%         end
%     end
        
end

if (subframe == 0)
    subframe = s + RRI;
    subchannels = current_subchannels;
end

end

