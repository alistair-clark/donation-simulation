import csv

def inputNumber(message):
    while True:
        userInput = input(message)
        if userInput == 'Y':
            return 'Y'
        try:
            int(userInput)
        except ValueError:
            print("Not an integer! Try again.")
            continue
        else:
            return userInput 
            break 

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
