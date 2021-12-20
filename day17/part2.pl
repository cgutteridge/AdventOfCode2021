#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );
require "../xmas.pl";
my $t0 = [gettimeofday];
my $n=0;

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

$rows[0] =~ m/target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)/;
my($xmin,$xmax,$ymin,$ymax) = ($1+0,$2+0,$3+0,$4+0);
print "($xmin,$xmax,$ymin,$ymax)\n";

my $times_to_xv0_hits = {};
for( my $xv0=1;$xv0<$xmax+2;++$xv0 ) {
	YV0: for( my $yv0=$ymin;$yv0<(-$ymin+2);++$yv0 ) {
		my $x = 0;
		my $y = 0;
		my $xv = $xv0;
		my $yv = $yv0;
		while( $y>=$ymin ) {
			$x+=$xv;
			$y+=$yv;
			$xv-- if $xv>0;
			$yv--;
			if( $x>=$xmin && $x<=$xmax && $y>=$ymin && $y<=$ymax ) {
				++$n;	
				next YV0;
			}
		}
	}
}





#not 1891
############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

