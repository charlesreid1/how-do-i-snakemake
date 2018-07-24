ghurl = 'git@github.com:charlesreid1/how-do-i-snakemake.git'
cmrurl = 'ssh://git@git.charlesreid1.com:222/charlesreid1/how-do-i-snakemake.git'
cmrmkm = 'ssh://git@git.charlesreid1.com:222/charlesreid1/mkdocs-material.git'
index = 'index.html'

rule default:
    message:
        """

Welcome to the Snakefile for the how-do-i-snakemake repo.
This Snakefile contains utility methods for building and
deploying the site.
        
----------------------------------------
            Snakefile

Add the -p or --printshellcmd flag to print the shell commands being run.
Add the -n or --dryrun flag to do a dry run.


To clone the deployed site to site/:
    snakemake -p clone_site


To initialize submodules (if you did not clone this repo recursively):
    snakemake -p submodule_init


To build the documentation in docs/ into the site/ directory:
    snakemake build
        

To build and serve the documentation site locally (viewable at localhost:8000):
    snakemake serve


To safely clean the documentation site before next deployment:
    snakemake clean_docs


To build and deploy the updated documentation site to Heroku app dcppc-private-www:
    snakemake deploy_docs

"""


rule clone_site:
    """
    Clone the deployed site to site/
    and add the proper remotes.
    """
    output:
        'site'
    shell:
       '''
       git clone -b gh-pages {ghurl} site/
       cd site \
            && git remote add cmr {cmrurl} \
            && git remote add gh {ghurl}
       '''


rule submodule_init:
    """
    Initialize the submodules (mkdocs-material)
    so we can build the documentation.
    """
    shell:
        '''
        git submodule update --init
        '''


rule build:
    """
    Build the documentation with mkdocs.
    """
    shell:
        '''
        mkdocs build
        '''


rule serve:
    """
    Serve the documentation with mkdocs.
    Visit localhost:8000 in your browser.
    """
    shell:
        '''
        mkdocs serve 
        '''


rule clean_docs:
    """
    Safely clean the deployed documentation site.
    """
    shell:
        '''
        rm -fr site/content/*
        '''


rule deploy_docs:
    """
    Deploy the documentation.
    """
    shell:
        '''
        mkdocs build
        cd site/
        git add -A .
        git commit --allow-empty . -m 'updating site'
        git push cmr gh-pages
        git push gh gh-pages 
        '''

