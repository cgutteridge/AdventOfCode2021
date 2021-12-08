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

my $data = [];
foreach my $row ( @rows ) {
	my( $a, $b ) = split( / \| /, $row );
	push @$data, [ [ split( / /, $a )], [ split(  / /, $b ) ] ];
}

# segments used -> digit
# 2 - 1
# 3 - 7
# 4 - 4
# 5 - 2,3,5
# 6 - 0,6,9
# 7 - 8

my $n = 0;
foreach my $combo ( @$data ) {
	foreach my $digit ( @{$combo->[1]} ) {
		$n++ if( length( $digit ) == 2 );
		$n++ if( length( $digit ) == 3 );
		$n++ if( length( $digit ) == 4 );
		$n++ if( length( $digit ) == 7 );
	}
}

print sprintf( "PART 1 = %d\n", $n );
