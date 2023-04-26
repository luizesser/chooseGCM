#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(chooseGCM)
library(leaflet)
library(sf)
library(raster)
library(checkmate)
library(factoextra)
library(ggcorrplot)

parameter_tabs <- tabsetPanel(
  id = "params",
  type = "hidden",

  tabPanel("optimize_clusters",
             selectInput("method_opt", "Method:",
                         c("Silhouette" = "silhouette",
                           "Elbow (WSS)" = "wss",
                           "GAP" = "gap_stat")),
             numericInput("n",
                          "Number of cells",
                          value = 1000,
                          min = 1000,
                          max = 100000,
                          step = 1000)
  ),

  tabPanel("hclust_gcms",
             sliderInput("k",
                         "Number of clusters (k)",
                         min = 1,
                         max = 24,
                         value = 5),
             numericInput("n",
                          "Number of cells",
                          value = 1000,
                          min = 1000,
                          max = 100000,
                          step = 1000),
  ),

  tabPanel("kmeans_gcms",
             sliderInput("k",
                         "Number of clusters (k)",
                         min = 1,
                         max = 24,
                         value = 5),
             selectInput("method", "Distance method:",
                         c("Euclidean" = "euclidean",
                           "Maximum" = "maximum",
                           "Manhattan" = "manhattan",
                           "Canberra" = "canberra",
                           "Binary" = "binary",
                           "Minkowski" = "minkowski"))
  ),

  tabPanel("cor_gcms",
             selectInput("method_cor", "Correlation method:",
                         c("Pearson" = "pearson",
                           "Kendall" = "kendall",
                           "Spearman" = "spearman"))
  ),

  #tabPanel("summary_gcms"
  #)
)



# Define UI
ui <- fluidPage(
      sidebarPanel(h1("chooseGCM"),
                   fluidPage(
                     h3("Environment"),
                     fileInput(inputId = "s",
                               label = "Upload GCMs. Choose rasterStacks (.tif):",
                               multiple = TRUE,
                               accept = c('.tif')),
                     fileInput(inputId = "study_area",
                               label = "Upload shapefile of study area:",
                               multiple = TRUE,
                               accept = c('.shp','.dbf','.sbn','.sbx','.shx','.prj')),
                     selectInput(inputId = "var_names",
                                 choices = paste0('bio_',1:19),
                                 label = "Variables:",
                                 multiple=T,
                                 selected=c('bio_1', 'bio_12')),
                     actionButton("plot_map", "Plot map",
                                  style="color: #fff; background-color: #337ab7; border-color: #2e6da4; margin-bottom: 5")
                   ),

                   fluidPage(
                     h3("Functions"),
                       style = "background-color: gray99;",
                       selectInput("select",
                                   label = "Select Function:",
                                   choices = list("Optimize Clusters" = 'optimize_clusters',
                                                  "Hierarchical Clustering" = 'hclust_gcms',
                                                  "K-means" = 'kmeans_gcms',
                                                  "Correlation" = "cor_gcms"
                                                  #"Summary" = "summary_gcms"
                                                  ),
                                   selected = 1),
                        parameter_tabs,
                        actionButton("do", "Run",
                                     style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
                   )
      ),
      mainPanel(
          plotOutput("map"),
          plotOutput("opt_clust")
      )
)


# Define Server
server <- function(input, output) {

  options(shiny.maxRequestSize=500*1024^2)

  s_input <- reactive({
    if (!is.null(input$s)){
      l <- lapply(input$s$datapath, function(x){
        s <- raster::stack(x)
        names(s) <- paste0('bio_',1:19) # Rename rasters
        return(s)})
      names(l) <- input$s$names
      return(l)
    } else {
      return()
    }
  })

  upload_study_area <- reactive({
    if (!is.null(input$study_area)){
      shpDF <- input$study_area
      prevWD <- getwd()
      uploadDirectory <- dirname(shpDF$datapath[1])
      setwd(uploadDirectory)
      for (i in 1:nrow(shpDF)){
        file.rename(shpDF$datapath[i], shpDF$name[i])
      }
      shpName <- shpDF$name[grep(x=shpDF$name, pattern="*.shp")]
      shpPath <- paste(uploadDirectory, shpName, sep="/")
      setwd(prevWD)
      study_area <- st_read(shpPath)
      return(study_area)
    } else {
      return()
    }
  })

 #  output$map <- renderLeaflet({
 #    leaflet() %>%
 #      addTiles() %>%
 #      addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
 #  })

  observeEvent(input$select, {
    updateTabsetPanel(inputId = "params", selected = input$select)
  })

  observeEvent(input$plot_map, {
    output$map <- renderPlot({
      if (!is.null(s_input())){
        plot(crop(s_input()[[1]][[1]],upload_study_area()))
        plot(upload_study_area(), add=T)
      }
    })
  })

  observeEvent(input$do, {
    if(input$select == 'optimize_clusters'){
      output$opt_clust <- renderPlot({
        optimize_clusters(s_input(), input$var_names, study_area=upload_study_area(), method = input$method_opt, n = input$n)
      })
    }
    if(input$select == 'hclust_gcms'){
      output$opt_clust <- renderPlot({
        hclust_gcms(s_input(), input$var_names, study_area=upload_study_area(), k = input$k, n = input$n)
      })
    }
    if(input$select == 'kmeans_gcms'){
      output$opt_clust <- renderPlot({
        kmeans_gcms(s_input(), input$var_names, study_area=upload_study_area(), k = input$k, method = input$method)
      })
    }
    if(input$select == 'cor_gcms'){
      output$opt_clust <- renderPlot({
        cor_gcms(s_input(), input$var_names, study_area=upload_study_area(), method = input$method_cor)
      })
    }
    #if(input$select == 'summary_gcms'){ # change to render table.
    #  output$opt_clust <- renderPlot({
    #    summary_gcms(s_input(), input$var_names, study_area=upload_study_area())
    #  })
    #}
  })
}

# Run the application
shinyApp(ui = ui, server = server)
