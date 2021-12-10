#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

my $SCORES = {
    ')'=> 3,
    ']'=> 57,
    '}'=> 1197,
    '>'=> 25137,
};

my $n=0;

ROW: foreach my $row ( @rows ) {
	print "\n$row\n";
	my @chars = split( //, $row );
	my @stack = ();
	foreach my $char ( @chars ) {
	#	print $char." ".join( "",@stack)."\n";
		if( $char eq "[" ) {
			push @stack, "]";
			next;
		} 
		if( $char eq "{" ) {
			push @stack, "}";
			next;
		} 
		if( $char eq "<" ) {
			push @stack, ">";
			next;
		} 
		if( $char eq "(" ) {
			push @stack, ")";
			next;
		} 
		if( $char eq $stack[-1] ) {
			pop @stack;
			next;
		}
		print "SYNTAX ERROR expected ".$stack[-1]." but found $char\n";
		$n += $SCORES->{$char};
		next ROW;
	}
	if( @stack ) { 
		print "INCOMPLETE\n";
		next ROW;
	}
	print "OK\n";	
}

print sprintf( "PART1 => %d\n", $n );
