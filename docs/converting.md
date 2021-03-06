# Converting Workflows to Snakemake

One of the common questions about Snakemake is, **how should beginners get
started?**

When you're starting out with Snakemake, one of the first hurdles you'll
encounter is a big gap between the examples (simple) and your real-world
workflow (complicated).

Snakemake is a relatively new (but well-documented) piece of software, so there
aren't a lot of examples, and the ones you can find will leave you wanting more.
Starting out, you'll find that (nearly) every step of your workflow presents
some kind of corner case that's not covered in any Snakemake examples.

Two recommendations to help overcome this:

1. Don't _start_ with Snakemake - start with shell scripts. Get your pipeline
   working as a shell script or a list of commands first, using a small data set.
   _Then_ convert the workflow to Snakemake.

2. Converting your workflow from shell scripts to a Snakefile can happen in
   _stages_. Start with a single Snakemake rule that calls a single bash shell
   script that downloads all of the reads at once (handle the complexity in the
   shell script).  Eventually, you can start to break up the shell script into
   smaller parts, and convert some of those parts into separate Snakemake rules.


## Example: Filtering Sequencer Reads

Let's illustrate the process of converting a workflow from shell scripts to a
Snakefile, and doing so in stages, using a hypothetical workflow that involves
downloading data files containing reads from a sequencer from an external URL:

| Read Files | URL (note: these links are fake) |
|------------|----------------------------------|
| `SRR606_1_reads.fq.gz` | <http://example.com/SRR606_1_reads.fq.gz> | 
| `SRR606_2_reads.fq.gz` | <http://example.com/SRR606_2_reads.fq.gz> |
| `SRR607_1_reads.fq.gz` | <http://example.com/SRR607_1_reads.fq.gz> |
| `SRR607_2_reads.fq.gz` | <http://example.com/SRR607_2_reads.fq.gz> |
| `SRR608_1_reads.fq.gz` | <http://example.com/SRR608_1_reads.fq.gz> |
| `SRR608_2_reads.fq.gz` | <http://example.com/SRR608_2_reads.fq.gz> |
| `SRR609_1_reads.fq.gz` | <http://example.com/SRR609_1_reads.fq.gz> |
| `SRR609_2_reads.fq.gz` | <http://example.com/SRR609_2_reads.fq.gz> |


## Stage 1: Shell Script + Snakefile

### The Shell Script

Start out with a single Snakemake rule that calls a single bash shell script
that downloads all the reads. Here is a shell script that uses for loop magic
to download each of the read files:

**`download_reads.sh`:**

```
#!/bin/bash
# 
# Download some fake read files

# Fail on the first error
set -e

reads=" SRR606_1_reads.fq.gz
SRR606_2_reads.fq.gz
SRR607_1_reads.fq.gz
SRR607_2_reads.fq.gz
SRR608_1_reads.fq.gz
SRR608_2_reads.fq.gz
SRR609_1_reads.fq.gz
SRR609_2_reads.fq.gz"

for read in $reads; do

    echo "Now downloading read file: ${read}"
    
    # Download the read file's (fake) URL
    curl -L https://example.com/${read} -o ${read}

    echo "Done."

done
```

The `set -e` option will stop execution of the script if any errors are
encountered. If any of the downloads fail, the shell script will fail, and 
the Snakemake `download_reads` rule will fail.

Paste this into `download_reads.sh`, and run the following command on
the command line to make `download_reads.sh` executable:

```bash
$ chmod download_reads.sh
```

### The Snakemake Strategy

Now we want to create a Snakefile with a single very simple rule called
`download_reads` that will call `download_reads.sh`. 

Right away, we run into a challenge: Snakemake operates using files and
filenames to infer which rules to run and which rules to skip.  That means any
Snakemake rule to download read files needs to have a list of files that will
only be present if the rule that runs the download reads script has successfully
run.

If we want to have Snakemake run the `download_reads.sh` script with a single
rule, our options, in order of worst to best, are:

* **(WORST)** We can tell Snakemake the name of every read file (copy-and-paste from the
  shell script into the Snakefile) so it knows what read files should be
  present when the download script has run. This requires duplicating the 
  list of read file names across two files - **YUCK!!!**
  
* **(BETTER BUT STILL BAD)** We can tell Snakemake the name of _one_ read file, so
  that if that one read file is present, Snakemake will assume the rest are also
  present and that the `download_reads.sh` script has already been run. This has
  the same disadvantage of needing to keep read file names coordinated across
  two separate files, but also has the disadvantage that it cannot detect if the
  process of downloading reads actually completed, or if it was only partially
  completed. 

