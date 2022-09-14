% Routine which estimates alveolar proportions for one mouse or several 
% mice.
%
% INPUT:
%   miceIDs = list of file names of .mat files containing mice ventilator
%   recordings.
% OUTPUT:
%   resultsMice.xlsx = estimated proportions, key volumes and pressures are
%   exported in an excel file
%
% Remarks: New pressure waveform is used, but can easily be switched to the
% Old pressure waveform by replacing the getVentilatorPressureNew by
% getVentilatorPressure and by changing the .in reference values files by 
% the referenceValuesMiceOld.in one.
%
% Sep 2022

%% Initialize
miceIDs = {'data/CTL-008.mat','data/CTL-012.mat','data/CTL-013.mat',...
    'data/CTL-014.mat','data/CTL-016.mat','data/CTL-033.mat',...
    'data/LAV-007.mat','data/LAV-008.mat','data/LAV-009.mat',...
    'data/LAV-010.mat','data/LAV-015.mat','data/LAV-031.mat'};
nMice = length(miceIDs);
exportResults = zeros(nMice,12);

%Open Simulink circuit
load_system("RHcircuitVarC.slx");

%Time to generate pressure waveforms
sampleTime = 0.01;
numSteps = 501; 
time = sampleTime*(0:numSteps-1); 
time = time';

