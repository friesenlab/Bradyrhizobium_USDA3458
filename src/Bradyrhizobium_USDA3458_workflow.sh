#!/bin/bash

#Written RAWIII
#June 24th, 2019

#remove adapters/trim
bbduk.sh -Xmx1g in1=Bradyrhizobium_USDA3458_raw_R1.fastq.gz in2=Bradyrhizobium_USDA3458_raw_R2.fastq.gz out1=Bradyrhizobium_USDA3458_trim_R1.fastq.gz out2=Bradyrhizobium_USDA3458_trim_R2.fastq.gz ref=~/bbmap/resources/adapters.fa ktrim=r k=21 mink=11 hdist=2 tpe tbo 

#decon phix and trim further
bbduk.sh -Xmx1g in1=Bradyrhizobium_USDA3458_trim_R1.fastq.gz in2=Bradyrhizobium_USDA3458_trim_R2.fastq.gz out1=Bradyrhizobium_USDA3458_trim-decon_R1.fastq.gz out2=Bradyrhizobium_USDA3458_trim-decon_R2.fastq.gz qtrim=r trimq=25 maq=25 minlen=50 ref=~/bbmap/resources/phix174_ill.ref.fa.gz k=31 hdist=1 stats=F1_all_trim-decon-stats.txt

#load modules for unicycler
module load python3/3.5.0
module load bowtie2/2.3.4
module load blast/2.7.1
module load samtools/1.6

#run unicycler assembly and pilon polishing
/home/richard.white3/Unicycler/unicycler-runner.py -1 Bradyrhizobium_USDA3458_trim-decon_R1.fastq.gz -2 Bradyrhizobium_USDA3458_trim-decon_R2.fastq.gz -o Bradyrhizobium_USDA3458_dir --pilon_path /pilon-1.22.jar

#subsample >200 bp for GenBank submission
reformat.sh in=Bradyrhizobium_USDA3458_raw-assem.fasta out=Bradyrhizobium_USDA3458_wo200bp.fasta minlength=1000 aqhist=Bradyrhizobium_USDA3458_hist_200bp.txt

#subsample 1k contigs
reformat.sh in=Bradyrhizobium_USDA3458_raw-assem.fasta out=Bradyrhizobium_USDA3458_1k.fasta minlength=1000 aqhist=Bradyrhizobium_USDA3458_hist_1k.txt

#Prokka annotation (all raw contigs, all contigs >200 bp for Genbank, and 1k contigs)
prokka Bradyrhizobium_USDA3458_raw-assem.fasta --cpu 28 --outdir Bradyrhizobium_USDA3458_raw --prefix Bradyrhizobium_USDA3458_raw --rfam
prokka Bradyrhizobium_USDA3458_wo200bp.fasta --cpu 28 --outdir Bradyrhizobium_USDA3458_200bp --prefix Bradyrhizobium_USDA3458_200bp --rfam
prokka Bradyrhizobium_USDA3458_1k.fasta --cpu 28 --outdir Bradyrhizobium_USDA3458_1k --prefix Bradyrhizobium_USDA3458_1k --rfam
