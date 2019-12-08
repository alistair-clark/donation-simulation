# This file contains functions used to create plots

# load packages
library(tidyverse)
library(scales)
library(MASS)

# basic histogram of expenses
plot_expenses_histogram <- function(expenses) {
  ggplot(expenses, aes(x = expenses)) +
    geom_histogram(binwidth = 100,
                   color = "grey30",
                   fill = "white") +
    ylim(0, 4) +
    scale_x_continuous(label = dollar,
                       limit = c(1800, 5200)) +
    labs(
      title = "",
      subtitle = "",
      x = "Monthly Expenses, in $",
      y = "Count of Months"
    )
}

# histogram of expenses with density curve
plot_expenses_density <- function(expenses) {
  ggplot(expenses, aes(x = expenses)) +
    geom_histogram(
      aes(y = ..density..),
      binwidth = 100,
      color = "grey30",
      fill = "white"
    ) +
    geom_density(alpha = .1, fill = "antiquewhite3") +
    scale_x_continuous(label = dollar,
                       limit = c(1800, 5200)) +
    labs(
      title = "",
      subtitle = "",
      x = "Monthly Expenses, in $",
      y = "Density"
    )
}

# histogram, density, and theoretical distribution
plot_expenses_theoretical <- function(expenses, distribution="lognormal") {
  # fit distribution to expenses
  fit_data <- fitdistr(expenses[[1]], densfun=distribution)
  
  # create function to plot theoretical density
  expenses_dens <- function(x) dlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
  ggplot(expenses, aes(x = expenses)) +
    geom_histogram(aes(y = ..density..),
                   binwidth = 100, color = "grey30", fill = "white") +
    xlim(1800, 5200) +
    stat_function(fun = expenses_dens, color = "red") +
    geom_density(alpha = .2, fill = "antiquewhite3") +
    labs(title = "",
         subtitle = '',
         x = "Monthly Cost of Living, in $",
         y = 'Density')
}

# theoretical distribution with sample year
plot_expenses_sample <- function (expenses) {
  expenses_sim <- data.frame(monthly_expense = expenses_func(12))
  ggplot(expenses, aes(x = expenses)) +
    xlim(1800, 5200) +
    ylim(0, 0.0015) +
    geom_point(data = expenses_sim,
               x = expenses_sim$monthly_expense,
               y=0.00003,
               color='black',
               size=5,
               alpha=0.5) +
    stat_function(fun = expenses_dens, color = "red") +
    labs(title = "",
         subtitle = '',
         x = "Monthly Cost of Living, in $",
         y = 'Density')
}

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
