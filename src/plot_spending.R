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
           filename = paste0(out_dir,"histogram.png"))
    ggsave(plot = dist,
           filename = paste0(out_dir,"distribution.png"))
    ggsave(plot = sim,
           filename = paste0(out_dir,"simulation.png"))
}

plot_spending <- function(df,
                          add_histogram = FALSE,
                          add_density = FALSE,
                          add_theoretical = FALSE,
                          add_simulation = FALSE) {
  
  # Create blank plot
  full_plot <- ggplot(df,
                      aes(x = amount)) +
    scale_x_continuous(label = dollar,
                       limits = c(min(df$amount) - 500,
                                  max(df$amount) + 500)
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
        spending_dens <- function(x) dlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
        
        # Add lognormal curve to graph
        full_plot <- 
          full_plot +
          stat_function(aes(x = amount),
                        fun = spending_dens,
                        color = "red")
      }
      if (add_simulation) {
        # simulate 12 months of spending
        spending_func <- function(x) rlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
        spending_sim <- data.frame(monthly_spending = spending_func(12))
        
        # add simulated spending to plot
        full_plot <- 
          full_plot +
          geom_point(data = spending_sim,
                     x = spending_sim$monthly_spending,
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

main(opt[["--in_file"]], opt[["--out_dir"]])