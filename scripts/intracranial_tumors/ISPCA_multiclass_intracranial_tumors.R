set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data	split ID
#2 Filename into which to store	the PCA results	object, with whole path
#3 Whole data file name with path
#4 Data splits file
#5 DMR file
#6 Use DMR information or not
#7 Normalize ISPCA components or not
#8 binarize classes before ISPCA?

#Test that the number of input arguments is correct
if (length(args)!=7) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("featureSelection_methods.R")

print(args)

INPUT_FILE=args[3]
DATASPLITS_FILE=args[4]

load(INPUT_FILE)
load(DATASPLITS_FILE)

if (strtoi(args[6])==1){
  load(args[5])
}

ID=strtoi(args[1])

#Brain data does not have to be normalized as it is given as RPKM

#Remove all-zero rows from DataMatrix
BrainData.matrix <- BrainData.matrix[rowSums(BrainData.matrix)>0,]

PCA_result_list <- list()

AllClasses <- unique(dataSplits$df$Classes)
print("List of all classes")
print(AllClasses)


if (strtoi(args[7])==1){
 normalize_components=TRUE
}else{
 normalize_components=FALSE
}


if (strtoi(args[6])==1){
  PCA_result_list <- list()
  for(i in 1:length(AllClasses)){
    PCA_results <- ISPCA_allWindows(BrainData.matrix,classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], FeatureList=FeatureList, class=i, transform=1,NC=length(dataSplits$samples[[ID]])-1,NORMALIZE=normalize_components)
    PCA_result_list[[i]] <- PCA_results
  }
    
}else{
  #Note that class is placeholder
  PCA_results <- ISPCA_allWindows(BrainData.matrix, classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], FeatureList=NULL, class=10, transform=1,NC=length(dataSplits$samples[[ID]])-1,NORMALIZE=normalize_components)
  PCA_result_list[[1]] <- PCA_results
}

save(PCA_result_list, file=args[2])


