# Terminology

* **container** - Containers are like very lightweight
    virtual machines that can provide an isolated,
    consistent, reproducible environment in which to
    run software.

* **directive** - this refers to subheadings of rules,
    such as `input:` or `output:` or `shell:`

* **docker** - Docker is a program that allows running
    containers. Docker is very popular in enterprise
    software engineering, but presents challenges for
    scientific computing because it requires an admin
    account and presents security risks, making it
    hard to run in an HPC environment.

* **rule** - Snakemake rules define a given task,
    the input files it depends on, the output files
    it produces, the shell commands it should run,
    etc.

* **singularity** - Singularity is a program that allows
    running containers, like Docker, but without requiring
    an admin account and without many of the security 
    concerns that Docker creates.

* **Snakefile** - Snakemake is a Python program that is used
    to run a set of commands in a file; Snakefile is the
    default name of the file in which Snakemake expects to
    find those definitions.

