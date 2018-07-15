# How Do I Snakemake?

A guide to getting up and running with Snakemake.

Snakemake is a powerful tool for building complex workflows in Python.
It is similar to [GNU make](https://www.gnu.org/software/make/),
from whence it derives its name.

However, Snakemake is more powerful than make, and there are some important 
differences (that are also reasons for `make` users to migrate to Snakemake):

* Snakemake is implemented in Python, so Snakemake is able to bootstrap on the
  capabilities of Python. Snakefiles are also Python programs, so Python modules
  can be used in workflow definitions.

* Snakemake integrates seamlessly with conda, and a conda environment file can
  be specified for a given rule.

* Snakemake can be used with Singularity (containerization technology for
  running Docker containers on high performance computing (HPC) clusters)
  or with Kubernetes (technology for running multiple Docker containers across
  multiple machines).

* Snakemake integrates with HPC batch and queue systems, and can be used to
  run workflows using HPC or batch systems.

## Installing

[Installing Snakemake](installing.md) - covers the installation of Snakemake 
using pip or conda.


## Terminology

[Snakemake Terminology](terminology.md) - a glossary of Snakemake terms used
throughout this documentation and what they mean.


## Converting Workflows to Snakemake

[Converting Workflows to Snakemake](converting.md) - covers strategies for
converting shell script workflows into Snakemake workflows.


