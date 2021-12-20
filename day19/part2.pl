#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );
use POSIX;
use Carp qw/ confess /;
use Math::Matrix;
require "../xmas.pl";
my $t0 = [gettimeofday];
my $n=0;

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

my $scanners = [];
my $id;
foreach my $row ( @rows ) {
	if( $row =~ m/--- scanner (\d+) ---/ ) {
		$id=$1+0;
		# b - beacons visible to this scanner
		# all - beacons known relative to this scanner
		$scanners->[$id] = { id=>$id, b=>[], coverage => [ [[-1000,-1000,-1000], [1000,1000,1000]] ] };
		next;
	}
	next if( $row =~ m/^\s*$/ );
	my( $x,$y,$z ) = split( ",", $row );
	push @{$scanners->[$id]->{b}}, [ $x+0,$y+0,$z+0 ];
}


############################################################

my $rotx = [ 
	[ 1, 0, 0],  
	[ 0, 0,-1], 
	[ 0, 1, 0] ];
my $roty = [ 
	[ 0, 0, 1],  
	[ 0, 1, 0], 
	[-1, 0, 0] ];
my $rotz = [ 
	[ 0,-1, 0],  
	[ 1, 0, 0], 
	[ 0, 0, 1] ];
my $identity = [ 
	[ 1, 0, 0],
	[ 0, 1, 0],
	[ 0, 0, 1] ];
my @dirs = ( 
	$identity,
	matmult( $identity, $rotx ),
	matmult( $identity, $rotx, $rotx ),
	matmult( $identity, $rotx, $rotx, $rotx ),
	matmult( $identity, $roty ),
	matmult( $identity, $roty, $roty, $roty ),
);
my @rots = ();
foreach my $dir ( @dirs ) {
	push @rots, $dir;
	push @rots, matmult( $dir, $rotz );
	push @rots, matmult( $dir, $rotz,$rotz );
	push @rots, matmult( $dir, $rotz,$rotz,$rotz );
}

#my $ex= [
#	[-1,-1,1],
##	[-2,-2,2],
#	[-3,-3,3],
#	[-2,-3,1],
#	[5,6,-4],
#	[8,0,7] ];
#foreach my $rot( @rots ) {
#	printMatrix( matmult( $ex, $rot ));
#	print "\n";
#}
#exit;
	
#my $x={};
#foreach my $rot( @rots ) {
#	printMatrix( $rot ); print "\n";
#	my $c = $rot->[0]->[0].":".  $rot->[0]->[1].":".  $rot->[0]->[2].":".
#		$rot->[1]->[0].":".  $rot->[1]->[1].":".  $rot->[1]->[2].":".
#		$rot->[2]->[0].":".  $rot->[2]->[1].":".  $rot->[2]->[2].":";
#	if( $x->{$c} ) {
#		die;
#	}
#	$x->{$c}=1;
#}
#exit;
############################################################

my $pairs = {};
MAIN: while( scalar @$scanners ) {
	print "NEW LOOP\n";
	foreach my $scanner ( @$scanners ) {
		print "* ".$scanner->{id}." ".(scalar @{$scanner->{b}})."\n";
	}
	my $tested = {};
	my $tries = 0;
	A: for( my $a_i=0; $a_i<@$scanners-1; ++$a_i ) {
		print "$a_i .. \n";
		my $scanner_a = $scanners->[$a_i];
		# compare this with every non-joined scanner we've not already tried for it
		my $a_beacons = $scanner_a->{b};

		my $a_beacon_lookup = {};
		foreach my $beacon ( @$a_beacons ) { $a_beacon_lookup->{join( ",",@$beacon)}=1;}

		B: for( my $b_i=$a_i+1; $b_i<@$scanners; ++$b_i ) {
			my $scanner_b = $scanners->[$b_i];
			#print "$a_i .. $b_i\n";

			# try rotating 
			for(my $r_i=0;$r_i<@rots;++$r_i ) {
				my $rot = $rots[$r_i];
				
				my $b_beacons_rotated = matmult( $scanner_b->{b}, $rot );
#				printMatrix( $b_beacons_rotated );
#				print "---\n";
				# try each beacon in B as if it were the first beacon in A

				foreach my $anchor_beacon_a ( @$a_beacons ) {
				foreach my $anchor_beacon_b ( @$b_beacons_rotated ) {
					my $score = 0;
					$tries++;

					# assume $anchor_beacon is beacon a[0], and see how many matches we get
					foreach my $beacon ( @$b_beacons_rotated ) {
						my $bid = join( ",",
							$beacon->[0] - $anchor_beacon_b->[0] + $anchor_beacon_a->[0],
							$beacon->[1] - $anchor_beacon_b->[1] + $anchor_beacon_a->[1],
							$beacon->[2] - $anchor_beacon_b->[2] + $anchor_beacon_a->[2],
						);
						if( $a_beacon_lookup->{$bid} ) { $score++; }
					}
					#if( $score > 1 ) { print "S=$score\n"; }
					if( $score >= 12 ) {
						print "MATCH $a_i..$b_i (".$scanner_a->{id}." .. ". $scanner_b->{id}." (score=$score)\n";
						my $irot = Math::Matrix->new($rot)->inv->as_array;
						$pairs->{$a_i}->{$b_i} = [ [0,0,0], $rot, [
							- $anchor_beacon_b->[0] + $anchor_beacon_a->[0],
							- $anchor_beacon_b->[1] + $anchor_beacon_a->[1],
							- $anchor_beacon_b->[2] + $anchor_beacon_a->[2] ] ];
						$pairs->{$b_i}->{$a_i} = [ [
							 $anchor_beacon_b->[0] - $anchor_beacon_a->[0],
							 $anchor_beacon_b->[1] - $anchor_beacon_a->[1],
							 $anchor_beacon_b->[2] - $anchor_beacon_a->[2] ], $irot, [0,0,0] ];
						next B;
					}
				}}
			}

				
		}
	}
	last;
}


