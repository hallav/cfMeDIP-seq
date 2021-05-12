set.seed(123)

N_rows <- 100
N_samples <- 5

#Generate random numbers (counts) for five samples between values 0 and 50
sample1_counts <- sample(0:50, N_rows, replace = TRUE)
sample2_counts <- sample(0:50, N_rows, replace = TRUE)
sample3_counts <- sample(0:50, N_rows, replace = TRUE)
sample4_counts <- sample(0:50, N_rows, replace = TRUE)
sample5_counts <- sample(0:50, N_rows, replace = TRUE)

OUTPUTFOLDER <- "..." #The directory where to store thw files must be defined before running this script
#Save into files
cat(sample1_counts, file = paste(OUTPUTFOLDER,"/dummy_counts_sample1.txt",sep=""),sep="\n")
cat(sample2_counts, file = paste(OUTPUTFOLDER,"/dummy_counts_sample2.txt",sep=""),sep="\n")
cat(sample3_counts, file = paste(OUTPUTFOLDER,"/dummy_counts_sample3.txt",sep=""),sep="\n")
cat(sample4_counts, file = paste(OUTPUTFOLDER,"/dummy_counts_sample4.txt",sep=""),sep="\n")
cat(sample5_counts, file = paste(OUTPUTFOLDER,"/dummy_counts_sample5.txt",sep=""),sep="\n")

#Prepare dummy genomic window (i.e. count file row) names object
dummy_window_names <-data.frame(WindowsCoords = rep("", N_rows))

#Here we use dummy coordinates instead of actual ones. The actual coordinates should contain genomic window coordinates (chromosome, start and end site) in string format
for(i in 1:N_rows){
  dummy_window_names$WindowsCoords[i] <- paste("window_coords_",i,sep="")
}
dummy_window_names$WindowsCoords <- as.factor(dummy_window_names$WindowsCoords)

#Save into file
save(dummy_window_names,file = paste(OUTPUTFOLDER,"/dummy_genomic_window_coords.RData",sep=""))

#Make a data matrix out of the dummy counts for the five samples
#The collectDataMatrix could also be used for this (data_utilities.R)
DM <- matrix(,nrow=dim(dummy_window_names)[1],ncol=N_samples)
DM[,1] <- sample1_counts
DM[,2] <- sample2_counts
DM[,3] <- sample3_counts
DM[,4] <- sample4_counts
DM[,5] <- sample5_counts

sample_names=c("dummy_sample1","dummy_sample2","dummy_sample3","dummy_sample4","dummy_sample5")

rownames(DM)=dummy_window_names$WindowsCoords
colnames(DM)=sample_names

#Save into file
save(DM,file = paste(OUTPUTFOLDER,"/dummy_dataMatrix.RData",sep=""))

