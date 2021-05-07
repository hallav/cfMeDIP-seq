#This script is for comparing the cfMeDIP-seq DMRs to RRBS-seq DMCs from Shen et al. (2018) Sensitive tumour detection and classification using plasma cell-free DNA methylomes. Nature 563, 579–583. https://doi.org/10.1038/s41586-018-0703-0)
#Note that the file and folder paths must be defined before running this script

#Where the RRBS-seq DMCs are located
#The DMCs are provided as supplementary material of Shen et al. (2018) 
INPUTFOLDER<-###
#The folder where the DMRs have been stored (PDAC vs. control comparison only)
DMRFOLDER<-###

find_overlaps <- function(DMR1, DMR2){

  #A function for going through DMR1 and find those that have overlapping regions in DMR2
  #DMR1 and DMR2 should be data frames with chromosome in 1st column, DMR start in 2nd and DMR end in 3rd column
  overlap_indicator <- rep(0,nrow(DMR1))

  for(i in 1:nrow(DMR1)){ 
    temp <- subset(DMR2 , chr==DMR1[i,1] & start>=DMR1[i,2] & end<=DMR1[i,3])
    overlap_indicator[i]<-nrow(temp)
  }
  return(overlap_indicator)
}

find_overlaps_direction <- function(DMR1, DMR2){

  #A function for going through DMR1 and find those that have overlapping regions in DMR2
  #DMR1 and DMR2 should be data frames with chromosome in 1st column, DMR start in 2nd and DMR end in 3rd column, 4th column indicates whether the DMR is hyper- (1) or hypomethylated (0)
  overlap_indicator <- rep(0,nrow(DMR1))

  for(i in 1:nrow(DMR1)){
    temp <- subset(DMR2 , chr==DMR1[i,1] & start>=DMR1[i,2] & end<=DMR1[i,3] & direction==DMR1[i,4])
    overlap_indicator[i]<-nrow(temp)
  }
  return(overlap_indicator)
}

#Load RRBS-seq DMCs
#The supplementary tables were originally provided as xlsx files, but the relevant columns were picked and saved as txt files for this purpose
DMCs_tissuevstissue <- read.table(paste(INPUTFOLDER,"/Supplementary_Table_2.txt",sep=""),sep="\t",header=FALSE)
DMCs_tissuevsPBMC <- read.table(paste(INPUTFOLDER,"/Supplementary_Table_3.txt",sep=""),sep="\t",header=FALSE)


#Form a data frame
RRBS_DMRs_tissuevstissue <-data.frame(chr=DMCs_tissuevstissue[,1],start=DMCs_tissuevstissue[,2],end=DMCs_tissuevstissue[,3],direction=ifelse(DMCs_tissuevstissue[,4]>0,1,0),stringsAsFactors=FALSE)
RRBS_DMRs_tissuevsPBMC <-data.frame(chr=DMCs_tissuevsPBMC[,1],start=DMCs_tissuevsPBMC[,2],end=DMCs_tissuevsPBMC[,3],direction=ifelse(DMCs_tissuevsPBMC[,4]>0,1,0),stringsAsFactors=FALSE)


#Define directory where the figures are stored
FIGFOLDER <- ###
FIGNAME<-paste(FIGFOLDER,"/DMR_overlap_with_RRBS_DMCs.pdf",sep="")

list_of_overlap_tables_tissuevstissue <- list()
list_of_overlap_tables_allMethods_tissuevstissue <- list()

list_of_overlap_tables_tissuevsPBMC <- list()
list_of_overlap_tables_allMethods_tissuevsPBMC <- list()

