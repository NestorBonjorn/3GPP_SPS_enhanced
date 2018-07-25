# 3GPP sidelink SPS procedure simulator

This repo consists of a simulator that calculates transmission collision probabilities between UEs using the semi-persistent scheduling (SPS) procedure used for sidelink communications in mode 4, as standardized by 3GPP in Release 14. For that, we simulate a set of UEs that transmit to each other in a periodic manner. Moreover, an enhancement of the current standardized system can also be simulated. The standardized version is simulated if the `proposal` flag is set to `false` and our proposed enhancement is simulated if the `proposal` flag is set to `true`. Note, though, that this simulator is not a perfect recreation of the 3GPP-standardized system since the objective is not to take all the parameters of the system into account but to have a 'basic' simulator where it is easy to modify things and, therefore, to propose new enhancements. In this way, this simulator takes several assumptions: 

1. All UEs transmit periodically with the same rate, i.e., they use the same RRI value and they send packets of equal size. 
2. When generating resource candidates in the resource selection window, we consider as candidates the resources that were available in the previous RRI and we discard as candidates the resources that were occupied in the previous RRI. In both cases we do that regardless of a received power threshold since we do not simulate TX/RX power.
3. If a transmission is not colliding with another transmission, it will be correctly decoded by the other vehicles, but if two or more transmissions are colliding, we consider that all of them will be incorrectly decoded at the receivers. This assumption is only used for our proposed approach when simulating the counter transmission between UEs. In the rest of the simulator, we do not care about this assumption because the final output is transmission collision probability results, and not Block Error Rate, or Packet Delivery Ratio.

In order to run this simulator you just need to download the source code from this repo and run the `main.m` file in MATLAB. This will generate a plot (the output of the simulator) indicating the average transmission collision probability results over time between the different simulated UEs. The simulated 'time' depends on the number of subframes simulated in each simulation (indicated by `num_subframes_simulated`), and the result is an average collision probability because we repeat the simulation several times (as defined in `num_simulations`) and we calculate the average of the different simulation results in order to obtain the final output. In each simulation, we randomly initialize the UEs configuration, i.e., the parameter values of the UEs at time zero.

The inputs of the simulator are the aforementioned `proposal` flag, the number of simulated UEs (indicated by `num_vehicles`), the different SPS parameters, such as `RRI`, `T1`, `T2`, `C1`, `C2` and `probResourceKeep`, and two frequency-related parameters (`N_subch` and `L_subch`). However, you can also change the aforementioned `num_subframes_simulated` or `num_simulations`. All these parameters are described below.

## Parameters configuration

### Simulation parameters
The simulator starts by defining a set of simulation-related parameters, such as the flag (`proposal`) indicating whether we simulate our proposed enhancement or not, the simulated number of vehicles (`num_vehicles`), the number of simulations (`num_simulations`) from which we will take the average in order to obtain the final result, and the number of subframes simulated in each simulation (`num_subframes_simulated`). We also initialize the variable that will store the different simulation results as a matrix of zeros (`cumul_cat`).

```matlab
proposal = true;                                                    % Flag indicating whether we use our proposed approach or not
num_vehicles = 10;                                                  % Number of simulated vehicles
num_simulations = 10;                                               % Number of simulations
num_subframes_simulated = 1000000;                                  % Number of simulated subframes per simulation
cumul_cat = zeros(num_subframes_simulated/1000,num_simulations);    % It will store the different simulation results
```

### SPS parameters
Then, we define the SPS parameters. `RRI` is the time between two consecutive UE's transmissions, `T1` and `T2` define the boundaries of the resource selection window, `C1` and `C2` define the set of counters (from C1 to C2, both inclusive) that can be chosen by a UE when its counter expires, and `probResourceKeep` is the probability to keep the resources also when the counter expires. By default, we assume a maximum latency requirement of 20 ms; for this reason, `RRI` and `T2` are set to 20 ms.

```matlab
RRI = 20;   % Resource Reservation Interval in miliseconds
T1 = 2;     % Resource selection window low boundary in miliseconds
T2 = 20;    % Resource selection window high boundary in miliseconds
C1 = 25;    % SL_RESOURCE_RESELECTION_COUNTER low boundary
C2 = 75;    % SL_RESOURCE_RESELECTION_COUNTER high boundary
probResourceKeep = 0.4; % Probability to keep the resources when the counter expires
```

### Frequency parameters
Finally, we define two frequency-related parameters: `N_subch` and `L_subch`. The former indicates the number of subchannels in the grid, and the latter the number of subchannels occupied by the packet to be transmitted. By default they are both set to 1 for the sake of simplicity.

