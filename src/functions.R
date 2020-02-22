# author: Alistair Clark
# date: 2020-02-22
# Contains helper functions required to run the donation-simulation project.

#################################################################################
# Plotting functions
#################################################################################

#' Create waterfall plot of budget.
#'
#' @param df Dataframe containing 'income', 'taxes', and 'savings'
#'
#' @return ggplot Waterfall plot of budget.
#'
#' @examples
#' budget_waterfall(budget_df)
budget_waterfall <- function(df) {
  # Add "remaining" column
  df <-
    df %>%
    mutate(remaining = income - taxes - savings)
  
  # Reshape data and add columns needed to create waterfall plot
  df <-
    df %>%
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
  options(scipen = 999)
  df %>%
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
}

#' Wrapper function for plotting multiple variations of the same plot.
#'
#' Function allows for plotting histogram with absolute values or density.
#' Also allows for plotting kernel density, a fitted log-normal distribution,
#' and simulate monthly expenses from the fitted distribution.
#'
#' @param df dataframe with a column of monthly expenses
#' @param add_histogram option to add a histogram to the plot
#' @param add_density option to add a kernel density curve to the plot
#' @param add_theoretical option to fit a log-normal distribution using MLE
#' @param add_simulation option to show a simulation of expenses
#'
#' @return a ggplot plot
#'
#' @examples
#' plot_spending(df)
#' plot_spending(spending_df, add_theoretical = TRUE, add_simulation = TRUE)
plot_spending <- function(df,
                          add_histogram = FALSE,
                          add_density = FALSE,
                          add_theoretical = FALSE,
                          add_simulation = FALSE) {
  # Create blank plot
  full_plot <- ggplot(df, aes(x = amount)) +
    scale_x_continuous(label = dollar,
                       limits = c(min(df$amount) - 500,
                                  max(df$amount) + 500)) +
    labs(x = "Monthly Spending, in $")
  
  # Check if y axis scale needs to be changed to density
  if (add_density |
      add_theoretical |
      add_simulation) {
    # Add histogram
    if (add_histogram) {
      full_plot <-
        full_plot +
        geom_histogram(
          aes(y = ..density..),
          binwidth = 100,
          color = "grey30",
          fill = "white"
        ) +
        labs(title = "Histogram of Past Monthly Expenses")
    }
    
    # Add kernel density
    if (add_density) {
      full_plot <-
        full_plot +
        geom_density(aes(y = ..density..),
                     alpha = 0.1,
                     fill = "antiquewhite3")
    }
    
    # Determing if fitting a lognormal distribution is required
    if (add_theoretical | add_simulation) {
      # Fit lognormal distribution to the data
      fit_data <- fitdistr(df$amount, "lognormal")
      
      if (add_theoretical) {
        # Create functions to plot lognormal curve on graph
        spending_dens <-
          function(x)
            dlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
        
        # Add lognormal curve to graph
        full_plot <-
          full_plot +
          stat_function(aes(x = amount),
                        fun = spending_dens,
                        color = "red") +
          labs(subtitle = "Red line represents probability distribution of monthly spending")
      }
      if (add_simulation) {
        # simulate 12 months of spending
        spending_func <-
          function(x)
            rlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
        spending_sim <-
          data.frame(monthly_spending = spending_func(12))
        
        # add simulated spending to plot
        full_plot <-
          full_plot +
          geom_point(
            data = spending_sim,
            x = spending_sim$monthly_spending,
            y = 0.00003,
            color = 'black',
            size = 3,
            alpha = 0.5
          ) +
          ylim(0, 0.0014) +
          labs(title = "Simulated Monthly Expenses for 1 year",
               subtitle = "Each black dot represents a simulated month of expenses")
      }
    }
    return(full_plot)
  }
  if (add_histogram) {
    # Create a basic histogram using counts (not density)
    full_plot <-
      full_plot +
      geom_histogram(binwidth = 100,
                     color = "grey30",
                     fill = "white") +
      labs(title = "Histogram of Past Monthly Expenses",
           y = "Number of Months")
  }
  full_plot
}

#' Plot results of Monte Carlo simulation.
#' 
#' Plot shows a histogram of the amount over / under budget
#' for each year in the simulation.
#'
#' @param df Dataframe with outpouts from `simulate` function
#' @param donation_level % of income to donate to charity
#' @param one_year TRUE if only showing one simulated year
#'
#' @return ggplot histogram of simulated values.
#'
#' @examples
#' plot_simulation(simulations_df, 15)
plot_simulation <- function(df, donation_level, one_year = FALSE) {
  if (one_year == TRUE) {
    df2 <- df[1, ]
  } else {
    df2 <- df
  }
  ggplot(df2, aes(x = result, colour = net)) +
    geom_histogram(
      bins = 100,
      fill = "white",
      alpha = 0.5,
      position = "identity"
    ) +
    scale_color_manual(values = c("Over budget" = "firebrick4", "Under budget" = "forestgreen")) +
    scale_x_continuous(label = scales::dollar,
                       limits = c(min(df$result) + 500,
                                  max(df$result) + 500)) +
    geom_vline(aes(xintercept = 0)) +
    labs(
      title = paste0('Donation level: ', donation_level, "%"),
      x = "Amount over or under budget, in $",
      y = "Count of simulated years",
      colour = ''
    ) +
    theme(legend.position = "top")
}

