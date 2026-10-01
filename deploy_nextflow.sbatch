#!/bin/bash

## JOB IDENTIFICATION 
#SBATCH --job-name=NXF_Assembler		# Assing a job name.
#SBATCH --output=%J.out    			# Redirect stdout to this file
#SBATCH --error=%J.err				# Redirect stderr to this file

## RESOURCES
#SBATCH --partition=epyc			# The requested queue partition (e.g defq)
#SBATCH --nodes=1                               # Number of nodes to use
#SBATCH --tasks-per-node=1                      # Number of tasks per node.
#SBATCH --cpus-per-task=20                    	# CPUs per task.
#SBATCH --mem-per-cpu=8000                    	# In megabytes, unless unit explicitly stated
#SBATCH --time=72:00:00	                  	# Assign a max time for the job to run. 

## JOB NOTIFICATIONS
#SBATCH --mail-user=shelleydr@cardiff.ac.uk     # Email address used for event notification
#SBATCH --mail-type=all                         # Email on all job notifications

## DOCUMENT VARIABLES
echo "Environment Variables:"
echo "######################"
echo "hostname=$(hostname)"
echo `date "+%d_%m_%Y"`
echo "USER=${USER}"
echo "## JOB IDENTIFICATION"
echo \$SLURM_JOB_NAME=${SLURM_JOB_NAME}
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo "## ASSIGNED RESOURCES"
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

# Write jobscript to output file (good for reproducibility)
cat $0

## LAUNCHING HPC MODULES 
module load Nextflow/25.10.2
module load Apptainer/1.5.1-GCCcore-14.3.0

## USE NXF V2 SYNTAX
export NXF_SYNTAX_PARSER=v2

## CREATE DIRECTORY FOR NEXTFLOW REPORTS
mkdir NXF_Reports

## EXECUTE NXF RUN COMMAND
nextflow run main.nf \
		-c nextflow.config \
		-with-report NXF_Reports/${SLURM_JOB_ID}_report.html \	
		-with-timeline NXF_Reports/${SLURM_JOB_ID}_timeline.html

## REMOVE ALL ACTIVE MODULES
module purge
