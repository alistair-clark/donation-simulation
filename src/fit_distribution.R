# This code fits a theoretical distribution to historical expenses
# using maximum-likelihood estimation. It then defines two functions
# used in plotting and monte carlo simulation.

# load libraries
library(MASS)

# fit a lognormal distribution
fit_data <- fitdistr(past_expenses[[1]], densfun="lognormal")

# create two functions used in plotting and monte carlo simulation
expenses_dens <- function(x) dlnorm(x, fit_data$estimate[1], fit_data$estimate[2])
expenses_func <- function(x) rlnorm(x, fit_data$estimate[1], fit_data$estimate[2])