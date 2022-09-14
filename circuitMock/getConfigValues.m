function [params] = getConfigValues(refVals,proportionHealthy,...
    proportionRecruitable)
% Function which computes the circuit parameters based on given alveolar
% proportions (healthy and recruitable) and reference circuit values
% usually obtained from the referenceValues.in file.
%
% INPUTS:
%   refVals = structure with 5 fields (Rh, Rr, Ch, Cr, TOP)
%   proportionHealthy = scalar proportion of healthy (h) alveoli 
%   proportionRecruitable = scalar proportion of recruitable (r) alveoli
% OUTPUT:
%   params = structure with 6 fields (R1, R2a, R2b, C1, C2, TOP)
%
% Remark: proportions must be between [0;1] and their sum can not exceed 1.
% Default values of each proportion is 0.5.
%
% Sep 2022

    arguments
        refVals (1,1) struct {mustHaveFields(refVals,5)}
        proportionHealthy (1,1) double ...
            {mustBeNonnegative(proportionHealthy),...
            mustBeLessThanOrEqual(proportionHealthy,1)} = 0.5
        proportionRecruitable (1,1) double ...
            {mustBeNonnegative(proportionRecruitable),...
            mustBeLessThanOrEqual(proportionRecruitable,1)} = 0.5
    end
    
    %If not enough inputs specified, use 50% h & 50% r proportions 
    if nargin < 3
        proportionHealthy = 0.5;
        proportionRecruitable = 0.5;
    end
    if (proportionHealthy+proportionRecruitable > 1)
        error('Sum of H and R proportions should be one or less.')
    end

    %Define how R2 is split between R2a and R2b
    proportionR2a = 0.01; 
    if (proportionR2a > 1)
        error('Proportion of R2a can not be higher than 1')
    end
    
    %Deduce associated circuit variables values
    R2tot = refVals.Rr/proportionRecruitable;
    params.R1 = refVals.Rh/proportionHealthy;
    params.R2a = proportionR2a*R2tot;
    params.R2b = (1-proportionR2a)*R2tot;
    params.C1 = proportionHealthy*refVals.Ch;
    params.C2 = proportionRecruitable*refVals.Cr;
    params.Von = refVals.TOP;

    %Simulink doesn't allow for zero of Inf component values
    vals = struct2cell(params);
    f = fieldnames(params);
    for i=1:length(fieldnames(params))
        if isinf(vals{i})
            params.(f{i}) = 1e8;
        elseif vals{i}==0
            params.(f{i}) = 1e-8;
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