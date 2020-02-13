# This file contains functions used to create plots

# load packages
library(tidyverse)
library(scales)
library(MASS)

# histogram of expenses
plot_expenses <- function(df,
                          add_histogram = FALSE,
                          add_density = FALSE,
                          add_theoretical = FALSE,
                          add_simulation = FALSE) {
  
  # Create blank plot
  full_plot <- ggplot(df,
                      aes(x = amount)) +
    scale_x_continuous(label = dollar,
                       limits = c(min(amount) - 500,
                                  max(amount) + 500)
                       ) +
    labs(
      title = "",
      subtitle = "",
      x = "Monthly Spending, in $"
      )
  
  # Check if y axis scale needs to be changed to density
  if (add_density |
      add_theoretical |
      add_simulation) {
    
    # Add histogram
    if (add_histogram) {
      full_plot <- 
        full_plot +
        geom_histogram(aes(y = ..density..),
                       binwidth = 100,
                       color = "grey30",
                       fill = "white")
    }
    
    # Add density
    if (add_density) {
      full_plot <- 
        full_plot +
        geom_density(aes(y = ..density..),
                     alpha = .1,
                     fill = "antiquewhite3") 
    }
    
    # For both plots, a fitted distribution is required
    if (add_theoretical | add_simulation) {
      
      # Fit lognormal distribution to the data
      fit_data <- fitdistr(df$amount, "lognormal")
      
      if (add_theoretical) {
        # Create functions to plot lognormal curve on graph
        expenses_dens <- function(x) dlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
        
        # Add lognormal curve to graph
        full_plot <- 
          full_plot +
          stat_function(aes(x = amount),
                        fun = expenses_dens,
                        color = "red")
      }
      if (add_simulation) {
        # simulate 12 months of expenses
        expenses_func <- function(x) rlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
        expenses_sim <- data.frame(monthly_expense = expenses_func(12))
        
        # add simulated expenses to plot
        full_plot <- 
          full_plot +
          geom_point(data = expenses_sim,
                     x = expenses_sim$monthly_expense,
                     y=0.00003,
                     color='black',
                     size=5,
                     alpha=0.5)
      }
    }
    return(full_plot)
  }
  if (add_histogram) {
    full_plot <- 
      full_plot + 
      geom_histogram(aes (x = amount),
                     binwidth = 100,
                     color = "grey30",
                     fill = "white")
  }
  full_plot  
}
plot_expenses(past_expenses,add_density = TRUE, add_theoretical = TRUE, add_histogram = TRUE)

# budget waterflow chart
budget_waterflow <- function(income, rrsp, taxes, savings, remaining) {
  # Create dataframe from to use in plot
  budget <-
    data.frame(
      item = c("Salary", "RRSP", "Taxes", "Savings", "Remaining"),
      amount = c(income, rrsp_contrib, taxes, savings, remaining)
    )
  budget$id <- c(1:5)
  budget$item <- factor(budget$item,
                        levels = budget$item[order(budget$id)])
  budget$start <- c(
    0,
    (income - rrsp),
    (income - rrsp - taxes),
    (income - rrsp - taxes - savings),
    (income - rrsp - taxes - savings - remaining)
  )
  budget$end <- c(income,
                  income,
                  budget$start[[2]],
                  budget$start[[3]],
                  budget$start[[4]])
  budget$type <- c("positive",
                   "negative",
                   "negative",
                   "negative",
                   "net")
  
  # Create waterfall chart for budget
  budget %>%
    ggplot(aes(x = item, fill = type)) +
    geom_rect(aes(
      x = item,
      xmin = id - 0.4,
      xmax = id + 0.4,
      ymin = end,
      ymax = start
    )) +
    labs(title = 'Annual Budget',
         subtitle = '',
         x = '',
         y = "Dollars ($)") +
    scale_y_continuous(labels = dollar) +
    guides(fill = FALSE)
}

# 
