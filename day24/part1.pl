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

# not 19914975421164
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
if(0) {
for my $a ( 1..9 ) {
for my $b ( 1..9 ) {
next if( $a==$b );
print "$a//$b\n";
my @base = ();
for(1..14){ push @base, $a ; }
push @base, $a;
my $control = process(@base);
for(1..14){
	my @d = @base;
	$d[$_] = $b;
	my $p = process(@d );
	if( $p ne $control ) { print "$a, $b, $_ -> $p\n";
}}
print "\n";
}}
exit;
}



my $z_to_largest = {};
for( my $digit=1; $digit<=9; ++$digit ) {
	my $z = process( 1, $digit );
	if( !defined $z_to_largest->{$z} || $digit > $z_to_largest->{$z} ) { 
		$z_to_largest->{$z} = [$digit,[$digit]];
	}
}
print "-----\n";
my $max;
for( my $index=2;$index<=14;++$index ) {
	print "INDEX=$index ".(scalar keys %$z_to_largest )."\n";
	my  $elapsed = tv_interval ( $t0, [gettimeofday]);
	print sprintf( "Elapsed time => %fs\n", $elapsed );
	my $new_z_to_largest = {};
	PRE: foreach my $prefix ( values %$z_to_largest ) {
		for( my $digit=9; $digit>=1; --$digit ) {
#print Dumper( $prefix );
#print join( ",", @{$prefix->[1]} )."+$digit\n";
			my $z = process( $index, @{$prefix->[1]}, $digit );
			my $v = $prefix->[0] * 10 + $digit;
			if( !defined $new_z_to_largest->{$z} || $v > $new_z_to_largest->{$z}->[0] ) { 
				$new_z_to_largest->{$z} = [ $v, [ @{$prefix->[1]}, $digit ] ];
			}
			if( $index==14 && $z==0 ) { 
				print "!!! = $v\n";
				if( !defined $max || $v>$max ) { $max = $v; }
			}
		}
	}
	$z_to_largest = $new_z_to_largest;
}
print "got to end: ".(scalar keys %$z_to_largest )."\n";

print "$max\n";
