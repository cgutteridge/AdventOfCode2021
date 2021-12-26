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


#
#!!! = 29914999975365
#!!! = 69914999975369
#!!! = 59914999975368
#!!! = 19914999975364
#!!! = 49914999975367
#!!! = 39914999975366




if(0) {
for my $a ( 0..9 ) {
for my $b ( 0..9 ) {
	my $d = "${a}991499997536${b}";
	my $p = process( 14, split( //, $d ));
	next unless $p==0;
	print "$d ... $a, $b -> $p\n";
}}
print "\n";
exit;
}



my $z_to_smallest = {};
for( my $digit=1; $digit<=9; ++$digit ) {
	my $z = process( 1, $digit );
	if( !defined $z_to_smallest->{$z} || $digit > $z_to_smallest->{$z} ) { 
		$z_to_smallest->{$z} = [$digit,[$digit]];
	}
}
print "-----\n";
my $min;
for( my $index=2;$index<=14;++$index ) {
	print "INDEX=$index ".(scalar keys %$z_to_smallest )."\n";
	my  $elapsed = tv_interval ( $t0, [gettimeofday]);
	print sprintf( "Elapsed time => %fs\n", $elapsed );
	my $new_z_to_smallest = {};
	PRE: foreach my $prefix ( values %$z_to_smallest ) {
		for( my $digit=9; $digit>=1; --$digit ) {
#print Dumper( $prefix );
#print join( ",", @{$prefix->[1]} )."+$digit\n";
			my $z = process( $index, @{$prefix->[1]}, $digit );
			my $v = $prefix->[0] * 10 + $digit;
			if( $index!=14 ) {
				if( !defined $new_z_to_smallest->{$z} || $v < $new_z_to_smallest->{$z}->[0] ) { 
					$new_z_to_smallest->{$z} = [ $v, [ @{$prefix->[1]}, $digit ] ];
				}	
			} 
			else {
				if( $z==0 ) { 
					print "!!! = $v\n";
					if( !defined $min || $v<$min ) { $min = $v; }
				}
			}
		}
	}
	$z_to_smallest = $new_z_to_smallest;
}
print "got to end: ".(scalar keys %$z_to_smallest )."\n";

print "$min\n";
