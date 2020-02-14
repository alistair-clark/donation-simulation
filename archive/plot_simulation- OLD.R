source("src/01_load_and_clean_data.R")
source("src/02_explore_data.R")
source("src/03_identify_distribution.R")
source("src/04_annual_budget.R")
source("src/05_simulate_budget.R")
source("src/06_simulate_donation.R")

simulations5 <- data.frame(iteration = c(1:10000),
                           result = c(simulate_donation(5, 10000)))
simulations5$percent <- " 5% donated"

simulations10 <- data.frame(iteration = c(1:10000),
                           result = c(simulate_donation(10, 10000)))
simulations10$percent <- "10% donated"

simulations15 <- data.frame(iteration = c(1:10000),
                           result = c(simulate_donation(15, 10000)))
simulations15$percent <- "15% donated"

simulations20 <- data.frame(iteration = c(1:10000),
                           result = c(simulate_donation(20, 10000)))
simulations20$percent <- "20% donated"

simulations25 <- data.frame(iteration = c(1:10000),
                           result = c(simulate_donation(25, 10000)))
simulations25$percent <- "25% donated"

simulations30 <- data.frame(iteration = c(1:10000),
                            result = c(simulate_donation(30, 10000)))
simulations30$percent <- "30% donated"

totalsimulations <- rbind(simulations5, simulations10, simulations15, simulations20, simulations25, simulations30)
totalsimulations$net <- ifelse(totalsimulations$result < 0, "Over budget", "Under budget")

ggplot(totalsimulations, aes(x = result, color = net)) +
  geom_histogram(bins=200, fill="white", alpha=0.5, position="identity") +
  facet_wrap(~percent, ncol = 1) +
  scale_color_manual(values=c("firebrick4", "forestgreen")) +
  geom_vline(aes(xintercept=0)) +
  theme(axis.text.y=element_blank(),
        axis.ticks.y=element_blank()) +
  labs(title = paste0('Donation levels: 5%, 10%, 15%, 20%, 25%'),
       x = "Amount over or under budget, in $",
       y = "Count of simulated years",
       colour = '')

