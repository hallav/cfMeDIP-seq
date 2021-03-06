
set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data	split ID
#2 Filename into which to store	the FeatureList	object, with whole path
#3 Whole thinned data file name with path
#4 Data splits file
#5 File name into which the top DMRs are stored
#6 File name into which the bottom DMRs are stored
#7 number of DMRs to be saved into a file
#8 New (1) or original (0) data transformation

#Test that the number of input arguments is correct
if (length(args)!=8) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("featureSelection_methods.R")

INPUT_FILE=args[3]
DATASPLITS_FILE=args[4]

load(INPUT_FILE)
load(DATASPLITS_FILE)

ID=strtoi(args[1])


FeatureList_all <- DMR_finding_modifiedT_noZeroCounts(wholeData_thinned, classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], nDMR = strtoi(args[7]), newTransformation=strtoi(args[8])) 

FeatureList <- FeatureList_all$standard

save(FeatureList, file=args[2])

FeatureList_top <- FeatureList_all$top

FeatureList_bottom <- FeatureList_all$bottom

save(FeatureList_top, file=args[5])
save(FeatureList_bottom, file=args[6]
