#!/usr/bin/perl

use strict;
use warnings;

my( $xv0, $yv0 ) = @ARGV;

my $y = 0;
my $x = 0;
my $xv = $xv0;
my $yv = $yv0;
my $t = 0;
while( $t<25 ) {
	$x+=$xv;
	$y+=$yv;
	$xv-- if $xv>0;
	$yv--;
	$t++;
	print sprintf( "t=%d  %d,%d    v=%d,%d\n", $t,$x,$y,$xv,$yv);
}
