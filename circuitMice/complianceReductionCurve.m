% Routine which defines the C(p) (compliance curve) by fitting (i) mice
% experimental elastances for CTL and LAV mice up to 15 cmH2O, and (ii)
% literature murine elastance data from 15 to 40 cmH2O, with a polynomial
% function of degree 4.
%
% INPUTS:
%   MechanicsDetails.xlsx = excel file containing the mice experimental 
%   elastances
%   Elastance_paper_fitted.xlsx = excel file containing the literature
%   murine elastance data from 15 to 40 cmH2O (extracted from the figure
%   with Engauge Digitizer)
% OUTPUTS:
%   polyCTLfit = polynomial coefficients for elastance of CTL mice up to 
%   15 cmH2O
%   polyLAVfit = polynomial coefficients for elastance of LAV mice up to 
%   15 cmH2O
%   polyPaperfit = polynomial coefficients for literature elastance fitted 
%   from 15 to 40 cmH2O.  
%
% Sep 2022

%% Polynomial fitting of experimental CTL and LAV mice elastances
filename = 'data/MechanicsDetails.xlsx';
sheet = 2;

xlRange = 'A1:G20';
[elastancesExcel,miceIDs]  = xlsread(filename,sheet,xlRange);

PEEPs = elastancesExcel(1,:);
elastMoyLAV = mean(elastancesExcel(2:8,1:6));
elastMoyCTL = mean(elastancesExcel(10:20,1:6));

polyLAVfit = polyfit(PEEPs,elastMoyLAV,4);
polyCTLfit = polyfit(PEEPs,elastMoyCTL,4);

%% Polynomial fitting of murine elastance curve from Zosky et al.
filename = 'data/ElastanceZosky.xlsx';
sheet = 1;
xlRange = 'A18:B37';

[elastancesPaper]  = xlsread(filename,sheet,xlRange);

pressPaper = elastancesPaper(:,1);
elastPaper = elastancesPaper(:,2);

polyPaperFit = polyfit(pressPaper,elastPaper,4);

