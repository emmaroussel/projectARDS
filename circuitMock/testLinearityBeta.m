% Routine which demonstrates the linearity of proportions of recruitable
% alveoli with volumes (by simulating subjects with 0-beta-(1-beta)
% proportions and Case 3 pressures).
%
% INPUT:
%   none
% OUTPUT:
%   Plot of tidal volumes as a function of recruitable alveolar proportions
%
% Sep 2022

%% Initialization
% Define mock subjects
alpha.patient1 = 0;
beta.patient1 = 1;
alpha.patient2 = 0;
beta.patient2 = 0.9;
alpha.patient3 = 0;
beta.patient3 = 0.8;
alpha.patient4 = 0;
beta.patient4 = 0.7;
alpha.patient5 = 0;
beta.patient5 = 0.6;
alpha.patient6 = 0;
beta.patient6 = 0.5;
alpha.patient7 = 0;
beta.patient7 = 0.4;
alpha.patient8 = 0;
beta.patient8 = 0.3;
alpha.patient9 = 0;
beta.patient9 = 0.2;
alpha.patient10 = 0;
beta.patient10 = 0.1;
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

    % Case 3: above TOP (11 to 17 cmH20)
    ventilatorSetts3 = refVentilatorSet;
    ventilatorSetts3.pmin = 11;
    ventilatorSetts3.pmax = 17;
    inputSignal = getVentilatorPressure(time,ventilatorSetts3);
    inputSignal = inputSignal';

%% Run circuit for all patients & Case 3 pressures
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
bet = zeros(1,nPatients);
for j=1:nPatients
    bet(j) = betas{j};
end

figure(1)
plot(bet,Vs,'*-k','LineWidth',1.4,'MarkerSize',8)
grid on
xlabel('Recruitable Proportion')
ylabel('Volume [mL]')
set(gca,'FontSize',12);
title('Tidal volumes according to recruitable proportions for Case 3')
