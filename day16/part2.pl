#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );
require "../xmas.pl";
my $t0 = [gettimeofday];
my $n=0;

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

my @bits = ();
foreach my $hex ( split //, $rows[0] ) {
	my $bin = sprintf( "%04b", hex($hex) );
	for(my $i=0;$i<4;++$i) {
		push @bits, substr( $bin,$i,1)+0;
	}
}
#print join( "",@bits)."\n";

my( $struct, @tail ) = parse( @bits );

$n = solve( $struct );


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

sub bin {
	my $n = 0;
	foreach( @_ ) { 
		$n = $n*2+$_;
	}
	return $n;
}

# return op, remaining bits
sub parse {
	my( @bits ) = @_;

	die if !@bits;

	my $version = bin(splice(@bits,0,3));
	my $type = bin(splice(@bits,0,3));
	#print "v=$version t=$type\n";

	if( $type == 4 ) {
		# literal
		my @nbits=();
		while( $bits[0]==1 ) {
			my @block = splice(@bits,0,5);
			push @nbits,$block[1],$block[2],$block[3],$block[4];
		}
		my @block = splice(@bits,0,5);
		push @nbits,$block[1],$block[2],$block[3],$block[4];
		my $lit = bin( @nbits );
		#print "lit=$lit\n";	
		return ({ vsum=>$version,version=>$version, type=>"literal", value=>$lit}, @bits );
	}

	# operator
	my $ltype = shift @bits;

	my $packets = [];
	my $vsum = $version;
	if( $ltype == 0 ) {
		my $length = bin(splice(@bits,0,15));
		#print "Lbits=$length\n";
		my @subbits = splice(@bits,0,$length);
		while( @subbits ) {
			my( $packet, @tailbits ) = parse( @subbits );
			push @$packets, $packet;
			$vsum += $packet->{vsum};
			@subbits = @tailbits;
		}
	} else {
		my $npack = bin(splice(@bits,0,11));
		while( $npack ) {
		#print "npack=$npack\n";
			my( $packet, @tailbits ) = parse( @bits );
			push @$packets, $packet;
			$vsum += $packet->{vsum};
			@bits = @tailbits;
			$npack--;
		}
	}
	return( {vsum=>$vsum, version=>$version, type=>$type, packets=>$packets}, @bits );
		
	#print join( "",@bits)."\n";
	return {};
}

sub solve {
	my( $p ) = @_;

	if( $p->{type} eq "literal" ) { return $p->{value}; }

	if( $p->{type} == 0 ) {
		# sum
		my $n = 0;
		foreach my $sp ( @{$p->{packets}} ) {
			$n += solve($sp);
		}
		return $n;
	}

	if( $p->{type} == 1 ) {
		# product
		my $n = 1;
		foreach my $sp ( @{$p->{packets}} ) {
			$n *= solve($sp);
		}
		return $n;
	}

	if( $p->{type} == 2 ) {
		# min
		my $n;
		foreach my $sp ( @{$p->{packets}} ) {
			my $p = solve($sp);
			$n = $p if( !defined $n || $p<$n );
		}
		return $n;
	}

	if( $p->{type} == 3 ) {
		# max
		my $n;
		foreach my $sp ( @{$p->{packets}} ) {
			my $p = solve($sp);
			$n = $p if( !defined $n || $p>$n );
		}
		return $n;
	}

	die if 2!=@{$p->{packets}};
	my $a = solve($p->{packets}->[0]);
	my $b = solve($p->{packets}->[1]);

	if( $p->{type} == 5 ) {
		# greater
		return ( $a>$b ? 1 : 0 );
	}

	if( $p->{type} == 6 ) {
		# less
		return ( $a<$b ? 1 : 0 );
	}

	if( $p->{type} == 7 ) {
		# greater
		return ( $a==$b ? 1 : 0 );
	}

	die;
}
