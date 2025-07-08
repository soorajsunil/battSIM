function [vbatt, ibatt, soc, ocv, i1, i2, i3] = battSIM(I, t, Batt, sigma_i, sigma_v)

% If only three arguments are provided, set noise values to zero
if nargin==3;sigma_i=0; sigma_v=0; end

% Ensure input current and time vectors are column vectors
I = I(:);
t = t(:);

% Extract battery parameters from the input structure
soc0        = Batt.soc0; % Initial state of charge (SOC)
Q           = Batt.Q;    % Battery capacity (Ah)
R0          = Batt.R0;   % Battery internal resistance (ohm)
ModelID     = Batt.ModelID; % Battery model identifier {'R0','1RC','2RC','3RC'}
SOC_OCV_LUT = Batt.SOC_OCV_LUT; % 2-D Lookup table for SOC vs OCV

% Extract circuit model parameters
if isfield(Batt,'R1'); R1 = Batt.R1; else; R1 = NaN; end
if isfield(Batt,'C1'); C1 = Batt.C1; else; C1 = NaN; end
if isfield(Batt,'R2'); R2 = Batt.R2; else; R2 = NaN; end
if isfield(Batt,'C2'); C2 = Batt.C2; else; C2 = NaN; end
if isfield(Batt,'R3'); R3 = Batt.R3; else; R3 = NaN; end
if isfield(Batt,'C3'); C3 = Batt.C3; else; C3 = NaN; end

%% Coulomb counting SOC
soc    = nan(size(I)); % Initialize SOC array
diff_t = diff(t); % Compute time differences
delta  = [diff_t(1); diff_t]; clear diff_t % Ensure delta has the same size

% Initialize SOC using the first current sample
soc(1) = soc0 + I(1)*(delta(1))/(Q*3600);

for k = 2:length(I)

    % Trapezoidal integration for SOC estimation
    soc(k) = soc(k-1) + (I(k) + I(k-1)) * delta(k) / (2*Q*3600);

    % Limit SOC to valid range [0,1]
     soc(k) = min(max(soc(k), 0), 1);  % Clamp between 0 and 1

end

%% Determination of OCV via SOC-OCV lookup
ocv = interp1(SOC_OCV_LUT(:,1),SOC_OCV_LUT(:,2),soc,'linear','extrap');

%% Compute decay coefficients for the RC circuits
alpha1 = exp(-(delta/(R1*C1)));
alpha2 = exp(-(delta/(R2*C2)));
alpha3 = exp(-(delta/(R3*C3)));

% Compute transient currents for the RC circuits
i1 = nan(size(I));
i2 = nan(size(I));
i3 = nan(size(I));
i1(1) = (1-alpha1(1))*I(1);
i2(1) = (1-alpha2(1))*I(1);
i3(1) = (1-alpha3(1))*I(1);
for k = 2:length(I)
    i1(k) = alpha1(k)*i1(k-1) + (1-alpha1(k))*I(k);
    i2(k) = alpha2(k)*i2(k-1) + (1-alpha2(k))*I(k);
    i3(k) = alpha3(k)*i3(k-1) + (1-alpha3(k))*I(k);
end

%% Compute terminal voltage drop based on the selected battery model
switch ModelID
    case {'Rint','R0'}
        vdrop= I*R0;
    case '1RC'
        vdrop= I*R0 + i1*R1;
    case '2RC'
        vdrop= I*R0 + i1*R1 + i2*R2;
    case '3RC'
        vdrop= I*R0 + i1*R1 + i2*R2 + i3*R3;
    otherwise
        error('invalid ModelID')
end

%% Compute battery terminal voltage and current with added noise
vbatt = ocv + vdrop + sigma_v*randn(size(vdrop));  % Battery noisy terminal voltage
ibatt = I + sigma_i*randn(size(I));                % Battery noisy current

end