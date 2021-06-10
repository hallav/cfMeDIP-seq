

args <- commandArgs(TRUE)
#1: thinned whole data file name and path
#2: output file name and path
#3: seed number
#4: non-thinned whole data file name and path

#OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697

source("OnevAllClassifiers.R")
set.seed(strtoi(args[3]))

INPUT_FILE=args[1] 
WHOLEDATA_FILE=args[4]
OUTPUT_FILE=args[2]

load(INPUT_FILE)
load(WHOLEDATA_FILE)

dataSplits <- SplitFunction(wholeData_thinned,wholeData$classes)

classes.df = dataSplits$df

AllClasses.v <- unique(classes.df$Classes)


save(dataSplits,file=OUTPUT_FILE)
