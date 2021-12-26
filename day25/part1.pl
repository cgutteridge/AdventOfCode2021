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

my $MAP = { ">"=>0, "v"=>1, "."=>2 };

my $movers = [ [], [] ];

my $grid = [];
my $y=0;
foreach my $row ( @rows ) {
	my $x=0;
	foreach my $cell ( split( //, $row ) ) {
		my $v = $MAP->{$cell};
		if( $MAP->{$cell} != 2 ) { 
			push @{$movers->[$v]}, [$x,$y]; 
			$grid->[$y]->[$x] = $v;
		}
		$x++;
	}
	$y++;
}
my $WIDTH = length( $rows[0] );
my $HEIGHT = @rows;

print "W=$WIDTH, H=$HEIGHT\n";
printGrid($grid);
#print Dumper( $movers );
############################################################

my $moved = 1;
my $loop = 0;
while( $moved ) {
	$moved = 0;
	$loop++;

	foreach my $dir ( 0..1 ) {
		my $new_grid = [];
		my $new_movers = [];
		foreach my $mover ( @{$movers->[1-$dir]} ) {
			my( $x,$y ) = @$mover;
			$new_grid->[$y]->[$x] = 1-$dir;
		}
		foreach my $mover ( @{$movers->[$dir]} ) {
			my( $x,$y ) = @$mover;
			my( $tx, $ty );
			if( $dir == 0 ) {
				($tx,$ty) = ( ($x+1)%$WIDTH, $y );
			} else {
				($tx,$ty) = ( $x,($y+1)%$HEIGHT );
			}
			if( !defined $grid->[$ty]->[$tx] ) {
				# can move
				$new_grid->[$ty]->[$tx] = $dir;
				push @{$new_movers}, [$tx,$ty];
				$moved = 1;
			} else {
				# can't move
				$new_grid->[$y]->[$x] = $dir;
				push @{$new_movers}, [$x,$y];
			}
		}
		$grid = $new_grid;
		$movers->[$dir] = $new_movers;
		print "LOOP=$loop DIR=$dir\n";
		printGrid($grid);
	}	

}

$n=$loop;



############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

sub printGrid {
	my( $grid ) = @_;

	my $MAP = [">","v"];
	for(my $y=0;$y<$HEIGHT;++$y ) {
		for(my $x=0;$x<$WIDTH;++$x ) {
			my $v = $grid->[$y]->[$x];
			if( defined $v ) {	
				print $MAP->[$v];
			} else {
				print ".";
			}
		}	
		print "\n";	
	}
	print "\n";	
}



