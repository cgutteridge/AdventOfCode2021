#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my @rows = readfile( "data" );
my $commands = [];
foreach my $row ( @rows ) {
	push @$commands, [ split / /, $row ];
}

#print Dumper( $commands );

my $dir = { 
	up=>[0,-1],
	down=>[0,1],
	forward=>[1,0]
};
my $x=0;
my $d=0;
foreach my $cmd ( @$commands ) {
	my $vector = $dir->{$cmd->[0]};
	$x+= $vector->[0] * $cmd->[1];
	$d+= $vector->[1] * $cmd->[1];
	#print "($x,$d)\n";
}
my $n = $x*$d;
print "PART 1: $n\n";
