library(shiny)
library(markdown)
library(rhandsontable)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("How much can you afford to donate to charity?"),
  h4("An interactive tool for optimizing your charitable donations."),
  helpText("Created by Alistair Clark"),
  
  # Add Navigation Bar
  navbarPage("",
             tabPanel("Step 1: Create a basic budget",
                      sidebarLayout(
                        sidebarPanel(
                          h4("Enter your annual income, taxes, and savings"),
                          numericInput("income", label = "Income:", value = 100000),
                          numericInput("taxes", label = "Taxes:", value = 20727),
                          numericInput("savings", label = "Savings:", value = 25000),
                          helpText("Note: you can calculate taxes using an online calculator and enter the result above.")
                        
                      ),
                      mainPanel(
                        wellPanel(h4(htmlOutput("remaining"), align = "center")),
                        div(plotOutput("budget", width = "80%"), align = "center")
                      ))
                      ),
             tabPanel("Step 2: Add past expenses",
                      sidebarLayout(
                        sidebarPanel(
                          h4("Update the table below with your past monthly expenses"),
                          helpText("Monthly expenses should include everything other than taxes and savings, including rent, gas, groceries, etc."),
                          rHandsontableOutput("hot", width = "100%")
                        ),
                        mainPanel(wellPanel(h4(htmlOutput("average"), align = "center")),
                                  div(
                                    plotOutput("histogram", width = "80%"),
                                    br(),br(),
                                    plotOutput("distribution", width = "80%"),
                                    br(),br(),
                                    plotOutput("simulation", width = "80%")),
                                  align = "center")
                      )
                      ),
             
             tabPanel("Step 3: Simulate your donations",
                      sidebarLayout(
                        sidebarPanel(
                          numericInput("donation", label = "% of income donated to charity:", value = 15),
                          helpText("Adjust this number up and down until you find a donation level that fits your budget and risk tolerance.")
                        ),
                        mainPanel(
                          wellPanel(h4(htmlOutput("over"), align = "center")),
                          div(
                            br(),
                            plotOutput("donation_plot", width = "80%"),
                            br(),
                            plotOutput("facet", height = 700, width = "80%"),
                            br(), br(),
                            align = 'center'
                          ))
                        )
                      ),
             tabPanel("How the model works", icon = icon("question-circle"),
                      mainPanel(tags$a(href="https://github.com/alistair-clark/donation-simulation", h4("Github repository with full code")),
                                br(),
                                tags$a(href="https://github.com/alistair-clark/donation-simulation/blob/master/doc/report.md", h4("Aricle: How much of my salary can I afford to donate to charity?")),
                                
                        
                      )
                      )
             
             )
  )
)