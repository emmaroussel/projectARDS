% Routine which runs Simulink model for several subjects with defined
% alveolar proportions and for the three pressure cases (below, across and
% above the TOP).
%
% INPUTS:
%   alphas = structure with proportions of healthy alveoli for each subject 
%   betas = structure with proportions of recruitable alveoli for each 
%   subject
% OUTPUTS:
%   Flow plots for ventilator, branch H and branch R (jpg format)
%   Tidal volumes in an excel file
%
% Sep 2022

%% Initialization
% Define mock subjects
alpha.patient1 = 1;
beta.patient1 = 0;

alpha.patient2 = 0;
beta.patient2 = 1;

alpha.patient3 = 0;
beta.patient3 = 0;

alpha.patient4 = 0;
beta.patient4 = 0.5;

alpha.patient5 = 0.8;
beta.patient5 = 0.2;

alpha.patient6 = 0.5;
beta.patient6 = 0.5;

alpha.patient7 = 0.5;
beta.patient7 = 0;

alpha.patient8 = 0.4;
beta.patient8 = 0.2;

alpha.patient9 = 0.2;
beta.patient9 = 0.8;

alpha.patient10= 0.2;
beta.patient10 = 0.2;

nPatients = length(fieldnames(alpha));

%Open Simulink circuit (without window)
load_system("RHcircuit.slx");

%Retrieve reference circuit parameters and ventilator settings
fid_ref = fopen('referenceValues.in','r+'); 
[refCircuitVals,refVentilatorSet] = getReferenceValues(fid_ref);

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

%% Run Simulink circuit for all subjects & all pressure cases
pressures = struct2cell(inputSignal);
alphas = struct2cell(alpha);
betas = struct2cell(beta);
volumesMax = cell(nCases,nPatients);

for i=1:nCases

    inputPressureData = timeseries(pressures{i},time);

    for j=1:nPatients

        %Set subject alveoli phenotype
        params = getConfigValues(refCircuitVals,alphas{j},betas{j}); 
        setSimulinkModelValues(params);

        %Run circuit
        out = sim("RHcircuit.slx");
    
        %Get volumes
        [Vtmax,VHtmax,VRtmax] = getVolumesMax(out,refVentilatorSet.RR);
        volumesMax{i,j} = [Vtmax,VHtmax,VRtmax];
    
        %Save plots
        f1=figure(1);
        plotSimulationResults(out,refVentilatorSet.RR); 
            %Same RR for all three pressure cases here
    
        f2=figure(2);
        plotSimulationResults(out,refVentilatorSet.RR,1);
    
        filepath = 'Results\';
        filename1 = strcat('subject',num2str(j,'%d'),'_case',...
            num2str(i,'%d'),'_a',num2str(100*alphas{j},'%d'),'b',...
            num2str(100*betas{j},'%d'),'_f1.jpg');
        saveas(f1, fullfile(filepath, filename1));
        filename2 = strcat('subject',num2str(j,'%d'),'_case',...
            num2str(i,'%d'),'_a',num2str(100*alphas{j},'%d'),'b',...
            num2str(100*betas{j},'%d'),'_f2.jpg');
        saveas(f2, fullfile(filepath, filename2));
    end
end

%% Save volumes in excel file
writecell(volumesMax,'Results\volumesMax.xls')

%Additional plot to see volume evolution as we move from Case 1 to 3 (not
%saved)
Vmaxs1 = zeros(nPatients,1);
Vmaxs2 = zeros(nPatients,1);
Vmaxs3 = zeros(nPatients,1);
for j = 1:nPatients
    Vmaxs1(j) = volumesMax{1,j}(1);
    Vmaxs2(j) = volumesMax{2,j}(1);
    Vmaxs3(j) = volumesMax{3,j}(1);
end

Vmaxs = horzcat(Vmaxs1,Vmaxs2,Vmaxs3);
casesP = categorical({'Case 1','Case 2','Case 3'});
casesP = reordercats(casesP,{'Case 1','Case 2','Case 3'});
x = [1,2,3];
X1 = repmat(x,nPatients,1); 
X1= X1';
Vmaxs = Vmaxs';

Markers = 'os^v><d*|x';
nMarkers = length(Markers);

figure(3)
for i=1:nPatients
 plot(X1(:,i),Vmaxs(:,i),'LineStyle','-','Color','k','Marker',...
     Markers(i),'Linewidth',1.4,'Markersize',8,'Markerfacecolor','w');
 hold on
end
hold off
legend({'#1','#2','#3','#4','#5','#6','#7','#8','#9','#10'},...
    'Location','eastoutside','FontSize',12)
ylabel('Volume [mL]')
xticks([1 2 3])
xticklabels({'Case 1','Case 2','Case 3'})
set(gca,'FontSize',14);
grid on
