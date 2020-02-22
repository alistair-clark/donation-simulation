



# load libraries
library(shiny)
library(scales)
library(tidyverse)

# load helper functions
source("../../src/functions.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  budget_df <- reactive({
    df <- tibble(
      'income' = input$income,
      'taxes' = input$taxes,
      'savings' = input$savings
    )
    
    # Add "remaining" column
    df <-
      df %>%
      mutate(remaining = income - taxes - savings)
    df
  })
  
  output$budget <- renderPlot({
    budget_waterfall(budget_df())
  })
  
  output$remaining <- renderUI({
    HTML(
      paste0(
        "After savings and taxes, you have <b>",
        dollar(budget_df()$remaining),
        "</b> remaining per year for living expenses and charitable donations."
      )
    )
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
    rhandsontable(values$data, stretchH = "all")
  })
  
  output$average <- renderUI({
    avg_expense <- mean(values$data$amount)
    HTML(paste0(
      "Your average monthly expenses are <b>",
      dollar(avg_expense),
      "</b>."
    ))
  })
  
  output$donation_plot <- renderPlot({
    simulations_df <- simulate(values$data, budget_df(), input$donation)
    plot_simulation(simulations_df, input$donation)
  })
  
  output$facet <- renderPlot({
    plot_facet(budget_df(), values$data)
  })
  
  
  
  output$over <- renderUI({
    simulations_df <- simulate(values$data, budget_df(), input$donation)
    percent_over <-
      simulations_df %>%
      filter(net == "Over budget") %>%
      nrow() / 10000 * 100
    
    HTML(paste0(
      "If you donate ",
      input$donation,
      "% of your salary to charity, you have a ",
      "<b>",
      percent_over,
      "</b>",
      "% chance of going over budget."
    ))
  })
})