#' Create facet plot showing multiple simulations.
#'
#' @param budget_df Dataframe contianing 'income', 'taxes', and 'savings'
#' @param spending_df Dataframe containing column of monthly spending.
#'
#' @return ggplot Facet plot showing histogram at multiple donation levels
#'
#' @examples
#' plot_facet(budget_df, spending_df)
plot_facet <- function(budget_df, spending_df) {
  fit_data <- fitdistr(spending_df$amount, "lognormal")
  spending_func <-
    function(x)
      rlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
  
  # Simulate 10,000 years of budget at multiple other donation levels (5%, 10% ... 30%)
  donation_levels <- seq(5, 30, 5)
  facet_df <- simulate_multiple(donation_levels,
                                10000,
                                budget_df$income,
                                budget_df$remaining,
                                spending_func)
  ggplot(facet_df, aes(x = result, color = net)) +
    geom_histogram(
      bins = 200,
      fill = "white",
      alpha = 0.5,
      position = "identity"
    ) +
    facet_wrap( ~ percent, ncol = 1) +
    scale_color_manual(
      values = c("Over budget" = "firebrick4", "Under budget" = "forestgreen"),
      guide = guide_legend(reverse = TRUE)
    ) +
    scale_x_continuous(label = scales::dollar) +
    geom_vline(aes(xintercept = 0)) +
    labs(
      title = paste0('Donation levels: 5%, 10%, 15%, 20%, 25%, 30%'),
      x = "Amount over or under budget, in $",
      y = "Count of simulated years",
      colour = ''
    )
}


#################################################################################
# Simulation functions
#################################################################################

#' Simulate annual budget surplus / defecit.
#'
#' @param donation_percent % of income donated to charity
#' @param num_years The number of years to simulate
#' @param income Total income (i.e. salary)
#' @param remaining Total income remaining after taxes and savings
#' @param spending_func Log-normal distribution, specified using MLE
#'
#' @return dataframe of budget surplus/deficit for each simulated year
#'
#' @examples
#' simulate_donation(10, 10000, 100000, 50000, log_normal)
simulate_donation <-
  function(donation_percent,
           num_years,
           income,
           remaining,
           spending_func) {
    replicate(n = num_years,
              remaining - sum(spending_func(12)),
              simplify = TRUE) - donation_percent / 100 * income
  }

#' Simulate annual budget surplus / defecit at multiple
#' donation levels.
#'
#' @param donation_range Vector of donation levels to simulate.
#' @param num_years The number of years to simulate
#' @param income Total income (i.e. salary)
#' @param remaining Total income remaining after taxes and savings
#' @param spending_func Log-normal distribution, specified using MLE
#'
#' @return dataframe of budget surplus/deficit for each simulated year
#'
#' @examples
#' simulate_multiple(seq(5, 30, 5), 10000, 100000, 50000, log_normal)
simulate_multiple <-
  function(donation_range,
           num_years,
           income,
           remaining,
           spending_func) {
    df = NULL
    for (i in donation_range) {
      simulations <- data.frame(iteration = c(1:num_years),
                                result = c(
                                  simulate_donation(i, num_years, income, remaining, spending_func)
                                ))
      simulations$percent <- paste0(i, "% donated")
      simulations$name <- i
      df = rbind(df, simulations)
    }
    df$percent <- reorder(df$percent, df$name)
    df$net <- ifelse(df$result > 0, "Under budget", "Over budget")
    df
  }



#' Monte Carlo simulation of budget
#'
#' @param spending_df Dataframe containing column of monthly spending.
#' @param budget_df Dataframe contianing 'income', 'taxes', and 'savings'
#' @param donation_level % of income to donate to charity
#'
#' @return df simulated budget for each year in simulation
#'
#' @examples
#' 
simulate <- function(spending_df, budget_df, donation_level) {
  # Fit lognormal distribution to the data using maximum-likelihood estimation
  fit_data <- fitdistr(spending_df$amount, "lognormal")
  spending_func <-
    function(x)
      rlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
  # Simulate 10,000 years of the annual budget
  num_years <- 10000
  simulations <- data.frame(iteration = c(1:num_years),
                            result = c(
                              simulate_donation(
                                donation_level,
                                num_years,
                                budget_df$income,
                                budget_df$remaining,
                                spending_func
                              )
                            ))
  simulations$net <-
    ifelse(simulations$result < 0, "Over budget", "Under budget")
  simulations
}