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

# x_acc = -1
# x_vel = -1t + x_vel_init
# x_pos = -2.t.t + t.x_vel_init + 0

# x_vel_init values where x_pos>=xmin && xpos<=xmax
# x_vel > 0

# y_acc = -1
# y_vel = -1t + y_vel_init
# y_pos = -2.t.t + t.y_vel_init + 0


# x_pos = -2.t.t + t.x_vel_init + 0
# y_pos = -2.t.t + t.y_vel_init + 0

# given x_pos,y_pos, what was X_vel_init & y_vel_init?
# x_pos = -2.t.t + t.x_vel_init + 0
# y_pos = -2.t.t + t.y_vel_init + 0

# 0 = 2.t.t - t.x_vel_init + x_pos;
# a=2
# b=t.x_vel_init
# c=x_pos



# find all the X initial velocities that pass through the area
my @xv_inits = ();
XIV: for(my $xv_init=1;$xv_init<=$maxx;++$xv_init ) {
	my $x = 0;	
	my $xv = $xv_init;
	while( $xv > 0 ) {
		$x += $xv;
		$xv--;
		if( $x>=$minx && $x<=$maxx ) {
			push @xv_inits,$xv_init;
			next XIV;
		}
	}
}
print "".(scalar @xv_inits )."\n";


my $best_apex;
my $yv_init = 0;
YIV: while(1) {
	$yv_init++;
	foreach my $xv_init ( @xv_inits ) {
		my $x = 0;	
		my $y = 0;	
		my $xv = $xv_init;
		my $yv = $yv_init;
		my $apex;
		while( $yv > 0 || $y>$miny ) {
			if( !defined $apex || $y>$apex ) { $apex = $y; }
			$x += $xv;
			$y += $yv;
			$xv--;
			$yv--;
			if( $x>=$minx && $x<=$maxx && $y>=$miny && $y<=$maxy ) {
				print "$xv_init,$yv_init HIT! apex=$apex\n";
				if( !defined $best_apex || $apex > $best_apex ) { $best_apex=$apex; }
				next YIV;
			}
		}
	
	}
}

############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

