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
#This script takes in an OTU table which has OTUID, SPUTUM, and MAXPP columns preceeding the actual plates in question. The algorithm then works to minimize the number of plates that need to be sequenced in order to capture all OTUs present above the input abundance. Abundance should be input as decimals such as 0.001 which corresponds to 0.1% relative abundance.

#Usage: plateCoverageAlgorithm_denovo.pl otu_table_maxpp.txt abund
#output: otu_table_maxpp_seqPlates_abund.txt

#Check usage
if (($#ARGV+1) != 2) {
        print "\nUsage: plateCoverageAlgorithm_denovo.pl otu_table_maxpp.txt abund (in decimal)\n";
        exit;
}

#Open files
$in = $ARGV[0];
open (IN, "<", $in) or die "$!";
$in =~/(.*)\.txt/;
#Initialize abund
$abund = $ARGV[1];
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
#Make a copy of plateList
@plateListCopy = @plateList;
#Initialize OTUList & OTUsOnPlates
%OTUsOnPlates = ();
for($a=1; $a <= $#in; $a++) {
	@woline = split("\t", $in[$a]);
	$otu = shift @woline; #rid of OTUID
	$otu = shift @woline; #rid of SPUTUM
	#$otu = shift @woline; #rid of MAXPP
	$OTUsOnPlates{$otu} = [ @woline ];
}
#Initialize seqPlates
$seqPlates = "";
#Initialize amgList
$amgList = "";
@markedForDeletion;
foreach my $b ( keys %OTUsOnPlates ) {
	@tmpPlateList = @{$OTUsOnPlates{$b}};
	#check to see if there is only one non zero element in tmpPlateList
	@count = "";
	foreach ($d=0 ; $d <= $#tmpPlateList; $d++) {
		if ($tmpPlateList[$d] > $abund) {
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
		foreach $e ( keys %OTUsOnPlates ) {
			@tmp = @{$OTUsOnPlates{$e}};
			if ($tmp[$plateX] > $abund) {
				push @markedForDeletion, $e;
			}
		}
	} elsif ($#count == 0) {
		#OTU isn't present above the abundance cutoff
		push @markedForDeletion, $b;
	}
	
}
foreach my $x (@markedForDeletion) {
	delete $OTUsOnPlates{$x};
}
#while hash isn't empty
while (scalar(%OTUsOnPlates)) {
	#deal with any leftover OTUs by prioritizing plates with the most OTUs on the leftover list
	for ($f=0; $f <= $#plateList; $f++) {
		if ($plateList[$f]) {
			foreach $g ( keys %OTUsOnPlates ) {
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
	foreach $g ( keys %OTUsOnPlates ) {
		@tmp = @{$OTUsOnPlates{$g}};
		if ($tmp[$plateID] > $abund) {
			delete $OTUsOnPlates{$g};
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
