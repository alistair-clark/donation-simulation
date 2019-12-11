# This file contains input variables used in this analysis.

# Load packages
library(tidyverse)

## Input #1: past expenses (rent, food, gas, etc.)
##################################################
# Must be a dataframe with one column
# Units = dollars ($)
past_expenses <- tibble(expenses = c(3325.27, 3204.42, 2175.79, 3435.20,
                                     2386.07, 2714.56, 4786.10, 2201.55,
                                     3298.67, 2673.46, 2110.75, 2734.18,
                                     2386.90, 3463.15, 2262.02, 2448.68,
                                     2419.96, 4250.16, 2760.98, 2611.05,
                                     2799.57, 3356.27, 2665.70, 3044.05,
                                     2633.97, 2940.95, 2520.44, 3206.64)
                        )


## Input #2: budget assumptions
##################################################

income <- 100000
rrsp <- 15000
savings <- 10000

# found using https://simpletax.ca/calculator
taxes <- 20727


## Input #3: % of salary donated
##################################################
percent_donated <- 15