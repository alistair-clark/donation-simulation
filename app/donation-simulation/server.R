
library(shiny)
library(scales)
library(tidyverse)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  
  
  output$budget <- renderPlot({
    # Create dataframe with data in budget.csv
    budget_df <- tibble(input$income, input$taxes, input$savings)
    
    # Add "remaining" column
    budget_df <-
      budget_df %>%
      mutate(remaining = input$income - input$taxes - input$savings)
    
    # Reshape data and add columns needed to create waterfall plot
    budget_df <-
      budget_df %>%
      gather(key = 'item', value = 'amount') %>%
      mutate(
        id = c(1:4),
        item = factor(item, levels = item[order(id)]),
        start = c(
          0,
          (amount[1] - amount[2]),
          (amount[1] - amount[2] - amount[3]),
          (amount[1] - amount[2] - amount[3] - amount[4])
        ),
        end = c(amount[1],
                amount[1],
                start[2],
                start[3]),
        type = c("positive",
                 "negative",
                 "negative",
                 "net")
      )
    
    # Create waterfall chart
    options(scipen = 999)
    p <- budget_df %>%
      ggplot(aes(
        fill = type,
        x = item,
        xmin = id - 0.4,
        xmax = id + 0.4,
        ymin = end,
        ymax = start
      )) +
      geom_rect() +
      labs(
        title = 'Annual Budget',
        subtitle = '',
        x = '',
        y = "Dollars ($)"
      ) +
      scale_y_continuous(labels = dollar) +
      geom_text(aes(
        y = end,
        label = paste0("$", prettyNum(amount, big.mark = ",")),
        hjust = 0.5,
        vjust = 2
      )) +
      guides(fill = FALSE)
    
    p
  })
  
  output$spending <- renderPlot({
    plot(cars, type=input$plotType)
  })
  
  values <- reactiveValues()
  
  ## Handsontable
  # observe({
  #   if (!is.null(input$table)) {
  #     DF = hot_to_r(input$table)
  #   } else {
  #     if (is.null(values[["DF"]]))
  #       DF <- DF
  #     else
  #       DF <- values[["DF"]]
  #   }
  #   values[["DF"]] <- DF
  # })
  # 
  # output$table <- renderRHandsontable({
  #   DF <- values[["DF"]]
  #   if (!is.null(DF))
  #     rhandsontable(DF, useTypes = as.logical(input$useType), stretchH = "all")
  # })
  # 
  # ## Save 
  # observeEvent(input$save, {
  #   finalDF <- isolate(values[["DF"]])
  #   saveRDS(finalDF, file=file.path(outdir, sprintf("%s.rds", outfilename)))
  # })
  
  
})
