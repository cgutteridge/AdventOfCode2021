#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################


# f = sum( abs( offset - x ) )

my @crabpos = split( /,/, $rows[0] );
my $t = 0;
my $min;
my $max;
foreach my $p ( @crabpos ) {
	$min = $p if( !defined $min || $p<$min );
	$max = $p if( !defined $max || $p>$max );
	$t+=$p;
}
print sprintf(  "min=%d, max=%d\n", $min, $max );
my $cheapest_score;
my $cheapest_target;
for( my $i=$min; $i<=$max; ++$i ) {
	my $score = 0;
	foreach my $p ( @crabpos ) {
		my $dist = abs( $i-$p );
		$score += ($dist*$dist+$dist)/2;
	}
	if( !defined $cheapest_score || $score < $cheapest_score ) {
		$cheapest_target = $i;
		$cheapest_score = $score;
	}
	print sprintf(  "target=%d, score=%d\n", $i, $score );
}
print sprintf(  "target=%d, PART2=%d\n", $cheapest_target, $cheapest_score );

