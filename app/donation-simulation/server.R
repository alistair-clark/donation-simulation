


# load libraries
library(shiny)
library(scales)
library(tidyverse)

# load helper functions
source("../../src/functions.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$budget <- renderPlot({
    # Create dataframe with data in budget.csv
    budget_df <- tibble(
      'income' = input$income,
      'taxes' = input$taxes,
      'savings' = input$savings
    )
    
    # Add "remaining" column
    budget_df <-
      budget_df %>%
      mutate(remaining = income - taxes - savings)
    
    budget_waterfall(budget_df)
  })
  
  # Handsontable
  DF <-
    tibble(
      'amount' = c(
        3325.27,
        3204.42,
        2175.79,
        3435.2,
        2386.07,
        2714.56,
        4786.1,
        2201.55,
        3298.67,
        2673.46,
        2110.75,
        2734.18,
        2386.9,
        3463.15,
        2262.02,
        2448.68,
        2419.96,
        4250.16,
        2760.98,
        2611.05,
        2799.57,
        3356.27,
        2665.7,
        3044.05,
        2633.97,
        2940.95,
        2520.44,
        3206.64
      )
    )
  
  values <- reactiveValues(data = DF)
  
  
  
  observe({
    if (!is.null(input$hot)) {
      values$data <- hot_to_r(input$hot)
    }
  })
  
  output$histogram <- renderPlot({
    plot_spending(values$data,
                  add_histogram = TRUE)
  })
  output$distribution <- renderPlot({
    plot_spending(values$data,
                  add_histogram = TRUE,
                  add_theoretical = TRUE)
  })
  output$simulation <- renderPlot({
    plot_spending(values$data,
                  add_theoretical = TRUE,
                  add_simulation = TRUE)
  })
  
  output$hot <- renderRHandsontable({
    rhandsontable(DF, stretchH = "all")
  })
  
  output$donation_plot <- renderPlot({
    budget_df <- tibble(
      'income' = input$income,
      'taxes' = input$taxes,
      'savings' = input$savings
    )
    
    # Add "remaining" column
    budget_df <-
      budget_df %>%
      mutate(remaining = income - taxes - savings)
    
    simulations_df <- simulate(values$data, budget_df, input$donation)
    plot_simulation(simulations_df, input$donation)
  })
  
  output$facet <- renderPlot({
    budget_df <- tibble(
      'income' = input$income,
      'taxes' = input$taxes,
      'savings' = input$savings
    )
    
    # Add "remaining" column
    budget_df <-
      budget_df %>%
      mutate(remaining = income - taxes - savings)
    # Plot
    plot_facet(budget_df, values$data)
  })
  
})
