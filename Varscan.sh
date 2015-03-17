#####
# Var Scan calls
####









#testing VarScan Output 
#http://varscan.sourceforge.net/using-varscan.html#v2.3_mpileup2cns
	#OPTIONS:
	#	--min-coverage	Minimum read depth at a position to make a call [8]
	#	--min-reads2	Minimum supporting reads at a position to call variants [2]
	#	--min-avg-qual	Minimum base quality at a position to count a read [15]
	#	--min-var-freq	Minimum variant allele frequency threshold [0.01]
	#	--min-freq-for-hom	Minimum frequency to call homozygote [0.75]
	#	--p-value	Default p-value threshold for calling variants [99e-02]
	#	--strand-filter	Ignore variants with >90% support on one strand [1]
	#	--output-vcf	If set to 1, outputs in VCF format
	#	--variants	Report only variant (SNP/indel) positions (mpileup2cns only) [0]









	#at what minimum coverage should ti call SNPS?
	#how to deal with Tri (or tetra) alleles? 



#default
samtools mpileup -f am45new.fasta HDB183.sorted.bam | java -jar VarScan.v2.3.7.jar mpileup2cns --variants > HDB183.CNS




#test coverage = 3
samtools mpileup -f am45new.fasta HDB183.sorted.bam | java -jar VarScan.v2.3.7.jar mpileup2cns --min-coverage 3 --variants > HDB183.cov3.CNS



#For each population we need one .CNS file:

samtools mpileup -f am45new.fasta /media/data1/afz/fastq/LDB127.sorted.stampy.rg.dp.gatk.bam  /media/data1/afz/fastq/LDB136.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB153.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB162.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB181.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB196.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB221.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB23S.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB29.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB35S.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB40S.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB5.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB6.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB8.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/LDB9.sorted.stampy.rg.dp.gatk.bam | java -jar VarScan.v2.3.7.jar mpileup2cns --min-coverage 5 --min-var-freq 0.05 --min-freq-for-hom 0.66 --variants > LDB.raw.CNS


samtools mpileup -f am45new.fasta /media/data1/afz/fastq/HDB139.sorted.stampy.rg.dp.gatk.bam  /media/data1/afz/fastq/HDB191.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB148.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB195.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB150.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB199.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB175.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB288.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB179.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB302.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB183.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB303.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB187.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB30S.sorted.stampy.rg.dp.gatk.bam /media/data1/afz/fastq/HDB189.sorted.stampy.rg.dp.gatk.bam | java -jar VarScan.v2.3.7.jar mpileup2cns --min-coverage 5 --min-var-freq 0.05 --min-freq-for-hom 0.66 --variants > HDB.raw.CNS








