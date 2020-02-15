# How much of my salary can I afford to donate to charity?
Using Monte Carlo simulation and Maximum Likelihood Estimation to tackle the uncertainty of life

Author: Alistair Clark
***
It costs $2,196 to save a human life[<sup>1</sup>](#footnotes).

I've known this number for years, and yet I still find it hard to give consistently. No matter how detailed my budget, it seems like every month an unexpected expense pops up and derails my plans to donate -- a last minute wedding gift, replacing the car airconditioner, or an emergency vet bill.

**Budgets are deterministic, but life is stochastic.** Rather than fight against that fact, I decided to embrace it. This project uses a combination of techniques including maximum likelihood estimation and Monte Carlo simulation to help me estimate how much I can actually afford to donate to charity.

## Report

[Click here to read the full write-up](/doc/report.html) and find out much I can afford to donate.

## Next steps for this project:

- [ ] Share article with data science publications
- [ ] Create a web app that allows others to run the same analysis

## Usage

There are two ways to run this analysis:

### 1. Use Docker

*Note: the following instructions depend on running this in a unix shell (e.g., terminal or Git Bash). Windows users may have to use Git Bash, set Docker to use Linux containers, and have shared their drives with Docker.*

To replicate the analysis, please follow the instruction:

1. Install [Docker](https://www.docker.com/get-started)
2. Clone this GitHub repository
3. Download the docker image using the following command at the command line/terminal:

```
docker pull alistairjlclark/donation-simulation:latest
```

4. To replicate the analysis, navigate to the root directory of this project using the command line/terminal, and run the following command:

```
docker run --rm -v /$(pwd):/donation-simulation alistairjlclark/donation-simulation:latest make -C 'donation-simulation' all
```

5. To reset this repository to a clean state, with no intermediate or results files, run the following command at the command line/terminal from the root directory of this project:

```
docker run --rm -v /$(pwd):/donation-simulation alistairjlclark/donation-simulation:latest make -C 'donation-simulation' clean
```

### 2. Without using Docker

To replicate the analysis, clone this GitHub repository, install the dependencies listed below, and run the following commands at the command line/terminal from the root directory of this project:

```
make all
```

To reset this repository to a clean state, run the following command at the command line/terminal from the root directory of this project:

```
make clean
```

Full scripts of this analysis can be found [here](https://github.com/alistair-clark/donation-simulation/tree/master/src).

#### Dependencies

- R version 3.6.2 and R packages:
    - tidyverse==1.3.0
    - MASS==7.3.51.5
    - docopt==0.6.1
    - scales==1.1.0
- GNU make 4.2.1

## Footnotes

1.  [GiveWell: _Giving 101: The Basics_](https://www.givewell.org/giving101#footnote1_1dmjnp5)