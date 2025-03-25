# Battery Simulation Model

This MATLAB function `battSIM` simulates the electrical behavior of a battery using an equivalent circuit model. It calculates the battery's state of charge (SOC), open-circuit voltage (OCV), transient currents, and terminal voltage based on a given current profile.

## Define battery parameters for the simulation
```matlab

% State-of-Charge (SOC) vs Open-Circuit Voltage (OCV) lookup table
% Each row represents a (SOC, OCV) pair
Batt.SOC_OCV_LUT = [
    0.0000    2.5000  % Fully discharged
    0.0050    2.8080
    0.0352    3.1179
    0.0854    3.3182
    0.1357    3.4193
    0.2915    3.5826
    0.4523    3.6941
    0.8392    4.0664
    0.9548    4.1121
    1.0000    4.2000  % Fully charged
];

Batt.soc0 = 0.5;  % % Initial SOC at the start of the simulation (0 to 1)

Batt.Q = 4;     % Battery capacity in ampere-hours (Ah)
Batt.R0 = 0.02; % Internal resistance of the battery (Ohms)

% First RC circuit parameters
Batt.R1 = 0.01;   % Resistance in first RC network (Ohms)
Batt.C1 = 100;    % Capacitance in first RC network (Farads)

% Second RC circuit parameters (not used in 1RC model)
Batt.R2 = 0;      % Resistance in second RC network (Ohms)
Batt.C2 = 0;      % Capacitance in second RC network (Farads)

% Model type used for the battery simulation
% Options: 'Rint', '1RC', '2RC'
Batt.ModelID = '1RC';  % Using a single RC circuit model

% Run simulator
[vbatt, ibatt, soc, ocv, delta, i1] = battSIM(I, t, Batt);
