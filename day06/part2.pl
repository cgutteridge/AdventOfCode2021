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
my @fish_days = (0,0,0,0,0,0,0,0,0);
my $n = scalar @fish;
foreach my $fish ( @fish ) {
	$fish_days[$fish]++;
}
for(my $day=1; $day<=256; ++$day ) {
	my $spawning = shift @fish_days;
	$n += $spawning;
	$fish_days[6]+=$spawning;
	$fish_days[8]+=$spawning;
	print sprintf( "Day %2d - %6d fish\n", $day, $n );
}

