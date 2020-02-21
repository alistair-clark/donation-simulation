# author: Alistair Clark
# date: 2020-02-12

"
Create and save 3 plots of spending. Save plots as a png file.

Usage: plot_spending.R --in_file=<in_file> --out_dir=<out_dir>

Options:
--in_file=<in_file>  Path (including filename) of the budget data (csv).
--out_dir=<out_dir>  Path to directory where the figures will be saved.

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

main <- function(in_file, out_dir) {
  # Create dataframe with data in spending.csv
  spending_df <- read_csv(in_file, col_names = FALSE)
  spending_df <-
    spending_df %>%
    gather(key = "month", value = "amount")
  
  # Create 3 plots: histogram, histogram + distribution, simulation
  hist <- plot_spending(spending_df,
                        add_histogram = TRUE)
  dist <- plot_spending(spending_df,
                        add_histogram = TRUE,
                        add_theoretical = TRUE)
  sim <- plot_spending(spending_df,
                       add_theoretical = TRUE,
                       add_simulation = TRUE)
  
  # Save png files
  ggsave(plot = hist,
         filename = paste0(out_dir, "histogram.png"),
         width = 7,
         height = 5)
  ggsave(plot = dist,
         filename = paste0(out_dir, "distribution.png"),
         width = 7,
         height = 5)
  ggsave(plot = sim,
         filename = paste0(out_dir, "simulation.png"),
         width = 7,
         height = 5)
}

main(opt[["--in_file"]], opt[["--out_dir"]])