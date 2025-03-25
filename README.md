# Battery Simulator 

This MATLAB function `battSIM` simulates the electrical behavior of a battery using an equivalent circuit model. It calculates the battery's state of charge (SOC), open-circuit voltage (OCV), transient currents, and terminal voltage based on a given current profile. The `battSIM` function includes: 
- **State-of-charge estimation** using Coulomb counting.
- **Open-circuit voltage determination** from a given SOC-OCV lookup table.
- **Transient current calculations** based on first and second-order RC circuits.
- **Flexible battery models**, including options for internal resistance (`Rint`), single RC circuit (`1RC`), and double RC circuit (`2RC`).
- **Noise simulation** for both battery current and voltage.

## Define load current (depending on usage)
```matlab
dt = 1;      % Time step in seconds
Tmax = 10;   % Maximum time in seconds
t  = (dt:dt:Tmax)';   % Time stamps from dt to Tmax
I  = 1*ones(size(t));  % Load current (constant 1 A for the simulation)
```

## Define battery parameters for the simulation
```matlab

% State-of-Charge (SOC) vs Open-Circuit Voltage (OCV) lookup table
Batt.SOC_OCV_LUT = [  % Each row represents a (SOC, OCV) pair
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
[vbatt, ibatt, soc, ocv] = battSIM(I, t, Batt);

```

## References
If you would like to learn more about battery modeling and battery management system design, refer to:

@book{balasingam2023robust,  
  title={Robust Battery Management System Design With MATLAB},  
  author={Balasingam, Balakumar},  
  year={2023},  
  publisher={Artech House}  
}
