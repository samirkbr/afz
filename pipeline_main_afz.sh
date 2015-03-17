#!/usr/bin/env bash





# ========Argument checking =========================
# Correct number of arguments
if [ "$#" -ne 6 ]; then
	echo "Usage: ./pipeline_main FASTA FILES DIVERGENCE bam_directory vcf_directory beelist " 
	exit
fi
pattern="^0\.[0-9]+)?$"


# =========== Input checking block ==============
# ========== So that we are not overriding existing folders =======
if [ ! -f "$1" ]; then
        echo "Error: FASTA file is not valid" >&2
        exit
fi
if [ ! -d "$2" ]; then
        echo "Error: FASTQ directory is not valid" >&2
        exit
fi
if [[ ! $3 =~ $pattern ]]; then
        echo "Error: Divergence has to be a number between 0 and 1"
        exit
fi
if [[ -d $4 ]]; then
       echo "Error: Bam directory already exists. Delete it or give your bam directory another name"
       exit
fi
if [[ -d $5 ]]; then
        echo "Error: VCF directory already exists. Delete it or give your vcf directory another name"
        exit
fi
if [ ! -f "$6" ]; then
        echo "Error: Bee list file is not valid" >&2
        exit
fi
# ======= End of Input checking block ====================

FASTA=$1
FASTQ=${2%/}
BEE_LIST=`readlink -e $6`
#BEE_LIST=/home/maisha/pipeline/complete_beelist.txt
#BEE_LIST=/home/maisha/pipeline/beelist2.txt
# create the bee list and bwa aln all the fastq files
DIVERGENCE=$3
diver_out=${DIVERGENCE#*.}
bam_dir=${4%/}
vcf_dir=${5%/}
REGIONLIST=`readlink -e $7`
merged_vcf_dir=${vcf_dir}_snps
#snp_info=${8%/}
#REGIONLIST=/home/maisha/pipeline/Bter_regions.txt
dir=_dir
delimi=_
delimi2=-
TEMP=${vcf_dir}_temp
#TEMP=/media/data1/bombus/temp_vcf_directory


cd $FASTQ
# get all the directories

# ======= bwa aligning, sampe, view, sort, merge; Output is one sorted bam file and its index file =======================
bwa_func(){

	bee=$1
	# bwa for all
	#find . -maxdepth 1 -name "*$bee*.fastq" | xargs -I {} bash -c "bwa aln -t10 $FASTA '{}' > '{}.sai'"
	
	pidlist_sampe=""
	# bwa sampe parallel
	for i in 1
	#LDB23S_R1.fastq.sai
	
	do 

		r1=`find . -maxdepth 1 -name "$bee$delimi*R1*.fastq*sai"`
		r2=`find . -maxdepth 1 -name "$bee$delimi*R2*.fastq*sai"`		
	 	fq1=`find . -maxdepth 1 -name "$bee$delimi*R1.fastq"` 
		fq2=`find . -maxdepth 1 -name "$bee$delimi*R2.fastq"`
		
		(bwa sampe -r "@RG\tID:$bee\tPL:illumina\tLB:$bee\tPU:run\tSM:$bee" $FASTA $r1 $r2 $fq1 $fq2 \
		| samtools view -Sb - \
		| samtools sort -@ 5 - ${bee}.sorted)&
		pidlist_sampe="$pidlist_sampe $!"

	done
	for pid in $pidlist_sampe
	do
    		wait $pid
	done

	export PICARD=/usr/lib/picard-tools-1.80
	picard MarkDuplicates.jar I=${bee}.sorted.bam O=${bee}.sorted.bam METRICS_FILE=oDups VALIDATION_STRINGENCY=SILENT MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000
	
	#clean up log file and .dp
	#rm oDups
	#rm ${bee}.sorted.bam.dp
	samtools index ${bee}.sorted.bam
	
	#rm ${bee}${delimi}1.sorted.bam
	#rm ${bee}${delimi}2.sorted.bam
		
	
}

# ==== POINTS to the bwa_func above with parallel approach  ====
do_bwa_aln(){
	while read bee
	do
		bwa_func $bee &
		NPROC=$(($NPROC+1))
		if [ "$NPROC" -ge 4 ]; then
       			wait
       	 		NPROC=0
   		fi

	done < $BEE_LIST
}




# ======= STEP CONTROL - Edit this  ===================
execute_bwa=`do_bwa_aln`
wait
