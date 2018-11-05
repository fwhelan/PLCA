# PLCA
PLate Coverage Algorithm (PLCA) for Culture-Enriched MetaGenomics (CEMG)

An algorithm for determining the optimal subset of plates for conducting culture-enriched metagenomic sequencing based on an OTU table obtained from 16S rRNA gene sequencing (or other) marker gene sequencing.

Inputs:  
a. an OTU table in tab-delimited format. Entries in the table must be formatted as relative abundance measures and not raw read counts. The first column is expected to be the OTU-ID; the second column is expected to be the culture-independent sample; the remaining columns represent the culture-enriched samples, one per column.  
b. a relative abundance cutoff. This cutoff is used to determine whether an OTU is considered "cultured" or not. It must be given as a relative abundance between 0 and 1.  
c. (_adjusted_ algorithm only) a culture-independent relative abundance cutoff. This cutoff is used to determine the list of abundant OTUs from within the culture-independent sequencing that the user is interested in obtaining from CEMG.  

The _de novo_ version of this algorithm is the original version and should be used in the situation in which one is interested in determining a set of plates based solely on their content. However, the _adjusted_ PLCA should be used when the user is interested in only sequencing OTUs present within the original culture-independent sequencing data.