%% Estimate alveolar proportions for each mouse
for k = 1:nMice
    miceID = miceIDs{1,k}; 

    %Retrieve mouse recordings
    %For each PEEP ladder step, retrieve 10 breaths towards the end of each
    %step 
    [extractedBreaths,indivBreaths] = extractTenBreaths(miceID);
    nBreaths = 10;

    %Compute the mice specific V and P of Block 1 and 6
    VmaxMiceBlock1 = zeros(1,nBreaths-1);
    PmaxMiceBlock1 = zeros(1,nBreaths-1);
    PminMiceBlock1 = zeros(1,nBreaths-1);
    VmaxMiceBlock6 = zeros(1,nBreaths-1);
    PmaxMiceBlock6 = zeros(1,nBreaths-1);
    PminMiceBlock6 = zeros(1,nBreaths-1);
    for i = 1:nBreaths-1
        VmaxMiceBlock1(i) = max(indivBreaths(1,i+1).V);
        PmaxMiceBlock1(i) = max(indivBreaths(1,i+1).P);
        PminMiceBlock1(i) = indivBreaths(1,i+1).P(1); 
        VmaxMiceBlock6(i) = max(indivBreaths(6,i+1).V);
        PmaxMiceBlock6(i) = max(indivBreaths(6,i+1).P);
        PminMiceBlock6(i) = indivBreaths(6,i+1).P(1); 
    end
    VmaxMiceBlock1MeanTot = mean(VmaxMiceBlock1);
    PmaxMiceBlock1MeanTot = mean(PmaxMiceBlock1);
    PminMiceBlock1MeanTot = mean(PminMiceBlock1);
    VmaxMiceBlock6MeanTot = mean(VmaxMiceBlock6);
    PmaxMiceBlock6MeanTot = mean(PmaxMiceBlock6);
    PminMiceBlock6MeanTot = mean(PminMiceBlock6);

    if PminMiceBlock1MeanTot < 0
        PminMiceBlock1MeanTot=0;
    end
    
    if VmaxMiceBlock1MeanTot >= 0.1170
    %A ADAPTER
    error(['Need to decrease Rh (and Rr) in referenceValues.in ' ...
        'file to increase max volume circuit possible ' ...
        '(e.g., put resistances to 1.1 or lower if new p wavform ' ...
        'or to 1.8 or lower for old p waveform). Use these new ' ...
        'resistances for all mice to be able to compare proportions.']);
    end

    %%Estimate healthy alveoli proporiton (alpha)
    %Retrieve reference circuit parameters and ventilator settings
    fid_ref = fopen('referenceValuesMiceNew.in','r+'); 
    [refCircuitVals,refVentilatorSet] = getReferenceValues(fid_ref);

    %Generate pressure waveform
    ventilatorSetts = refVentilatorSet;
    ventilatorSetts.pmin = PminMiceBlock1MeanTot;
    ventilatorSetts.pmax = PmaxMiceBlock1MeanTot;
    inputSignal = getVentilatorPressureNew(time,ventilatorSetts);
    inputSignal = inputSignal';
    inputPressureData = timeseries(inputSignal,time);

    %Set alveoli proportions to 1-0-0
    baselineParams = getConfigValues(refCircuitVals,1,0);
    setSimulinkModelValues(baselineParams); 

    %Compute compliances values updated according to ventilator pressures
    [allC1,allC2] = getCompliances(inputSignal,...
        baselineParams.C1,baselineParams.C2);
    inputC1Data =  timeseries(allC1,time);
    inputC2Data =  timeseries(allC2,time);
    
    %Run circuit
    out = sim("RHcircuitVarC.slx");
    
    %Find tidal volume of the circuit output 
    [Vcircuit,~,~,~] = getVolumesMax(out,ventilatorSetts.RR);

    %Estimate alpha
    alphaEst = VmaxMiceBlock1MeanTot/Vcircuit;
    
    %%Estimate recruitable alveoli proporiton (beta)
    %Retrieve reference circuit parameters and ventilator settings
    fid_ref = fopen('referenceValuesMiceNew.in','r+'); 
    [refCircuitVals,refVentilatorSet] = getReferenceValues(fid_ref);
    
    %Generate pressure waveform
    ventilatorSetts = refVentilatorSet;
    ventilatorSetts.pmin = PminMiceBlock6MeanTot;
    ventilatorSetts.pmax = PmaxMiceBlock6MeanTot;
    inputSignal = getVentilatorPressureNew(time,ventilatorSetts); 
    inputSignal = inputSignal';
    inputPressureData = timeseries(inputSignal,time);
    
    %Set alveoli proportions to alphaEst-0-(1-alphaEst)
    baselineParams = getConfigValues(refCircuitVals,alphaEst,0); 
    setSimulinkModelValues(baselineParams); 
    
    %Compute compliances values updated according to ventilator pressures
    [allC1,allC2] = getCompliances(inputSignal,...
        baselineParams.C1,baselineParams.C2);
    inputC1Data =  timeseries(allC1,time);
    inputC2Data =  timeseries(allC2,time);

    %Run circuit
    out = sim("RHcircuitVarC.slx");
    
    %Find tidal volume of the circuit output
    [Vc1,~,~,~] = getVolumesMax(out,ventilatorSetts.RR);


    %Set alveoli proportions to alphaEst-(1-alphaEst)-0
    baselineParams = getConfigValues(refCircuitVals,alphaEst,1-alphaEst);
    setSimulinkModelValues(baselineParams); 
    
    %Compute compliances values updated according to ventilator pressure
    [allC1,allC2] = getCompliances(inputSignal,...
        baselineParams.C1,baselineParams.C2);
    inputC1Data =  timeseries(allC1,time);
    inputC2Data =  timeseries(allC2,time);
    
    %Run circuit
    out = sim("RHcircuitVarC.slx");
    
    %Find tidal volume of the circuit output
    [Vc2,~,~,~] = getVolumesMax(out,ventilatorSetts.RR);

    %Estimate beta
    if VmaxMiceBlock6MeanTot < Vc1
        betaEst = 0;
    elseif VmaxMiceBlock6MeanTot > Vc2
        betaEst = 1-alphaEst;
    else 
        betaEst = (1-alphaEst)*(VmaxMiceBlock6MeanTot-Vc1)/(Vc2-Vc1);
    end

    %%Estimate damaged alveoli proporiton (gamma)
    gammaEst = 1-alphaEst-betaEst;
    
    %%Save results to export
    exportResults(k,:) = [alphaEst,betaEst,gammaEst,Vcircuit,...
        VmaxMiceBlock1MeanTot,Vc1,Vc2,VmaxMiceBlock6MeanTot,...
        PminMiceBlock1MeanTot,PmaxMiceBlock1MeanTot,...
        PminMiceBlock6MeanTot,PmaxMiceBlock6MeanTot];
end

%% Export results to excel sheet
writematrix(exportResults,'results/resultsMice.xlsx','Sheet',1,...
    'Range','B2:M13')



