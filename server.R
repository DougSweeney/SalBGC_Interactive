library(shiny)
library(dplyr)

function(input, output, session){
  #Set working Directory and Call in dependencies
  library(shiny)
  library(dplyr)
  setwd("./")
  xcoord <- read.csv("x axis.txt", sep = "\t", col.names = c("X1", "X2", "BGC"), header = F)
  ycoord <- read.csv("y axis.txt", sep = "\t", col.names = c("y1", "y2", "Strain"), header = F)
  datafile <- read.csv("salinisporaBGC-clustering.csv", col.names = c("AntiSmash5_GBK", "Strain", "Species", "GCF", "BGC_T1", "BGC_T2", "BGC_T3", "BGC_T4"))
  datafile$Strain <- sub("_.{2,3}_...$", "", datafile$Strain)
  #Set up for comparison later
  charZ <- character(0)
  #Create clickCoords as reactive value, hard code it to the fist strain and first BGC (lazy coding)
  clickCoords <- reactiveValues(xy=data.frame(x=c(800), y=c(1070)))
  #Get click coords and set clickCoords to the x,y values
  observeEvent(input$image_click, {
    clickCoords$xy[1,] <- c(input$image_click$x, input$image_click$y)
  })
  
  #Render BGC Image, need to figure out how to resize or zoom with clicking better  
  output$image1 <- renderImage({
    width  <- session$clientData$output_image1_width
    height <- session$clientData$output_image1_height
    list(
      src = "GCF2mod.abundance-01.png",
      contentType = "image/png",
      width = "width",
      height = "height"
    )
  })
  #Print out data about clicked point
  output$info <- renderPrint({
    #Filter x / y data files for correct row based on click x,y coordinates
    xcoord <- filter(filter(xcoord, X1 <= clickCoords$xy[1,1]), X2 > clickCoords$xy[1,1])
    ycoord <- filter(filter(ycoord, y1 <= clickCoords$xy[1,2]), y2 > clickCoords$xy[1,2])
    #Filter datafile for xcoord$BGC and verify ycoord$Strain is there. If yes, return bgc link, else return "ycoord$Strain doesnot contain xcoord$BGC"
    dat1 <- filter(datafile, as.character(datafile$GCF) == as.character(xcoord$BGC))
    dat <- filter(dat1, dat1$Strain == as.character(ycoord$Strain))
    
    print(paste("Strain:", as.character(ycoord$Strain)))
    print(paste("BGC Family:", xcoord$BGC))
    #Make sure strain has BGC, return GBK file or inform user BGC isnt in strain
    if (identical(as.character(dat$AntiSmash5_GBK), charZ)) {
      print(paste("Strain", ycoord$Strain, "does not contain", xcoord$BGC))
     } else {
       print(paste("BGC GBK File: ", as.character(dat$AntiSmash5_GBK), ".gbk", sep=""))
     }
    print(paste("Strain AntiSmash5 File: ", "https://github.com/alex-b-chase/salBGCevol/blob/master/antismash5/",as.character(ycoord$Strain),".tar.gz", sep=""))
   })
  
  #Create output table of all strains that contain BGC
  output$table1 <- renderTable({
    #Get BGC Name by filtering x coord file by clicked x coordinate
    xcoord <- filter(filter(xcoord, X1 <= clickCoords$xy[1,1]), X2 > clickCoords$xy[1,1])
    #Filter datafile for rows containing BGC to show strains with BGC
    dat1 <- filter(datafile, as.character(datafile$GCF) == as.character(xcoord$BGC))
    dat1
  })
}
