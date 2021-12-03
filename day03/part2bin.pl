#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my @rows = readfile( "data" );
my $size = length $rows[0];
my $numbers = [];
foreach my $row ( @rows ) {
	my $n = 0;
	foreach( split //, $row ) { $n = $n*2+($_ eq "1"?1:0); }	
	push @$numbers, $n;
}
#print Dumper( $numbers );exit;

my $oxy = filter( $numbers, sub { my( $list0, $list1 ) = @_; if( scalar @$list1 >= scalar @$list0 ) { return 1 } else { return 0; }});
my $co2 = filter( $numbers, sub { my( $list0, $list1 ) = @_; if( scalar @$list1 >= scalar @$list0 ) { return 0 } else { return 1; }});
#print Dumper( $oxybits, $co2bits );
print "$oxy, $co2\n";

my $n = $oxy * $co2;
print "PART 2: $n\n";

exit;

sub filter {
	my( $list, $pick, $bit ) = @_;

	$bit = $size-1 unless defined $bit;

#	print "\nbit:$bit\n";
#	foreach my $l ( @$list ) {
#		print sprintf( "%${size}b\n", $l );
#	}

	return $list->[0] if( scalar @$list == 1);

	# make lists of all the numbers with 1 and 0 at this pos. 
	my @bybit = ( [], [] );
	# add up how many 1 bits
	my $mask = 1<<$bit;
	foreach my $number ( @$list ) {
		push @{$bybit[$number&$mask?1:0]}, $number;
	}


	no strict 'refs';
	my $choice = &$pick( @bybit );	
	use strict 'refs';

	return filter( $bybit[$choice], $pick, $bit-1 );
}