sub find_routes {
	my( $scan_id, $pairs, $route, $routes ) = @_;
	$routes->{$scan_id}=$route;
	foreach my $to_id ( keys %{$pairs->{$scan_id}} ) {
		next if( defined $routes->{$to_id} );
		
		find_routes( $to_id, $pairs, [[$to_id,$scan_id],@$route],  $routes ) ;
	}
}
my $scanner_by_id = {};
foreach my $scanner ( @$scanners ) { $scanner_by_id->{$scanner->{id}} = $scanner; }
my $routes = {};
find_routes( 0, $pairs, [], $routes );
my $beacons = {};

foreach my $id ( keys %$routes ) {
	my $scanner = $scanner_by_id->{$id};
	my $sbeacons = [ [0,0,0] ];
	my $route = $routes->{$id};
 	print "$id..";
	print "".(scalar @$sbeacons )." ";
	foreach my $r_id ( @$route ) {	
		print join( "=>", @$r_id);
		print " ";
		my( $tbefore, $rot, $tafter ) = @{$pairs->{$r_id->[1]}->{$r_id->[0]}};
		my $sbeacons2 = [];
		foreach my $beacon ( @$sbeacons ) {
			push @$sbeacons2, [ 
				$beacon->[0] + $tbefore->[0],
				$beacon->[1] + $tbefore->[1],
				$beacon->[2] + $tbefore->[2]
			];
		}
		my $sbeacons3 = matmult( $sbeacons2, $rot );
		my $sbeacons4 = [];
		foreach my $beacon ( @$sbeacons3 ) {
			push @$sbeacons4, [ 
				$beacon->[0] + $tafter->[0],
				$beacon->[1] + $tafter->[1],
				$beacon->[2] + $tafter->[2]
			];
		}

		$sbeacons = $sbeacons4;
	}
	print "\n";

	foreach my $beacon ( @$sbeacons ) {
		print ".";
		my $bid = join( ",", @$beacon );
		if( $beacons->{$bid} ) { 
			print "boink!\n";
		} else {
			$beacons->{$bid}=$beacon;
		}
	}
	print "\n";
}	

print Dumper ($beacons);
my @blist = values %$beacons;
my $max = 0;
for(my $i=0;$i<@blist;++$i) {
	for(my $j=0;$j<@blist;++$j) {
		next if $i==$j;
		my $bi = $blist[$i];
		my $bj = $blist[$j];
		my $mn = abs($bi->[0]-$bj->[0])+ abs($bi->[1]-$bj->[1])+abs($bi->[2]-$bj->[2]);
		if( $mn > $max ) { $max = $mn; }
	}
}

$n= $max;

############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

sub matmult {
	my( $a, @mults ) = @_;

	# just assume the sizes are OK
	
	while( @mults ) {
		my $b = shift( @mults );
		# error if the first one's width doesn't match the second one's height
		if( ref $a->[0] ne "ARRAY" ) { confess; }
		if( scalar @{$a->[0]} != scalar @$b ) {die "matrix mismatch"; }
		my $width = scalar @{$b->[0]};
		my $height = scalar @$a;
		my $joinsize = scalar @$b;
		my $result = [];
		
		for(my $y=0;$y<$height;++$y ) {
		for(my $x=0;$x<$width;++$x ) {
			my $t = 0;
			for(my $k=0;$k<$joinsize;++$k) {
				$t += $a->[$y]->[$k] * $b->[$k]->[$x];
			}
			$result->[$y]->[$x] = $t;
		}}
		$a = $result;
	}

	return $a;
}
			

sub printMatrix {
	my( $mat ) = @_;

	foreach my $row (@$mat ) {
		print "|";
		foreach my $val (@$row ) { print sprintf( " %3d", $val ); }
		print " |\n";
	}
}
