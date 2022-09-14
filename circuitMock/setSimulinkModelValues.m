function [] = setSimulinkModelValues(circuitValues)
% Function which sets Simulink model variables to some given values. 
%
% INPUT:
%   circuitValues = structure with 6 fields (R1, R2a, R2b, C1, C2, Von)
% OUTPUT:
%   none - modifies Simulink model.
%
% Sep 2022

    arguments
        circuitValues (1,1) struct {mustHaveFields(circuitValues,6)}
    end

    mWks = get_param(bdroot, 'modelworkspace');
    mWks.DataSource = 'MATLAB File';
    mWks.FileName = 'inputCircuitValues';
    mWks.assignin('R1', circuitValues.R1);
    mWks.assignin('R2a', circuitValues.R2a);
    mWks.assignin('R2b', circuitValues.R2b);
    mWks.assignin('C1', circuitValues.C1);
    mWks.assignin('C2', circuitValues.C2);
    mWks.assignin('Von', circuitValues.Von);
    mWks.saveToSource;
    mWks.reload;
end

function mustHaveFields(input,numFields)
    % Test for number of dimensions    
    if ~isequal(length(fieldnames(input)),numFields)
        eid = 'Size:wrongDimensions';
        msg = ['Input must have ',num2str(numFields),' fields'];
        throwAsCaller(MException(eid,msg))
    end
end