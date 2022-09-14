## Goal
The aim was to model a circuit to deduce alveolar proportions based on 
pressure and flow ventilator recordings of control and ARDS mice.

## How
A Simulink circuit modeling healthy (H) and recruitable (R) alveoli is 
herein coded. Alveolar proportions proportionally change circuit 
parameters. Alveoli capacitors are variable to model lung stiffening with
pressures. The main script is findProportionsMice where alveolar proportions
for a group of mice are estimated.

## Details
### Functions 

- **extractTenBreaths**: Function which extracts 10 breaths towards the end of 
each PEEP ladder step. Measurements extracted are pressure (P), volume (V),
flow (Q), time (experimental time) and time0 (individual breath time 
starting at t=0).
- **getCompliances**: Function which computes the compliance values (C1 and C2) 
according to pressure using the curve C(p) which is defined from polynomial
fitting of experimental mice elastance curves (portion 1: up to 15 cmH2O) 
and from polynomial fitting of literature elastance curve (portion 2: above 
15 cmH2O).
- **getConfigValues**: Function which computes the circuit parameters based on 
given alveolar proportions (healthy and recruitable) and reference circuit 
values usually obtained from a .in file.
- **getReferenceValues**: Function which retrieves baseline circuit parameters 
and ventilator settings from an input file (.in) with specific structure.
- **getVentilatorPressure**: Function which computes ventilator pressure 
waveform based on given ventilator settings and time vector. "Old" pressure
waveform is herein applied (i.e., waveform with exponential inspiratory and 
expiratory phases).
- **getVentilatorPressureNew**: Function which computes ventilator pressure 
waveform based on given ventilator settings and time vector. "New" pressure 
waveform is herein applied (i.e., waveform with linear inspiratory phase 
and exponential expiratory phase).
- **getVolumesMax**: Function which retrieves tidal volume (or maximal volume) 
from Simulink flow output.
- **plotSimulationResults**: Function which plots Simulink outputs. If 
plotCurrents option is off (=0), then a plot showing pressure, flow, 
total volume, volume in branch H and volume in branch R with time, is 
generated. If plotCurrents option if on (=1), then a plot showing the flows
(total, branch H and branch R) for the 2nd breath is generated.
- **setSimulinkModelValues**: Function which sets Simulink model variables to 
some given values. 

### Scripts

- **complianceReductionCurve**: Routine which defines the C(p) (compliance 
curve) by fitting (i) mice experimental elastances for CTL and LAV mice up 
to 15 cmH2O, and (ii) literature murine elastance data from 15 to 40 cmH2O,
with a polynomial function of degree 4.
- **findProportionsMice**: Routine which estimates alveolar proportions for one 
mouse or several mice.
- **inputCircuitValues**: Input file specifying circuit parameters used for 
initializing Simulink circuit. These values are changed through MATLAB 
scripts before running simulations (setSimulinkModelValues.m). This file 
should not be changed.

### Others

- **referenceValuesMiceNew.in**: Input file describing the baseline circuit 
parameters and ventilator settings for mice when the New ventilator 
pressure waveform is used (linear inspiratory phase + exponential 
expiratory phase).
- **referenceValuesMiceOld.in**: Input file describing the baseline circuit 
parameters and ventilator settings for mice when the Old ventilator 
pressure waveform is used (exponential inspiratory and expiratory phases).
-** RHcircuitVarC.slx**: Simulink circuit modeling the respiratory system 
(where the circuit upper branch corresponds to healthy alveoli and the 
bottom branch to recruitable alveoli) and a pressure-controlled ventilator.
Capacitors were made pressure-dependent to model the lung stiffening with 
pressure behavior.
