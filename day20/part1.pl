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

my $enhance_string = "";
while(my $row=shift @rows ) {
	last if $row eq "";
	$enhance_string .= $row;
}

my @enhance=();
foreach my $char ( split( //, $enhance_string ) ) {
	if( $char eq '#' ) {
		push @enhance,1;
	} else {
		push @enhance,0;
	} 
}

my $grid = [];
foreach my $row ( @rows ) {
	my $grid_row = [];
	foreach my $char ( split( //, $row ) ) {
		if( $char eq '#' ) {
			push @$grid_row, 1;
		} else {
			push @$grid_row, 0;
		} 
	}
	push @$grid, $grid_row;
}

printGrid($grid);

# enhance
my $void = 0;
for(1..2) {
	my $H=(scalar @$grid);
	my $W=(scalar @{$grid->[0]});
	my $H2=$H+2;
	my $W2=$W+2;
	my $ngrid = [];
	for(my $y=0; $y<$H2; ++$y ) {
		my $nrow = [];
		for(my $x=0; $x<$W2; ++$x ) {
			my $v = 0;
			for( my $yi=$y-2;$yi<=$y;$yi++ ) {
				for( my $xi=$x-2;$xi<=$x;$xi++ ) {
					$v*=2;
					if( $yi>=0 && $yi<$W && $xi>=0 && $xi<$H ) {
						# known space
						$v+= $grid->[$yi]->[$xi];
					} else {
						# void
						$v+= $void;
					}
				}
			}
			push @$nrow, $enhance[$v];
		}
		push @$ngrid,$nrow;
	}
	if( $void == 0 ) {
		$void = $enhance[0];
	} else {
		$void = $enhance[511];
	}

	printGrid( $ngrid);
	$grid = $ngrid;
}	

	
foreach my $row ( @$grid ) {
	foreach my $cell ( @$row ) {
		$n+= $cell;
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

sub printGrid {
	my( $grid ) = @_;

	foreach my $row ( @$grid ) {
		foreach my $cell ( @$row ) {
			print ( $cell ? "#" : "." );
		}	
		print "\n";	
	}
	print "\n";	
}



