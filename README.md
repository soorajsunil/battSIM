# Battery Simulator - ``` battSIM ```

The MATLAB function ```battSIM``` simulates the electrical behavior of a battery using an equivalent circuit model. It computes:
- **State-of-charge estimation** using Coulomb counting.
- **Open-circuit voltage lookup** from a given SOC-OCV table.
- **RC transient current calculations** based on first, second, or third-order RC circuits.
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
Batt.R1 = 0.0015; Batt.C1 = 2400;
Batt.R2 = 0.0030; Batt.C2 = 1500;
Batt.R3 = 0.0080; Batt.C3 = 2000;
```

## Run simulator (without noise)
```matlab
[vbatt, ibatt, soc, ocv] = battSIM(I, t, Batt);
```

## Run simulator (with noise)
```matlab
sigma_v = 1e-3;  % Voltage measurement noise (V)
sigma_i = 1e-6;  % Current measurement noise (A)
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
