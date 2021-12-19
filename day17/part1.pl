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
my($minx,$maxx,$miny,$maxy) = ($1+0,$2+0,$3+0,$4+0);
print "($minx,$maxx,$miny,$maxy)\n";

# work out all the times minx<=x<=maxx

#ya = -1
#yv = initv + t.ya
#y  = t*t*a/2 + t*(v0-a/2)
#a = -1

#y = t*t * -0.5 + t*(yv0 + 0.5 )
#x = t*t * -0.5 + t*(xv0 + 0.5 )

#0 = t*t * -0.5 + t*(yv0 + 0.5 ) - y
#0 = t*t * -0.5 + t*(xv0 + 0.5 ) - x

# t = (-b +- sqrt( b.b - 4.a.c ) / 2.a
# a=-0.5
# b=yv0+0.5
# c=-y

# t = (-b +- sqrt( b.b - 4.a.c ) / 2.a
# t = (-(yv0+0.5) +- sqrt( (yv0+0.5)^2 - 4.(-0.5).(-y) ) / 2.(-0.5)

# t = ( -yv0 - 0.5 +- sqrt( (yv0+0.5)^2 - 2y ) / -1
# t = ( xv0 + 0.5 +- sqrt( (xv0+0.5)^2 - 2x ) 
#x = t*t * -0.5 + t*(xv0 + 0.5 )





XIV: for(my $xv0=1;$xv0<=$maxx;++$xv0 ) {
	# t = ( xv0 + 0.5 +- sqrt( (xv0+0.5)^2 - 2x ) 

	print "$xv0..\n";
	my @sol = ();
	my $sq1 = ($xv0 + 0.5)*($xv0 + 0.5 ) - $minx ;
	if( $sq1 >= 0 ) {
		print "MINLINE: ".join( ",", $xv0 + 0.5 + sqrt( $sq1 ), $xv0 + 0.5 - sqrt( $sq1 ) )."\n";
	}
	my $sq2 = ($xv0 + 0.5)*($xv0 + 0.5 ) - $maxx ;
	if( $sq2 >= 0 ) {
		print "MAXLINE: ".join( ",", $xv0 + 0.5 + sqrt( $sq2 ), $xv0 + 0.5 - sqrt( $sq2 ) )."\n";
	}


	

}
__DATA__

# find xdir which lands in range with most steps
my $best_iv;
my $best_steps=0;
	my $steps =0;
	my $x = 0;	
	my $xv = $xv_init;
	my $hit = 0;
	while( $x<=$maxx && $xv) {
		if( $x>=$minx ) { $hit=1; }
		$steps++;
		$x+=$xv;
		$xv--;
	}
	if( $hit && $steps>$best_steps ) {
		$best_steps = $steps;
		$best_iv = $xv_init;
	}
}

print "BEST XIV = $best_iv\n";

# number of steps to get from 0 to -ymin
my $post_return_steps=0;
my $y = 0;
my $yv = 0;
while( $y<$miny ) { <F2>

print "
exit;

		


my $best_apex;
my $yv_init = 0;
YIV: while(1) {
	$yv_init++;
	XIV: for(my $xv_init=1;$xv_init<=$maxx;++$xv_init ) {
		my $x = 0;	
		my $y = 0;	
		my $xv = $xv_init;
		my $yv = $yv_init;
		print "\n$xv,$yv: ";
		my $apex;
		while( $yv > 0 || $y>=$miny ) {
			print " $y";
			$x += $xv;
			$y += $yv;
			$xv--;
			$yv--;
			if( !defined $apex || $y>$apex ) { $apex = $y; }
			if( $x>=$minx && $x<=$maxx && $y>=$miny && $y<=$maxy ) {
				print "$xv_init,$yv_init HIT! apex=$apex\n";
				if( !defined $best_apex || $apex > $best_apex ) { $best_apex=$apex; }
				next XIV;
			}
		}
	
	}
}
$n = $best_apex;
#not 1891
############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

