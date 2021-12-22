#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );
use POSIX;
require "../xmas.pl";
my $t0 = [gettimeofday];
my $n=0;

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

my $rules = [];
#on x=-30..22,y=-28..20,z=-17..37
foreach my $row ( @rows ) {
	my $rule = {};
	$row =~ m/^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$/;
	( $rule->{mode}, $rule->{x}->{min}, $rule->{x}->{max}, $rule->{y}->{min}, $rule->{y}->{max}, $rule->{z}->{min}, $rule->{z}->{max} ) = ( $1,$2,$3,$4,$5,$6,$7 );
	push @$rules,$rule;
}

############################################################

my @zones = ();
# zones are a list of ON or OFF areas. We do the rules backwards so new zones may not intersect with existing zones
RULE: foreach my $rule ( reverse @$rules ) {
	my @zones_to_add = ( $rule );

	ADD: while( @zones_to_add ) {
		# for next zone, if it doesn't overlap any existing zones, add it,
		# otherwise split it on the first zone it intersects and add those zones to the todo list
		# ?? unless it's off and the other zone is off too?
		my $zone_to_add = shift @zones_to_add;
		#print "consider ".zonetext($zone_to_add)."\n";
		ZONE: foreach my $zone ( @zones ) {

			# do they intersect?
			next if( $zone_to_add->{x}->{max} < $zone->{x}->{min} );
			next if( $zone_to_add->{x}->{min} > $zone->{x}->{max} );
			next if( $zone_to_add->{y}->{max} < $zone->{y}->{min} );
			next if( $zone_to_add->{y}->{min} > $zone->{y}->{max} );
			next if( $zone_to_add->{z}->{max} < $zone->{z}->{min} );
			next if( $zone_to_add->{z}->{min} > $zone->{z}->{max} );

			# if fully contained then don't add
			if( $zone_to_add->{x}->{min} >= $zone->{x}->{min} 
			 && $zone_to_add->{x}->{max} <= $zone->{x}->{max} 
			 && $zone_to_add->{y}->{min} >= $zone->{y}->{min} 
			 && $zone_to_add->{y}->{max} <= $zone->{y}->{max} 
			 && $zone_to_add->{z}->{min} >= $zone->{z}->{min} 
			 && $zone_to_add->{z}->{max} <= $zone->{z}->{max} ) {
				#print "CONTAINED: don't add\n";
				next ADD;
			}
#     |-----
#   |--|
#     |--|
#      |--|
#  |--|
# |--|

#     |-----
#   AABB
#     BBBB
#      BBBB
#  AAAB
# AAAA
#     |-----

			# there's 6 possible ways to split - on the min and max planes of the existing zone
			foreach my $axis ( qw/ x y z / ) {
				my $add1 = { 
					mode=>$zone_to_add->{mode}, 
					x=>$zone_to_add->{x},
					y=>$zone_to_add->{y},
					z=>$zone_to_add->{z} };
				my $add2 = { 
					mode=>$zone_to_add->{mode}, 
					x=>$zone_to_add->{x},
					y=>$zone_to_add->{y},
					z=>$zone_to_add->{z} };
				# $axis min
				if( $zone_to_add->{$axis}->{min} <  $zone->{$axis}->{min} 
			 	 && $zone_to_add->{$axis}->{max} >= $zone->{$axis}->{min} ) {
					# split on the zone's x-min plane
					$add1->{$axis} = { min=>$zone_to_add->{$axis}->{min}, max=>$zone->{$axis}->{min}-1 },
					$add2->{$axis} = { min=>$zone->{$axis}->{min},        max=>$zone_to_add->{$axis}->{max} },
					unshift @zones_to_add, $add1;
					unshift @zones_to_add, $add2;
					next ADD;
				}
				# $axis max
				if( $zone_to_add->{$axis}->{min} <= $zone->{$axis}->{max} 
			 	 && $zone_to_add->{$axis}->{max} >  $zone->{$axis}->{max} ) {
					$add1->{$axis} = { min=>$zone_to_add->{$axis}->{min}, max=>$zone->{$axis}->{max} },
					$add2->{$axis} = { min=>$zone->{$axis}->{max}+1,      max=>$zone_to_add->{$axis}->{max} },
					unshift @zones_to_add, $add1;
					unshift @zones_to_add, $add2;
					next ADD;
				}
			}
		}

		#print "ADD\n";	
		# no intersect
		push @zones, $zone_to_add;
	}
}
		
foreach my $zone ( @zones ) {
	next if $zone->{mode} eq "off";
	my $size_x = $zone->{x}->{max}-$zone->{x}->{min}+1;
	my $size_y = $zone->{y}->{max}-$zone->{y}->{min}+1;
	my $size_z = $zone->{z}->{max}-$zone->{z}->{min}+1;
	$n += $size_x * $size_y * $size_z;
}


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART2 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################


sub zonetext {
	my( $zone ) = @_;

	return sprintf( "x=%d..%d y=%d..%d z=%d..%d   (%s)",$zone->{x}->{min},$zone->{x}->{max},$zone->{y}->{min},$zone->{y}->{max},$zone->{z}->{min},$zone->{z}->{max},$zone->{mode} );
}
