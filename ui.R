library(shiny)
library(dplyr)

#UI Section, creates 2 tabs. 1 with image and clicked info, the other with all strains containing clicked BGC
fluidPage({
  library(shiny)
  library(dplyr)
  titlePanel("Salinispora GeneClusterFamilies by Phylogeny")
  tabsetPanel(type="tabs",
              tabPanel("Image", fixedPanel(verbatimTextOutput("info")),imageOutput("image1", click="image_click")),
              tabPanel("GCF Table", column(12, tableOutput("table1"))))
})