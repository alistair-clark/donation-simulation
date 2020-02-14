# donation-simulation data pipe
# author: Alistair Clark
# date: 2020-02-13
# Usage: see project README for instructions on running this analysis

all: figs/budget_waterfall.png figs/distribution.png figs/histogram.png figs/simulation.png figs/donation_sim.png figs/facet.png

# Create budget visualizations
figs/budget_waterfall.png : data/budget.csv
	Rscript src/plot_budget.R --in_file=data/budget.csv --out_dir=figs/

# Create spending visualization
figs/distribution.png figs/histogram.png figs/simulation.png : data/spending.csv
	Rscript src/plot_spending.R --in_file=data/spending.csv --out_dir=figs/

# Create simulation visualizations
figs/donation_sim.png figs/facet.png : data/budget.csv data/spending.csv data/donation.csv
	Rscript src/plot_simulation.R --in_budget=data/budget.csv --in_spending=data/spending.csv --in_donation=data/donation.csv --out_dir=figs/

clean: 
	rm -rf figs/*