
set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data	split ID
#2 Filename into which to store	the PCA results	object, with whole path
#3 Whole thinned data file name with path
#4 Data splits file
#5 DMR file
#6 Use DMR information or not
#7 Normalize ISPCA components or not

#Test that the number of input arguments is correct
if (length(args)!=7) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("featureSelection_methods.R")

INPUT_FILE=args[3]
DATASPLITS_FILE=args[4]

load(INPUT_FILE)
load(DATASPLITS_FILE)

if (strtoi(args[6])==1){
  load(args[5])
}

ID=strtoi(args[1])

#Data normalization with respect to the total read counts
wholeData_thinned <- normalizecounts_scale(wholeData_thinned)

#Remove all-zero rows from wholeData_thinned
wholeData_thinned <- wholeData_thinned[rowSums(wholeData_thinned)>0,]

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
  for(i in 1:length(AllClasses)){
    PCA_results <- ISPCA_allWindows(wholeData_thinned,classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], FeatureList=FeatureList, class=i, transform=1,NC=length(dataSplits$samples[[ID]])-1,NORMALIZE=normalize_components,binarize=1)
    PCA_result_list[[i]] <- PCA_results
  }
    
}else{
  for(i in 1:length(AllClasses)){
    PCA_results <- ISPCA_allWindows(wholeData_thinned, classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], FeatureList=NULL, class=i, transform=1,NC=length(dataSplits$samples[[ID]])-1,NORMALIZE=normalize_components,binarize=1)
    PCA_result_list[[i]] <- PCA_results
  }

}

save(PCA_result_list, file=args[2])



