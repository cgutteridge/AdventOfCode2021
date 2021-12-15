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
my $p = {};
for(my $i=0;$i<length($r1)-1;$i++) {
	$p->{substr($r1,$i,2)}++;
}
my $first = substr($r1,0,1);
my $last = substr($r1,length($r1)-1,1);
print "F,L = $first,$last\n";

shift @rows;
my $t = {};
my $els = {};
foreach my $row ( @rows ) {
	my( $k,$v ) = split( / -> /, $row );
	$t->{$k}=[substr($k,0,1).$v,$v.substr($k,1,1)];
}


for(my $loop=1;$loop<=40;++$loop ) {
#print Dumper( $p );
	my $p2 = {};
	foreach my $pair ( keys %$p ) {
		my $pair2a = $t->{$pair}->[0];
		my $pair2b = $t->{$pair}->[1];
		$p2->{$pair2a}+=$p->{$pair};
		$p2->{$pair2b}+=$p->{$pair};
	}
	$p=$p2;

}

my $s={};
$s->{$first}+=0.5;
$s->{$last}+=0.5;
foreach my $pair ( keys %$p ) { 
	foreach my $e ( split ( //, $pair ) ) { $s->{$e}+=$p->{$pair}/2; }
}
foreach my $e ( sort keys %$s ) { print "$e => ".($s->{$e})."\n"; }
my $min;
my $min_e;
my $max;
my $max_e;
foreach my $e ( keys %$s ) {
	next if $e eq "_";
	if( !defined $min || $s->{$e}<$min ) {
		$min = $s->{$e};
		$min_e = $e;
	}
	if( !defined $max || $s->{$e}>$max ) {
		$max = $s->{$e};
		$max_e = $e;
	}
}
print "$min $min_e $max $max_e\n";
$n = $max-$min;

############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART2 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################
