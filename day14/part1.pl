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

my $r1 = shift @rows;
my @p = split(//, $r1);
shift @rows;
my $t = {};
foreach my $row ( @rows ) {
	my( $k,$v ) = split( / -> /, $row );
	$t->{$k}=$v;
}
for(my $loop=1;$loop<=10;++$loop) {
	my @p2=($p[0]);
	for(my $i=1;$i<scalar @p;++$i) {
		my $k = $p[$i-1].$p[$i];
		push @p2, $t->{$k};
		push @p2, $p[$i];
	}
	#print join("",@p2);
	#print "\n";
	@p=@p2;
}	
my $s={};
foreach my $e ( @p ) { 
	$s->{$e}++;
}
foreach my $e ( sort keys %$s ) { print "$e => ".$s->{$e}."\n"; }
my $min;
my $min_e;
my $max;
my $max_e;
foreach my $e ( keys %$s ) {
	if( !defined $min || $s->{$e}<$min ) {
		$min = $s->{$e};
		$min_e = $e;
	}
	if( !defined $max || $s->{$e}>$max ) {
		$max = $s->{$e};
		$max_e = $e;
	}
}

$n = $max-$min;

############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################
