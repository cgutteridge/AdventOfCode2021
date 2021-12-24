#!/usr/bin/perl 

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
my $n=0;

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

#    inp a - Read an input value and write it to variable a.
#    add a b - Add the value of a to the value of b, then store the result in variable a.
#    mul a b - Multiply the value of a by the value of b, then store the result in variable a.
#    div a b - Divide the value of a by the value of b, truncate the result to an integer, then store the result in variable a. (Here, "truncate" means to round the value toward zero.)
#    mod a b - Divide the value of a by the value of b, then store the remainder in variable a. (This is also called the modulo operation.)
#    eql a b - If the value of a and b are equal, then store the value 1 in variable a. Otherwise, store the value 0 in variable a.

############################################################

my $prog = [];
foreach my $row ( @rows ) {
	my( @cmd ) = split( / /, $row );
	push @$prog,\@cmd;
}

print Dumper( $prog );
print "".(scalar @$prog)."\n";

for( 0..13 ) {
	print join( ",", $prog->[$_*18+4]->[2],  $prog->[$_*18+5]->[2],  $prog->[$_*18+15]->[2] )."\n";
}


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

