function [Vt,VHt,VRt,indmax] = getVolumesMax(simOutput,RR)
% Function which retrieves tidal volume (or maximal volume) from Simulink
% flow output.
%
% INPUTS:
%   simOutput = Simulink output
%   RR = respiratory rate with which the pressure waveform was created (one
%   of the ventilator settings)
% OUTPUTS:
%   Vt = tidal volume (occurs at tmax)
%   VHt = volume of healthy alveoli (branch H) at tmax
%   VRt = volume of recruitable alveoli (branch R) at tmax
%   indmax = time index of maximal volume (index of tmax)
%
% Remark: only 2nd breath data are used. The 1st breath is transient so not
% used, and following breaths after the second one are identical to the 2nd
% breath.
%
% Sep 2022

    t   = simOutput.tout;
    Q   = squeeze(simOutput.logsout{3}.Values.Data);
    QH  = squeeze(simOutput.logsout{4}.Values.Data);
    QR  = squeeze(simOutput.logsout{5}.Values.Data);
    
    %Delineate the 2nd breath
    T       = 60/RR;
    indBeg  = find(ismembertol(t,T,1e-6));
    indEnd  = find(ismembertol(t,2*T,1e-6));
    tBreath = t(indBeg:indEnd);

    %Compute volumes by cumulative integral of flow
    V       = cumtrapz(tBreath,Q(indBeg:indEnd));
    VH      = cumtrapz(tBreath,QH(indBeg:indEnd));
    VR      = cumtrapz(tBreath,QR(indBeg:indEnd));

    [Vt,indmax] = max(V);
    VHt         = VH(indmax);
    VRt         = VR(indmax); 
    
    indmax = indmax + indBeg -1;
end