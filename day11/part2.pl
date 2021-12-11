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
my $WIDTH = scalar @{$grid->[0]};
my $HEIGHT = scalar @$grid;

my $LOOPS = 100;
for( my $loop=1; 1;++$loop) {
	my $flashes_this_loop = 0;

	my @flashes = ();
	for(my $y=0;$y<$HEIGHT;++$y ) {
		for(my $x=0;$x<$WIDTH;++$x ) {
			$grid->[$y]->[$x]++;
			if( $grid->[$y]->[$x] > 9 ) {
				push @flashes,[$x,$y];
				$grid->[$y]->[$x] = 0; # stop getting added to by flashes this turn
			}
		}
	}
	while( my $flash = shift @flashes ) {
		$flashes_this_loop++;
		#print "\n";
		#print_grid($grid);
		#print "TODO:";
		#foreach my $f ( @flashes ) { print sprintf("[%d,%d]",$flash->[0],$flash->[1] );}
		#print "\n";
		#print sprintf( "FLASH (aaa aah) %d,%d\n", $flash->[0],$flash->[1] );
		for( my $yo=-1; $yo<=1; $yo++ ) {		
			for( my $xo=-1; $xo<=1; $xo++ ) {
				my $x2=$flash->[0]+$xo;
				my $y2=$flash->[1]+$yo;
				next if $x2<0;
				next if $x2>$WIDTH-1;
				next if $y2<0;
				next if $y2>$HEIGHT-1;
				if( $grid->[$y2]->[$x2] != 0 ) {
					$grid->[$y2]->[$x2]++;
					if( $grid->[$y2]->[$x2] > 9 ) {
						$grid->[$y2]->[$x2] = 0;
						push @flashes, [ $x2, $y2 ];
					}
				}
			}
		}
		#print "\n";
	}
		
	#print_grid($grid);
	if( $flashes_this_loop == $WIDTH*$HEIGHT ) { 
		print sprintf( "PART2 => %d\n", $loop );
		exit;
	}
}




exit;

sub print_grid
{
	my( $grid ) = @_;

	foreach my $row ( @$grid ) {
		print join( "", @$row )."\n";
	}
}
