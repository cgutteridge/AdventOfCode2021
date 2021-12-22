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

my $start = [];
foreach my $row ( @rows ) {
	$row=~m/^Player (\d+) starting position: (\d+)$/;
	$start->[$1-1]=$2-1;
}

my $d=0;

my $player = 0;
my $pos = [ @$start ]; # stores the offset NOT the score value so pos=1 => index=0
my $score = [0,0];
my $dice = 0;

print Dumper($pos);
my $rolls = 0;
while( 1 ) {
	my $roll = 0;
	$roll += $dice+1;
	$dice = ($dice+1)%100;
	$roll += $dice+1;
	$dice = ($dice+1)%100;
	$roll += $dice+1;
	$dice = ($dice+1)%100;
	$rolls+=3;

	$pos->[$player] = ( $pos->[$player]+$roll ) % 10;

	$score->[$player] += $pos->[$player]+1;
	print sprintf( "%d %d %d\n", $roll, $pos->[$player],$score->[$player] );

	if( $score->[$player] >= 1000 ) {
		my $other_player = ($player+1)%2;
		$n = $score->[$other_player]*$rolls;
		last;	
	}
		


	$player = ($player+1)%2;
}


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

