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

main <- function(in_budget, in_spending, in_donation, out_dir) {
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

    # Read donation %
    donation_df <- read_csv(in_donation, col_names = c('donation'))
    donation_level <- donation_df$donation
    
    # Fit lognormal distribution to the data using MLE
    fit_data <- fitdistr(spending_df$amount, "lognormal")
    spending_dens <- function(x) dlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
    spending_func <- function(x) rlnorm(x, fit_data$estimate[1], fit_data$estimate[2])

    # Simulate donation level for 10,000 years using Monte Carlo
    num_simulations <- 10000
    simulations <- data.frame(iteration = c(1:num_simulations),
                              result = c(simulate_donation(donation_level,
                                                           num_simulations,
                                                           budget_df$income, 
                                                           budget_df$remaining,
                                                           spending_func)))
    simulations$net <- ifelse(simulations$result < 0, "Over budget", "Under budget")

    # Plot chosen donation level
    p <- ggplot(simulations, aes(x = result, colour = net)) +
            geom_histogram(bins=100, fill="white", alpha=0.5, position="identity") +
            scale_color_manual(values=c("firebrick4", "forestgreen")) +
            xlim(-6000, 12000) +
            geom_vline(aes(xintercept=0)) +
            labs(title = paste0('Donation level: ', donation_level, "%"),
                x = "Amount over or under budget, in $",
                y = "Count of simulated years",
                colour = '') +
            theme(legend.position="top")

    # Plot facet with multiple donation levels
    facet_df <- simulate_multiple(donation_level,
                                  num_simulations,
                                  budget_df$income,
                                  budget_df$remaining,
                                  spending_func)
    facet <- ggplot(facet_df, aes(x = result, color = net)) +
        geom_histogram(bins=200, fill="white", alpha=0.5, position="identity") +
        facet_wrap(~percent, ncol = 1) +
        scale_color_manual(values=c("firebrick4", "forestgreen"),
                           guide = guide_legend(reverse = TRUE)) +
        geom_vline(aes(xintercept=0)) +
        labs(title = paste0('Donation levels: 5%, 10%, 15%, 20%, 25%, 30%'),
            x = "Amount over or under budget, in $",
            y = "Count of simulated years",
            colour = '')
    
    # Save png files
    ggsave(plot = p,
           filename = paste0(out_dir,"donation_sim.png"))
    ggsave(plot = facet,
           filename = paste0(out_dir,"facet.png"))
}




#' Simulates 12 months of expenses for a given number of years
#'
#' @param num_years The number of years to simulate
#'
#' @return Budget remaining after subtracting cost of living
#' @export
#'
#' @examples
#' simulate_year(100)
simulate_year <- function(num_years, remaining, spending_func) {
  replicate(n = num_years, 
            remaining - sum(spending_func(12)),
            simplify = TRUE)
}


simulate_donation <- function(donation_percent, num_simulations, income, remaining, spending_func) {
  simulate_year(num_simulations, remaining, spending_func) - donation_percent/100 * income
}

simulate_multiple <- function(donation_percent, num_simulations, income, remaining, spending_func) {
    df = NULL
    for (i in seq(5, 30, 5)) {
        simulations <- data.frame(iteration = c(1:10000),
                                  result = c(simulate_donation(i, 10000, income, remaining, spending_func)))
        simulations$percent <- paste0(i, "% donated")
        simulations$name <- i
        df = rbind(df, simulations)
    }
    df$percent <- reorder(df$percent, df$name)
    df$net <- ifelse(df$result > 0, "Under budget", "Over budget")
    df
}

main(opt[["--in_budget"]], opt[["--in_spending"]], opt[["--in_donation"]], opt[["--out_dir"]])