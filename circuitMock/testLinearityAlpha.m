% Routine which demonstrates the linearity of proportions of healthy
% alveoli with volumes (by simulating subjects with alpha-0-(1-alpha)
% proportions and Case 1 pressures).
%
% INPUT:
%   none
% OUTPUT:
%   Plot of tidal volumes as a function of healthy alveolar proportions
%
% Sep 2022

%% Initialization
% Define mock subjects
alpha.patient1 = 1;
beta.patient1 = 0;
alpha.patient2 = 0.9;
beta.patient2 = 0;
alpha.patient3 = 0.8;
beta.patient3 = 0;
alpha.patient4 = 0.7;
beta.patient4 = 0;
alpha.patient5 = 0.6;
beta.patient5 = 0;
alpha.patient6 = 0.5;
beta.patient6 = 0;
alpha.patient7 = 0.4;
beta.patient7 = 0;
alpha.patient8 = 0.3;
beta.patient8 = 0;
alpha.patient9 = 0.2;
beta.patient9 = 0;
alpha.patient10 = 0.1;
beta.patient10 = 0;
alpha.patient11 = 0;
beta.patient11 = 0;

nPatients = length(fieldnames(alpha));

%Open Simulink circuit (without window)
load_system("RHcircuit.slx");

%Retrieve reference circuit parameters and ventilator settings
fid_ref = fopen('referenceValues.in','r+'); 
[refCircuitVals,refVentilatorSet] = getReferenceValues(fid_ref);

%Create the ventilator pressure waveforms for Case 1 
sampleTime = 0.01;
numSteps = 501; 
time = sampleTime*(0:numSteps-1); 
time = time';
    
    % Case 1: below TOP (0 to 6 cmH20)
    ventilatorSetts1 = refVentilatorSet;
    inputSignal = getVentilatorPressure(time,ventilatorSetts1);
    inputSignal = inputSignal';

%% Run circuit for all patients & Case 1 pressures
alphas = struct2cell(alpha);
betas = struct2cell(beta);
volumesMax = zeros(nPatients,3);

inputPressureData = timeseries(inputSignal,time);

for j=1:nPatients
    %Set patient alveoli phenotype
    params = getConfigValues(refCircuitVals,alphas{j},betas{j}); 
    setSimulinkModelValues(params);

    %Run circuit
    out = sim("RHcircuit.slx");

    [Vtmax,VHtmax,VRtmax] = getVolumesMax(out,refVentilatorSet.RR);
    volumesMax(j,:) = [Vtmax,VHtmax,VRtmax];
end


%% Plot results
Vs = volumesMax(:,1);
alp = zeros(1,nPatients);
for j=1:nPatients
    alp(j) = alphas{j};
end

figure(1)
plot(alp,Vs,'*-k','LineWidth',1.4,'MarkerSize',8)
grid on
xlabel('Healthy Proportion')
ylabel('Volume [mL]')
set(gca,'FontSize',12);
title('Tidal volumes according to healthy proportions for Case 1')