for(METHOD in 1:3){
  list_of_overlap_tables_tissuevstissue <- list()
  list_of_overlap_tables_tissuevsPBMC <- list()

  index <- 1
  for(THINNING in c(4,5,6)){
    DMRFOLDER_Fisher<-paste(DMRFOLDER,"/totalReadcount10_",THINNING,"/DMRs_for_RRBS_comparison/Fisher",sep="")
    DMRFOLDER_moderatedt_newT<-paste(DMRFOLDER,"totalReadcount10_",THINNING,"/DMRs_for_RRBS_comparison/moderatedt_newTransformation",sep="")
    DMRFOLDER_moderatedt<-paste(DMRFOLDER,"/totalReadcount10_",THINNING,"/DMRs_for_RRBS_comparison/moderatedt",sep="")

    number_of_DMRs_with_overlapping_RRBS_DMR_tissuevstissue <- rep(0,100)
    number_of_DMRs_with_overlapping_RRBS_DMR_tissuevsPBMC <- rep(0,100)

    for(ID in 1:100){
      if(METHOD==1){
        DMRFOLDER<-DMRFOLDER_moderatedt
      }else{
        if(METHOD==2){
          DMRFOLDER<-DMRFOLDER_moderatedt_newT
        }else{
          DMRFOLDER<-DMRFOLDER_Fisher
        }
      }

      #Load cfMeDIP-seq DMRs 
      load(paste(DMRFOLDER,"/found_DMRS_bottom_",ID,".RData",sep=""))
      load(paste(DMRFOLDER,"/found_DMRS_top_",ID,".RData",sep=""))

      if(METHOD==3){
        #Pick the DMRs for control vs. pancreatic cancer comparison
        temp1 <- unlist(strsplit(FeatureList_top_Fisher$PDAC,split="[.]"))
        #Pick the DMRs for control vs. pancreatic cancer comparison
        temp2 <- unlist(strsplit(FeatureList_bottom_Fisher$PDAC,split="[.]"))
      }else{
        if(METHOD==1){
          temp1 <- unlist(strsplit(FeatureList_top$PDAC,split="[.]"))
          temp2 <- unlist(strsplit(FeatureList_bottom$PDAC,split="[.]"))
        }else{
          temp1 <- unlist(strsplit(FeatureList_top_newT$PDAC,split="[.]"))
          temp2 <- unlist(strsplit(FeatureList_bottom_newT$PDAC,split="[.]"))
        }
      }

      temp2<- matrix(temp2,ncol=3,byrow=TRUE)
      temp1<- matrix(temp1,ncol=3,byrow=TRUE)

      #Form a data frame

      cfMeDIP_DMRs <- data.frame(chr= c(temp1[,1],temp2[,1]), start=c(as.numeric(temp1[,2]),as.numeric(temp2[,2])), end=c(as.numeric(temp1[,3]),as.numeric(temp2[,3])),direction=c(rep(1,nrow(temp1)),rep(0,nrow(temp2))),stringsAsFactors=FALSE)

      #Go through cfMeDIP-seq DMRs and find those that have overlapping RRBS-DMC(s)

      print("Overlaps when the direction is taken into account")
      cfMeDIP_DMRs_overlaps_tissuevstissue <- find_overlaps_direction(cfMeDIP_DMRs,RRBS_DMRs_tissuevstissue)
      cfMeDIP_DMRs_overlaps_tissuevsPBMC <- find_overlaps_direction(cfMeDIP_DMRs,RRBS_DMRs_tissuevsPBMC)

      number_of_DMRs_with_overlapping_RRBS_DMR_tissuevstissue[ID]<-length(which(cfMeDIP_DMRs_overlaps_tissuevstissue>0))
      number_of_DMRs_with_overlapping_RRBS_DMR_tissuevsPBMC[ID]<-length(which(cfMeDIP_DMRs_overlaps_tissuevsPBMC>0))
    }  

    list_of_overlap_tables_tissuevstissue[[index]] <- number_of_DMRs_with_overlapping_RRBS_DMR_tissuevstissue
    list_of_overlap_tables_tissuevsPBMC[[index]] <- number_of_DMRs_with_overlapping_RRBS_DMR_tissuevsPBMC
    index <- index+1

  }
  list_of_overlap_tables_allMethods_tissuevstissue[[METHOD]] <- list_of_overlap_tables_tissuevstissue
  list_of_overlap_tables_allMethods_tissuevsPBMC[[METHOD]] <- list_of_overlap_tables_tissuevsPBMC

}

