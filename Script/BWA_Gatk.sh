read -p " enter your Reference:" Re1
read -p " enter the Read 1:" r1
read -p " enter the Read 2:" r2
#indexing
bwa index "$Re1"
#ALignment
bwa mem -M -t 10 "$Re1" Data/"$r1" Data/"$r2" > output/"$r1"/"$r1"_bwa.sam
#Bam_File
samtools view -bS output/"$r1"/"$r1"_bwa.sam -o output/"$r1"/"$r1"_bwa.bam
#Sort_Bam
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar SortSam VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_bwa.bam O=output/"$r1"/"$r1"_Sort_bwa.bam SORT_ORDER=coordinate
#Pcr_Duplicates
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar MarkDuplicates VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_Sort_bwa.bam O=output/"$r1"/"$r1"_PCR_bwa.bam REMOVE_DUPLICATES=true M=output/"$r1"/"$r1"_pcr_bwa.metrics
#ID_Addition
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_PCR_bwa.bam O=output/"$r1"/"$r1"_RG_bwa.bam SO=coordinate RGID=SRR"$r1" RGLB=SRR"$r1" RGPL=illumina RGPU=SRR"$r1" RGSM=SRR"$r1" CREATE_INDEX=true
#Variant_calling
gatk --java-options "-Xmx10g" HaplotypeCaller -R "$Re1" -I output/"$r1"/"$r1"_RG.bam -O output/"$r1"/BWA_GATK_"$r1".vcf.gz
#variant_Sepration_Indel_SNV
vcftools --vcf output/"$r1"/BWA_GATK_"$r1".vcf --remove-indels --recode --recode-INFO-all --out output/"$r1"/BWA_GATK_SNP_"$r1".vcf
vcftools --vcf output/"$r1"/BWA_GATK_"$r1".vcf --keep-only-indels  --recode --recode-INFO-all --out output/"$r1"/BWA_GATK_Indels_"$r1".vcf
