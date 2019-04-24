# PLCA
PLate Coverage Algorithm (PLCA) for Culture-Enriched MetaGenomics (CEMG)

An algorithm for determining the optimal subset of culture plates for conducting culture-enriched metagenomic sequencing based on an OTU table obtained from 16S rRNA gene sequencing (or other) marker gene sequencing.

Inputs:  
a. an OTU table in tab-delimited format. Entries in the table must be formatted as relative abundance measures and not raw read counts. The first column is expected to be the OTU ID; the second column is expected to be the culture-independent (i.e. original) sample; the remaining columns represent the culture-enriched samples, one per column. The table does not need to be OTUs; abundances of species, ASVs, or non-16S rRNA marker gene studies can also be used.
b. a relative abundance cutoff. This cutoff is used to determine whether an OTU is considered "cultured" or not, and thus should be included as a target for culture-enriched metagenomic sequencing. It must be given as a relative abundance between 0 and 1.  
c. (_adjusted_ algorithm only) a culture-independent relative abundance cutoff. This cutoff is used to determine the list of abundant OTUs from within the culture-independent sample that the user is interested in obtaining from CEMGs.  

The _denovo_ version of this algorithm should be used when the user is interested in determining a set of culture plates based solely on their content (for example, for clinically-motivated studies interested in abundant taxa). In contrast, the _adjusted_ PLCA should be used when the user is interested in only sequencing OTUs present within the original culture-independent sequencing data (for example, for studies of biodiversity, investigations interested in low abundance taxa).

```
perl plateCoverageAlgorithm_denovo.pl 

Usage: plateCoverageAlgorithm_denovo.pl otu_table_maxpp.txt <culture-enrichment threshold> (in decimal)
        where otu_table_maxpp.txt is a tab-delimited table with the following column structure: OTU ID Original_sample Maximum_abundance_across_culture Plate1 Plate2 ... PlateX Taxonomy
              the abundance threshold is the cutoff at which you wish to include an OTU/species in the output
```

```
perl plateCoverageAlgorithm_adjusted.pl 

Usage: plateCoverageAlgorithm_adjusted.pl otu_table_maxpp.txt <culture-independent threshold> <culture-enrichment threshold> (in decimal)
        where otu_table_maxpp.txt is a tab-delimited table with the following column structure: OTU ID Original_sample Maximum_abundance_across_culture Plate1 Plate2 ... PlateX Taxonomy
              the abundance in the original sample is the abundance cutoff in the original sample for OTUs to be included in the output
              the abundance threshold is the cutoff at which an OTU is to be considered cultured
```

# An example
We recently performed culture-enrichment on a set of cystic fibrosis lung microbiota samples. Exporated sputum was collected from participants of the study; the original/culture-independent sequencing was performed on this sample in parallel with culture-enrichment on various media in both anaerobic and aerobic conditions. For the first sputum sample in our study, we obtained bacterial growth on 24 cultured plates.

16S rRNA gene sequencing was performed on the original sample as well as these 24 cultured plates. `PLCA_tutorial/otu_table.txt` includes the relative abundance information for the original sputum sample, the culturing, as well as a maximum relative abundance of each OTU across culture conditions.

## _denovo_ PLCA: an example
`perl plateCoverageAlgorithm_denovo.pl otu_table.txt 0.0001` will calculate the culture conditions necessary for metagenomic sequencing in order to cover all OTUs >=0.0001 (0.01%) present in the culture enrichment (according to the 16S rRNA gene sequencing results). When we run the _denovo_ PLCA with this abundance threshold, the following should be printed to screen:
```
0.0001
Plate2
Plate3
Plate4
Plate5
Plate6
Plate7
Plate8
Plate9
Plate10
Plate11
Plate12
Plate13
Plate14
Plate16
Plate18
Plate19
Plate20
Plate23
Plate24
```
Additionally, these results are output to `otu_table_denovoPLCA_0.0001.txt`. In this case, 19 of the 24 original plates are needed to recapitulate all OTUs >= 0.01%. In contrast, a less stringent abundance cutoff results in less plates being necessary:
```
perl plateCoverageAlgorithm_denovo.pl otu_table.txt 0.1
0.1
Plate2
Plate3
Plate16
Plate18
Plate20
```

## _adjusted_ PLCA: an example
`perl plateCoverageAlgorithm_adjusted.pl otu_table.txt 0.0001 0.005` will subset all OTUs to only those present at >=0.0001 (0.01%) in the original sample, and target those for culture-enriched metagenomic sequencing. An OTU is considered cultured, if it is found on a plate with an abundance of >=0.005 (0.5%). Sometimes, OTUs that are identified in the orignal sample greater than the abundance threshold is not cultured on any plate. In these cases, a warning will be output by the _adjusted_ PLCA, for example `WARNING: OTU 227 isn't present on a plate above the abundance threshold of 0.005 and will not be included in the coverage algorithm's calculations.` This means that this OTU will not be targetted for culture-enriched metagenomics unless the culture-enrichment threshold is adjusted. For example:
```
perl plateCoverageAlgorithm_adjusted.pl otu_table.txt 0.001 0.0001
0.001
0.0001
WARNING: OTU 187 isn't present on a plate above the abundance threshold of 0.0001 and will not be included in the coverage algorithm's calculations.

WARNING: Of 11, 1 will be ignored.

Plate1
```
In this case, OTU 187 was not cultured and thus is ignored in the calculation of culture-enriched plates.
