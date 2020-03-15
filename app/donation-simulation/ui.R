
library(shiny)
library(markdown)
library(rhandsontable)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("How much can you afford to donate to charity?"),
  
  # Add Navigation Bar
  navbarPage("",
             tabPanel("Step 1: Create a basic budget",
                      sidebarLayout(
                        sidebarPanel(
                          h4("Fill in the below:"),
                          numericInput("income", label = "Income:", value = 100000),
                          numericInput("taxes", label = "Taxes:", value = 20727),
                          numericInput("savings", label = "Savings:", value = 25000),
                          helpText("Note: you can calculate taxes using an online calculator and enter the result above.")
                        
                      ),
                      mainPanel(
                        wellPanel(h4(htmlOutput("remaining"), align = "center")),
                        plotOutput("budget")
                      ))
                      ),
             tabPanel("Step 2: Add past expenses",
                      sidebarLayout(
                        sidebarPanel(
                          h4("Add past expenses:"),
                          helpText("Fill out the table and then click the 'Save' button."),
                          rHandsontableOutput("hot")
                        ),
                        mainPanel(wellPanel(h4(htmlOutput("average"), align = "center")),
                                  plotOutput("histogram"),
                                  plotOutput("distribution"),
                                  plotOutput("simulation"))
                      )
                      ),
             
             tabPanel("Step 3: Simulate your donations",
                      sidebarLayout(
                        sidebarPanel(
                          h4("TBD:"),
                          numericInput("donation", label = "Donation (as % of income):", value = 15)
                        ),
                        mainPanel(
                          wellPanel(h4(htmlOutput("over"), align = "center")),
                          br(),
                          plotOutput("donation_plot"),
                          plotOutput("facet")
                          )
                        )
                      ),
             tabPanel("How the model works", icon = icon("question-circle"))
             )
  )
)

  
# navbarPage("Navbar!",
#            tabPanel("Plot",
#                     sidebarLayout(
#                       sidebarPanel(
#                         radioButtons("plotType", "Plot type",
#                                      c("Scatter"="p", "Line"="l")
#                         )
#                       ),
#                       mainPanel(
#                         plotOutput("plot")
#                       )
#                     )
#            )
# )
  
  
  
  
  # # Sidebar with a slider input for number of bins 
  # sidebarLayout(
  #   sidebarPanel(
  #      sliderInput("bins",
  #                  "Number of bins:",
  #                  min = 1,
  #                  max = 50,
  #                  value = 30)
  #   ),
  #   
  #   # Show a plot of the generated distribution
  #   mainPanel(
  #      plotOutput("distPlot")