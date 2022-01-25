
library(dplyr)

args <- commandArgs(TRUE)
#1: output file name and path
#2: seed number

source("data_utilities.R")

#OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697
source("OnevAllClassifiers.R")

set.seed(strtoi(args[2]))

#BrainData_v2.RData file from Ankur Chakravarthy. (2020). Reproducibility archive for MeDIP analyses of plasma DNA from brain tumour patients. (1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.3715312
INPUT_FILE="BrainData_v2.RData"

FILTERED_DATA_FILE="BrainData_6classes_datamatrix.RData"
FILTERED_CLASS_FILE="BrainData_6classes_phenotypes.RData"
OUTPUT_FILE=args[1]

load(INPUT_FILE)

#The next two lines of code from "Multiclass_production.Rmd" file from https://doi.org/10.5281/zenodo.3715312 by Ankur Chakravarthy (2020)
#Filtering out Normal and Lymphoma classes (6 classes remain after this)
BrainData.phenotype <- filter(BrainData.phenotype , !Class %in% c("Normal","Lymphoma"))
#Sorting the data matrix into same order as phenotype information object
BrainData.matrix <- BrainData.matrix[,match(BrainData.phenotype$SampleID, colnames(BrainData.matrix))]

#Saving the filtered objects for later use.
save(BrainData.matrix,file=FILTERED_DATA_FILE)
save(BrainData.phenotype,file=FILTERED_CLASS_FILE)

dataSplits <- SplitFunction(BrainData.matrix,BrainData.phenotype$Class)

classes.df = dataSplits$df

AllClasses.v <- unique(classes.df$Classes)


save(dataSplits,file=OUTPUT_FILE)
