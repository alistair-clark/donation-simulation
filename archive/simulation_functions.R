# This file contains code for running monte carlo simulations
# on annual expenses and budget at various donation levels.


#' Simulates 12 months of expenses for a given number of years
#'
#' @param num_years The number of years to simulate
#'
#' @return Budget remaining after subtracting cost of living
#' @export
#'
#' @examples
#' simulate_year(100)
sim_before_donation <- function(expenses, num_years) {
  replicate(n = num_years, 
            income - rrsp - taxes - savings - sum(expenses_func(12)),
            simplify = TRUE)
}


sim_after_donation <- function(expenses, percent_donated, income, num_years) {
  simulate_budget(expenses, income, num_years) - percent_donated/100 * income
}
