# This code loads and cleans a text file with 28 months of expenses
# from my personal spending tracking.

# load data from text file
cost_of_living_actual <- read_tsv(file="data/raw_spending.csv",
                                  col_names = c('source', 'monthly_cost'))

# clean data to remove whitespace and $
cost_of_living_actual$monthly_cost <- as.numeric(gsub('[^a-zA-Z0-9.]',
                                                      '',
                                                      cost_of_living_actual$monthly_cost))

# write clean csv file for use in other analysis
write_csv(cost_of_living_actual, "data/clean_spending")