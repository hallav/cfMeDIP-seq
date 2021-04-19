set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data	split ID
#2 Filename into which to store	the PCA results	object, with whole path
#3 Whole thinned data file name with path
#4 Data splits file
#5 DMR file

#Test that the number of input arguments is correct
if (length(args)!=5) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("featureSelection_methods.R")


INPUT_FILE=args[3]
DATASPLITS_FILE=args[4]

load(INPUT_FILE)
load(DATASPLITS_FILE)
load(args[5])


ID=strtoi(args[1])

#Data normalization with respect to the total read counts
wholeData_thinned <- normalizecounts_scale(wholeData_thinned)

#Remove all-zero rows from wholeData_thinned
wholeData_thinned <- wholeData_thinned[rowSums(wholeData_thinned)>0,]

PCA_result_list <- list()

AllClasses <- unique(dataSplits$df$Classes)
print("List of all classes")
print(AllClasses)


for(i in 1:length(AllClasses)){
  PCA_results <- PCA_onlyDMRs(wholeData_thinned, Indices = dataSplits$samples[[ID]], FeatureList=FeatureList, class=i, transform=1)
  PCA_result_list[[i]] <- PCA_results
}

save(PCA_result_list, file=args[2])


