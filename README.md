# Code repository for "Volumetric Nanophotonics for Enhanced Scintillation and Remote Light Outcoupling"

Scripts and functions for data processing used in the manuscript "Volumetric Nanophotonics for Enhanced Scintillation and Remote Light Outcoupling" by S. Pajovic *et al.* (2026). This code is made publicly available to facilitate review of the methods reported in the manuscript.

Please note that this repository is a work in progress and incomplete as of the last commit. This repository will be updated periodically (e.g., when the arXiv identifier of the preprint becomes available).

## Data availability

Some raw data are not included in this repository (for now) due to their large size and potential restrictions on distribution. Data supporting the findings of the manuscript not found in this repository may be made available by the corresponding author(s) upon reasonable request, subject to any data sharing restrictions.

As previously mentioned, this repository will be updated with additional documentation, code, and supplementary materials as they become available.

## Code and data descriptions

Below are brief descriptions of what the different scripts and functions do, sorted by subfolder.

### Length Estimation/

- `length_estimation_v3.m` : used to estimate etch depth from optical microscope images, following the method outlined in Sec. S3A in the Supplementary Materials.
- `helper.py` : contains helper functions to load scintillation enhancement and etch depth datasets.
- `length_data_python.csv` : contains etch depth data for plotting in Python.
- `plot_fn_of_etch_round.ipynb` : Jupyter Notebook that outputs Fig. 1(c)(iii).

### Scintillation Enhancement/

#### Spatial Enhancement/
- `autoAlignAvg.m` : used to align three of the same intensity measurement (i.e., patterned, unpatterned, or background) to calculate their average and standard deviation.
- `autoAlignPUB.m` : used to align patterned, unpatterned, and background intensity measurements to calculate spatial scintillation enhancement.
- `calculateEnhancement.m` : calculates spatial scintillation enhancement.
- `getAlignmentShift.m` : calculates alignment shift from cross-correlation.
- `autoAlignScript.m` : automatically uses the above-mentioned functions to loop through a dataset and calculate spatial scintillation enhancement.

### Figs. 1(c)(iii), 3(b)-(c)/
- `helper.py` : contains helper functions to load scintillation enhancement and etch depth datasets.
- `length_data_python.csv` : contains estimated etch depth data, obtained via optical microscopy.
- **Final Enhancement Results/** : contains pattern-wise scintillation enhancement after each round of etching.
- `plot_fn_of_etch_round.ipynb` : Jupyter Notebook that outputs Fig. 1(c)(iii) in cell 9.
- `plot_fn_of_length_and_period_v1.ipynb` : Jupyter Notebook that outputs Figs. 3(b)-(c) (cells 4 and 6).

### Fig. 3(a)/
- `show_image_lineProfile.m` : outputs Fig. 3(a).
- `YbYAG_PC-27_160kVp_25W_patterns=23L-27R_binning=4_width=16_patterned_autoaveraged.csv` : line profile data.
- `YbYAG_PC-27_160kVp_25W_patterns=23L-27R_binning=4_width=16_patterned.png` : image data.

### Fig. 4/
- `YAGCe+PC-16_w=0.025in_a=0_exptime=250ms_pumpcurr=1.5A.tif` : image data for Fig. 4(b).

#### Fig. 4(c)(i)/
- `fitting_parameter_comparison.ipynb` : outputs Fig. 4(c)(i).
- `fitting_parameters_yagce_microct_10-19-2026.npz`, `fitting_parameters_yagce_synchrotron_10-19-2026.npz`, ... : NumPy arrays containing fitting parameters C and λ for each scintillator and excitation source.

#### Fig. 4(c)/
Code and data are organized by scintillator > excitation source. The code fits the data to Eq. (3) in the main text and outputs one of the panels/subplots in Fig. 4(c).

**YAG:Ce/**
- Micro-CT/`light_collection_fit_YAGCe_PC-16.ipynb` : outputs top-right panel of Fig. 4(c) in cell 11. Requires `YAGCe_PC-16_07-10-2025_Variable_w-values_results_10-19-2026.mat` and `YAGCe_PC-16_07-10-2025_Variable_y-values_results_10-19-2026.mat`.
- Synchrotron/`light_collection_fit_may_beamtime_data.ipynb` : outputs top-center panel of Fig. 4(c) in cell 10. Requires `analysis_results_variable_w-values_all_energies_10-19-2026.mat` and `analysis_results_variable_y-values_w=0.5mm_all_energies_10-19-2026.mat`.
- UV Laser/`light_collection_fit_v2.ipynb` : outputs top-left panel of Fig. 4(c) in cell 11. Requires `analysis_results_fine_10-19-2026.mat` and `analysis_results_10-19-2026.mat`.

**YAGYb/**
- Micro-CT/`light_collection_fit_YAGYb_PC-27_average.ipynb` : outputs bottom-right panel of Fig. 4(c) in cell 11. Requires `YAGYb_PC-27_07-07-2025_Variable_w-values_results_10-19-2026.mat` and `YAGYb_PC-27_07-07-2025_Variable_y-values_results_10-19-2026.mat`.
- Synchrotron/`data_fit_v5.ipynb` : outputs bottom-center panel of Fig. 4(c) in cell 8. Requires `Light_Collecting_Intensity_Data_updated_error_bars.mat`.

### Fig. 2(b)/
Uncropped versions of the images shown in Fig. 2(b).

## Corresponding authors

- Simo Pajovic, [pajovics@mit.edu](mailto:pajovics@mit.edu) (current address: [pajovics@caltech.edu](mailto:pajovics@caltech.edu))
- Charles Roques-Carmes, [crc@ista.ac.at](mailto:crc@ista.ac.at)
