# Ernakovich lab Meta'omics tutorial Part 1: The Data Preprocessing workflow
**NOTE:** *This has been modified to run on the Ernakovich HPC setup (premise) by Hannah Holland-Moritz*

*If you find this tutorial helpful or useful, please let us know, it really helps us out to know how many people are finding it useful, thanks!
Updated July 25, 2024*

## Summary
This workflow is a replicate of the [QA protocol](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/data-preprocessing/) implemented at JGI for Illumina reads and use the program “rqcfilter2” from BBTools(38:96) which implements them as a pipeline. 

We suggest opening the tutorial online to understand more about each step. The original pipeline on which this tutorial is based can be found here: [https://nmdc-edge.org/tutorial](https://nmdc-edge.org/tutorial)

## Getting started
The goal of the workflow in this repository is to take sequencing data and clean it in preparation for downstream processes. Specifically we'll be using it as the first step in our laboratory's 'Omics workflow system.

### Why go to the hassel of WDL?
Bioinformatics often requires running a series of the same programs on similar files over and over again. Therefore it can be useful to use a workflow management system that strings these varioius scripts and steps together so that the processing pipeline is repeatable, reliable, and easily documentable. One way of doing this is to use WDL ([Workflow Description Language](https://docs.openwdl.org/en/stable/)) to describe your workflow and all of its component parts. [Cromwell](https://cromwell.readthedocs.io/en/stable/) is a workflow management system developed by the Broad Institute geared towards implementing scientific workflows. Essentially Cromwell can be used to ready `*.wdl` files and actually do the hard work of running and documenting your bioinformatics workflow in real time. 

## Setup (part 1) - Steps before starting pipeline

### Before you begin:

#### Clone or Download this tutorial from github
Once you have logged in, you can download a copy of the tutorial and workflow into your directory on the server. To retrieve the folder with this tutorial from github directly to the server, type the following into your terminal and hit return after each line.

```bash
wget https://github.com/ErnakovichLab/ReadsQC.git
unzip main.zip
```
If there are ever updates to the tutorial on github, you can update the contents of this folder by downloading the new version from the same link as above.

#### Install Cromwell
Cromwell is a java based program and requires java 11 or greater to run. Cromwell is the software that does the heavy lifting for us in interpreting the WDL language and orchestrating the workflow. The default java version on premise is below what Cromwell requires. Therefore we will install java and Cromwell in an anaconda environment which we will invoke prior to running the pipeline. 

```bash
# load anaconda on the premise HPC
module load anaconda/colsa

# Create the environment and install cromwell and its java dependencies
conda create -n cromwell -c bioconda cromwell

# After installation is complete
conda activate cromwell

# Download the cromwell jar file (you'll want to save this somewhere where you won't delete it and can find it later)
mkdir cromwell
cd cromwell
wget https://github.com/broadinstitute/cromwell/releases/download/87/cromwell-87.jar
```

(Note currently we don't actually run cromwell from this environment directly, we mostly just rely on it for the java. This is because I have no idea where the cromwell jar file is in the depths of the conda environment...)

#### Installing singularity images on premise
One of the reasons this workflow is so portable is that it relies on the use of containers for its software needs. Often one of the most challenging parts of implementing a repeatable bioinformatics workflow is installing the software. Too often, software from one step conflicts with software from a downstream step, or the workflow works on one operating system but not all. In the past these difficulties could be prohibitive to replication of a workflow, the use of containers helps solve that problem. Containers essentially spoof a program into thinking it is running on the kind computer/operating system they need to run with all the dependencies the need to run correctly.

One of the most popular kinds of container software is Docker. All of the necessary programs to run this workflow have been saved as Docker containers by the folks at NMDC. However most HPC systems (like premise) don't use Docker since it requries each user to have administrator level access to use effectively. Instead, many HPC systems prefer to use [Singularity](https://docs.sylabs.io/guides/3.0/user-guide/quick_start.html) which is safter to use and can seamlessly import Docker containers.

For Ernakovich lab users, I have installed the singularity containers in our shared directory. Therefore, all you need to do is create "symlinks" (symbolic links - this is kind of analogous to a shortcut on your desktop machine) that link to the Singularity containers in `/mnt/home/ernakocvich/shared/SingularityImages` 

Create a symlink to the singularity directory. 

```bash
cd ReadsQC
ln -s /mnt/home/ernakovich/shared/software/SingularityImages microbiomedata
ln -s /mnt/home/ernakovich/shared/software/SingularityImages bfoster1
```

If you are not on premise or in the Ernakovich lab, you'll need to install the images in your own directory before creating the symlinks above (replace the ernakovich path with the path to the location of your own SingularityImages folder). Note that the image names need to include the numbers and colons so that they match the names of the containers in the .wdl files exactly, which is why we change their names:
```bash
module load singularity
cd ReadsQC
mkdir SingularityImages
cd SingularityImages
singularity pull img-omics docker://bfoster1/img-omics:0.1.1
singularity pull pbmarkdup docker://microbiomedata/pbmarkdup:1.0
singularity pull bbtools docker://microbiomedata/bbtools
singularity pull workflowmeta docker://microbiomedata/workflowmeta:1.1.1

# Change the names to match wdl calls
mv bbtools bbtools:38.96
mv img-omics img-omics:0.1.9
mv pbmarkdup pbmarkdup:1.0
mv workflowmeta workflowmeta:1.1.1
```

#### Other less common setup steps
##### Make sure the Required Database is Installed
This workflow requires the RQCFilterData database which is quite large. Luckily the wonderful premise sysadmins have installed it for us in the premise shared database folder: `/mnt/home/hcgs/shared/databases/readsqc/refdata`

So if you are working on premise, you won't need to do anything special.

However if you are not working on premise and need to install it yourself, follow the instructions below. Then replace all instances of `/mnt/home/hcgs/shared/databases/readsqc/refdata` in the shortReads.wdl file with the path to the database on your system.

* [RQCFilterData Database](https://portal.nersc.gov/cfs/m3408/db/RQCFilterData.tgz): It is a 106G tar file includes reference datasets of artifacts, adapters, contaminants, phiX genome, host genomes.  

* Prepare the Database

```bash
	mkdir -p refdata
	wget https://portal.nersc.gov/cfs/m3408/db/RQCFilterData.tgz
	tar xvzf RQCFilterData.tgz -C refdata
	rm RQCFilterData.tgz
```
## Setup (part 2) - Creating your input files
Section to include:
- [] json setup
- [] dealing with multiple json files
- [] other kinds of inputs

## Run workflow (part 3) - Launching single and multiple jobs
Section to include:
- [] how to launch both array and single jobs
- [] the basic steps of the workflow (refer to nmdc; particularly important to define rqcfilter options)

## After running workflow (part 4) - 
- [] Interpret the output (where aremy files!)
- [] modifying the workflow
- [] dealing with failed samples

## Other information
### Running Workflow in Cromwell

Description of the files:
 - `.wdl` file: the WDL file for workflow definition
 - `.json` file: the example input for the workflow
 - `.conf` file: the conf file for running Cromwell.
 - `.sh` file: the shell script for running the example workflow

### The Docker images and Dockerfile can be found here
[microbiomedata/bbtools:38.92](https://hub.docker.com/r/microbiomedata/bbtools)

### Input files

1. database path, 
2. fastq (illumina paired-end interleaved fastq), 
3. project name 
4. resource where run the workflow
5. informed_by 

```
{
    "nmdc_rqcfilter.database": "/global/cfs/projectdirs/m3408/aim2/database", 
    "nmdc_rqcfilter.input_files": "/global/cfs/cdirs/m3408/ficus/8434.3.102077.AGTTCC.fastq.gz", 
    "nmdc_rqcfilter.proj":"nmdc:xxxxxxx",
    "nmdc_rqcfilter.resouce":"NERSC -- perlmutter",
    "nmdc_rqcfilter.informed_by": "nmdc:xxxxxxxx"
}
```

### Output files

The output will have one directory named by prefix of the fastq input file and a bunch of output files, including statistical numbers, status log and a shell script to reproduce the steps etc. 

The main QC fastq output is named by prefix.anqdpht.fast.gz. 

```
|-- 8434.1.102069.ACAGTG.anqdpht.fastq.gz
|-- filterStats.txt
|-- filterStats.json
|-- filterStats2.txt
|-- adaptersDetected.fa
|-- reproduce.sh
|-- spikein.fq.gz
|-- status.log
|-- ...
```

### List of changes made for adapting to Premise:
- [x] changed the database location in *.wdl files to the premise shared database location (`/mnt/home/hcgs/shared/databases/readsqc/refdata`) 
- [ ] modified the `input.json` file to use the E.coli reads in the `test/` directory.
- [ ] extensive modifications to shifter.conf (soon to be renamed singularity.conf)
  - Docker root is changed to be full path to cromwell-executions file within ReadsQC (note, should add information to readme that this is configurable location)
  - Bound the database directory and data directories to the loading of singularity container; will need to add information to readme about how to do this. Ideally, we'd find a way to specify this in the json file rather than as runtime attributes.
- [ ] changed the names of the containers in the wdl files to reflect the names that were originally used. (this minimizes user changes to run) 
- [ ] added the database location to runtime options so that it could be bound to the singularity call
- [ ] modified the submission script to include the working call to cromwell jar file and also to load the singularity module
