#Script for plotting PCA and ISPCA componentfrom modelTraining_methods.Rs
#Note that file and folder paths must be defined before running this script

library(ggplot2)
library(cowplot)
library(RColorBrewer)
getPalette = colorRampPalette(brewer.pal(8, "Accent"))

source("modelTraining_methods.R")

FIGFOLDER <- ### Folder where the figures will be saved into

#Function for obtaining a data frame of data projected to PCA components for plotting purposes
#Using function train_LR_RHS_model_PCA_features from modelTraining_methods.R as basis 
PCA_for_plotting <- function(DM, classInformation, isISPCA=0, TrainIndices, pca_results, normalize_pca=0,N_components=153){

  if(isISPCA==1){
    library(dimreduce)
  }

  DM_Train <- DM[,TrainIndices]
  class_train <- classInformation[TrainIndices,]
  X <- t(predict(pca_results, t(DM_Train))) 

  X <- as.matrix(X[1:N_components,])

  if(normalize_pca==1){
    print("Normalizing training data")
    X <- standardizecounts_scale_only(X)
  }

  DM_test <- DM[,!colnames(DM) %in% class_train$ID]
  class_test <- classInformation%>%filter(!ID %in% class_train$ID)
  X_test <- t(predict(pca_results, t(X_test)))
  X_test <- as.matrix(X_test[1:N_components,])

  if(normalize_pca==1){
    print("Normalizing test data")
    X_train_temp = t(as.matrix(predict(pca_results, t(DM_Train))))
    X_test <- standardizecounts_validation_scale_only(X_train_temp[1:N_components,],X_test)
    rm(X_train_temp)
  }

  levels(class_train$Classes) <- c("AML","BLCA","BRCA","Normal","CRC","LUC","PDAC","RCC")
  levels(class_test$Classes) <- c("AML","BLCA","BRCA","Normal","CRC","LUC","PDAC","RCC")

  CLASSNAMES <- unique(class_train$Classes)

  CLASSNAMES_test <- rep("none",length(CLASSNAMES))

  CLASS_COUNTS_train <- rep("none",length(CLASSNAMES))
  CLASS_COUNTS_test <-	rep("none",length(CLASSNAMES))

  CLASS_INDICATOR_train <- rep("none",length(class_train$Classes))
  CLASS_INDICATOR_test <- rep("none",length(class_test$Classes))

  for(C in 1:length(CLASSNAMES)){
    CLASS_COUNTS_train[C] <- length(which(class_train$Classes==CLASSNAMES[C]))
    CLASS_COUNTS_test[C] <- length(which(class_test$Classes==CLASSNAMES[C]))
    CLASSNAMES_test[C] <- paste(CLASSNAMES[C]," (test)",sep="")

    CLASS_INDICATOR_train[which(class_train$Classes==CLASSNAMES[C])]=as.character(CLASSNAMES[C])
    CLASS_INDICATOR_test[which(class_test$Classes==CLASSNAMES[C])]=CLASSNAMES_test[C]
  }


  PCA_list <- list(PCA_train=X, PCA_test=X_test, class_indicator_train=as.character(CLASS_INDICATOR_train),class_indicator_test=as.character(CLASS_INDICATOR_test))

  return(PCA_list)
}

#Load data
DATASPLIT<-1
THINNING<-4
CLASS<-1

RESULTFOLDER <-### Folder where the results from the different steps of the analysis are saved
DATAFOLDER <-### Folder where the data has been stored

#load data splits
load(paste(RESULTFOLDER,"/datasplits/dataSplits_sameReadcount_10_",THINNING,".RData",sep=""))
#load thinned data
load(paste(DATAFOLDER,"/thinneddata/wholedata_thinned_allClasses_sameReadcount10_",THINNING,".RData",sep=""))

#load PCA object
load(paste(RESULTFOLDER,"/DMRs/sameReadcount10_",THINNING,"/PCA_with_DMRs/PCA_results_dataSplit_",DATASPLIT,".RData",sep=""))
PCA_PCA_result_list <- PCA_result_list

#load ISPCA object
load(paste(RESULTFOLDER,"/DMRs/sameReadcount10_",THINNING,"/ISPCA/ISPCA_DMR_results_dataSplit_",DATASPLIT,".RData",sep=""))
ISPCA_PCA_result_list <- PCA_result_list

#load binary ISPCA object
load(paste(RESULTFOLDER,"/DMRs/sameReadcount10_",THINNING,"/ISPCA_without_binarize/ISPCA_DMR_results_dataSplit_",DATASPLIT,".RData",sep=""))
ISPCA_bin_PCA_result_list <- PCA_result_list


