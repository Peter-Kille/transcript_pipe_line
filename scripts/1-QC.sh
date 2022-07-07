#!/bin/bash
#author: Peter Kille
#SBATCH --partition=jumbo
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=8000
#SBATCH --error="%J.err"
#SBATCH --output="%J.out"

echo "General Env Var Info:"
echo "================================="
echo "hostname=$(hostname)"
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

module load fastp/v0.20

#core sample name no direction or fastq.gz

#Base directory
dir="/mnt/scratch/smbpk/Pea_aphid"

#Location of raw data
rawdir="/mnt/scratch/smbpk/Pea_aphid/fastq_files"


trimdir="/mnt/scratch/smbpk/Pea_aphid/trim_fastq"

#Step 1 - transfer and rename raw data files.  This may need to be editted to merge any files that are associated with the same condition.
#declare input files - do not include _1.fastq.gz
declare -a rawdata=(\
"PA1_S7"
"PA5_S9"
)

for (( i=0 ; i<${#rawdata[@]} ; i++ ));do


	fastp -i "${rawdir}/${rawdata[${i}]}_merge_R1.fastq.gz" -I "${rawdir}/${rawdata[${i}]}_merge_R2.fastq.gz" -o "${trimdir}/${rawdata[${i}]}_1_trim.fastq.gz" -O "${trimdir}/${rawdata[${i}]}_2_trim.fastq.gz" \
        -w ${SLURM_CPUS_PER_TASK} \
        -h "${trimdir}/${rawdata[${i}]}report.html" \
        -j "${trimdir}/${rawdata[${i}]}report.json"

done

module unload fastp/v0.20

module load fastqc/v0.11.9

for (( i=0 ; i<${#rawdata[@]} ; i++ ));do

	fastqc -t 2 "${rawdir}/${rawdata[${i}]}_R1.fastq.gz" "${rawdir}/${rawdata[${i}]}_R2.fastq.gz"
	fastqc -t 2 "${trimdir}/${rawdata[${i}]}_1_trim.fastq.gz" "${trimdir}/${rawdata[${i}]}_2_trim.fastq.gz"

done

module unload fastqc/v0.11.9

