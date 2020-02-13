"""
Collect user inputs.

Usage:
    inputs.py
"""

import csv
from docopt import docopt
opt = docopt(__doc__)

def inputNumber(message):
    while True:
        userInput = input(message)
        if userInput == 'Y':
            return 'Y'
        try:
            float(userInput)
        except ValueError:
            print("Not a number! Try again.")
            continue
        else:
            return userInput 
            break 

def main():
    with open('data/budget.csv', 'x') as f:
        x = csv.writer(f)
        income = inputNumber("Annual income: ")
        taxes = inputNumber("Annual taxes: ")
        savings = inputNumber("Annual savings: ")
        x.writerow([income, taxes, savings])

    with open('data/spending.csv', 'x') as f:
        x = csv.writer(f)
        result = []
        while True:
            expense = inputNumber("Monthly expense (type 'Y' if done): ")
            if expense == 'Y':
                break
            else:
                result.append(expense)
        x.writerow(result)

    with open('data/donation.csv', 'x') as f:
        x = csv.writer(f)
        donation = inputNumber("Donation level (% of income): ")
        
        x.writerow([donation])

if __name__ == '__main__':
    main()