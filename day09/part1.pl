#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

my $grid = [];
foreach my $row ( @rows ) {
	my $grow = [];
	foreach my $cell ( split( //, $row ) ) {
		push @$grow, $cell+0;
	}
	push @$grid,$grow;
}

my $width = scalar @{$grid->[0]}; # assume all rows are the same length
my $height = scalar @$grid;
print sprintf( "size => %d x %d\n", $width, $height );

my $n=0;
for(my $y=0;$y<$height;++$y) { 
	CELL: for(my $x=0;$x<$width;++$x) { 
		next CELL if( $x>0         && $grid->[$y]->[$x-1] <= $grid->[$y]->[$x] );
		next CELL if( $x<$width-1  && $grid->[$y]->[$x+1] <= $grid->[$y]->[$x] );
		next CELL if( $y>0         && $grid->[$y-1]->[$x] <= $grid->[$y]->[$x] );
		next CELL if( $y<$height-1 && $grid->[$y+1]->[$x] <= $grid->[$y]->[$x] );
		$n += 1 + $grid->[$y]->[$x];
		print sprintf( "min => %d,%d (%d)\n", $x, $y, $grid->[$y]->[$x] );
	}
}

print sprintf( "PART1 => %d\n", $n );
