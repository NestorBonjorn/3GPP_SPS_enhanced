% Number of simulations
num_simulations = 10;

% Number of simulated subframes per simulation
num_subframes_simulated = 1000000;

% It will store the different simulation results
cumul_cat = zeros(num_subframes_simulated/1000,num_simulations);

% Whether we use our proposed approach (proposal=true) or not 
% (proposal=false)
proposal = true;
    
%% General parameters
num_vehicles = 10;
probResourceKeep = 0;

%% Temporal parameters
RRI = 20; % Resource Reservation Interval in miliseconds
T1 = 2; % in miliseconds
T2 = 20; % in miliseconds
C1 = 63; % SL_RESOURCE_RESELECTION_COUNTER low boundary
C2 = 63; % SL_RESOURCE_RESELECTION_COUNTER high boundary

%% Frequency parameters
num_subchannels = 1; % Number of subchannels in the grid
packet_subchannels = 1; % Number of subchannels that a packet occupies
                        % (it depends on packet_size, num_subchannels 
                        % and bandwidth
    
for i = 1:num_simulations
    
    % Display current simulation number
    disp([num2str(i) ' simulation'])

    % UEs parameters initialization (random)
    UEs = struct('counter',{},'subframe',{},'subchannels',{});
    for UE = 1:num_vehicles
        UEs(UE).counter = randi([1,C2]);
        UEs(UE).subframe = randi([1,RRI]);
        subchannel_start = randi([1,num_subchannels-(packet_subchannels-1)]);
        UEs(UE).subchannels = subchannel_start:(subchannel_start+packet_subchannels-1);
    end

    %% Simulation
    % Subchannels used in each subframe.
    sensing = cell(num_subframes_simulated,1); 
    % Transmitted counter values in each subframe.
    sensing_counter = cell(num_subframes_simulated,1);
    % Number of collisions in each subframe.
    collisions = zeros(num_subframes_simulated,1); 
    % Number of transmissions in each subframe.
    num_transmissions_list = zeros(num_subframes_simulated,1); 
    
    % We iterate for each of the simulated subframes
    for s = 1:num_subframes_simulated
        if mod(s,100000) == 0
            disp(s)
        end
        
        % Dynamic scenario: every 10 seconds we randomly change the 
        % parameters for one of the UEs simulating that a new UE is 
        % entering into the system (and 1 UE is leaving)
        if (mod(s,10000) == 0)
            rand_UE = randi(num_vehicles);
            UEs(rand_UE).counter = randi([1,C2]);
            UEs(rand_UE).subframe = randi([s,s+RRI-1]);
            subchannel_start = randi([1,num_subchannels-(packet_subchannels-1)]);
            UEs(rand_UE).subchannels = subchannel_start:(subchannel_start+packet_subchannels-1);
        end
        
        % We iterate for each of the simulated vehicles
        for UE = 1:num_vehicles
            % If the current UE transmits in this subframe
            if UEs(UE).subframe == s 

                % If we simulate our proposed approach
                if proposal == true
                    % Perform counter reselection (if necessary)
                    UEs(UE).counter = counter_reselection_advanced(UEs(UE).counter, sensing_counter, s, RRI, C2, num_vehicles);
                    % Simulate the tranmission of the UE's current counter
                    sensing_counter{s}(end+1) = UEs(UE).counter;
                end
                
                % Simulate the current UE's transmission
                sensing{s} = vertcat(sensing{s},UEs(UE).subchannels(:));
                
                num_transmissions_list(s) = num_transmissions_list(s) + 1;

                % If the counter value is not zero don't trigger resource
                % reselection
                if UEs(UE).counter ~= 0
                    UEs(UE).subframe = s + RRI; % Reserve subframe
                    UEs(UE).counter = UEs(UE).counter - 1; % Update counter
                % If the counter value is zero, consider triggering 
                % resource reselection (depending on probResourceKeep)
                else
                    % With probability probResourceKeep don't trigger 
                    % resource reselection.
                    if rand() < probResourceKeep
                        UEs(UE).subframe = s + RRI; % Reserve subframe
                    
                    % With probability (1-probResourceKeep) trigger
                    % resource reselection
                    else
                        
                        %%% Sensing-based resource reselection
                        [subframe, subchannels] = reselection_advanced(s, sensing, T1, T2, RRI, num_subchannels, UEs(UE).subchannels, packet_subchannels);
                        UEs(UE).subframe = subframe;
                        UEs(UE).subchannels = subchannels;

                        %%% Random resource reselection
    %                     UEs(UE).subframe = s + randi([1,RRI]);
    %                     subchannel_start = randi([1,num_subchannels-(packet_subchannels-1)]);
    %                     UEs(UE).subchannels = subchannel_start:(subchannel_start+packet_subchannels-1);
                    end
                    UEs(UE).counter = randi([C1,C2]); % Update counter
                end
            end
        end

        % Count number of colliding tranmissions in this subframe
        collisions(s) = calc_collisions(num_subchannels, packet_subchannels, sensing{s});

        % If there is a collision in one subframe we delete the counters
        % from the variable that stores them in this subframe so that they
        % cannot be used for counter reselection in our proposed approach
        if proposal == true
            if collisions(s) > 0
                sensing_counter{s} = [];
            end
        end

    end

    % Total number of transmission collisions in this simulation
    num_collisions = sum(collisions);
    % Average transmission collision percentage in this simulation
    percentage_collisions = num_collisions / sum(num_transmissions_list) * 100;
    
    %% Results processing
    % We obtain cumulative transmission collision probability every 1 
    % second. 
    
    sim_cumul_collision_prob = zeros(num_subframes_simulated/1000,1);
    c = 1;
    for s = 1:num_subframes_simulated
        if mod(s,1000) == 0
            sim_cumul_collision_prob(c) = sum(collisions(1:s)) / sum(num_transmissions_list(1:s));
            c = c + 1;
        end
    end

    cumul_cat(:,i) = sim_cumul_collision_prob;
end

% Average over all simulation results
cumul_collision_prob = mean(cumul_cat,2);
semilogy(cumul_collision_prob)
grid on
xlabel("Time (s)")
ylabel("Average collision probability p_c")
