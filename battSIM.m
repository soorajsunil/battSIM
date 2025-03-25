function [vbatt, ibatt, soc, ocv, delta, i1, i2] = battSIM(I, t, Batt, sigma_i, sigma_v)

% If only three arguments are provided, set noise values to zero
if nargin==3;sigma_i=0; sigma_v=0; end

% Ensure input current and time vectors are column vectors
I = I(:);
t = t(:);

% Extract battery parameters from the input structure
Q    = Batt.Q; % Battery capacity (Ah)
soc0 = Batt.soc0; % Initial state of charge (SOC)

R0 = Batt.R0; % Internal resistance of the battery (Ohm)
R1 = Batt.R1; % First RC circuit resistance (Ohm)
C1 = Batt.C1; % First RC circuit capacitance (Farad)
R2 = Batt.R2; % Second RC circuit resistance (Ohm)
C2 = Batt.C2; % Second RC circuit capacitance (Farad)

SOC_OCV_LUT = Batt.SOC_OCV_LUT; % 2-D Lookup table for SOC vs OCV
 
h       = 0; % Hysteresis voltage component
ModelID = Batt.ModelID; % Battery model identifier

%% Coulomb counting to estimate SOC

soc    = nan(size(I)); % Initialize SOC array
diff_t = diff(t); % Compute time differences
delta  = [diff_t(1); diff_t]; clear diff_t % Ensure delta has the same size

% Initialize SOC using the first current sample
soc(1) = soc0 + I(1)*(delta(1))/(Q*3600);

for k = 2:length(I)

    % Trapezoidal integration for SOC estimation
    soc(k) = soc(k-1) + (I(k) + I(k-1)) * delta(k-1) / (2*Q*3600);
    
    % Limit SOC to valid range [0,1]
    if soc(k)>=1
        soc(k)=1;
    elseif soc(k)<=0
        soc(k)=0;
    else
        continue;
    end

end

%% Determination of OCV via SOC-OCV lookup
ocv = interp1(SOC_OCV_LUT(:,1),SOC_OCV_LUT(:,2),soc);

%% Determining current through R1 and R2

% Compute decay coefficients for first and second RC circuits
alpha1 = exp(-(delta/(R1*C1)));
alpha2 = exp(-(delta/(R2*C2)));

% Initialize arrays for transient currents through R1 and R2
i1  = nan(size(I));
i2  = nan(size(I));

% Compute initial transient currents
i1(1) = (1-alpha1(1))*I(1);
i2(1) = (1-alpha2(2))*I(1);

for k = 2:length(I)
    i1(k) = alpha1(k)*i1(k-1) + (1-alpha1(k))*I(k);
    i2(k) = alpha1(k)*i2(k-1) + (1-alpha1(k))*I(k);
end

%% Determination of Voltage drop and the Battery Terminal Voltage

% Compute terminal voltage drop based on the selected battery model
switch ModelID
    case {'Rint','R0'}
        vdrop= I*R0 + h;
    case '1RC'
        vdrop= I*R0 + i1*R1 + h;
    case '2RC'
        vdrop= I*R0 + i1*R1 + i2*R2 + h;
    otherwise
        error('invalid ModelID')
end

% Compute battery terminal voltage and current with added noise
vbatt = ocv + vdrop + sigma_v*randn(size(vdrop));  % Battery noisy terminal voltage
ibatt = I + sigma_i*randn(size(I));                % Battery noisy current

end