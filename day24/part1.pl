#!/usr/bin/perl -I.

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );
use POSIX;
use Carp qw/ confess /;
use Math::Matrix;
require "../xmas.pl";
my $t0 = [gettimeofday];
my $next_report = time()+1;
my $n=0;


############################################################
# End of boilerplate
############################################################

require "compiled.pl";
# 1, 10,13
# 1, 13,10
# 1, 13,3

#26,-11,1
# 1, 11,9
#26,-4 ,3

# 1, 12,5
# 1, 12,1
# 1, 15,0

#26,-2 ,13
#26,-5 ,7
#26,-11,15
#26,-13,12
#26,-10,8
if( 0 ) {
print process( split //,"55555555555555" )."\n";
exit;
print "\n";
print process( split //,"15555555555555" )."\n";
print process( split //,"51555555555555" )."\n";
print process( split //,"55155555555555" )."\n";
print process( split //,"55515555555555" )."\n";
print process( split //,"55551555555555" )."\n";
print process( split //,"55555155555555" )."\n";
print process( split //,"55555515555555" )."\n";
print process( split //,"55555551555555" )."\n";
print process( split //,"55555555155555" )."\n";
print process( split //,"55555555515555" )."\n";
print process( split //,"55555555551555" )."\n";
print process( split //,"55555555555155" )."\n";
print process( split //,"55555555555515" )."\n";
print process( split //,"55555555555551" )."\n";
exit;
}



my $z_to_largest = {};
for( my $digit=1; $digit<=9; ++$digit ) {
	my $z = process( 1, $digit );
	if( !defined $z_to_largest->{$z} || $digit > $z_to_largest->{$z} ) { 
		$z_to_largest->{$z} = [ [$digit,[$digit]] ];
	}
}
for( my $index=2;$index<=14;++$index ) {
	print "INDEX=$index ".(scalar keys %$z_to_largest )."\n";
	my  $elapsed = tv_interval ( $t0, [gettimeofday]);
	print sprintf( "Elapsed time => %fs\n", $elapsed );
	my $new_z_to_largest = {};
	PRE: foreach my $prefix ( values %$z_to_largest ) {
		for( my $digit=1; $digit<=9; ++$digit ) {
			my $z = process( $index, @{$prefix->[1]}, $digit );
			my $v = $prefix->[0] * 10 + $digit;
			if( !defined $new_z_to_largest->{$z} || $v > $new_z_to_largest->{$z} ) { 
				$new_z_to_largest->{$z} = [ $v, [ @{$prefix->[1]}, $digit ] ];
			}
			if( $index==14 && $z==0 ) { 
				print "!!! = $v\n";
				exit;	
			}
		}
	}
	$z_to_largest = $new_z_to_largest;
}
print "got to end: ".(scalar keys %$z_to_largest )."\n";

exit;








#6940187212
#4860946412
#fixed
#4780975612
#fixed
#4777899812
#4777781512
#4777776962
#fixed
#fixed
#fixed
#fixed
#fixed
#4777776787
my $scores = {};
my $total = 0;
for(my $a=9;$a>=1;$a--) {
for(my $b=9;$b>=1;$b--) {
for(my $c=9;$c>=1;$c--) {
for(my $d=9;$d>=1;$d--) {
for(my $e=9;$e>=1;$e--) {
for(my $f=9;$f>=1;$f--) {
for(my $g=9;$g>=1;$g--) {
	my @digits = ($a,$b,$c,$d,$e,$f,$g);
	my $p = process( @digits );
	$scores->{$p}++;
	$total++;
	#print join( "", @digits )." .. $p\n";
	if( time > $next_report ) {
		$next_report = time+1;
		print scalar( keys %$scores )." / $total\n";;
	}
}}}}}}}
print scalar( keys %$scores )." / $total\n";;
exit;

my $lowest ;
for(my $a=9;$a>=1;$a--) {
for(my $b=9;$b>=1;$b--) {
for(my $c=9;$c>=1;$c--) {
for(my $d=9;$d>=1;$d--) {
for(my $e=9;$e>=1;$e--) {
for(my $f=9;$f>=1;$f--) {
for(my $g=9;$g>=1;$g--) {
	my @digits = ( $a,$b,9,$c,9,$d,$e,$f,9,9,9,9,9,$g );
	my $p = process( 7, @digits );
	if(!defined $lowest || $p < $lowest ) {
		print "$p\n";
		$lowest=$p;
	}
	if( 0==$p ) {
		print join( "",@digits )."\n";
	}
	if( time > $next_report ) {
		$next_report = time+1;
		print "".join( "",@digits )." .. $p\n";
	}
}}}}}}}

