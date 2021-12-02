#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my @rows = readfile( "data" );
print Dumper( \@rows );

my $n = 0;
my $last;
foreach my $v ( @rows ) {
	if( defined $last && $v>$last ) { $n++; }
	$last = $v;
}
print "PART 1: $n\n";
