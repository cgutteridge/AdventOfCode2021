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

my @fish = split( /,/, $rows[0] );

for(my $day=1; $day<=80; ++$day ) {
	my @new_fish = ();
	for( my $i=0;$i<scalar @fish;++$i ) {
		$fish[$i]--;
		if( $fish[$i] == -1 ) {
			$fish[$i]=6;
			push @new_fish, 8;
		}
	}
	push @fish, @new_fish;
	##print sprintf( "Day %2d - %6d fish: %s\n", $day, scalar @fish, join( ",", @fish ));
	print sprintf( "Day %2d - %6d fish\n", $day, scalar @fish );
}

