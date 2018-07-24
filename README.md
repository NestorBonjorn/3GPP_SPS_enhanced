# 3GPP sidelink SPS procedure simulator

This repo consists of a simulator of the SPS procedure used for sidelink communications such as in V2X communications as standardized by 3GPP in Release 14. Moreover, an enhancement of the current standardized system is also simulated. 

```matlab
%% Simulation parameters
proposal = true; % Flag indicating whether we use our proposed approach or not
num_simulations = 10; % Number of simulations
num_subframes_simulated = 1000000;                                  % Number of simulated subframes per simulation
cumul_cat = zeros(num_subframes_simulated/1000,num_simulations);    % It will store the different simulation results
```