* **(BEST)** We can bypass the use of the read files altogether and use a handy
  command, `touch`, to create a simple empty file whose presence indicates the
  download reads step has run. When we instruct Snakemake to run the download
  reads script, we add a command like `touch .downloaded_reads`, so that if the
  file `.downloaded_reads` is present, the rule will not be run.

Why do we use a file prefixed with a dot? That keeps the file hidden when we run `ls`
and keeps our working directory clean. 

We need to tell Snakemake that the dotfile we touch is the output of the rule,
so that it knows to link the dotfile `.downloaded_reads` with the rule
`download_reads`. To do that, we use Snakemake's `touch()` command when we
specify the output files from the rule.

!!! tip "Tip: Running shell scripts with Snakemake"
    
    If you are writing a Snakemake rule that runs a shell script that outputs
    multiple files, you can avoid keeping duplicate lists of files in both the
    shell script and the Snakefile by defining the output of the Snakemake rule
    that runs the shell script to be a dotfile (file whose name starts with a
    dot, so it is hidden) that is touched when the rule is finished.
    
    Use Snakemake's `touch()` function in the `output:` section of your rule.


### The Snakefile

Our Snakefile will define a single rule to run the shell script using
the command above. This Snakefile demonstrates a couple of concepts:

* Using the `touch()` function to link the `.downloaded_reads` dotfile with
  the `download_reads` rule
* Using a normally-defined Python variable inside of a Snakemake rule
* Documenting a rule using a triple-quoted Python docstring and using
  Python-style `#` comments

**`Snakefile`:**

```python
touchfile = '.downloaded_reads'

rule download_reads:
    """
    Run a shell script that downloads all of our read files.
    """
    output:
        # This rule is now linked to this touchfile
        touch(touchfile)
    shell:
        '''
        ./download_reads.sh
        '''
```

Paste the Python code above into a file called `Snakefile`.


### Snakemake Flags

Before we run Snakemake, let's cover two useful flags:

* The `--dryrun` or `-n` option will print out the rules that Snakemake would
  run, but does not actually run them.

* The `--printshellcmds` or `-p` option will print out the shell command
  associated with each rule.

