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

my $x=0;
my $d=0;
my $aim=0;
foreach my $cmd ( @$commands ) {
	if( $cmd->[0] eq "up" ) {
		$aim -= $cmd->[1];
	} 
	elsif( $cmd->[0] eq "down" ) {
		$aim += $cmd->[1];
	}
	elsif( $cmd->[0] eq "forward" ) {
		$x += $cmd->[1];
		$d += $aim * $cmd->[1];
	}
	else {
		die "Unexpected command";
	}
	#print "($x,$d)\n";
}
my $n = $x*$d;
print "PART 2: $n\n";