```matlab
N_subch = 1;    % Number of subchannels in the grid
L_subch = 1;    % Number of subchannels that a packet occupies
```

## Simulation
After that, we start the actual simulation by starting a 'for' loop that will iterate over each of the simulations. 

In each simulation, we start by initializing the UEs parameters at time zero. These parameters consist of the SL_RESOURCE_RESELECTION_COUNTER value, as well as the subchannels and the first subframe where they will transmit. 

```matlab
UEs = struct('counter',{},'subframe',{},'subchannels',{});
    for UE = 1:num_vehicles
        UEs(UE).counter = randi([1,C2]);                                        % SL_RESOURCE_RESELECTION_COUNTER
        UEs(UE).subframe = randi([1,RRI]);                                      % First subframe where the UE transmits
        subchannel_start = randi([1,N_subch-(L_subch-1)]);
        UEs(UE).subchannels = subchannel_start:(subchannel_start+L_subch-1);    % Subchannels where the UE transmits
    end
```

Then, we start a 'for' loop that will iterate over all the simulated subframes. In each subframe, we iterate over all the UEs in order to find if one or more UEs transmit in this subframe. For each UE that transmits in the current subframe, we simulate its transmission by updating the `sensing` variable, which stores the subchannels occupied in each simulated subframe. However, before that, if the `proposal` flag is set to `true`, we perform the counter reselection procedure by calling to the `counter_reselection` function, defined in the `counter_reselection.m` file. This will simulate our proposed enhancement, which consists in changing the UE's current counter value if another UE is using the same counter at the same time. In case the `proposal` flag is set to `true`, we also update the variable `sensing_counter`, which stores the counters sent in each subframe, simulating the transmission of the counters.

After that, we simulate the SPS procedure logic. That is, if the current UE's counter is different than 0, the UE keeps its current resources, i.e., reserves for transmission the subframe at a distance of RRI of the current subframe and the subchannels used for transmission are not modified. Moreover, its counter value is decreased by one. If the current UE's counter is 0, the UE will trigger resource reselection with probability `probResourceKeep` and will keep its current resources with probability (1 - `probResourceKeep`). In both cases, the UE chooses a new counter value between `C1` and `C2`. If resource reselection is triggered, the new subframe and the new subchannels where the UE will transmit are obtained from the `resource_reselection` function, defined in the `resource_reselection.m` file.

```matlab
% If the counter value is not zero don't trigger resource reselection
if UEs(UE).counter ~= 0
    UEs(UE).subframe = s + RRI;             % Reserve subframe
    UEs(UE).counter = UEs(UE).counter - 1;  % Update counter
% If the counter value is zero, consider triggering resource reselection (depending on probResourceKeep)
else
    % With probability probResourceKeep don't trigger resource reselection.
    if rand() < probResourceKeep
        UEs(UE).subframe = s + RRI; % Reserve subframe
    % With probability (1-probResourceKeep) trigger resource reselection
    else
        % Sensing-based resource reselection
        [subframe, subchannels] = reselection_advanced(s, sensing, T1, T2, RRI, N_subch, UEs(UE).subchannels, L_subch);
        UEs(UE).subframe = subframe;
        UEs(UE).subchannels = subchannels;
    end
    % Update SL_RESOURCE_RESELECTION_COUNTER
    UEs(UE).counter = randi([C1,C2]); 
end
```

The process above is performed for each UE that transmits in the current subframe. After that, we calculate the number of collisions in this subframe by using the `sensing` variable. If we are simulating our proposed enhancement (i.e., `proposal=true`) and there is a collision in this subframe, we delete the counters stored in the `sensing_counter` variable, so that they cannot be used by the UEs when performing counter reselection. If there is no collision, the UEs will be able to use the transmitted counter(s) in this subframe as information when performing counter reselection. This follows the aforementioned assumpion 3.

When all the simulations are done, we calculate the cumulative transmission collision probability every 1 second of each simulation and we store it in the `sim_cumul_collision_prob` list. In this way, the first value of `sim_cumul_collision_prob` contains the average transmission collision probability during the first second of the simulation (i.e., along the first 1000 subframes), the second value contains the average transmission collision probability during the first 2 seconds of the simulation (i.e., along the first 2000 subframes). Therefore, the last value of `sim_cumul_collision_prob` contains the average transmission collision probability along all the simulation. That's why we call the output 'cumulative'.

Finally, we take the average of all the resulting `sim_cumul_collision_prob` outputs, and we plot it. 
