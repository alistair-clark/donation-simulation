# author: Alistair Clark
# date: 2020-02-12

"
Create waterfall plot of budget and save to a file. Saves plot as a png file.

Usage: plot_budget.R --in_file=<in_file> --out_dir=<out_dir>

Options:
--in_file=<in_file>  Path (including filename) of the budget data (csv).
--out_dir=<out_dir>  Path to directory where the figure will be saved.

" -> doc

# Load libraries
library(docopt)
library(tidyverse)

# load helper functions
source("src/functions.R")

# docopt parsing
opt <- docopt(doc)

main <- function(in_file, out_dir) {
  # Create dataframe with data in budget.csv
  budget_df <- read_csv(in_file,
                        col_names = c("income", "taxes", "savings"))
  
  # Create waterfall chart
  p <- budget_waterfall(budget_df)
    
  # Save png file
  ggsave(plot = p,
         filename = paste0(out_dir, "budget_waterfall.png"),
         width = 7,
         height = 5
        )
}

main(opt[["--in_file"]], opt[["--out_dir"]])