# Installing Snakemake

Also see the [installation
page](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html#installation-via-conda)
of the Snakemake documentation.


## Prerequisites

Before you can install Snakemake, you will need to install Python.

I recommend [pyenv](https://github.com/pyenv/pyenv), which provides a very
simple and graceful solution to the problem of managing multiple versions of
Python on a single machine.

The creators of pyenv also provide [pyenv-installer](https://github.com/pyenv/pyenv-installer),
which enables the installation of pyenv with a single command.

Also see [how-do-i-pyenv](https://pages.charlesreid1.com/how-do-i-pyenv).


## Installing Snakemake from Pypi with Pip

Once you have Python installed, you should have `pip` available as well.
Snakemake can be installed using pip:

```
$ virtualenv -p python3 .venv
$ source .venv/bin/activate
$ pip install snakemake
```

## Installing Snakemake from Bioconda with Conda

If you are using conda, you can install Snakemake using conda by first 
adding some conda channels, then installing Snakemake using `conda install`:



