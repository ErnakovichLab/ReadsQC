#!/bin/bash

## Note - Slurm script comments require two hash symbols (##).  A single
## hash symbol immediately followed by SBATCH indicates an SBATCH
## directive.  "##SBATCH" indicates the SBATCH command is commented
## out and is inactive.

## Original SBACTCH commands. I've marked the ones I added below with a  **
##SBATCH --time=12:00:00
##SBATCH --output=/global/cfs/projectdirs/m3408/aim2/rqc_filter/log/rqc_filter_1393.log**
##SBATCH --nodes=1
##SBATCH --ntasks=1**
##SBATCH --cpus-per-task 62** # Note this may be a bit high for premise to handle...
##SBATCH --mail-type=END,FAIL**
##SBATCH --mail-user=your@mail.com**
##SBATCH --constraint=haswell
##SBATCH --account=m3408
##SBATCH --job-name=rqc_1393**


## NTasks is not thread count, be sure to leave it set at 1
#SBATCH --ntasks=1

## If your program will be using less than 24 threads, or you
## require more than 24 threads, set cpus-per-task to the 
## desired threadcount.  Leave this commented out for the
## default 24 threads. 

# The most we specify in the wdl files is 16 threads. 
#SBATCH --cpus-per-task=16

## You will need to specify a minimum amount of memory in the
## following situaitons:
##   1. If you require more than 128GB of RAM, specify either:
##      a. "--mem=512000" for at least 512GB of RAM (6 possible nodes)
##      b. "--mem=1000000" for at least 1TB of RAM (2 possible nodes)
##   2. If you are running a job with less than 24 threads, you will
##      normally be given your thread count times 5.3GB in RAM.  So
##      a single thread would be given about 5GB of RAM.  If you
##      require more, please specify it as a "--mem=XXXX" option,
##      but avoid using all available RAM so others may share the node.

# We comment this out because at most we specify 70GB of RAM, far lower than the 
# 5GB x16 threads we'll be given
##SBATCH --mem=512000

## Normally jobs will restart automatically if the cluster experiences
## an unforeseen issue.  This may not be desired if you want to retain
## the work that's been performed by your script so far.   
## --no-requeue

## Normal Slurm options
## SBATCH -p shared
#SBATCH --job-name="test_cromwell"
#SBATCH --output=rqc_filter_%j.log
#SBATCH --mail-type=END,FAIL
##SBATCH --mail-user=heh1030@unh.edu
##SBATCH --job-name=rqc_%j


## Load the appropriate modules first.  Linuxbrew/colsa contains most
## programs, though some are contained within the anaconda/colsa
## module.  Refer to http://premise.sr.unh.edu for more info.
module purge
module load anaconda/colsa
conda activate cromwell # we mostly just use this for the java. We'll invoke the jar file 87 directly

module load singularity
## Instruct your program to make use of the number of desired threads.
## As your job will be allocated an entire node, this should normally
## be 24.
#cromwell --help
#cromwell run cromwell_test.wdl


#java -Dconfig.file=shifter.conf -jar /mnt/home/ernakovich/heh1030/Software/cromwell/cromwell-87.jar run -m metadata_out.json -i input.json rqcfilter.wdl
java -Dconfig.file=singularity.conf -jar /mnt/home/ernakovich/heh1030/Software/cromwell/cromwell-87.jar run -i ../json_inputs/BMI_HFWLLBGX7_Plate61WellF7_input.json -m metadata_out.json rqcfilter.wdl

