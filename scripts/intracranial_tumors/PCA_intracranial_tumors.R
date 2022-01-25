set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data	split ID
#2 Filename into which to store	the PCA results	object, with whole path
#3 Whole data file name with path
#4 Data splits file
#5 DMR file

#Test that the number of input arguments is correct
if (length(args)!=5) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("modifiedClassifiers.R")

print(args)

INPUT_FILE=args[3]
DATASPLITS_FILE=args[4]

load(INPUT_FILE)
load(DATASPLITS_FILE)
load(args[5])

ID=strtoi(args[1])

#Braindata does not have to be normalized, as it comes as RPKM

#Remove all-zero rows from DataMatrix
BrainData.matrix <- BrainData.matrix[rowSums(BrainData.matrix)>0,]

PCA_result_list <- list()

AllClasses <- unique(dataSplits$df$Classes)
print("List of all classes")
print(AllClasses)


for(i in 1:length(AllClasses)){
  PCA_results <- PCA_onlyDMRs(BrainData.matrix, Indices = dataSplits$samples[[ID]], FeatureList=FeatureList, class=i, transform=2)
  PCA_result_list[[i]] <- PCA_results
}

save(PCA_result_list, file=args[2])


