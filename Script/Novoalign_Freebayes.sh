read -p " enter your Reference:" Re1
read -p " enter the Read 1:" r1
read -p " enter the Read 2:" r2
#indexing
novoindex "$Re1".nix "$Re1"
#Alignment
novoalign -d "$Re1".nix -f Data/"$r1" Data/"$r2" -i 200,50 -o SAM > output/"$r1"/"$r1"_novoalign.sam -c 10 2>output/"$r1"/"$r1"_log.txt
#Bam_File
samtools view -bS output/"$r1"/"$r1"_novoalign.sam -o output/"$r1"/"$r1"_novoalign.bam
#Sort_Bam
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar SortSam VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_novoalign.bam O=output/"$r1"/"$r1"_Sort_novoalign.bam SORT_ORDER=coordinate
#Pcr_Duplicates
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar MarkDuplicates VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_Sort_novoalign.bam O=output/"$r1"/"$r1"_PCR_novoalign.bam REMOVE_DUPLICATES=true M=output/"$r1"/"$r1"_pcr_novoalign.metrics
#ID_Addition
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_PCR_novoalign.bam O=output/"$r1"/"$r1"_RG_novoalign.bam SO=coordinate RGID=SRR"$r1" RGLB=SRR"$r1" RGPL=illumina RGPU=SRR"$r1" RGSM=SRR"$r1" CREATE_INDEX=true
#Variant_Calling-Free_Bayes
freebayes -f -f "$Re1" -v output/"$r1"/novoalign_Freebayes_"$r1".vcf output/"$r1"/"$r1"_RG_novoalign.bam
#variant_Sepration_Indel_SNV
vcftools --vcf output/"$r1"/novoalign_Freebayes_"$r1".vcf --remove-indels --recode --recode-INFO-all --out output/"$r1"/novoalign_FreeBayes_SNP_"$r1".vcf
vcftools --vcf output/"$r1"/novoalign_Freebayes_"$r1".vcf --keep-only-indels  --recode --recode-INFO-all --out output/"$r1"/novoalign_FreeBayes_Indels_"$r1".vcf
