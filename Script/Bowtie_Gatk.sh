read -p " enter your Reference:" Re1
read -p " enter the Read 1:" r1
read -p " enter the Read 2:" r2
#indexing
bowtie index bowtie2-build "$Re1" "$Re1"
#Alignment
bowtie2 -p 10 -x "$Re1" -1 Data/"$r1" -2 Data/"$r2" -S output/"$r1"/"$r1"_bowtie.sam
#Bam_File
samtools view -bS output/"$r1"/"$r1"_bowtie.sam -o output/"$r1"/"$r1"_bowtie.bam
#Sort_Bam
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar SortSam VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_bowtie.bam O=output/"$r1"/"$r1"_Sort_bowtie.bam SORT_ORDER=coordinate
#Pcr_Duplicates
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar MarkDuplicates VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_Sort_bowtie.bam O=output/"$r1"/"$r1"_PCR_bowtie.bam REMOVE_DUPLICATES=true M=output/"$r1"/"$r1"_pcr_bowtie.metrics
#ID_Addition
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_PCR_bowtie.bam O=output/"$r1"/"$r1"_RG_bowtie.bam SO=coordinate RGID=SRR"$r1" RGLB=SRR"$r1" RGPL=illumina RGPU=SRR"$r1" RGSM=SRR"$r1" CREATE_INDEX=true
#Vsriant_calling
gatk --java-options "-Xmx10g" HaplotypeCaller -R "$Re1" -I output/"$r1"/"$r1"_RG.bam -O output/"$r1"/bowtie_GATK_"$r1".vcf.gz
#variant_Sepration_Indel_SNV
vcftools --vcf output/"$r1"/bowtie_GATK_"$r1".vcf --remove-indels --recode --recode-INFO-all --out output/"$r1"/bowtie_GATK_SNP_"$r1".vcf
vcftools --vcf output/"$r1"/bowtie_GATK_"$r1".vcf --keep-only-indels  --recode --recode-INFO-all --out output/"$r1"/bowtie_GATK_Indels_"$r1".vcf

