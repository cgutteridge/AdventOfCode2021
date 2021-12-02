#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my @rows = readfile( "data" );
print Dumper( \@rows );

my $n = 0;
my $last;
foreach my $i ( 0..((scalar @rows)-3) ) {
	my $v = $rows[$i]+$rows[$i+1]+$rows[$i+2];;
	if( defined $last && $v>$last ) { $n++; }
	$last = $v;
}
print "PART 2: $n\n";
