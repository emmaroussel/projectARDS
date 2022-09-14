% Routine which estimates the alveolar proportions of a mock subject: 1)
% run Simulink model for the subject with known proportions and extract its
% flow output; 2) apply the proportions estimation procedure to the mock
% subject measurements from 1).
%
% INPUTS:
%   alpha = proportion of healthy alveoli of mock subject
%   beta = proportion of recruitable alveoli of mock subject
% OUTPUTS:
%   alphaEst = estimated proportion of healthy alveoli of mock subject
%   betaEst = estimated proportion of recruitable alveoli of mock subject
%   gammaEst = estimated proportion of damaged alveoli of mock subject
%
% Sep 2022

%% 1) Obtain mock subject measurements (<=> runSimulinkMockSubject.m)

% Define mock subject
alpha   = 0.5;
beta    = 0.4;

%Open Simulink circuit (without window)
load_system("RHcircuit.slx");

%Retrieve reference circuit parameters and ventilator settings
fid_ref = fopen('referenceValues.in','r+'); 
[refCircuitVals,refVentilatorSet] = getReferenceValues(fid_ref);

%Set subject alveoli phenotype
params = getConfigValues(refCircuitVals,alpha,beta); 
setSimulinkModelValues(params);

%Create the ventilator pressure waveforms for the 3 cases
nCases = 3; %1: below TOP, 2: across TOP, 3: above TOP
sampleTime = 0.01;
numSteps = 501; 
time = sampleTime*(0:numSteps-1); 
time = time';
    
    % Case 1: below TOP (0 to 6 cmH20)
    ventilatorSetts1 = refVentilatorSet;
    inputSignal.case1 = getVentilatorPressure(time,ventilatorSetts1);
    inputSignal.case1 = inputSignal.case1';
    
    % Case 2: across TOP (7 to 13 cmH20)
    ventilatorSetts2 = refVentilatorSet;
    ventilatorSetts2.pmin = 7;
    ventilatorSetts2.pmax = 13;
    inputSignal.case2 = getVentilatorPressure(time,ventilatorSetts2);
    inputSignal.case2 = inputSignal.case2';
    
    % Case 3: above TOP (11 to 17 cmH20)
    ventilatorSetts3 = refVentilatorSet;
    ventilatorSetts3.pmin = 11;
    ventilatorSetts3.pmax = 17;
    inputSignal.case3 = getVentilatorPressure(time,ventilatorSetts3);
    inputSignal.case3 = inputSignal.case3';

pressures = struct2cell(inputSignal);
tExport = cell(nCases,1);
PExport = cell(nCases,1);
QExport = cell(nCases,1);

for i=1:nCases
    inputPressureData = timeseries(pressures{i},time);

    %Run circuit
    out = sim("RHcircuit.slx");
    
    %Extract and store P and Q
    tExport{i,1} = out.tout;
    PExport{i,1} = squeeze(out.logsout{1}.Values.Data);
    QExport{i,1} = squeeze(out.logsout{3}.Values.Data);
end

%At this point, we have the subject pressure and flow synthetic data for
%cases 1 to 3. So we can start the proportions estimation procedure

%% 2) Proportions Estimation Procedure from synthetic data

%Find Vs1 : subject tidal volume for Case 1 pressures
T = 60/ventilatorSetts1.RR; 
t = tExport{1,1};
indBeg = find(ismembertol(t,T,1e-6));
indEnd = find(ismembertol(t,2*T,1e-6));
tBreath = t(indBeg:indEnd);
Q = QExport{1,1};
V = cumtrapz(tBreath,Q(indBeg:indEnd));
Vs1 = max(V);

%Find Vmax of the circuit for Case 1 pressures and 1-0-0 proportions
params = getConfigValues(refCircuitVals,1,0); %Set proportions to 1-0-0
setSimulinkModelValues(params);
inputPressureData = timeseries(pressures{1},time);
out = sim("RHcircuit.slx"); 
[Vcircuit,~,~,~] = getVolumesMax(out,ventilatorSetts1.RR);

%Estimate alpha
alphaEst = Vs1/Vcircuit;

%Find Vs3: subject tidal volume for Case 3 pressures
T = 60/ventilatorSetts3.RR; 
t = tExport{3,1};
indBeg = find(ismembertol(t,T,1e-6));
indEnd = find(ismembertol(t,2*T,1e-6));
tBreath = t(indBeg:indEnd);
Q = QExport{3,1};
V = cumtrapz(tBreath,Q(indBeg:indEnd));
Vs3 = max(V);

%Find V0 of the circuit for Case 3 and alphaEst-0-(1-alphaEst) proportions
params = getConfigValues(refCircuitVals,alphaEst,0);
setSimulinkModelValues(params);
inputPressureData = timeseries(pressures{3},time);
out = sim("RHcircuit.slx"); 
[V0,~,~,~] = getVolumesMax(out,ventilatorSetts3.RR);

%Find V(1-alphaEst) of the circuit for Case 3 and alphaEst-(1-alphaEst)-0
%proportions
params = getConfigValues(refCircuitVals,alphaEst,1-alphaEst);
setSimulinkModelValues(params);
inputPressureData = timeseries(pressures{3},time);
out = sim("RHcircuit.slx"); 
[V1a,~,~,~] = getVolumesMax(out,ventilatorSetts3.RR);

%Estimate beta
if Vs3 <= V0
    betaEst = 0;
elseif Vs3 >= V1a
    betaEst = 1-alphaEst;
else 
    betaEst = (1-alphaEst)*(Vs3-V0)/(V1a-V0);
end

%Deduce estimation of D alveolar proportion (gamma)
gammaEst = 1 - alphaEst - betaEst;

