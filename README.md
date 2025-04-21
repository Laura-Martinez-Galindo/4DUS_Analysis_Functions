# 4DUS_Analysis_Functions
This is a set of functions to help compile and analyze data after 4DUS image analysis has been performed

##Use the following functions for individual files:

Use Plot_Ell for longitudinal strain cartesian plot
Use Plot_Ecc for circumferntial strain cartesian plot
Use Plot_Err for radial strain polar plot at peak systole
Use Plot_Ea for radial strain polar plot at peak systole

Use export_eccel_fcn to get a formatted excel file that matches GUI output

##Use the following functions for compiling results from multiple files:

First use results_struct_compilation and compile results from selected files for analysis

Use Regional_EccEll_Compilation for excel output of regional Ecc and Ell values (peak strain, systolic strain, early/late diastolic strain)
Use AHA_Regional_Err_Compilation for excel output of regional Err values (peak strain, systolic strain, early/late diastolic strain)
Use AHA_Regional_Ea_Compilation for excel output of regional Ea values (peak strain, systolic strain, early/late diastolic strain)

##Use the following for MI specific analysis
wall_thinning MI
SA_Strain_MI
SA_strain_compiled
