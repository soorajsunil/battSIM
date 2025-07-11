function [vbatt, ibatt, soc, ocv] = battSIM(I, t, Batt, sigma_i, sigma_v)


if nargin==3;sigma_i=0; sigma_v=0; end % If only three arguments are provided, set noise values to zero
I = I(:); t = t(:); % ensure input current and time vectors are column vectors

% Extract battery parameters from the input structure 
soc0        = Batt.soc0;        % Initial state of charge (SOC)
Q           = Batt.Q;           % Battery capacity (Ah)
R0          = Batt.R0;          % Battery internal resistance (Ohm)
ModelID     = Batt.ModelID;     % Battery model identifier {'R0','1RC','2RC','3RC'}
SOC_OCV_LUT = Batt.SOC_OCV_LUT; % 2-D SOC-OCV Lookup table

% Extract circuit model parameters
if isfield(Batt,'R1'); R1 = Batt.R1; else; R1 = NaN; end
if isfield(Batt,'C1'); C1 = Batt.C1; else; C1 = NaN; end
if isfield(Batt,'R2'); R2 = Batt.R2; else; R2 = NaN; end
if isfield(Batt,'C2'); C2 = Batt.C2; else; C2 = NaN; end
if isfield(Batt,'R3'); R3 = Batt.R3; else; R3 = NaN; end
if isfield(Batt,'C3'); C3 = Batt.C3; else; C3 = NaN; end

%% Coulomb counting SOC

diff_t = diff(t);                          % Compute time differences
Ts     = [diff_t(1); diff_t]; clear diff_t % Ensure delta has the same size

% Initialize SOC using the first current sample
soc    = nan(size(I)); % Initialize SOC array
soc(1) = soc0 + I(1)*(Ts(1))/(Q*3600);

for k = 2:length(I)
    % Trapezoidal integration for SOC estimation
    soc(k) = soc(k-1) + (I(k) + I(k-1)) * Ts(k) / (2*Q*3600);

    % Limit SOC to valid range [0,1]
     soc(k) = min(max(soc(k), 0), 1);  % Clamp between 0 and 1
end

%% Determination of OCV via SOC-OCV lookup
ocv = interp1(SOC_OCV_LUT(:,1),SOC_OCV_LUT(:,2),soc,'linear','extrap');

%% Compute terminal voltage drop based on the selected battery model
switch ModelID
    case {'Rint','R0'}
        vdrop = I*R0;
    case '1RC'
        vdrop = I*R0 + vRC(I,Ts,R1,C1);
    case '2RC'
        vdrop = I*R0 + vRC(I,Ts,R1,C1) + vRC(I,Ts,R2,C2);
    case '3RC'
        vdrop = I*R0 + vRC(I,Ts,R1,C1) + vRC(I,Ts,R2,C2) + vRC(I,Ts,R3,C3);
    otherwise
        error('invalid ModelID')
end

%% Compute battery terminal voltage and current with added noise
vbatt = ocv + vdrop + sigma_v*randn(size(vdrop));  % Battery noisy terminal voltage
ibatt = I + sigma_i*randn(size(I));                % Battery noisy current

end

% ---- RC Dynamics Function ----
function v = vRC(I, Ts, R, C)
    alpha = exp(-Ts./(R*C));
    i1 = zeros(size(I));
    i1(1) = (1 - alpha(1)) * I(1);
    for k = 2:length(I)
        i1(k) = alpha(k) * i1(k-1) + (1 - alpha(k)) * I(k);
    end
    v = R*i1;
end