function [refCircuit,refVentilator] = getReferenceValues(fid_ref)
% Function which retrieves baseline circuit parameters and ventilator 
% settings from an input file (.in) with specific structure.
%
% INPUT:
%   fid_ref = index after opening input file (referenceValues.in)
% OUTPUTS:
%   refCircuit = structure with 5 fields (Rh, Rr, Ch, Cr, TOP) defining the
%   baseline circuit parameters
%   refVentilator = structure with 6 fields (RR, IE, pmin, pmax, tauExp 
%   and tauInsp) defining the reference ventilator settings
%
% Sep 2022

%------------------- CIRCUIT REFERENCE VALUES ---------------------------%
    fgetl(fid_ref);
    fgetl(fid_ref);
    refCircuit.Rh = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refCircuit.Rr = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refCircuit.Ch = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refCircuit.Cr = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refCircuit.TOP = fscanf(fid_ref,'%e',[1,1]);

    
%------------------- VENTILATOR REFERENCE VALUES ------------------------%
    fgetl(fid_ref);
    fgetl(fid_ref);
    fgetl(fid_ref);
    fgetl(fid_ref);
    refVentilator.RR = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refVentilator.IE = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refVentilator.pmin = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refVentilator.pmax = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refVentilator.tauExp = fscanf(fid_ref,'%e',[1,1]);

    fgetl(fid_ref);
    fgetl(fid_ref);
    refVentilator.tauInsp = fscanf(fid_ref,'%e',[1,1]);

    if (refVentilator.pmax < refVentilator.pmin)
        error('pmax should be higher than pmin')
    end

end