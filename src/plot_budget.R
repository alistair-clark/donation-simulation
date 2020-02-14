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
library(scales)

# docopt parsing
opt <- docopt(doc)

main <- function(in_file, out_dir) {
    # Create dataframe with data in budget.csv
    budget_df <- read_csv(in_file,
                          col_names = c("income", "taxes", "savings"))
    
    # Add "remaining" column
    budget_df <-
        budget_df %>%
        mutate(remaining = income - taxes - savings)
    
    # Reshape data and add columns needed to create waterfall plot
    budget_df <-
        budget_df %>%
        gather(key = 'item', value = 'amount') %>%
        mutate(id = c(1:4),
               item = factor(item, levels = item[order(id)]),
               start = c(0,
                        (amount[1] - amount[2]),
                        (amount[1] - amount[2] - amount[3]),
                        (amount[1] - amount[2] - amount[3] - amount[4])),
               end = c(amount[1],
                       amount[1],
                       start[2],
                       start[3]),
               type = c("positive",
                        "negative",
                        "negative",
                        "net")
        )
    
    # Create waterfall chart for budget
    options(scipen=999)
    p <- budget_df %>%
         ggplot(aes(fill = type,
                    x = item,
                    xmin = id - 0.4,
                    xmax = id + 0.4,
                    ymin = end,
                    ymax = start
                    )) +
        geom_rect() +
        labs(title = 'Annual Budget',
                subtitle = '',
                x = '',
                y = "Dollars ($)") +
        scale_y_continuous(labels = dollar) +
        geom_text(aes(y = end, label = paste0("$", prettyNum(amount, big.mark = ",")), hjust=0.5, vjust=2)) +
        guides(fill = FALSE)
    
    # Save png file
    ggsave(plot = p,
           filename = paste0(out_dir,"budget_waterfall.png"))
}

main(opt[["--in_file"]], opt[["--out_dir"]])