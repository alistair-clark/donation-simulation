# donation-simulation

### Code Tasks

- [X] Create one plotting function?
- [X] Put `fitrdist` in a function? Think about the order
- [X] Add facet plot function
- [X] Review `plot_simulation` function to simplify
- [X] Add Make file
- [X] Add Docker
- [ ] tidy format code
- [ ] Add docstrings and comments
- [ ] Create Docker image and update README


### Writing Tasks

- [ ] Write report using presentation and existing report
- [ ] Write descriptive README


## Usage

There are two ways to run this analysis:

#### 1. Use Docker

*Note: the following instructions depend on running this in a unix shell (e.g., terminal or Git Bash). Windows users may have to use Git Bash, set Docker to use Linux containers, and have shared their drives with Docker.*

To replicate the analysis, please follow the instruction:

1. Install [Docker](https://www.docker.com/get-started)
2. Clone this GitHub repository
3. Download the docker image using the following command at the command line/terminal:

```
docker pull ***TODO***
```

4. To replicate the analysis, navigate to the root directory of this project using the command line/terminal, and run the following command:

```
docker run --rm -v /$(pwd):/donation-simulation test make -C 'donation-simulation' all
```

5. To reset this repository to a clean state, with no intermediate or results files, run the following command at the command line/terminal from the root directory of this project:

```
docker run --rm -v /$(pwd):/donation-simulation ***TODO*** make -C 'donation-simulation' clean
```

#### 2. Without using Docker

To replicate the analysis, clone this GitHub repository, install the dependencies listed below, and run the following commands at the command line/terminal from the root directory of this project:

```
make all
```

To reset this repository to a clean state, run the following command at the command line/terminal from the root directory of this project:

```
make clean
```

Full scripts of this analysis can be found [here](https://github.com/alistair-clark/donation-simulation/tree/master/src).

## Dependencies

- R version 3.6.2 and R packages:
    - tidyverse==1.3.0
    - MASS==7.3.51.5
    - docopt==0.6.1
    - scales==1.1.0
- GNU make 4.2.1
