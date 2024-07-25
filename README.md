# The Data Preprocessing workflow

## Summary
NOTE: This will be modified for the Ernakovich HPC setup
This workflow is a replicate of the [QA protocol](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/data-preprocessing/) implemented at JGI for Illumina reads and use the program “rqcfilter2” from BBTools(38:96) which implements them as a pipeline. 

## Required Database

* [RQCFilterData Database](https://portal.nersc.gov/cfs/m3408/db/RQCFilterData.tgz): It is a 106G tar file includes reference datasets of artifacts, adapters, contaminants, phiX genome, host genomes.  

* Prepare the Database

```bash
	mkdir -p refdata
	wget https://portal.nersc.gov/cfs/m3408/db/RQCFilterData.tgz
	tar xvzf RQCFilterData.tgz -C refdata
	rm RQCFilterData.tgz
```

## Running Workflow in Cromwell

Description of the files:
 - `.wdl` file: the WDL file for workflow definition
 - `.json` file: the example input for the workflow
 - `.conf` file: the conf file for running Cromwell.
 - `.sh` file: the shell script for running the example workflow

## Installing singularity images on premise
If you need to install the images in your own directory

```bash
module load singularity
cd ReadsQC
mkdir SingularityImages
cd SingularityImages
singularity pull img-omics docker://bfoster1/img-omics:0.1.1
singularity pull pbmarkdup docker://microbiomedata/pbmarkdup:1.0
singularity pull bbtools docker://microbiomedata/bbtools
```

Otherwise you can create a symlink to the singularity directory; note that the image names need to include the numbers and colons so that they match the names of the containers in the .wdl files exactly
```
cd ReadsQC
ln -s <full/path/to/directory/containing/bbtools/and/pbmarkdup/images> microbiomedata
ln -s <full/path/to/directory/containing/img-omics/images> bfoster1


need to insert directions here
```
## The Docker image and Dockerfile can be found here

[microbiomedata/bbtools:38.92](https://hub.docker.com/r/microbiomedata/bbtools)





## Input files

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

## Output files

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

## List of changes made for adapting to Premise:
- [x] changed the database location in *.wdl files to the premise shared database location (`/mnt/home/hcgs/shared/databases/readsqc/refdata`) 
- [ ] modified the `input.json` file to use the E.coli reads in the `test/` directory.
- [ ] extensive modifications to shifter.conf (soon to be renamed singularity.conf)
  - Docker root is changed to be full path to cromwell-executions file within ReadsQC (note, should add information to readme that this is configurable location)
  - Bound the database directory and data directories to the loading of singularity container; will need to add information to readme about how to do this. Ideally, we'd find a way to specify this in the json file rather than as runtime attributes.
- [ ] changed the names of the containers in the wdl files to reflect the names that were originally used. (this minimizes user changes to run) 
- [ ] added the database location to runtime options so that it could be bound to the singularity call
- [ ] modified the submission script to include the working call to cromwell jar file and also to load the singularity module
