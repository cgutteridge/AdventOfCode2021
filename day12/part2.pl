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

my @routes = find_routes( $nodes, 'start', "", 1, (start=>1) );
foreach my $r ( @routes ) { print "$r\n"; }
my $n = scalar @routes;
print sprintf( "PART2 => %d\n", $n );
exit;

sub find_routes {
	my( $nodes, $pos, $route, $magic_pass, %visited ) = @_;

	if( $pos eq "end" ) {
		return( $route );
	}

	my @routes = ();
	foreach my $exit ( sort keys %{$nodes->{$pos}} ) {
		next if $exit eq "start"; # never do start twice	
		if( !$visited{$exit} || $magic_pass ) {
			my $mp = $magic_pass;
			my %v2 = %visited;
			if( $exit =~ m/^[a-z]+$/ ) { 
				# if we've already been to this lowercase cave, use up my magic pass
				if( $visited{$exit} ) {
					$mp = 0;
				}
				$v2{$exit}=1; 
			}
			my @routes2 = find_routes( $nodes, $exit, $pos.":".$route, $mp, %v2 );
			push @routes, @routes2;
		}	
	}
	return @routes;
}
