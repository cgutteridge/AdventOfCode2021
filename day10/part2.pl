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
    ')'=> 1,
    ']'=> 2,
    '}'=> 3,
    '>'=> 4,
};

my @scoreslist = ();

ROW: foreach my $row ( @rows ) {
	print "\n$row\n";
	my @chars = split( //, $row );
	my @stack = ();
	foreach my $char ( @chars ) {
	#	print $char." ".join( "",@stack)."\n";
		if( $char eq "[" ) { push @stack, "]"; next; } 
		if( $char eq "{" ) { push @stack, "}"; next; } 
		if( $char eq "<" ) { push @stack, ">"; next; } 
		if( $char eq "(" ) { push @stack, ")"; next; } 
		if( $char eq $stack[-1] ) { pop @stack; next; }
		#print "SYNTAX ERROR expected ".$stack[-1]." but found $char\n";
		next ROW;
	}
	if( @stack ) { 
		my $score = 0;
		while( @stack ) {
			my $c = pop @stack;
			$score = $score*5 + $SCORES->{$c};
		}
		print "INCOMPLETE. Score=$score\n";
		push @scoreslist, $score;
		next ROW;
	}
	print "OK\n";	
}
@scoreslist=sort { $a<=>$b }  @scoreslist;
my $mid = (scalar @scoreslist-1)/2;
my $n=$scoreslist[$mid];
print sprintf( "PART2 => %d\n", $n );
