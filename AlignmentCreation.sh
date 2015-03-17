#!/usr/bin/env bash


###
# Alignment File creation for Africanized Bee Genome Project
###

##
	#Below are WHILE loops that loop through a lsit of bees (beelist.txt)
	#I've set them as single while loops so I can test the output after each stages
	#intend to make this all one function














###
#Create .sai
for f in /media/data1/afz/fastq/*.fastq
	do bwa aln -t20 /home/amel45/AM45/am45new.fasta $f > $f.sai &
done


###
#create .sorted.bam
filename='/media/data1/afz/git/beelist1.txt'
exec 4<$filename
echo Start
while read -u4 p ; do
	pidlist_sampe=""
   #LDB23S_R1.fastq.sai
	#echo $p
	endfq="_R1.fastq"
	endfq2="_R2.fastq"
	sai=".sai"
	fq1=$p$endfq
	fq2=$p$endfq2
	r1=$fq1$sai
	r2=$fq2$sai
	bwa sampe -r "@RG\tID:$p\tPL:illumina\tLB:$p\tPU:run\tSM:$p" /home/amel45/AM45/am45new.fasta $r1 $r2 $fq1 $fq2 | samtools view -Sb - | samtools sort -@ 5 - $p.sorted &
done




###
#create Stampy http://www.well.ox.ac.uk/~gerton/README.txt
#	$p.sorted.bam

filename='/media/data1/afz/git/beelist.txt'
exec 4<$filename
echo Start
while read -u4 p ; do
	pidlist_sampe=""
	stampy -t 20 -g am45new -h am45new --bamkeepgoodreads --substitutionrate=0.02 -M $p.sorted.bam > $p.sorted.sam
	samtools view -Sb $p.sorted.sam | samtools sort -@ 5 - $p.sorted.stampy
done




###
#Remove dups and add read groups
filename='/media/data1/afz/git/beelist.txt'
exec 4<$filename
echo Start
while read -u4 p ; do
	export PICARD=/usr/lib/picard-tools-1.80
	picard MarkDuplicates.jar I=$p.sorted.stampy.bam  O=$p.sorted.stampy.dp.bam METRICS_FILE=$p.Dups VALIDATION_STRINGENCY=SILENT MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000
	picard AddOrReplaceReadGroups.jar INPUT= $p.sorted.stampy.dp.bam   OUTPUT=$p.sorted.stampy.rg.dp.bam RGID=$p RGPL=illumina RGLB=$p RGPU=run RGSM=$p VALIDATION_STRINGENCY=LENIENT
	samtools index $p.sorted.stampy.rg.dp.bam
done





###
#GATK indel Realigner
filename='/media/data1/afz/git/beelist.txt'
exec 4<$filename
echo Start
while read -u4 p ; do
	gatk -T RealignerTargetCreator -R /home/amel45/AM45/am45new.fasta -nt 15 -I $p.sorted.stampy.rg.dp.bam  -o $p.intervals
	gatk -T IndelRealigner -R /home/amel45/AM45/am45new.fasta -I $p.sorted.stampy.rg.dp.bam  -targetIntervals  $p.intervals -o $p.sorted.stampy.rg.dp.gatk.bam
done