See [Executing
Snakemake](https://snakemake.readthedocs.io/en/stable/executable.html#all-options)
in the Snakemake documentation for a complete list of command line
arguments that Snakemake accepts.


### Running Snakemake

Start by making sure you have Snakemake installed (see the [Installing
Snakemake](installing.md) page for instructions).

When you run the `snakemake` command without specifying a target, it 
will determine a default target and run that. The default target is the
first rule in the Snakefile.

Alternatively, we can specify the `download_reads` target when we run Snakemake.

From the command line, run the following:

```bash
snakemake --dryrun --printshellcmds download_reads
```

This should show us that Snakemake will run a single rule and a single command:

```plain
$ snakemake --dryrun --printshellcmds download_reads
Building DAG of jobs...
Job counts:
	count	jobs
	1	download_reads
	1

rule download_reads:
    output: .downloaded_reads
    jobid: 0


        ./download_reads.sh

Job counts:
	count	jobs
	1	download_reads
	1
```

When we run the command without the `--dryrun` option, we should see
the output from several curl commands:

```
$ snakemake --printshellcmds download_reads
Building DAG of jobs...
Using shell: /usr/local/bin/bash
Provided cores: 1
Rules claiming more threads will be scaled down.
Job counts:
	count	jobs
	1	download_reads
	1

rule download_reads:
    output: .downloaded_reads
    jobid: 0


        ./download_reads.sh

Now downloading read file: SRR606_1_reads.fq.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1270  100  1270    0     0   2346      0 --:--:-- --:--:-- --:--:--  2347
Now downloading read file: SRR606_2_reads.fq.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1270  100  1270    0     0   6214      0 --:--:-- --:--:-- --:--:--  6195
Now downloading read file: SRR607_1_reads.fq.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1270  100  1270    0     0   5191      0 --:--:-- --:--:-- --:--:--  5204
Now downloading read file: SRR607_2_reads.fq.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1270  100  1270    0     0   5296      0 --:--:-- --:--:-- --:--:--  5313
Now downloading read file: SRR608_1_reads.fq.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1270  100  1270    0     0   5981      0 --:--:-- --:--:-- --:--:--  5990
Now downloading read file: SRR608_2_reads.fq.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1270  100  1270    0     0   6177      0 --:--:-- --:--:-- --:--:--  6165
Now downloading read file: SRR609_1_reads.fq.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1270  100  1270    0     0   4482      0 --:--:-- --:--:-- --:--:--  4487
Now downloading read file: SRR609_2_reads.fq.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1270  100  1270    0     0   5558      0 --:--:-- --:--:-- --:--:--  5570
Touching output file .downloaded_reads.
Finished job 0.
1 of 1 steps (100%) done
Complete log:
/tmp/how-do-i-snakemake/.snakemake/log/2018-07-16T145427.253977.snakemake.log
```

Notice that Snakemake does not touch the file `.downloaded_reads` until it
completes running the script. It is important to add the `set -e` command 
to any shell script being run this way, because otherwise the script
will keep going when it encounters errors, and Snakemake will think the
script completed successfully and will touch `.downloaded_reads`.


### The `.snakemake` Directory

The above script was run from `/tmp/how-do-i-snakemake`. Snakemake created a
directory called `.snakemake/` to store its own files. Snakemake automatically
creates a log of what occurred in `.snakemake/log/` in a timestamped log file:

```
/tmp/how-do-i-snakemake/.snakemake/log/2018-07-16T145427.253977.snakemake.log
```


### Re-running Snakemake

If you re-run Snakemake, it will find the `.downloaded_reads` file and will
not download the files again:

```
$ snakemake
Building DAG of jobs...
Nothing to be done.
Complete log: /private/tmp/how-do-i-snakemake/.snakemake/log/2018-07-16T165657.111397.snakemake.log
```

You can force Snakemake to re-download the files two ways:

* Remove the output dotfile that the rule creates; this will cause Snakemake
  to detect that the output file for the rule is missing, and it will re-run
  the rule.

* Run Snakemake with the `--force` flag.



## Stage 2: Replace Script with Snakefile (Hard-Coded)

The next step in converting our workflow to Snakemake is to 
hard-code the file names into a Snakemake rule and let Snakemake
run the curl command to download them. Here are the links:

| Read Files | URL (note: these links are fake) |
|------------|----------------------------------|
| `SRR606_1_reads.fq.gz` | <http://example.com/SRR606_1_reads.fq.gz> | 
| `SRR606_2_reads.fq.gz` | <http://example.com/SRR606_2_reads.fq.gz> |
| `SRR607_1_reads.fq.gz` | <http://example.com/SRR607_1_reads.fq.gz> |
| `SRR607_2_reads.fq.gz` | <http://example.com/SRR607_2_reads.fq.gz> |
| `SRR608_1_reads.fq.gz` | <http://example.com/SRR608_1_reads.fq.gz> |
| `SRR608_2_reads.fq.gz` | <http://example.com/SRR608_2_reads.fq.gz> |
| `SRR609_1_reads.fq.gz` | <http://example.com/SRR609_1_reads.fq.gz> |
| `SRR609_2_reads.fq.gz` | <http://example.com/SRR609_2_reads.fq.gz> |

There are multiple ways to modify the Snakefile to download the files directly.
The approach shown below uses a `run` directive to run Python code, and a
`shell()` call to run a shell command. It also shows how these two can be mixed:

**`Snakefile`:**

```python
touchfile = '.downloaded_reads'

# map of read files to read urls
reads = {
    "SRR606_1_reads.fq.gz" : "http://example.com/SRR606_1_reads.fq.gz",
    "SRR606_2_reads.fq.gz" : "http://example.com/SRR606_2_reads.fq.gz",
    "SRR607_1_reads.fq.gz" : "http://example.com/SRR607_1_reads.fq.gz",
    "SRR607_2_reads.fq.gz" : "http://example.com/SRR607_2_reads.fq.gz",
    "SRR608_1_reads.fq.gz" : "http://example.com/SRR608_1_reads.fq.gz",
    "SRR608_2_reads.fq.gz" : "http://example.com/SRR608_2_reads.fq.gz",
    "SRR609_1_reads.fq.gz" : "http://example.com/SRR609_1_reads.fq.gz",
    "SRR609_2_reads.fq.gz" : "http://example.com/SRR609_2_reads.fq.gz"
}

rule download_reads:
    """
    Download all of our read files using Python code + a shell command.
    """
    output:
        # This rule is now linked to this touchfile
        touch(touchfile)
    run:
        for read_file, read_url in reads:
            shell('''
                curl -L {read_url} -o {read_file}
            ''')
```

The Python variables `read_file` and `read_url` are available to the shell command
through `{read_file}` and `{read_url}`.


## Stage 3: Replace Script with Snakefile (Wildcards)



