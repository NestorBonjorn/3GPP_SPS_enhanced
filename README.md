# 3GPP sidelink SPS procedure simulator

This repo consists of a simulator of the semi-persistens scheduling (SPS) procedure used for sidelink communications in mode 4, as standardized by 3GPP in Release 14. Moreover, an enhancement of the current standardized system can also be simulated. The standardized version is simulated if the `proposal` flag is set to `false` and our proposed enchancement is simulated if the `proposal` flag is set to `true`. Note, though, that this simulator is not a perfect recreation of the 3GPP-standardized system since the objective is not to take all the parameters of the system into account but to have a 'basic' simulator where it is easy to modify things and, therefore, to propose new enhancements. In this way, this simulator takes several assumptions: 

1. All UEs transmit periodically with the same rate, i.e., they use the same RRI value and they send packets of equal size. 
2. When generating resource candidates in the resource selection window, we consider as candidates the resources that were available in the previous RRI and we discard as candidates the resources that were occupied in the previous RRI. In both cases we do that regardless of a received power threshold since we do not simulate TX/RX power.
3. If a transmission is not colliding with another transmission, it will be correctly decoded by the other vehicles, but if two or more transmissions are colliding, we consider that all of them will be incorrectly decoded at the receivers. This assumption is only used for our proposed approach when simulating the counter transmission between UEs. In the rest of the simulator, we do not care about this assumption because the final output is transmission collision probability results, and not Block Error Rate, or Packet Delivery Ratio.

In order to run this simulator you just need to download the source code from this repo and run the `main.m` file. This will generate a plot (the output of the simulator) indicating the average transmission collision probability results over time between the different simulated UEs. The simulated 'time' depends on the number of subframes simulated in each simulation (indicated by `num_subframes_simulated`), and it is an average collision probability because we repeat the simulation several times (as defined in `num_simulations`) and we calculate the average of the different simulation results in order to obtain the final output. In each simulation, we randomly initialize the UEs configuration, i.e., the parameter values of the UEs at time zero.

The inputs if the simulator are the aforementioned `proposal` flag, the number of simulated UEs (indicated by `num_vehicles`), the different SPS parameters, such as `RRI`, `T1`, `T2`, `C1`, `C2` and `probResourceKeep`, and two frequency-related parameters (`N_subch` and `L_subch`). However, you can also change the aforementioned `num_subframes_simulated` or `num_simulations`.

## Parameters configuration

### Simulation parameters
The simulator starts by defining a set of simulation-related parameters, such as the flag indicating whether we simulate our proposed enhancement or not, the number of simulations from which we will take the average in order to obtain the final result, and the number of subframes simulated in each simulation. We also initialize the variable that will store the different simulation results as a matrix of zeros.

```matlab
proposal = true;                                                    % Flag indicating whether we use our proposed approach or not
num_simulations = 10;                                               % Number of simulations
num_subframes_simulated = 1000000;                                  % Number of simulated subframes per simulation
cumul_cat = zeros(num_subframes_simulated/1000,num_simulations);    % It will store the different simulation results
```

### General parameters
Then, we define general parameters such as the number of vehicles that we simulate and the `probResourceKeep` which is a parameter of the standardized SPS procedure that indicates the probability to keep the resources when the counter expires, i.e., when it reaches zero.

```matlab
num_vehicles = 10;      % Number of simulated vehicles
probResourceKeep = 0.4; % Probability to keep the resources when the counter expires
```

### Temporal parameters
Then, we define temporal parameters which basically consist of the SPS parameters. `RRI` is the time between two consecutive UE's transmissions, `T1` and `T2` define the boundaries of the resource selection window, and `C1` and `C2` define the set of counters (from C1 to C2, both inclusive) that can be chosen by a UE when its counter expires. By default, we assume a maximum latency requirement of 20 ms. For this reason, `RRI` and `T2` are set to 20 ms.

```matlab
RRI = 20;   % Resource Reservation Interval in miliseconds
T1 = 2;     % Resource selection window low boundary in miliseconds
T2 = 20;    % Resource selection window high boundary in miliseconds
C1 = 25;    % SL_RESOURCE_RESELECTION_COUNTER low boundary
C2 = 75;    % SL_RESOURCE_RESELECTION_COUNTER high boundary
```

### Frequency parameters
Finally, we define two frequency-related parameters: `N_subch` and `L_subch`. The former indicates the number of subchannels in the grid, and the latter the number of subchannels occupied by the packet to be transmitted. By default they are both set to 1 for the sake of simplicity.

```matlab
N_subch = 1;    % Number of subchannels in the grid
L_subch = 1;    % Number of subchannels that a packet occupies
```

## Simulation
