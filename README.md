# Scripts for cfMeDIP-seq data analysis
This repository contains the scripts related to Halla-aho and Lähdesmäki (2021) [1]. The directory `scripts` contains the R-scripts where the methods are defined. The R and bash scripts where it is shown how the methods are used in each case have been divided into subdirectories

- `preparing_data`: collecting data matrix, generating data splits, thinning (subsampling) of the data
- `feature_selection`: finding DMRs (moderated t-tests, Fisher's exact test), performing PCA and ISPCA
- `model_training`: training the different models (GLMNet, logistic regression)
- `AUC_calculation`: calculating AUC values for discovery and validation cohorts
- `figures`: producing figures for Halla-aho and Lähdesmäki (2021) [1]
- `intracranial_tumors`: producing results for the intracranial tumors data set from [6,7].

As the aim of Halla-aho and Lähdesmäki (2021) was to compare results from different methods to the methods presented in Shen et al. (2018) [2], we utilised the methods from repositories [3] and [4] to produce results with the same methods as in [2]. The script repositories [3] and [4] have [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/legalcode) lisence. The scripts from [3] and [4] were utilised for data split generation, DMR finding, GLMnet model training and AUC calculation. Some of the methods were modified to allow parallelisation and to add features and the modified methods can be found from this repository. The original sources and modifications have been indicated in each of the files in this repository, if applicable. The R code files in `intracranial_tumors` depend on methods defined in the other folders.

The Stan model for the logistic regression model with regularised horseshoe prior is from [5].

## Example data

The folder `example_data` contains files that demonstrate the file formats of the data.
- `dummy_counts_sample*.txt`: files containing random generated read counts, there are five dummy samples in total
- `dummy_genomic_window_coords.RData`: file containing the row names for the files `dummy_counts_sample*.txt`
- `dummy_dataMatrix.RData`: a data matrix with the read counts for all the five dummy samples
- `prepare_dummy_files.R`: R script for preparing the files above

# Software and packages

List of used software and packages
- R 3.6.1
- boot 1.3.22
- broom 0.5.4
- caret 6.0.85
- cowplot 1.1.1
- dimreduce 0.2.1
- doParallel 1.0.15
- dplyr 0.8.4
- extrafont 0.17
- glmnet 3.0.2
- grid 3.6.1
- limma 3.42.2
- NMF 0.22.0
- RColorBrewer 1.1.2
- reshape2 1.4.3
- rstan 2.19.3
- stats 3.6.1
- tidyr 1.0.2

The scripts have been run in Linux environment.

# References

[1] Halla-aho and Lähdesmäki (2021). Probabilistic modeling methods for cell-free DNA methylation based cancer classification. https://doi.org/10.1101/2021.06.18.444402

[2] Shen et al. (2018). Sensitive tumour detection and classification using plasma cell-free DNA methylomes. Nature, 563(7732), 579-583. https://doi.org/10.1038/s41586-018-0703-0 

[3] Ankur Chakravarthy (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697

[4] Ankur Chakravarthy (2018). Intermediate data objects from running the machine learning code for Shen et al, Nature, 2018 [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1490920

[5] Piironen and Vehtari (2017). Sparsity information and regularization in the horseshoe and other shrinkage priors. Electronic Journal of Statistics, 11(2), 5018-5051. https://doi.org/10.1214/17-EJS1337SI

[6] Nassiri, F., Chakravarthy, A., Feng, S. et al. Detection and discrimination of intracranial tumors using plasma cell-free DNA methylomes. Nat Med 26, 1044–1047 (2020). https://doi.org/10.1038/s41591-020-0932-2

[7] Ankur Chakravarthy. (2020). Reproducibility archive for MeDIP analyses of plasma DNA from brain tumour patients. (1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.3715312
