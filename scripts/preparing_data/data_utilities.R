#Functions to work with the data files


collectDataMatrix <- function(PATH,FOLDERS,CLASSES,WINDOWFILE,NSAMPLES){
#PATH= path to the folder where the folders in FOLDERS are located
#FOLDERS= names of the folders in which the class-specific samples are being stored
#CLASSES= Vector with class names in the same order as the folders are in FOLDERS
#NROW= total number of rows (genomic windows)
#NCOL= total number of columns (samples)
#WINDOWFILE= path and filename for the file that contains the genomic window information (hg19_300bp_Windows object)
#Returns a list with two objects: matrix with each column corresponding to a sample and a class label vector

  load(WINDOWFILE,verbose=TRUE)
  
  DATAMATRIX=matrix(,nrow=dim(hg19_300bp_Windows)[1],ncol=NSAMPLES)
  N_FILES=matrix(,nrow=length(FOLDERS),ncol=1)
  S_IND=1
  SAMPLENAMES=c()
  
  for(i in c(1:length(FOLDERS))){
    FILES=list.files(paste(PATH,"/",FOLDERS[i],sep=""))
    N_FILES[i]=length(FILES)
    #It is assumed that the file names are of the format <cancer name abbreviation>_<sample number>_Counts.txt
    SAMPLENAMES=c(SAMPLENAMES, unlist(lapply(FILES,function (x) unlist(strsplit(x,"_C"))[1]))) 
    
    for(j in c(1:length(FILES))){
      SAMPLEDATA=read.table(paste(PATH,"/",FOLDERS[i],"/",FILES[j],sep=""), header=FALSE)
      DATAMATRIX[,S_IND]=as.matrix(SAMPLEDATA)
      S_IND=S_IND+1
    }
  } 


  rownames(DATAMATRIX)=hg19_300bp_Windows$WindowsCoords
  colnames(DATAMATRIX)=SAMPLENAMES
  
  DM = list("datamatrix"=DATAMATRIX, "classes"=rep(CLASSES,N_FILES))
  return(DM)
}

#The original implementation of the sampling was made by Emmi Rehn
#thinData thins every sample separately, preserving PERCENTAGE proportion of the counts for a sample

thinData <- function(DATA, PERCENTAGE){
  #DATA= the data object to be thinned
  #PERCENTAGE= how big portion of the reads is, number between 0 and 1
  
  for(i in c(1:dim(DATA)[2])){
    if(i==1){
      NEW_COUNTS=tabulate(sample(rep.int(1:dim(DATA)[1],times=DATA[,i]), size=round(sum(DATA[,i])*PERCENTAGE), replace=FALSE))
      THINNED=c(NEW_COUNTS,rep(0, dim(DATA)[1] - length(NEW_COUNTS)))
    }
    else{
      NEW_COUNTS=tabulate(sample(rep.int(1:dim(DATA)[1],times=DATA[,i]), size=round(sum(DATA[,i])*PERCENTAGE), replace=FALSE))
      THINNED=cbind(THINNED,c(NEW_COUNTS,rep(0, dim(DATA)[1] - length(NEW_COUNTS))))
    }
    
  }
  
  rownames(THINNED)=rownames(DATA)
  colnames(THINNED)=colnames(DATA)    
  
  return(THINNED)
}

#A modified version of the function above
#Instead of a percentage, a specified number of reads will be generated

thinData_readnumber <- function(DATA, READNUMBER){
  #DATA= the data object to be thinned
  #READNUMBER= number of reads to be generated for each sample

  for(i in c(1:dim(DATA)[2])){
    if(i==1){
      NEW_COUNTS=tabulate(sample(rep.int(1:dim(DATA)[1],times=DATA[,i]), size=READNUMBER, replace=FALSE))
      THINNED=c(NEW_COUNTS,rep(0, dim(DATA)[1] - length(NEW_COUNTS)))
    }
    else{
      NEW_COUNTS=tabulate(sample(rep.int(1:dim(DATA)[1],times=DATA[,i]), size=READNUMBER, replace=FALSE))
      THINNED=cbind(THINNED,c(NEW_COUNTS,rep(0, dim(DATA)[1] - length(NEW_COUNTS))))
    }
    
  }

  rownames(THINNED)=rownames(DATA)
  colnames(THINNED)=colnames(DATA)

  return(THINNED)
}
