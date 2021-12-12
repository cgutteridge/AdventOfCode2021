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

# Parse
my $nodes = {};
foreach my $row ( @rows ) {
	my( $from, $to ) =  split( /-/, $row );
	$nodes->{$from}->{$to}=1;
	$nodes->{$to}->{$from}=1;
}
#print Dumper( $nodes );

my @routes = find_routes( $nodes, 'start', "", (start=>1) );
my $n = scalar @routes;
print sprintf( "PART1 => %d\n", $n );
exit;

sub find_routes {
	my( $nodes, $pos, $route, %visited ) = @_;

	if( $pos eq "end" ) {
		return( $route );
	}

	my @routes = ();
	foreach my $exit ( sort keys %{$nodes->{$pos}} ) {
		if( !$visited{$exit} ) {
			my %v2 = %visited;
			if( $exit =~ m/^[a-z]+$/ ) { $v2{$exit}=1; }
			my @routes2 = find_routes( $nodes, $exit, $pos.":".$route, %v2 );
			push @routes, @routes2;
		}	
	}
	return @routes;
}
