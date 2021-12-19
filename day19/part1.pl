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

my $joinedup = [ shift @$scanners ];
my $found = {};
foreach my $beacon ( @{$joinedup->[0]->{b}} ) { $found->{join( ",",@$beacon)}=1;}

############################################################

my $rotx = [ [1, 0, 0],  [0, 0,-1], [ 0, 1, 0] ];
my $roty = [ [0, 0, 1],  [0, 1, 0], [-1, 0, 0] ];
my $rotz = [ [0,-1, 0],  [1, 0, 0], [ 0, 0, 1] ];

my $identity = [ [1,0,0],[0,1,0],[0,0,1] ];
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
foreach my $rot( @rots ) {
	#printMatrix( $rot ); print "\n";
}

############################################################


my $tested = {};
MAIN: while( scalar @$scanners ) {
	my $tries = 0;
	foreach my $jup_scanner ( @$joinedup ) {
print "JUP\n";
		# compare this with every non-joined scanner we've not already tried for it
		my $a_beacons = $jup_scanner->{b};

		my $a_beacon_lookup = {};
		foreach my $beacon ( @$a_beacons ) { $a_beacon_lookup->{join( ",",@$beacon)}=1;}
		#print Dumper( $a_beacon_lookup );

		FREE_SCANNER: for( my $i=0; $i<@$scanners; ++$i ) {
print "test scanner $i\n";
			my $free_scanner = $scanners->[$i];
			my $mcode = join( ":", sort(  $jup_scanner->{id}, $free_scanner->{id} ));
print "$mcode\n";
			if( $tested->{$mcode} ) {
				print "SKIP\n";
				next FREE_SCANNER;
			}
			$tested->{$mcode} = 1;

			# try rotating 
			foreach my $rot ( @rots ) {
#print "DIR\n";
				my $b_beacons = matmult( $free_scanner->{b}, $rot );
#				printMatrix( $b_beacons );
#				print "---\n";
				# try each beacon in B as if it were the first beacon in A

				foreach my $anchor_beacon ( @$b_beacons ) {
					my $score = 0;
					$tries++;

					# assume $anchor_beacon is beacon a[0], and see how many matches we get
					foreach my $beacon ( @$b_beacons ) {
						my $bid = join( ",",
							$beacon->[0] - $anchor_beacon->[0] + $a_beacons->[0]->[0],
							$beacon->[1] - $anchor_beacon->[1] + $a_beacons->[0]->[1],
							$beacon->[2] - $anchor_beacon->[2] + $a_beacons->[0]->[2],
						);
						if( $a_beacon_lookup->{$bid} ) { $score++; }
					}

					if( $score >= 12 ) {
						print "MATCH\n";
						my $modified_b = [];
						foreach my $beacon ( @$b_beacons ) {
							my $newb = [
								$beacon->[0] - $anchor_beacon->[0] + $a_beacons->[0]->[0],
								$beacon->[1] - $anchor_beacon->[1] + $a_beacons->[0]->[1],
								$beacon->[2] - $anchor_beacon->[2] + $a_beacons->[0]->[2],
							];
							my $bid = join( ",",@$newb);
							$found->{$bid}=1;
							push @{$modified_b}, $newb;
						}
						push @{$joinedup->[0]->{b}}, @$modified_b;
						#push @$joinedup, { id=>$free_scanner->{id}, b=>$modified_b };
						splice( @$scanners, $i, 1);
						next MAIN;
					}
				}
			}

				
		}
	}
	print "joined ".(scalar @$joinedup)."\n";
	die "no match ".(scalar @$scanners)." tries $tries\n";
}
$n = scalar keys %$found;
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
