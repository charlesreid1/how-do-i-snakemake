# How Do I Snakemake?

A guide to getting up and running with Snakemake.

Snakemake is a powerful tool for building complex workflows in Python.
It is similar in spirit to the [GNU make](https://www.gnu.org/software/make/)
program, from whence it derives its name.

Snakemake is more powerful than make, however, and there are some important 
differences (and reasons for make users to migrate to Snakemake):

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

## Quickstart

## Common Operations

