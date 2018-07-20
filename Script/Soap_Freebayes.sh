read -p " enter your Reference:" Re1
read -p " enter the Read 1:" r1
read -p " enter the Read 2:" r2
#indexing
2bwt-builder "$Re1"
#Alignment
soap -a Data/"$r1" -b Data/"$r2" -D "$Re1".index -o output/"$r1"/"$r1"_soap.soap -2 output/"$r1"/"$r1"_soap_SE.soap
#soap to SAM conversion
perl soap2sam.pl output/"$r1"/"$r1"_soap_SE.soap > output/"$r1"/"$r1"_soap.sam
#Bam_File
samtools view -bT output/"$r1"/"$r1"_soap.sam -o output/"$r1"/"$r1"_soap.bam
#Sort_Bam
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar SortSam VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_soap.bam O=output/"$r1"/"$r1"_Sort_soap.bam SORT_ORDER=coordinate
#Pcr_Duplicates
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar MarkDuplicates VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_Sort_soap.bam O=output/"$r1"/"$r1"_PCR_soap.bam REMOVE_DUPLICATES=true M=output/"$r1"/"$r1"_pcr_soap.metrics
#ID_Addition
java -Xmx10g -jar Tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups VALIDATION_STRINGENCY=SILENT I=output/"$r1"/"$r1"_PCR_soap.bam O=output/"$r1"/"$r1"_RG_soap.bam SO=coordinate RGID=SRR"$r1" RGLB=SRR"$r1" RGPL=illumina RGPU=SRR"$r1" RGSM=SRR"$r1" CREATE_INDEX=true
#Variant_Calling-Free_Bayes
freebayes -f -f "$Re1" -v output/"$r1"/soap_Freebayes_"$r1".vcf output/"$r1"/"$r1"_RG_soap.bam
#variant_Sepration_Indel_SNV
vcftools --vcf output/"$r1"/soap_Freebayes_"$r1".vcf --remove-indels --recode --recode-INFO-all --out output/"$r1"/soap_FreeBayes_SNP_"$r1".vcf
vcftools --vcf output/"$r1"/soap_Freebayes_"$r1".vcf --keep-only-indels  --recode --recode-INFO-all --out output/"$r1"/soap_FreeBayes_Indels_"$r1".vcf

