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
my $els = {};
foreach my $row ( @rows ) {
	my( $k,$v ) = split( / -> /, $row );
	$t->{$k}=$v;
	$els->{substr($k,0,1)}=1;
	$els->{substr($k,1,1)}=1;
	$els->{$v}=1;
}
print Dumper( $els );
my $t2 = {};
#foreach my $e1 ( keys %$els ) { foreach my $e2 ( keys %$els ) { foreach my $e3 ( keys %$els ) { foreach my $e4 ( keys %$els ) { foreach my $e5 ( keys %$els ) { foreach my $e6 ( keys %$els ) { foreach my $e7 ( keys %$els ) { foreach my $e8 ( keys %$els ) { $t2->{$e1.$e2.$e3.$e4.$e5.$e6.$e7.$e8} = $e1.$t->{$e1.$e2}.$e2.$t->{$e2.$e3}.$e3.$t->{$e3.$e4}.$e4.$t->{$e4.$e5}.$e5.$t->{$e5.$e6}.$e6.$t->{$e6.$e7}.$e7.$t->{$e7.$e8}.$e8; }}}} }}}}
$els->{_}=1;
$t->{__}="_";
foreach my $e ( keys %$els ) { $t->{$e."_"}="_"; }
foreach my $e1 ( keys %$els ) {
foreach my $e2 ( keys %$els ) {
foreach my $e3 ( keys %$els ) {
foreach my $e4 ( keys %$els ) {
	my $k = $e1.$e2.$e3.$e4;
	if( $k=~m/_/ ) { next if $k=~m/_[A-Z]/; }
	$t2->{$k} = $e1.$t->{$e1.$e2}.$e2.$t->{$e2.$e3}.$e3.$t->{$e3.$e4}.$e4;
}}}}



for(my $loop=1;$loop<=21;++$loop) {
print $loop."\n";
print join( "",@p)."\n";
	while( $p[-1] eq "_" ) { pop @p; }
	push @p, "_","_","_";

	my @p2=();
	for(my $i=0;$i<scalar @p;$i+=3) {
		last if( $p[$i] eq "_" ); 
		my $k = $p[$i].$p[$i+1].$p[$i+2].$p[$i+3];
		my $v = $t2->{$k};
		if( $i!=0 ) { $v = substr( $v,1); } # strip the first element off all but the first result
		foreach my $e666 ( split ( //, $v ) ) { push @p2, $e666; }
	}
	@p=@p2;
}	
my $s={};
foreach my $e ( @p ) { 
	$s->{$e}++;
}
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
