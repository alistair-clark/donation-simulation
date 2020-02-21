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

# load helper functions
source("src/functions.R")

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
  
  # Create dataframe of simulated data
  simulations_df <- simulate(spending_df, budget_df, donation_level)
  
  # Plot single year of simulation
  one_year <-
    plot_simulation(simulations_df, donation_level, one_year = TRUE)
  
  # Plot simulation results
  all_years <- plot_simulation(simulations_df, donation_level)

  # Plot facet with multiple donation levels
  facet <- plot_facet(budget_df, spending_df)
  
  # Save png files
  ggsave(
    plot = one_year,
    filename = paste0(out_dir, "sim_one-year.png"),
    width = 7,
    height = 5
  )
  ggsave(
    plot = all_years,
    filename = paste0(out_dir, "sim_full.png"),
    width = 7,
    height = 5
  )
  ggsave(
    plot = facet,
    filename = paste0(out_dir, "sim_facet.png"),
    width = 7,
    height = 7
  )
}

main(opt[["--in_budget"]], opt[["--in_spending"]], opt[["--in_donation"]], opt[["--out_dir"]])