#Data normalization with respect to the total read counts
wholeData_thinned <- normalizecounts_scale(wholeData_thinned)
#Remove all-zero rows from wholeData_thinned
wholeData_thinned <- wholeData_thinned[rowSums(wholeData_thinned)>0,]

#Apply new transformation of the data before giving it as an input to the model fitting
wholeData_thinned <- log2(wholeData_thinned * 0.3 + 0.5)

#PCA 

PCA_OBJECT_PCA <- PCA_PCA_result_list[[CLASS]]
PCA_list <- PCA_for_plotting(DM = wholeData_thinned, classInformation = dataSplits$df, TrainIndices = dataSplits$samples[[DATASPLIT]],isISPCA=0,normalize_pca=1,pca_results=PCA_OBJECT_PCA,N_components=153)
PCA_DF <- data.frame(pc1= c(PCA_list$PCA_train[1,],PCA_list$PCA_test[1,]), pc2= c(PCA_list$PCA_train[2,],PCA_list$PCA_test[2,]), pc3= c(PCA_list$PCA_train[3,],PCA_list$PCA_test[3,]), pc4= c(PCA_list$PCA_train[4,],PCA_list$PCA_test[4,]),  class =c(PCA_list$class_indicator_train,PCA_list$class_indicator_test),pc5= c(PCA_list$PCA_train[5,],PCA_list$PCA_test[5,]),pc6= c(PCA_list$PCA_train[6,],PCA_list$PCA_test[6,]))


#ISPCA
PCA_OBJECT_ISPCA <- ISPCA_PCA_result_list[[1]]
ISPCA_list <- PCA_for_plotting(DM = wholeData_thinned, classInformation = dataSplits$df, TrainIndices = dataSplits$samples[[DATASPLIT]],isISPCA=1,normalize_pca=0,pca_results=PCA_OBJECT_ISPCA,N_components=153)
ISPCA_DF <- data.frame(pc1= c(ISPCA_list$PCA_train[1,],ISPCA_list$PCA_test[1,]), pc2= c(ISPCA_list$PCA_train[2,],ISPCA_list$PCA_test[2,]), class =c(ISPCA_list$class_indicator_train,ISPCA_list$class_indicator_test),pc3= c(ISPCA_list$PCA_train[3,],ISPCA_list$PCA_test[3,]),pc4= c(ISPCA_list$PCA_train[4,],ISPCA_list$PCA_test[4,]),pc5= c(ISPCA_list$PCA_train[5,],ISPCA_list$PCA_test[5,]),pc6= c(ISPCA_list$PCA_train[6,],ISPCA_list$PCA_test[6,]),pc7= c(ISPCA_list$PCA_train[7,],ISPCA_list$PCA_test[7,]),pc8= c(ISPCA_list$PCA_train[8,],ISPCA_list$PCA_test[8,]),pc9= c(ISPCA_list$PCA_train[9,],ISPCA_list$PCA_test[9,]), pc10= c(ISPCA_list$PCA_train[10,],ISPCA_list$PCA_test[10,]),pc11= c(ISPCA_list$PCA_train[11,],ISPCA_list$PCA_test[11,]),pc12= c(ISPCA_list$PCA_train[12,],ISPCA_list$PCA_test[12,]))



PCA_OBJECT_ISPCA_bin <- ISPCA_bin_PCA_result_list[[CLASS]]
ISPCA_bin_list <- PCA_for_plotting(DM = wholeData_thinned, classInformation = dataSplits$df, TrainIndices = dataSplits$samples[[DATASPLIT]],isISPCA=1,normalize_pca=0,pca_results=PCA_OBJECT_ISPCA_bin,N_components=153)
ISPCA_bin_DF <- data.frame(pc1= c(ISPCA_bin_list$PCA_train[1,],ISPCA_bin_list$PCA_test[1,]), pc2= c(ISPCA_bin_list$PCA_train[2,],ISPCA_bin_list$PCA_test[2,]), pc3= c(ISPCA_bin_list$PCA_train[3,],ISPCA_bin_list$PCA_test[3,]), pc4= c(ISPCA_bin_list$PCA_train[4,],ISPCA_bin_list$PCA_test[4,]),  class =c(ISPCA_bin_list$class_indicator_train,ISPCA_bin_list$class_indicator_test),pc5= c(ISPCA_bin_list$PCA_train[5,],ISPCA_bin_list$PCA_test[5,]),pc6= c(ISPCA_bin_list$PCA_train[6,],ISPCA_bin_list$PCA_test[6,]))


#Make plots

#Plot 1: ISPCA
#PC1 vs PC2
print(ISPCA_list$PCA_train[1,])
print(ISPCA_list$PCA_test[1,])
print(ISPCA_list$class_indicator_train)
print(ISPCA_list$class_indicator_test)


