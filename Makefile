# donation-simulation data pipe
# author: Alistair Clark
# date: 2020-02-15
# Usage: see project README for instructions on running this analysis

all: figs/budget_waterfall.png figs/distribution.png figs/histogram.png figs/simulation.png figs/sim_one-year.png figs/sim_full.png figs/sim_facet.png doc/report.md doc/report.html

# Create budget visualizations
figs/budget_waterfall.png : data/budget.csv
	Rscript src/plot_budget.R --in_file=data/budget.csv --out_dir=figs/

# Create spending visualization
figs/distribution.png figs/histogram.png figs/simulation.png : data/spending.csv
	Rscript src/plot_spending.R --in_file=data/spending.csv --out_dir=figs/

# Create Monte Carlo simulation visualizations
figs/sim_one-year.png figs/sim_full.png figs/sim_facet.png : data/budget.csv data/spending.csv data/donation.csv
	Rscript src/plot_simulation.R --in_budget=data/budget.csv --in_spending=data/spending.csv --in_donation=data/donation.csv --out_dir=figs/

# Render report
doc/report.md doc/report.html : doc/report.Rmd
	Rscript -e "rmarkdown::render('doc/report.Rmd', output_format = 'github_document')"

clean: 
	rm -rf figs/*
	rm -rf doc/report.md doc/report.html