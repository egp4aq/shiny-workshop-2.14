# Load packages ----
library(shiny)
library(ggplot2)

# user interface ----
ui <- fluidPage(
    
    # app title ----
    tags$h1("My App Title"),
    
    # app subtitle ----
    tags$h4(tags$strong("Exploring Antarctic Penguin Data")),
    
    # body mass slider input ----
    sliderInput(inputId = "body_mass_input",
                label = "Select a range of body masses (g)",
                min = 2700, max = 6300, value = c(3000, 4000)),
    
    # body mass plot output ----
    plotOutput(outputId="body_mass_scatterplot_output"),
    
    # year checkbox input ----
    checkboxGroupInput(inputId = "year_input",
                       label = "Select year(s):",
                       choices = c(2007, 2008, 2009), # unique(penguins$year)
                       selected = c(2007, 2008)),
    
    # DT output ----
    DT::dataTableOutput(outputId = "penguin_DT_output")
    
)

# server ----
server <- function(input, output) {
    
    # render penguin scatter plot ----
    output$body_mass_scatterplot_output <- renderPlot({
        
        # filter body masses ----
        body_mass_df <- reactive({
            
            penguins %>%
                filter(body_mass_g %in% c(input$body_mass_input[1]:input$body_mass_input[2]))
            
        })
        
        # code to generate our plot
        ggplot(na.omit(body_mass_df()), # remember to include () after any reactive dataframe 
               aes(x = flipper_length_mm, y = bill_length_mm, 
                   color = species, shape = species)) +
            geom_point() +
            scale_color_manual(values = c("Adelie" = "darkorange", "Chinstrap" = "purple", "Gentoo" = "cyan4")) +
            scale_shape_manual(values = c("Adelie" = 19, "Chinstrap" = 17, "Gentoo" = 15)) +
            labs(x = "Flipper length (mm)", y = "Bill length (mm)", 
                 color = "Penguin species", shape = "Penguin species") +
            guides(color = guide_legend(position = "inside"),
                   size = guide_legend(position = "inside")) +
            theme_minimal() +
            theme(legend.position.inside = c(0.85, 0.2), 
                  legend.background = element_rect(color = "white"))
    })
    
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ##                           Build a reactive DataTable                         ----
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    year_df <- reactive({
        
        penguins %>%
            filter(year %in% c(input$year_input[1], input$year_input[3]))
    })
    
    # render the DT::dataTable ----
    output$penguin_DT_output <- DT::renderDataTable({
        
        
        DT::datatable(year_df())
    })
   
}

# combine our UI and server into an app ----
shinyApp(ui = ui, server = server)