#Build a data frame, one for each thinning, separately for tissue vs. tissue and tissue vs. PBMC
list_of_DFs_tissuevstissue <-list()
list_of_DFs_tissuevsPBMC <-list()

M1_tissuevstissue <- list_of_overlap_tables_allMethods_tissuevstissue[[1]]
M2_tissuevstissue <- list_of_overlap_tables_allMethods_tissuevstissue[[2]]
M3_tissuevstissue <- list_of_overlap_tables_allMethods_tissuevstissue[[3]]

M1_tissuevsPBMC <- list_of_overlap_tables_allMethods_tissuevsPBMC[[1]]
M2_tissuevsPBMC <- list_of_overlap_tables_allMethods_tissuevsPBMC[[2]]
M3_tissuevsPBMC <- list_of_overlap_tables_allMethods_tissuevsPBMC[[3]]

for(THINNING in 1:3){

  DF_tissuevstissue <- data.frame(method=rep(c("t-test", "t-test newT.", "Fisher"),each=100),
                   count=c(M1_tissuevstissue[[THINNING]],M2_tissuevstissue[[THINNING]],M3_tissuevstissue[[THINNING]]))

  DF_tissuevsPBMC <- data.frame(method=rep(c("t-test", "t-test newT.", "Fisher"),each=100),
                   count=c(M1_tissuevsPBMC[[THINNING]],M2_tissuevsPBMC[[THINNING]],M3_tissuevsPBMC[[THINNING]]))

  list_of_DFs_tissuevstissue[[THINNING]] <- DF_tissuevstissue
  list_of_DFs_tissuevsPBMC[[THINNING]] <- DF_tissuevsPBMC

}


library(ggplot2)
library(cowplot)

#Loop over the three thinning versions

list_of_plots_tissuevstissue <-list()
list_of_plots_tissuevsPBMC <- list()

for(THINNING in 1:3){

  p1 <- ggplot(list_of_DFs_tissuevstissue[[THINNING]],aes(x=method,y=count))+
            geom_boxplot(fill="seagreen", alpha=0.2,outlier.colour = "black",outlier.alpha = 1)+
            ylab("Number of DMRs with overlap") +
            ylim(0,15)+
            theme(axis.title.x=element_blank(),legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))
            
  p2 <- ggplot(list_of_DFs_tissuevsPBMC[[THINNING]],aes(x=method,y=count))+
            geom_boxplot(fill="seagreen", alpha=0.2,outlier.colour = "black",outlier.alpha = 1)+
            ylim(0,15)+
            theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none", text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))

  if(THINNING==1){

    p1 <- p1 + ggtitle("Tumour tissue vs. normal tissue ")+
          theme(plot.title = element_text(hjust = 0.5))

    p2 <- p2 + ggtitle("Tumour tissue vs. PBMC")+
          theme(plot.title = element_text(hjust = 0.5))

  }

  list_of_plots_tissuevstissue[[THINNING]] <- p1
  list_of_plots_tissuevsPBMC[[THINNING]] <- p2

}

library(extrafont)

loadfonts()

WIDTH_PDF<-6.69
HEIGHT_PDF<-4.5

top_row <- plot_grid(list_of_plots_tissuevstissue[[1]],list_of_plots_tissuevsPBMC[[1]],labels=NULL,ncol=2,label_size=6,hjust=0,vjust=0.5)
middle_row <- plot_grid(list_of_plots_tissuevstissue[[2]],list_of_plots_tissuevsPBMC[[2]],labels=NULL,ncol=2,label_size=6,hjust=0,vjust=0.5)
bottom_row <- plot_grid(list_of_plots_tissuevstissue[[3]],list_of_plots_tissuevsPBMC[[3]],labels=NULL,ncol=2,label_size=6,hjust=0,vjust=0.5)

ROC_grid <- plot_grid(top_row,middle_row,bottom_row,labels = "AUTO",label_size = 9, ncol = 1,scale = 0.9)

pdf(FIGNAME,width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(ROC_grid)
dev.off()
embed_fonts(FIGNAME, outfile = paste(FIGFOLDER,"/DMR_overlap_with_RRBS_DMCs_embed.pdf",sep=""))
 
 
