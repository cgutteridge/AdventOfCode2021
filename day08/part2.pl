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
	my $combo = { examples=>[], code=>[] };
	my( $examples, $codes ) = split( / \| /, $row );
	foreach my $example ( split( / /, $examples ) ) {
		push @{$combo->{examples}}, join( '', sort split( //, $example));
	}
	foreach my $code ( split( / /, $codes ) ) {
		push @{$combo->{code}}, join( '', sort split( //, $code));
	}

	push @$data, $combo;
}
#print Dumper( $data );

#   0:      1:      2:      3:      4:
#  aaaa    ....    aaaa    aaaa    ....
# b    c  .    c  .    c  .    c  b    c
# b    c  .    c  .    c  .    c  b    c
#  ....    ....    dddd    dddd    dddd
# e    f  .    f  e    .  .    f  .    f
# e    f  .    f  e    .  .    f  .    f
#  gggg    ....    gggg    gggg    ....
# 
#   5:      6:      7:      8:      9:
#  aaaa    aaaa    aaaa    aaaa    aaaa
# b    .  b    .  .    c  b    c  b    c
# b    .  b    .  .    c  b    c  b    c
#  dddd    dddd    ....    dddd    dddd
# .    f  e    f  .    f  e    f  .    f
# .    f  e    f  .    f  e    f  .    f
# gggg    gggg    ....    gggg    gggg


# 0 - abcefg
# 1 - cf
# 2 - acdeg
# 3 - acdfg
# 4 - bcdf
# 5 - abdfg
# 6 - abdefg
# 7 - acf
# 8 - abcdefg
# 9 - abcdfg

my @digit_sections = qw/ abcefg cf acdeg acdfg bcdf abdfg abdefg acf abcdefg abcdfg /;

# hash of segments in a display digit
my $MAP_MAP = [];
for(my $i=0;$i<@digit_sections;++$i ) {
	my $digit = $digit_sections[$i];
	foreach my $seg ( split( //, $digit ) ) {
		$MAP_MAP->[$i]->{$seg} = 1;
	}
}
my $n = 0;
foreach my $combo ( @$data ) {
	#print Dumper( $combo );
	# maps the abc code to a digit 0-9
	my $known_digits = {};
	my $unknown_codes = {};
	my $unknown_digits = { 0=>1, 1=>1, 2=>1, 3=>1, 4=>1, 5=>1, 6=>1, 7=>1, 8=>1, 9=>1, };
	# maps input wire letters a-g to the segment locations(s) they must be in output
	my $seg_map = {
		a => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		b => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		c => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		d => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		e => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		f => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		g => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
	};
	
	foreach my $encoded_digit ( @{$combo->{examples}} ) {
		$unknown_codes->{$encoded_digit} = 1;	
	}

	#print "STARTING MAP\n";
	#print_seg_map( $seg_map );

	# first do the easy ones
	foreach my $encoded_digit ( @{$combo->{examples}} ) {
		my $encoded_digit_means = undef;
		$encoded_digit_means = 1 if( length($encoded_digit) == 2 ); 
		$encoded_digit_means = 4 if( length($encoded_digit) == 4 ); 
		$encoded_digit_means = 7 if( length($encoded_digit) == 3 ); 
		$encoded_digit_means = 8 if( length($encoded_digit) == 7 ); 

		next unless defined $encoded_digit_means;

		$known_digits->{$encoded_digit} = $encoded_digit_means;
		delete $unknown_digits->{$encoded_digit_means};
		delete $unknown_codes->{$encoded_digit};
	
		remove_segments_from_map( $seg_map, $encoded_digit, $encoded_digit_means );

		#print $encoded_digit." = $encoded_digit_means\n";
		#print "segments_used_by_digit=".join( "", sort keys %{$MAP_MAP->[$encoded_digit_means]})."\n";

		#print_seg_map( $seg_map );
	}
	# hard bit


	my $sol = legal_mapping(  [sort keys %$unknown_codes],  [sort keys %$unknown_digits] , $seg_map );
	$sol =~ s/=>/,/g;
	$sol =~ s/,OK//g;
	my %solhash = split( /,/,$sol );	
	foreach my $code ( keys %solhash ) { $known_digits->{$code} = $solhash{$code}; }

	my $v = "";
	foreach my $code ( @{$combo->{code}} ) {
		#print "$code => ".$known_digits->{$code}."\n";
		$v .= $known_digits->{$code};
	}
	print "$v\n";

	$n+=$v;


}
print sprintf( "PART 2 = %d\n", $n );	
exit;

sub legal_mapping {
	my( $codes, $digits, $map, $depth ) = @_;

	$depth = 0 if !defined $depth;
#print "    "x$depth;
#print "legal_mapping( $depth, ".join( " ",@$codes ).", ".join( " ",@$digits ).")\n";
#print_seg_map( $map );


	if( scalar @$codes == 0 ) { return "OK"; }

	my $codes2 = [ @$codes ];
	my $code = shift @$codes2;

	my @solutions = ();

	# i is offset in digits we'll try mapping code to
	DIGIT: foreach my $digit ( @$digits ) {

		if( length($code) != length( $digit_sections[$digit] ) ) {
			next DIGIT;
		}
		#print "    "x$depth;
		#print "Considering $code=>$digit\n";
		#print "    "x$depth;
		#print "$digit has sections ".join( "", sort keys %{$MAP_MAP->[$digit]} )."\n";
		
		# can all the source wires could map to at least one segment in the digit
		my @wires = split( //, $code );
		foreach my $wire ( @wires ) {
			my $ok = 0;
			#print "    "x$depth;
			#print "Wire $wire can map to section ".join( "", sort keys %{$map->{$wire}} )."\n";
		
			SECTION: foreach my $section ( keys %{$map->{$wire}} ) {
				if( defined $MAP_MAP->[$digit]->{$section} ) { 
					$ok = 1;
					last SECTION;
				}
			}
			if( !$ok ) { 
				#print "    "x$depth;
				#print "wire $wire can't match up\n";
				next DIGIT;
			}
			#print "    "x$depth;
			#print "wire $wire ok\n";
		}

		my $digits2 = [];
		foreach my $digit_i ( @$digits ) {
			push @$digits2, $digit_i unless $digit == $digit_i;
		}
		my $newmap = {};
		foreach my $wire ( keys %$map ) {
			foreach my $segment ( keys %{$map->{$wire}} ) {
				$newmap->{$wire}->{$segment} = 1;
			}
		}

		remove_segments_from_map( $newmap, $code, $digit );

		my $res = legal_mapping( $codes2, $digits2, $newmap, $depth+1 );
		if( defined $res ) {
			push @solutions, "$code=>$digit,$res";
		}
	}

	#print "    "x$depth;
	#print "D$depth solutions= ".(scalar @solutions )."\n";
	if( @solutions == 1 ) {
		return $solutions[0];
	}
	if( @solutions > 1 )  {
		die "multiple solutions";
	}
	return undef;
}

sub could_it_map {
	my( $sources, $targets, $map, $desc ) = @_;
#print "cim...[$desc] (".join( "", @$sources ).")(". join( "", @$targets ).")\n";
	# if the lists are empty then they can map. yay.
	return 1 if scalar @$sources == 0;

	my $ok = 0;
	my @sources_tail = @$sources;
	my $sources_head = shift @sources_tail;

	# this function matches if the head matches to something AND the tail matches to the targets minus the thing the head matches to

	# loop over each thing the head matches to( or nothing)
	foreach my $target_for_head ( sort keys %{ $map->{$sources_head}} ) {
		my $targets2 = [];
#print "(".join( "", @$sources2 ).")(". join( "", @$targets2 ).")($sources_head )($target_for_head )\n";
		foreach my $target ( @$targets ) { push @$targets2, $target  unless $target eq $target_for_head; }
		if( could_it_map( \@sources_tail, $targets2, $map, $desc.",$sources_head=>$target_for_head" ) ) {
			return 1;
		}
	}
	return 0;
}



sub print_seg_map {
	my( $seg_map ) = @_;

	my $could_be = {};
	foreach my $segment_in_input ( sort keys %{$seg_map} ) {
		foreach my $segment_in_output ( sort keys %{$seg_map->{$segment_in_input}} ) {
			$could_be->{$segment_in_output}->{$segment_in_input}=1;
		}
	}
	my $text = {};
	foreach my $segment_in_output ( keys %{$could_be} ) {
		$text->{$segment_in_output} = join( "", sort keys %{$could_be->{$segment_in_output}} );
	}
	print "\n";
	print sprintf( "       %7s\n", $text->{a} );
	print sprintf( "%7s       %7s\n", $text->{b},$text->{c} );
	print sprintf( "       %7s\n", $text->{d} );
	print sprintf( "%7s       %7s\n", $text->{e},$text->{f} );
	print sprintf( "       %7s\n", $text->{g} );
	print "\n";
}

sub print_seg_map2 {
	my( $seg_map ) = @_;

	foreach my $segment_in_input ( sort keys %{$seg_map} ) {
		print "$segment_in_input: ";
		foreach my $segment_in_output ( sort keys %{$seg_map->{$segment_in_input}} ) {
			print $segment_in_output;
		}
		print "\n";
	}
	print "\n";
}

sub remove_segments_from_map {
	my( $seg_map, $encoded_digit, $encoded_digit_means ) = @_;
	# remove segments from the map that we know are not true as they are not used by this digit
	my @segments_used_by_encoded_digit = keys %{$MAP_MAP->[$encoded_digit_means]};
	foreach my $segment_in_input ( split( //, $encoded_digit ) ) {
		foreach my $segment_in_output ( keys %{$seg_map->{$segment_in_input}} ) {
			if( !defined $MAP_MAP->[$encoded_digit_means]->{$segment_in_output} ) {
				delete $seg_map->{$segment_in_input}->{$segment_in_output};
			}
		}
	}
}
