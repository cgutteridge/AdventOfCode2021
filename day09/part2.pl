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

my $nadirs = [];
my $basin = [];
for(my $y=0;$y<$height;++$y) { 
	$basin->[$y] = [];
	CELL: for(my $x=0;$x<$width;++$x) { 
		$basin->[$y]->[$x] = -1;
		next CELL if( $x>0         && $grid->[$y]->[$x-1] <= $grid->[$y]->[$x] );
		next CELL if( $x<$width-1  && $grid->[$y]->[$x+1] <= $grid->[$y]->[$x] );
		next CELL if( $y>0         && $grid->[$y-1]->[$x] <= $grid->[$y]->[$x] );
		next CELL if( $y<$height-1 && $grid->[$y+1]->[$x] <= $grid->[$y]->[$x] );
		print sprintf( "min => %d,%d (%d)\n", $x, $y, $grid->[$y]->[$x] );
		$basin->[$y]->[$x] = scalar @$nadirs;
		push @$nadirs,[$x,$y];
	}
}
my $sizes = [];
for( my $nadir_index=0; $nadir_index<@$nadirs; ++$nadir_index ) {
	my $backlog = [ $nadirs->[$nadir_index] ];
	my $size = 1;
	#print "\n\nNEW INDEX => $nadir_index\n\n";
	# while we've not looked at the edges of everything in the known basin	
	while( @$backlog ) {
		#print "NEW LOOP for $nadir_index with BACKLOG\n";
		#foreach my $c ( @$backlog ) { print sprintf( "* %d,%d\n", $c->[0], $c->[1] ); }
		my $cell = shift @$backlog;
		my $dirs;
		push @$dirs,[-1,0] if( $cell->[0]>0 );
		push @$dirs,[1,0]  if( $cell->[0]<$width-1 );
		push @$dirs,[0,-1] if( $cell->[1]>0 );
		push @$dirs,[0,1]  if( $cell->[1]<$height-1 );
		foreach my $dir ( @$dirs ) {
			my $x = $cell->[0]+$dir->[0];
			my $y = $cell->[1]+$dir->[1];
			next if $basin->[$y]->[$x] == $nadir_index;
			if( $basin->[$y]->[$x] >= 0 ) {
				print_basin( $basin);
				print "$x,$y\n";
				print "ni => $nadir_index\n";
				print "basin($x,$y) => ".$basin->[$y]->[$x] ."\n";
				die;
			}
			next if $grid->[$y]->[$x] == 9;
			# found a peanut
			$basin->[$y]->[$x] = $nadir_index;
			push @$backlog, [$x,$y];
			$size++;
			#print "$nadir_index adding [$x,$y]\n";
		}
	}

	print "BASIN $nadir_index size $size\n";
	push @$sizes,$size;

}
my @largest_first = sort { $b <=> $a } @$sizes;
my $n = $largest_first[0] * $largest_first[1] * $largest_first[2];
print sprintf( "PART2 => %d\n", $n );
exit;

sub print_basin {
	my( $basin ) = @_;

	for(my $y=0;$y<$height;++$y) { 
		for(my $x=0;$x<$width;++$x) { 
			print sprintf( "%3d ",$basin->[$y]->[$x]);
		}
		print "\n";
	}
}