plot_ISPCA <- ggplot(data=ISPCA_DF, aes(x=pc1,y=pc2,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC1")+
              ylab("PC2")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))

plot_ISPCA_legend <- ggplot(data=ISPCA_DF, aes(x=pc1,y=pc2,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16),name="")+
              xlab("PC1")+
              ylab("PC2")+
              theme(text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"),legend.key.height= unit(0.4, 'cm'),legend.key.width= unit(0.2, 'cm'),legend.spacing.y = unit(0.05, 'cm'))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(legend.text=element_text(size=7))+
              theme(legend.key=element_blank())

legend_ISPCA <- get_legend(plot_ISPCA_legend)

#PC3 vs PC4

plot_ISPCA2 <- ggplot(data=ISPCA_DF, aes(x=pc3,y=pc4,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC3")+
              ylab("PC4")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))

plot_ISPCA3 <- ggplot(data=ISPCA_DF, aes(x=pc5,y=pc6,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC5")+
              ylab("PC6")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))

plot_ISPCA4 <- ggplot(data=ISPCA_DF, aes(x=pc7,y=pc8,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC7")+
              ylab("PC8")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))
 
plot_ISPCA5 <- ggplot(data=ISPCA_DF, aes(x=pc9,y=pc10,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC9")+
              ylab("PC10")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))

plot_ISPCA6 <- ggplot(data=ISPCA_DF, aes(x=pc11,y=pc12,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC11")+
              ylab("PC12")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))

#Plot 2: binary ISPCA + PCA

plot_ISPCA_bin <- ggplot(data=ISPCA_bin_DF, aes(x=pc1,y=pc2,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC1")+
              ylab("PC2")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))


#PC3 vs PC4

plot_ISPCA_bin2 <- ggplot(data=ISPCA_bin_DF, aes(x=pc3,y=pc4,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC3")+
              ylab("PC4")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))

plot_ISPCA_bin3 <- ggplot(data=ISPCA_bin_DF, aes(x=pc5,y=pc6,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC5")+
              ylab("PC6")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))


#plot PCA results

plot_PCA <- ggplot(data=PCA_DF, aes(x=pc1,y=pc2,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC1")+
              ylab("PC2")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))

plot_PCA2 <- ggplot(data=PCA_DF, aes(x=pc3,y=pc4,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC3")+
              ylab("PC4")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
             theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))

plot_PCA3 <- ggplot(data=PCA_DF, aes(x=pc5,y=pc6,color=factor(class)))+
              geom_point()+
              scale_color_manual(values = getPalette(16))+
              xlab("PC5")+
              ylab("PC6")+
              theme(legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
              theme(aspect.ratio=1,panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))+
              theme(axis.title.x = element_text(face="bold", size=7),axis.title.y = element_text(face="bold", size=7))


library(extrafont)

loadfonts()

FIGID <- ""

WIDTH_PDF<-6.69
HEIGHT_PDF<-4.5

FIGNAME <-paste("ISPCA_plot_thinning",THINNING,"_dataSplit",DATASPLIT,"_class",CLASS,"_",FIGID,sep="")

ISPCA_grid <- plot_grid(plot_ISPCA,plot_ISPCA2,plot_ISPCA3,label_size=9,ncol=1,scale = 0.9)
ISPCA_bin_grid <- plot_grid(plot_ISPCA_bin,plot_ISPCA_bin2,plot_ISPCA_bin3,label_size=9,ncol=1,scale = 0.9)
PCA_grid <- plot_grid(plot_PCA,plot_PCA2,plot_PCA3,label_size=9,ncol=1,scale = 0.9)

all_plots_grid <- plot_grid(PCA_grid,ISPCA_bin_grid,ISPCA_grid,labels="AUTO",label_size=9,ncol=3)

pdf(file=paste(FIGFOLDER,"/",FIGNAME,".pdf",sep=""),width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(all_plots_grid,legend_ISPCA,ncol=2,scale=c(1,0.5),rel_widths=c(5,1)))
dev.off()
embed_fonts(paste(FIGFOLDER,"/",FIGNAME,".pdf",sep=""), outfile = paste(FIGFOLDER,"/",FIGNAME,"_embed.pdf",sep=""))

ISPCA_grid2 <- plot_grid(plot_ISPCA,plot_ISPCA2,plot_ISPCA3,plot_ISPCA4,plot_ISPCA5,plot_ISPCA6,label_size=9,nrow=2,scale = 0.9)
pdf(file=paste(FIGFOLDER,"/",FIGNAME,"_onlyISPCA",".pdf",sep=""),width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(ISPCA_grid2,legend_ISPCA,ncol=2,scale=c(1,0.5),rel_widths=c(3,1)))
dev.off()



