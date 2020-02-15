# author: Alistair Clark
# date: 2020-02-13

"
Create and save 2 plots simulating annual donation level using Monte Carlo
simulation.

Usage:
plot_simulation.R --in_budget=<in_budget> --in_spending=<in_spending> --in_donation=<in_donation> --out_dir=<out_dir>

" -> doc

# Load libraries
library(docopt)
library(tidyverse)
library(scales)
library(MASS)

# docopt parsing
opt <- docopt(doc)

main <- function(in_budget,
                 in_spending,
                 in_donation,
                 out_dir) {
  # Create dataframe with data in budget.csv
  budget_df <- read_csv(in_budget,
                        col_names = c("income", "taxes", "savings"))
  budget_df <-
    budget_df %>%
    mutate(remaining = income - taxes - savings)
  
  # Create dataframe with data in spending.csv
  spending_df <- read_csv(in_spending, col_names = FALSE)
  spending_df <-
    spending_df %>%
    gather(key = "month", value = "amount")
  
  # Read donation % from donation.csv
  donation_df <- read_csv(in_donation, col_names = c('donation'))
  donation_level <- donation_df$donation
  
  # Fit lognormal distribution to the data using maximum-likelihood estimation
  fit_data <- fitdistr(spending_df$amount, "lognormal")
  spending_dens <-
    function(x)
      dlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
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
  
  # Plot single year of simulation
  one_year <-
    ggplot(simulations[1, ], aes(x = result, colour = net)) +
    geom_histogram(
      bins = 100,
      fill = "white",
      alpha = 0.5,
      position = "identity"
    ) +
    scale_color_manual(values = c("Over budget" = "firebrick4", "Under budget" = "forestgreen")) +
    scale_x_continuous(label = scales::dollar,
                       limits = c(min(simulations$result) + 500,
                                  max(simulations$result) + 500)) +
  geom_vline(aes(xintercept = 0)) +
  labs(
    title = paste0('Donation level: ', donation_level, "%"),
    x = "Amount over or under budget, in $",
    y = "Count of simulated years",
    colour = ''
  ) +
  theme(legend.position = "top")

# Plot simulation results
all_years <- ggplot(simulations, aes(x = result, colour = net)) +
  geom_histogram(
    bins = 100,
    fill = "white",
    alpha = 0.5,
    position = "identity"
  ) +
  scale_color_manual(values = c("Over budget" = "firebrick4", "Under budget" = "forestgreen")) +
  scale_x_continuous(label = scales::dollar) +
  geom_vline(aes(xintercept = 0)) +
  labs(
    title = paste0('Donation level: ', donation_level, "%"),
    x = "Amount over or under budget, in $",
    y = "Count of simulated years",
    colour = ''
  ) +
  theme(legend.position = "top")

# Simulate 10,000 years of budget at multiple other donation levels (5%, 10% ... 30%)
donation_levels <- seq(5, 30, 5)
facet_df <- simulate_multiple(
  donation_levels,
  num_years,
  budget_df$income,
  budget_df$remaining,
  spending_func
)

# Plot facet with multiple donation levels
facet <- ggplot(facet_df, aes(x = result, color = net)) +
  geom_histogram(
    bins = 200,
    fill = "white",
    alpha = 0.5,
    position = "identity"
  ) +
  facet_wrap(~ percent, ncol = 1) +
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

# Save png files
ggsave(plot = one_year,
       filename = paste0(out_dir, "sim_one-year.png"),
       width = 7,
       height = 5)
ggsave(plot = all_years,
       filename = paste0(out_dir, "sim_full.png"),
       width = 7,
       height = 5)
ggsave(plot = facet,
       filename = paste0(out_dir, "sim_facet.png"),
       width = 7,
       height = 7)
}

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

main(opt[["--in_budget"]], opt[["--in_spending"]], opt[["--in_donation"]], opt[["--out_dir"]])