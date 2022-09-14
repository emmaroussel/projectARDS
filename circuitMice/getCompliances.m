function [allC1,allC2] = getCompliances(pressures,C1ref,C2ref)
% Function which computes the compliance values (C1 and C2) according to
% pressure using the curve C(p) which is defined from polynomial fitting of 
% experimental mice elastance curves (portion 1: up to 15 cmH2O) and from 
% polynomial fitting of literature elastance curve (portion 2: above 15
% cmH2O).
%
% INPUT:
%   pressures = vector with pressure values where we want to compute the
%   compliances
%   C1ref = C1 values derived from Ch according to proportion of healthy
%   alveoli (output of getConfigValues.m)
%   C2ref = C2 values derived from Ch"according to proportion of
%   recruitable alveoli (output of getConfigValues.m)
% OUTPUTS:
%   allC1 = vector with C1 values for all pressures of the input vector
%   pressures
%   allC2 = vector with C2 values for all pressures of the input vector
%   pressures
%
% Remark: fitting of elastance curves was done in the file
% complianceReductionCurve.m, and resulting coefficients are used here.
%
% Source (for literature elastance curve): Zosky et al. The bimodal
% quasi-static and dynamic elastance of the murine lung. Journal of Applied
% Physiology, 105(2):685-692, 2008.
%
% Sep 2022

% Fitting of mice elastances values w/ polynomial function degree 4 
% E_LAV portion 1
x4_LAV = 0.0006;
x3_LAV = 0.0254;
x2_LAV = -0.0982;
x1_LAV = -0.8067;
x0_LAV = 59.501;
E_LAVportion1 = @(p) x4_LAV*p^4 + x3_LAV*p^3 + x2_LAV*p^2 +...
    x1_LAV*p + x0_LAV;

% E_CTL portion 1
x4_CTL = 0.008;
x3_CTL = -0.1483;
x2_CTL = 1.0039;
x1_CTL = -3.5217;
x0_CTL = 35.177;
E_CTLportion1 = @(p) x4_CTL*p^4 + x3_CTL*p^3 + x2_CTL*p^2 +...
    x1_CTL*p + x0_CTL;

% Use literature (Zosky et al.) elastance curve to derive portion 2 
paperFit = [-0.00193902783848949,0.227071567991174,-9.60320691351439,...
    174.243224896124,-1049.13920026680]; 
pressFit = linspace(15,40,26);
Eportion2Paper = polyval(paperFit,pressFit);
facPortion2 = Eportion2Paper./Eportion2Paper(1);

% E_LAV portion 2
E_LAV15apx = E_LAVportion1(15);
E_LAVportion2keyPoints = facPortion2.*E_LAV15apx;
E_LAVportion2fit = polyfit(pressFit,E_LAVportion2keyPoints,4);
E_LAVportion2 = @(p) polyval(E_LAVportion2fit,p);

% E_CTL portion 2
E_CTL15apx = E_CTLportion1(15);
E_CTLportion2keyPoints = facPortion2.*E_CTL15apx;
E_CTLportion2fit = polyfit(pressFit,E_CTLportion2keyPoints,4);
E_CTLportion2 = @(p) polyval(E_CTLportion2fit,p);


% Get C1 and C2 for range of pressures defined as input
nPress = length(pressures);
allC1 = zeros(1,length(nPress));
allC2 = zeros(1,length(nPress));

C0 = mean([1/E_LAVportion1(0);1/E_CTLportion1(0)]);

for i=1:nPress
    p = pressures(i);
    if p > 15
        CLAV = 1/E_LAVportion2(p);
        CCTL = 1/E_CTLportion2(p);
        Cx = mean([CLAV;CCTL]);
        facChange = Cx/C0;
        allC1(i) = facChange*C1ref;
        allC2(i) = facChange*C2ref;
    else
        CLAV = 1/E_LAVportion1(p);
        CCTL = 1/E_CTLportion1(p);
        Cx = mean([CLAV;CCTL]);
        facChange = Cx/C0;
        allC1(i) = facChange*C1ref;
        allC2(i) = facChange*C2ref;
    end
end


end