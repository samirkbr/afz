#!/usr/bin/env bash


###
# SNP Calling with GATK
###


#Final .bam files are $p.sorted.stampy.rg.dp.gatk.bam





###
#Calling SNPs and INDELS for all Individuals, assuming 24 ploidy creating 1 VCF file:

gatk -R /home/amel45/AM45/am45new.fasta -T UnifiedGenotyper  -I /media/data1/afz/git/BAMs.list -o AFZ.raw.vcf -nt 10 -glm SNP -ploidy 24




###
#Forcing Queen genotype: SNPs and INDELS for all Individuals, assuming 24 ploidy creating 1 VCF file:

gatk -R /home/amel45/AM45/am45new.fasta -T UnifiedGenotyper  -I /media/data1/afz/git/BAMs.list -o AFZdp.raw.vcf -nt 10 -glm SNP -ploidy 2

gatk -R /home/amel45/AM45/am45new.fasta -T UnifiedGenotyper  -I /media/data1/afz/git/BAMs.list -o AFZdp.indel.vcf -nt 12 -glm  INDEL -ploidy 2





###
#Get out coverage (29549)
gatk -R /home/amel45/AM45/am45new.fasta -T DepthOfCoverage -I /media/data1/afz/git/BAMs.list -o AFZcoverage 





###
#3) Remove sites around indels:

gatk -R /home/amel45/AM45/am45new.fasta -T VariantFiltration -V PX.raw.vcf --mask  PX.indel.vcf --maskExtension 10 --maskName "InDel" -o PX.vcf




#3 17's and 18 
vcftools --vcf PX.vcf --plink 
	R
	chroms=read.table(file="out.map",header=)
	#snps1=chroms$V2[grep("^18.1:*",chroms$V2)]
	snps2=chroms$V2[grep("^17.*",chroms$V2)]
	snps2=data.frame(snps2)
	snps2$chrom=gsub(":.*", "",snps2$snps2)
	snps2$pos=gsub(".*:", "",snps2$snps2)
	write.table(snps2[,c(2,3)],file="Excluded17SNPs",col.names=F,row.names=F,quote=F)

vcftools --vcf PX.vcf  --recode --remove-filtered-all --exclude Excluded17SNPs --out PX  

###########


###
#4) Prepare Filters 
	#i) First, call 2 drones singly as diploids for a filtering option:
		# CALL SNPs as diploid
		gatk -R /home/amel45/AM45/am45new.fasta -T UnifiedGenotyper -I Q11D1.sorted.bam -o Q11D1.HET.vcf -nt 5 -glm SNP -ploidy 2
		gatk -R /home/amel45/AM45/am45new.fasta -T UnifiedGenotyper -I Q11D4.sorted.bam -o Q11D4.HET.vcf -nt 5 -glm SNP -ploidy 2
		gatk -R /home/amel45/AM45/am45new.fasta -T UnifiedGenotyper -I Q11D2.sorted.bam -o Q11D2.HET.vcf -nt 5 -glm SNP -ploidy 2
		gatk -R /home/amel45/AM45/am45new.fasta -T UnifiedGenotyper -I Q11D5.sorted.bam -o Q11D5.HET.vcf -nt 5 -glm SNP -ploidy 2
		
		#Compile list of Hetero SNPs
		vcftools --vcf Q11D1.HET.vcf --counts --out Q11D1
		vcftools --vcf Q11D4.HET.vcf --counts --out Q11D4
		vcftools --vcf Q11D2.HET.vcf --counts --out Q11D2
		vcftools --vcf Q11D5.HET.vcf --counts --out Q11D5
		
			R
			#This is an inefficient way to do this, but you've only got to do it once.
			for(i in list.files(pattern="*.frq.count")){
				x=readLines(i)
				print(i)
				#any line with :1 will have 2 alleles (i.e. hetero). Remove it!
				hets=grep(":1",x)
				x=x[hets]
				test=strsplit(x,"\t")
				test1=unlist(lapply(test, function(x) x[1]))
				test2=unlist(lapply(test, function(x) x[2]))
				write.table(cbind(test1,test2),file="HeteroSNPs",col.names=F,row.names=F,quote=F,append=T)
			}
		
	vcftools --vcf PX.recode.vcf  --recode --remove-filtered-all --exclude HeteroSNPs --out PX1  
	
	
	#ii) Quality and Depth Filters:
	vcftools --vcf PX1.recode.vcf --site-mean-depth
		R
		depth=read.table(file="out.ldepth.mean",header=T)
		#mean depth=50
		maxdp=1.5*IQR(depth$MEAN_DEPTH)+median(depth$MEAN_DEPTH)
		mindp=median(depth$MEAN_DEPTH)-(1.5*IQR(depth$MEAN_DEPTH))

	vcftools --vcf PX1.recode.vcf --recode --remove-filtered-all  --out PX2  --min-meanDP 12 --max-meanDP 88
		
	vcftools --vcf PX1.recode.vcf --site-quality
		R
		qual=read.table(file="out.lqual",header=T)
		
	vcftools --vcf PX1.recode.vcf --recode  --out PX2  --minQ 140
		#renamed this file to PX.vcf
	