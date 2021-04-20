# Scripts for cfMeDIP-seq data analysis
This repository contains the scripts related to Halla-aho and Lähdesmäki (2021). The directory `scripts` contains the R-scripts where the methods are defined. The R and bash scripts where it is shown how the methods are used in each case have been divided into subdirectories

- `preparing_data`: collecting data matrix, generating data splits, thinning (subsampling) of the data
- `feature_selection`: finding DMRs, performing PCA and ISPCA
- `model_training`: training the different models
- `AUC_calculation`: calculating AUC values for discovery and validation cohorts
- `figures`: producing figures for Halla-aho and Lähdesmäki (2021)

As the aim of Halla-aho and Lähdesmäki (2021) was to compare results from different methods to the methods presented in Shen et al. (2018), we utilised the methods from [] to reproduce the results. The scripts from [] were utilised for data split generation, DMR finding, GLMNet model training and AUC calculation. For this purpose we used scripts from [], [] and []. 

# References


