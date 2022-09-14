function pressureSignal = getVentilatorPressure(time,ventilatorSettings)
% Function which computes ventilator pressure waveform based on given
% ventilator settings and time vector. "Old" pressure waveform is herein
% applied (i.e., waveform with exponential inspiratory and expiratory
% phases).
%
% INPUTS:
%   time  = vector with all time points where pressure should be computed
%   ventilatorSettings = structure with 6 fields (RR, IE, pmin, pmax,
%   tauInsp, tauExp)
% OUTPUT:
%   pressureSignal = vector with ventilator pressure values
%
% Sep 2022

    arguments
        time (:,1) double 
        ventilatorSettings (1,1) struct ...
            {mustHaveFields(ventilatorSettings,6)}
    end

    RR = ventilatorSettings.RR;
    IE = ventilatorSettings.IE;
    pmin = ventilatorSettings.pmin;
    pmax = ventilatorSettings.pmax;
    tauExp = ventilatorSettings.tauExp;
    tauInsp = ventilatorSettings.tauInsp;

    if pmax < pmin
        error('pmax must be higher than pmin')
    end

    T = 60/RR; %Period (1 breath every T sec)
    durationInspiration = IE*T; %End inspiration (I:E=1:2 -> inspi = 1/3*T)
    pressureSignal = zeros(1,length(time));
    
    for i = 1:length(time)
        t = time(i);
    
        if t > T
            t = t - floor(t/T)*T;
        end
        
        if t < durationInspiration
            pressureSignal(i) = (pmax-pmin)*(1-exp(-tauInsp*t))+pmin;
        else 
            pressureSignal(i) = (pmax-pmin)*exp(-tauExp*...
                (t-durationInspiration))+pmin;
        end
    end

end

function mustHaveFields(input,numFields)
    % Test for number of dimensions    
    if ~isequal(length(fieldnames(input)),numFields)
        eid = 'Size:wrongDimensions';
        msg = ['Input must have ',num2str(numFields),' fields'];
        throwAsCaller(MException(eid,msg))
    end
end