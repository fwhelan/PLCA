#Pre:
#plateList = all plates
#OTUList = all OTUs, ordered by MAXPP in the input
#OTUsOnPlates = OTUs x abundance on Plates
#seqPlates = 0
#amgList = 0

#Post:
#plateList = 0
#OTUList = 0
#seqPlates = plates to sequence
#amgList = 0

#! /usr/bin/perl -w

#Author: Fiona J Whelan
#Date: April 30th 2015; March 19th 2018
#Algorithm to determine which media plates need to be sequenced
#This script takes in an OTU table which has OTUID, SPUTUM, and MAXPP columns preceeding the actual plates in question. The algorithm then works to minimize the number of plates that need to be sequenced in order to capture all OTUs present above the input abundance. Abundance should be input as decimals such as 0.001 which would be 0.1% relative abundance.

#Usage: plateCoverageAlgorithm_adjusted.pl otu_table_maxpp.txt Sputabund abund
#output: otu_table_maxpp_seqPlates_abund.txt

#Check usage
if (($#ARGV+1) != 3) {
        print "\nUsage: plateCoverageAlgorithm_adjusted.pl otu_table_maxpp.txt <abundance in sputum> <abundance threshold on plates> (in decimal)\n";
        exit;
}

#Open files
$in = $ARGV[0];
open (IN, "<", $in) or die "$!";
$in =~/(.*)\.txt/;
#Initialize abund
$Sputabund = $ARGV[1];
chomp($Sputabund);
print $Sputabund."\n";
$abund = $ARGV[2];
chomp($abund);
print $abund."\n";
#Open files
open (OUT, ">", $1."_seqPlates_$abund.txt") or die "$!";
#Initialize plateList
@in = <IN>;
chomp($in[0]);
@plateList = split("\t", $in[0]);
shift @plateList; #rid of OTUID;
shift @plateList; #rid of SPUTM;
#shift @plateList; #rid of MAXPP;
#rid of taxonomy
if ($plateList[$#plateList] eq "Consensus Lineage") {
	pop @plateList;
}
#Make a copy of plateList
@plateListCopy = @plateList;
#Initialize OTUList & OTUsOnPlates
%OTUsInSputum = ();
%OTUsOnPlates = ();
$sputumOTUs = 0;
for($a=1; $a <= $#in; $a++) {
	@woline = split("\t", $in[$a]);
	$otu = shift @woline; #rid of OTUID
	#rid of taxonomy
	if ($woline[$#woline]=~/p_/) {
		pop @woline;
	}
	#Only add OTU to list if it is > $abund
	if ($woline[0] >= $Sputabund) {
		$OTUsInSputum{$otu} = [ $woline[0] ];
		$sputumOTUs++;
	}
	shift @woline; #rid of SPUTUM
	#shift @woline; #rid of MAXPP
	$OTUsOnPlates{$otu} = [ @woline ]; 
}
#Initialize seqPlates
$seqPlates = "";
#Initialize amgList
$amgList = "";
$thresholdOTUs = 0;
@markedForDeletion;
foreach my $b ( keys %OTUsInSputum ) {
	@tmpPlateList = @{$OTUsOnPlates{$b}};
	#check to see if there is only one non zero elemner in tmpPlateList
	@count = "";
	foreach ($d=0 ; $d <= $#tmpPlateList; $d++) {
		#if ($tmpPlateList[$d] > 0) {
		if ($tmpPlateList[$d] >= $abund) {
			push @count, $d;
		}
	}
	if ($#count == 1) {
		#add plateX to seqPlates; remove OTU b from OTUsOnPlates; remove plateX from plateList
		$plateX = pop @count;
		$seqPlates[$plateX] = 1;
		push @markedForDeletion, $b;
		$plateList[$plateX] = 0;
		#for all OTUs present on plateX at abund > abund
		foreach $e ( keys %OTUsInSputum ) {
			@tmp = @{$OTUsOnPlates{$e}};
			if ($tmp[$plateX] >= $abund) {
				push @markedForDeletion, $e;
			}
		}
	} elsif ($#count == 0) {
		#OTU isn't present above the abundance cutoff
		print "WARNING: OTU $b isn't present on a plate above the abundance threshold of $abund and will not be included in the coverage algorithm's calculations.\n";
		$thresholdOTUs++;
		push @markedForDeletion, $b;
	}
	
}
foreach my $x (@markedForDeletion) {
	delete $OTUsInSputum{$x};
}

print "\nWARNING: Of $sputumOTUs, $thresholdOTUs will be ignored.\n\n";

#while hash isn't empty
while (scalar(%OTUsInSputum)) {
	#deal with any leftover OTUs by prioritizing plates with the most OTUs on the leftover list
	for ($f=0; $f <= $#plateList; $f++) {
		if ($plateList[$f]) {
			foreach $g ( keys %OTUsInSputum ) {
				@tmp = @{$OTUsOnPlates{$g}};
				if ($tmp[$f] > $abund) {
					$county[$f]++;
				}
			}
		}
	}
	#cycle through county to find max, preserve f	
	$max = 0;
	$plateID = 0;
	for($f=0; $f <=$#county; $f++) {
		if ($county[$f] > $max) {
			$max = $county[$f];
			$plateID = $f;
		}
	}
	#add plate f to seqPlates
	$seqPlates[$plateID] = 1;
	#for all OTUs present on plate F at abund > abund (code above)
	foreach $g ( keys %OTUsInSputum ) {
		@tmp = @{$OTUsOnPlates{$g}};
		if ($tmp[$plateID] > $abund) {
			delete $OTUsInSputum{$g};
		}
	}
	#continue until hash is empty
}

#Output seqPlates to OUT
@plateList = @plateListCopy;
for($h=0; $h <= $#seqPlates; $h++) {
	if ($seqPlates[$h]) {
		print OUT $plateList[$h]."\n";
		print $plateList[$h]."\n";
	}
}
close IN;
close OUT;
