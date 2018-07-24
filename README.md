# 3GPP sidelink SPS procedure simulator

This repo consists of a simulator of the SPS procedure used for sidelink communications in mode 4, as standardized by 3GPP in Release 14. Moreover, an enhancement of the current standardized system can also be simulated. The standardized version is simulated if the `proposal` flag is set to `false` and our proposed enchancement is simulated if the `proposal` flag is set to `true`. Note, though, that this simulator is not a perfect recreation of the 3GPP-standardized system since the objective is not to take all the parameters of the system into account but to have a 'basic' simulator where it is easy to modify and so to propose new enhancements. In this way, this simulator takes several assumptions: 

1. All UEs transmit periodically with the same rate, i.e., they use the same RRI value and they send packets of equal size. 
2. The resources used by other UEs are occupied regardless of a received power threshold.
3. If a transmission is not colliding with another transmission, it will be correctly decoded by the other vehicles, but if two or more transmissions are colliding, we consider that all of them will be incorrectly decoded at the receivers. This assumption is only used for our proposed approach when simulating the counter transmission between UEs. In the rest of the simulator, we do not care about this assumption because the final output is transmission collision probability results, and not Block Error Rate, or Packet Delivery Ratio.

In order to run this simulator you just need to download the source code from this repo and run the `main.m` file. This will generate a plot (the output of the simulator) indicating the average transmission collision probability results over time between the different simulated UEs. The simulated 'time' depends on the number of subframes simulated in each simulation (indicated by `num_subframes_simulated`), and it is an average collision probability because we repeat the simulation several times and we calculate the average of the different simulation results in order to obtain the final output. In each simulation, we randomly initialize the UEs configuration, i.e., the parameter values of the UEs at time zero. The number of simulations is defined in `num_simulations`. 

The simulator takes as input

## Parameters configuration

The simulator starts by defining a set of simulation-related parameters, such as a flag indicating whether we simulate our proposed enchancement or not, the number of simulations from which we will take the average in order to obtain the final result and the number of subframes simulated in each simulation. We also initialize the variable that will store the different simulation results as a matrix of zeros.

```matlab
%% Simulation parameters
proposal = true;                                                    % Flag indicating whether we use our proposed approach or not
num_simulations = 10;                                               % Number of simulations
num_subframes_simulated = 1000000;                                  % Number of simulated subframes per simulation
cumul_cat = zeros(num_subframes_simulated/1000,num_simulations);    % It will store the different simulation results
```

Then, we define general parameters such as the number of vehicles that we simulate and the `probResourceKeep` which is a parameter of the standardized SPS procedure that indicates the probability to keep the resources when the counter expires, i.e., it reaches zero.

```matlab
%% General parameters
num_vehicles = 10;      % Number of simulated vehicles
probResourceKeep = 0.4; % Probability to keep the resources when the counter expires
```
