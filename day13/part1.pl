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

my $dots = {};
my $WIDTH = 0;
my $HEIGHT = 0;
my $row = shift @rows;
while( $row ne "" ) {
	$dots->{$row} = 1;
	my( $x,$y ) = split( /,/, $row );
	$WIDTH=$x+1  if( $x+1>$WIDTH );
	$HEIGHT=$y+1 if( $y+1>$HEIGHT );
	$row = shift @rows;
}

my $folds = [];
foreach my $row ( @rows ) {
	$row =~ m/fold along ([xy])=(\d+)/;
	push @$folds, [$1,$2];
}
print Dumper($dots,$folds);
print "$WIDTH x $HEIGHT\n";

for( my $y=0;$y<$HEIGHT;++$y ) { for( my $x=0;$x<$WIDTH;++$x ) { if( $dots->{"$x,$y"} ) { print "#"; } else { print "."; } } print "\n"; }
print "\n";

foreach my $fold ( @$folds ) {
	my $newdots = {};
	foreach my $dot ( keys %$dots ) {
		my( $x,$y ) = split( /,/, $dot );
		if( $fold->[0] eq "x" ) {
			if( $x<$fold->[1] ) {
				$newdots->{"$x,$y"} = 1;
			}
			if( $x>$fold->[1] ) {
				$x = $fold->[1]*2-$x;
				$newdots->{"$x,$y"} = 1;
			}
		}
			
		if( $fold->[0] eq "y" ) {
			if( $y<$fold->[1] ) {
				$newdots->{"$x,$y"} = 1;
			}
			if( $y>$fold->[1] ) {
				$y = $fold->[1]*2-$y;
				$newdots->{"$x,$y"} = 1;
			}
		}
	}
	$dots = $newdots;
			
	if( $fold->[0] eq "x" ) {
		$WIDTH = $fold->[1];
	}
	if( $fold->[0] eq "y" ) {
		$HEIGHT = $fold->[1];
	}

	for( my $y=0;$y<$HEIGHT;++$y ) {
		for( my $x=0;$x<$WIDTH;++$x ) {
			if( $dots->{"$x,$y"} ) { 
				print "#";
			} else {
				print ".";
			}
		}
		print "\n";
	}
	$n = scalar keys %$dots;
	last;
}		


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################
