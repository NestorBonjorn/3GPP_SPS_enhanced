# 3GPP sidelink SPS procedure simulator

This repo consists of a simulator of the SPS procedure used for sidelink communications such as in V2X communications, as standardized by 3GPP in Release 14. Moreover, an enhancement of the current standardized system is also simulated.

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
