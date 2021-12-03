#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my @rows = readfile( "data" );
my $size = length $rows[0];
my $numbers = [];
foreach my $row ( @rows ) {
	push @$numbers, [ split //, $row ];
}

my @ones = ();
for( my $i=0;$i<$size;++$i) {$ones[$i]=0;}
# add up how many 1 bits
foreach my $number ( @$numbers ) {
	for( my $i=0;$i<$size;++$i) {
		$ones[$i]++ if $number->[$i];
	}
}

my $gamma = 0;
my $epsilon = 0;
my $f = 1;
for( my $i=$size-1; $i>=0; --$i ) {
	if( $ones[$i]>((scalar @$numbers)-$ones[$i]) ) {
		$gamma+=$f;
	} else {
		$epsilon+=$f;
	}
	$f*=2;
}
print "$gamma, $epsilon\n";

my $n = $gamma * $epsilon;
print "PART 1: $n\n";
