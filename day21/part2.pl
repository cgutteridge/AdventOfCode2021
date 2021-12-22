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

my $FREQ = { "3"=>"1", "4"=>"3", "5"=>"6", "6"=>"7", "7"=>"6", "8"=>"3", "9"=>"1" };
my $GOAL = 21;

my $start = [];
foreach my $row ( @rows ) {
	$row=~m/^Player (\d+) starting position: (\d+)$/;
	$start->[$1-1]=$2-1;
}



my $known = {};
my $results = resolve( [$start->[0],0],[$start->[1],0], 0 );

sub resolve {
	my( $p0, $p1, $togo ) = @_;

	# p0 and p1 are pos,score
	my $code = join( ",",join( ":",@$p0),join( ":",@$p1), $togo );
	if( defined $known->{$code} ) { return $known->{$code}; }

	# lets create some universes. 27 versions but
	my $wins=[0,0];
	foreach my $roll ( keys %$FREQ ) {
		my $pstate = [ [@$p0], [@$p1] ];
		$pstate->[$togo]->[0] += $roll;
		$pstate->[$togo]->[0] %= 10;
		$pstate->[$togo]->[1] += $pstate->[$togo]->[0]+1;
		my $uni_wins;
		if( $pstate->[$togo]->[1] >= $GOAL ) {
			if( $togo == 0 ) {
				$uni_wins = [1,0];
			} else {
				$uni_wins = [0,1];
			} 
		} else {
			$uni_wins = resolve( $pstate->[0], $pstate->[1], 1-$togo );
		}
		$wins->[0] += $uni_wins->[0]*$FREQ->{$roll};
		$wins->[1] += $uni_wins->[1]*$FREQ->{$roll};
	}
	$known->{$code} = $wins;
	return $wins;
}

my @results_ordered = sort {$a<=>$b} @$results;
$n=$results_ordered[1];


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART2 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

