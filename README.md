# Code repository for "Volumetric Nanophotonics for Enhanced Scintillation and Remote Light Outcoupling"

Scripts and functions for data processing used in the manuscript "Volumetric Nanophotonics for Enhanced Scintillation and Remote Light Outcoupling" by Pajovic *et al.* This code is made publicly available to facilitate review of the methods reported in the manuscript.

Please note that this repository is a work in progress and incomplete as of writing. This repository will be updated periodically (e.g., when the arXiv ID of the preprint becomes available).

## Code and data availability

The underlying datasets (especially raw data such as images) are not included in this repository for now due to their large size and potential restrictions on distribution. Data supporting the findings of the manuscript may be made available by the corresponding author(s) upon reasonable request, subject to any data sharing restrictions.

As a result of this, some scripts cannot be run without having the corresponding datasets in the same directory. However, as previously mentioned, this repository will be updated with additional documentation, code, and supplementary materials as they become available.

## Code descriptions

Below are brief descriptions of what the different scripts and functions do, sorted by subfolder.

### Length Estimation

- `length_estimation_v3.m`: used to estimate etch depth from optical microscope images, following the method outlined in Sec. S3A in the Supplementary Materials.
- `helper.py`: contains helper functions to load scintillation enhancement and etch depth datasets.
- `length_data_python.csv`: contains etch depth data for plotting in Python.
- `plot_fn_of_etch_round.ipynb`: Jupyter Notebook that outputs Fig. 1(c)(iii).

### Scintillation Enhancement

#### Spatial Enhancement/
- `autoAlignAvg.m`: used to align three of the same intensity measurement (i.e., patterned, unpatterned, or background) to calculate their average and standard deviation.
- `autoAlignPUB.m`: used to align patterned, unpatterned, and background intensity measurements to calculate spatial scintillation enhancement.
- `calculateEnhancement.m`: calculates spatial scintillation enhancement.
- `getAlignmentShift.m`: calculates alignment shift from cross-correlation.
- `autoAlignScript.m`: automatically uses the above-mentioned functions to loop through a dataset and calculate spatial scintillation enhancement.

## Corresponding authors

- Simo Pajovic, [pajovics@mit.edu](mailto:pajovics@mit.edu) (current address: [pajovics@caltech.edu](mailto:pajovics@caltech.edu))
- Charles Roques-Carmes, [crc@ista.ac.at](mailto:crc@ista.ac.at)
