## Goal
The aim was to model a circuit to deduce alveolar proportions based on 
pressure and flow ventilator recordings for ARDS patients.

## How
A Simulink circuit modeling healthy (H) and recruitable (R) alveoli is 
herein coded. Alveolar proportions proportionally change circuit 
parameters. Alveoli capacitors are here fixed. Main scripts are: 
(i) runSimulinkMockSubject and runSimulinkAllMockSubjects where proportions 
are prescribed for one or several patients and the Simulink circuit is run 
with given pressures, resulting in flow outputs;
(ii) findProportionsMockSubject where alveolar proportions for a mock 
subject (i.e., a subject whose pressure and flow are synthetic by running 
the Simulink circuit) are estimated.

## Details
### Functions 

- **getConfigValues**: Computes the circuit parameters based on given alveolar
proportions (healthy and recruitable) and reference circuit values
usually obtained from the referenceValues.in file.
- **getReferenceValues**: Retrieves baseline circuit parameters and ventilator 
settings from an input file (referenceValues.in) with specific structure.
- **getVentilatorPressure**: Computes ventilator pressure waveform based on 
given ventilator settings and time vector.
- **getVolumesAtTime**: Retrieves volume at a given time index from Simulink
flow output.
- **getVolumesMax**: Retrieves tidal volume (or maximal volume) from Simulink
flow output.
- **plotSimulationResults**: Plots Simulink outputs. If plotCurrents option is
off (=0), then a plot showing pressure, flow, total volume, volume in 
branch H and volume in branch R with time, is generated. If plotCurrents 
option if on (=1), then a plot showing the flows (total, branch H and 
branch R) for the 2nd breath is generated.
- **setSimulinkModelValues**: Sets Simulink model variables to some given 
values. 

### Scripts

- **findProportionsMockSubject**: Estimates the alveolar proportions of a mock 
subject: 1) run Simulink model for the subject with known proportions and 
extract its flow output; 2) apply the proportions estimation procedure to 
the mock subject measurements from 1). 
- **inputCircuitValues**: Input file specifying circuit parameters used for 
initializing Simulink circuit. These values are changed through MATLAB 
scripts before running simulations (setSimulinkModelValues.m). This file 
should not be changed.
- **runSimulinkAllMockSubjects**: Runs Simulink model for several subjects with 
known alveolar proportions and for the three pressure cases (below,
across and above the TOP).
- **runSimulinkMockSubject**: Runs Simulink model for one subject with known
alveolar proportions for the three pressure cases (below, across and above 
the TOP).
- **testLinearityAlpha**: Demonstrates the linearity of proportions of healthy
alveoli with volumes (by simulating subjects with alpha-0-(1-alpha)
proportions and Case 1 pressures).
- **testLinearityBeta**: Demonstrates the linearity of proportions of healthy
alveoli with volumes (by simulating subjects with alpha-0-(1-alpha)
proportions and Case 1 pressures).

### Others

- **referenceValues.in**: Input file describing the baseline circuit parameters 
and ventilator settings for mock subjects.
- **RHcircuit.slx**: Simulink circuit modeling the respiratory system (where 
the circuit upper branch corresponds to healthy alveoli and the bottom 
branch to recruitable alveoli) and a pressure-controlled ventilator.
