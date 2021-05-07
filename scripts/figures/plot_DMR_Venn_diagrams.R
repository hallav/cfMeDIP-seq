#This script is for calculating overlaps between DMRs found with different techniques and plotting Venn diagrams
#Note that the paths must be defined to run the script.


VD_list_of_lists <-list()
thinning_iteration <- 1

library(ggplot2)
library(VennDiagram)

library(RColorBrewer)
myCol <- brewer.pal(3, "Set2")

FIGFOLDER<-###
DMRFOLDER<-###

for(THINNING in c(4,5,6)){

M1<-"moderatedt"
M2<-"moderatedt_newT"
M3<-"Fisher"
M1FOLDER<-paste(DMRFOLDER,"/totalReadcount10_",THINNING,sep="")
M2FOLDER<-paste(DMRFOLDER,"/totalReadcount10_",THINNING,"/newTransformation",sep="")
M3FOLDER<-paste(DMRFOLDER,"/totalReadcount10_",THINNING,"/Fishers_exact_test",sep="")

#List for storing the DMRs for each method
DMRList_M1 <-list()
DMRList_M2 <-list()
DMRList_M3 <-list()

for(i in 1:100){

#Load DMR set 1

load(paste(M1FOLDER,"/found_DMRS_allClasses_",i,".RData",sep=""))
DMR1<-FeatureList

#Load DMR set 2
load(paste(M2FOLDER,"/found_DMRS_allClasses_",i,".RData",sep=""))
DMR2<-FeatureList

#Load DMR set 3
load(paste(M3FOLDER,"/found_DMRS_allClasses_",i,".RData",sep=""))
DMR3<-FeatureList

rm(FeatureList)

  for(class in 1:8){
    if(i==1){
      DMRList_M1[[class]] <-DMR1[[class]]
      DMRList_M2[[class]] <-DMR2[[class]]
      DMRList_M3[[class]] <-DMR3[[class]]
      CLASSNAMES<-names(DMR1)

    }else{
      DMRList_M1[[class]] <-unique(c(DMRList_M1[[class]],DMR1[[class]]))
      DMRList_M2[[class]] <-unique(c(DMRList_M2[[class]],DMR3[[class]]))
      DMRList_M3[[class]] <-unique(c(DMRList_M3[[class]],DMR3[[class]]))
    } 

  }

}


#Plot venn diagrams
#Venn diagram code from https://www.r-graph-gallery.com/14-venn-diagramm.html , accessed 5.2.2021

VD_list<-list()

for(class in 1:8){

VD_list[[class]] <- venn.diagram(
        x = list(DMRList_M1[[class]], DMRList_M2[[class]], DMRList_M3[[class]]),
        category.names = c("t-test" , "t-test newT." , "Fisher"),
        filename=NULL,
        lwd = 1.8,
        lty = 'blank',
        fill = myCol,
        cex = .45,
        fontface = "bold",
        fontfamily = "sans",
        cat.cex = 0.50,
        cat.fontface = "italic",
        cat.dist = c(0.19, 0.2, 0.17),
        cat.fontfamily = "sans",
        margin=0.1
)

}

VD_list_of_lists[[thinning_iteration]] <-VD_list

thinning_iteration <- thinning_iteration+1

}



#plotting the grid

library("cowplot")

library(extrafont)

loadfonts()

WIDTH_PDF<-6.69
HEIGHT_PDF<- 4

FIG_ID <-"allThinnings_170mm"

CLASSNAMES_fixed <- c("AML","BRCA","CRC","PDAC","BLCA","Normal","LUC","RCC") 


top_row <- plot_grid(plotlist=lapply(VD_list_of_lists[[1]],grobTree),labels=CLASSNAMES_fixed,nrow=2,label_size=6,hjust=-0.1,vjust=0)
middle_row <- plot_grid(plotlist=lapply(VD_list_of_lists[[2]],grobTree),labels=CLASSNAMES_fixed,nrow=2,label_size=6,hjust=-0.1,vjust=0)
bottom_row <- plot_grid(plotlist=lapply(VD_list_of_lists[[3]],grobTree),labels=CLASSNAMES_fixed,nrow=2,label_size=6,hjust=-0.1,vjust=0)

pdf(file=paste(FIGFOLDER,"/venn_diagram_DMR_overlap_allClasses_",FIG_ID,"_pdf.pdf",sep=""),
    width = WIDTH_PDF, height = HEIGHT_PDF)
plot_grid(top_row,middle_row,bottom_row,labels = "AUTO",label_size = 9, ncol = 1,scale = 0.9)
dev.off()
embed_fonts(paste(FIGFOLDER,"/venn_diagram_DMR_overlap_allClasses_",FIG_ID,"_pdf.pdf",sep=""), outfile = paste(FIGFOLDER,"/venn_diagram_DMR_overlap_allClasses_",FIG_ID,"_pdf_embed.pdf",sep=""))
