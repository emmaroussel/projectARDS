% Routine which runs Simulink model for one subject with known alveolar 
% proportions for the three pressure cases (below, across and above the 
% TOP).
%
% INPUTS:
%   alpha = proportion of healthy alveoli
%   beta = proportion of recruitable alveoli
% OUTPUTS:
%   Simulink output (pressure, flow, volume with time)
%
% Sep 2022

%% Initialization
% Define mock subject
alpha   = 1;
beta    = 0;

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

%% Run Simulink circuit for the 3 pressure cases
volumesMax = zeros(nCases,3);
pressures = struct2cell(inputSignal);

for i=1:nCases
    inputPressureData = timeseries(pressures{i},time);

    %Run circuit
    out = sim("RHcircuit.slx");

    %Get volumes
    [Vtmax,VHtmax,VRtmax] = getVolumesMax(out,refVentilatorSet.RR);
    volumesMax(i,:) = [Vtmax,VHtmax,VRtmax];

    %Save plots
    f1=figure(1);
    plotSimulationResults(out,refVentilatorSet.RR); 
        %Same RR for all three pressure cases here

    f2=figure(2);
    plotSimulationResults(out,refVentilatorSet.RR,1);

    filepath = 'Results\';
    filename1 = strcat('case',num2str(i,'%d'),...
        '_a',num2str(100*alpha,'%d'),'b',num2str(100*beta,'%d'),'_f1.jpg');
    saveas(f1, fullfile(filepath, filename1));
    filename2 = strcat('case',num2str(i,'%d'),...
        '_a',num2str(100*alpha,'%d'),'b',num2str(100*beta,'%d'),'_f2.jpg');
    saveas(f2, fullfile(filepath, filename2));
end

%% Save volumes in excel file
writematrix(volumesMax,'Results\volumesMax.xls')

