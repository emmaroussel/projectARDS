function [VatT,VHatT,VRatT] = getVolumesAtTime(simOutput,RR,indTime)
% Function which retrieves volume at a given time index from Simulink
% flow output.
%
% INPUTS:
%   simOutput = Simulink output
%   RR = respiratory rate with which the pressure waveform was created (one
%   of the ventilator settings)
%   indTime = time index where we wish to retrieve volumes
% OUTPUTS:
%   VatT = volume at indTime
%   VHatT = volume of healthy alveoli (branch H) at indTime
%   VRatT = volume of recruitable alveoli (branch R) at indTime
%
% Remark: only 2nd breath data are used. The 1st breath is transient so not
% used, and following breaths after the second one are identical to the 2nd
% breath.
%
% Sep 2022

    t = simOutput.tout;
    Q = squeeze(simOutput.logsout{3}.Values.Data);
    QN = squeeze(simOutput.logsout{4}.Values.Data);
    QR = squeeze(simOutput.logsout{5}.Values.Data);
    
    %Delineate the 2nd breath
    T = 60/RR;
    indBeg = find(t == T);
    indEnd = find(t == 2*T);
    tBreath = t(indBeg:indEnd);

    %Compute volumes by cumulative integral of flow
    V = cumtrapz(tBreath,Q(indBeg:indEnd));
    VH = cumtrapz(tBreath,QN(indBeg:indEnd));
    VR = cumtrapz(tBreath,QR(indBeg:indEnd));
    
    indTime = indTime - indBeg +1;
    VatT = V(indTime);
    VHatT = VH(indTime);
    VRatT = VR(indTime);
end