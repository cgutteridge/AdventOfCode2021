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
require "../xmas.pl";
my $t0 = [gettimeofday];
my $n=0;

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################


my $prog = [];
foreach my $row ( @rows ) {
	my( @cmd ) = split( / /, $row );
	push @$prog,\@cmd;
}


print "sub process {\n";
print "my \@input = \@_;\n";
print "\n";

#    inp a - Read an input value and write it to variable a.
#    add a b - Add the value of a to the value of b, then store the result in variable a.
#    mul a b - Multiply the value of a by the value of b, then store the result in variable a.
#    div a b - Divide the value of a by the value of b, truncate the result to an integer, then store the result in variable a. (Here, "truncate" means to round the value toward zero.)
#    mod a b - Divide the value of a by the value of b, then store the remainder in variable a. (This is also called the modulo operation.)
#    eql a b - If the value of a and b are equal, then store the value 1 in variable a. Otherwise, store the value 0 in variable a.

foreach my $cmd ( @$prog ) {
	my $a = $cmd->[1];
	my $b = $cmd->[2];
	$a = '$'.$a if $a =~ m/[a-z]/;
	if( $cmd->[0] eq "inp" ) {
		print sprintf( '%s = shift @input;'."\n", $a );
		next;
	}
	$b = '$'.$b if $b =~ m/[a-z]/;
	if( $cmd->[0] eq "add" ) { print sprintf( '%s = %s + %s;'."\n", $a,$a,$b ); }
	if( $cmd->[0] eq "mul" ) { print sprintf( '%s = %s * %s;'."\n", $a,$a,$b ); }
	if( $cmd->[0] eq "div" ) { print sprintf( '%s = int(%s / %s);'."\n", $a,$a,$b ); }
	if( $cmd->[0] eq "mod" ) { print sprintf( '%s = %s %% %s;'."\n", $a,$a,$b ); }
	if( $cmd->[0] eq "eql" ) { print sprintf( '%s = (%s == %s ? 1 : 0 );'."\n", $a,$a,$b ); }
}
print "return \$z;\n";
print "}\n\n1\n";


