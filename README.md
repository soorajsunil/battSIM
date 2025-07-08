# Battery Simulator 

This MATLAB function `battSIM` simulates the electrical behavior of a battery using an equivalent circuit model. It calculates the battery's state of charge (SOC), open-circuit voltage (OCV), transient currents, and terminal voltage based on a given current profile. The `battSIM` function includes: 
- **State-of-charge estimation** using Coulomb counting.
- **Open-circuit voltage determination** from a given SOC-OCV lookup table.
- **Transient current calculations** based on first and second-order RC circuits.
- **Flexible battery models**, including options for internal resistance (`Rint`), single RC circuit (`1RC`), and double RC circuit (`2RC`).
- **Noise simulation** for both battery current and voltage.

## Define load current (depending on usage)
```matlab
dt    = 0.1;               % Time step (s)
Tmax  = 10;                % Maximum simulation time (s)
t     = (dt:dt:Tmax)';     % Time vector
I     = ones(size(t));     % Constant load current (1 A)
```

## Define battery parameters for the simulation
```matlab

% Battery parameters
Batt.soc0 = 0.5;    % Initial SOC (0 to 1)
Batt.Q    = 4;      % Capacity (Ah)
Batt.R0   = 0.02;   % Internal resistance (Ohms)

% SOC-OCV lookup table
Batt.SOC_OCV_LUT = [  
    0.0000    2.5000  
    0.0050    2.8080
    0.0352    3.1179
    0.0854    3.3182
    0.1357    3.4193
    0.2915    3.5826
    0.4523    3.6941
    0.8392    4.0664
    0.9548    4.1121
    1.0000    4.2000  
];

% RC circuit parameters
Batt.ModelID = '3RC';  % Model type: 'R0', '1RC', '2RC', '3RC'
Batt.R1 = 0.01; Batt.C1 = 100;
Batt.R2 = 0.02; Batt.C2 = 100;
Batt.R3 = 0.02; Batt.C3 = 100;
```

## Run simulator
```matlab
[vbatt, ibatt, soc, ocv] = battSIM(I, t, Batt);
```

## Run simulator (with noise)
```matlab
sigma_v = 1e-3; % voltage measurement noise standard deviation 
sigma_i = 1e-6; % current measurement noise standard deviation 
[vbatt, ibatt, soc, ocv] = battSIM(I, t, Batt, sigma_i, sigma_v);
```

## References
If you would like to learn more about battery modeling and battery management system design, refer to:

@book{balasingam2023robust,  
  title={Robust Battery Management System Design With MATLAB},  
  author={Balasingam, Balakumar},  
  year={2023},  
  publisher={Artech House}  
}

For more details on SOC-OCV lookup table: 
https://github.com/soorajsunil/Piecewise-Battery-OCV
