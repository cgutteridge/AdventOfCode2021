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
# 1 - ef
# 2 - acdeg
# 3 - acdfg
# 4 - bcdf
# 5 - abdfg
# 6 - abdefg
# 7 - acf
# 8 - abcdefg
# 9 - abcdfg

my @map = qw/ abcefg ef acdeg acdfg bcdf abdfg abdefg acf abcdefg abcdfg /;

# hash of segments in a display digit
my $MAP_MAP = [];
for(my $i=0;$i<@map;++$i ) {
	my $digit = $map[$i];
	foreach my $seg ( split( //, $digit ) ) {
		$MAP_MAP->[$i]->{$seg} = 1;
	}
}

foreach my $combo ( @$data ) {
	print Dumper( $combo );
	# maps the abc code to a digit 0-9
	my $known_digits = {};
	my $known_codes = {};
	my $unknown_digits = { 0=>1, 1=>1, 2=>1, 3=>1, 4=>1, 5=>1, 6=>1, 7=>1, 8=>1, 9=>1, };
	# maps input letters a-g to the location(s) they must be in output
	my $seg_map = {
		a => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		b => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		c => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		d => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		e => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		f => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
		g => { a=>1, b=>1, c=>1, d=>1, e=>1, f=>1, g=>1 },
	};
	
	# first do the easy ones§
	foreach my $encoded_digit ( @{$combo->{examples}} ) {
		my $encoded_digit_means = undef;
		$encoded_digit_means = 1 if( length($encoded_digit) == 2 ); 
		$encoded_digit_means = 4 if( length($encoded_digit) == 4 ); 
		$encoded_digit_means = 7 if( length($encoded_digit) == 3 ); 
		$encoded_digit_means = 8 if( length($encoded_digit) == 7 ); 

		next unless defined $encoded_digit_means;

		$known_digits->{$encoded_digit} = $encoded_digit_means;
		$known_codes->{$encoded_digit_means} = $encoded_digit_means;
		delete $unknown_digits->{$encoded_digit_means};
		remove_segments_from_map( $seg_map, $encoded_digit, $encoded_digit_means );

		print $encoded_digit." = $encoded_digit_means\n";
		print "segments_used_by_digit=".join( "", sort keys %{$MAP_MAP->[$encoded_digit_means]})."\n";

		print_seg_map( $seg_map );
	}
	# hard bit
	HARDBIT: while( %$unknown_digits ) {
		print "\nHB LOOP needs: ".join( ",", sort keys %$unknown_digits )."\n";

		# for each unmapped numher, see if it can only be one unmapped code, if so set it as that and repeat the hard bit until everything is known

		DIGIT: foreach my $digit ( keys %$unknown_digits ) {
			# try this digit  unknown codes only
			print " Considering: $digit\n";
			my $digit_could_by_encoded_as;
			ENCDIGIT: foreach my $encoded_digit ( @{$combo->{examples}} ) {
				next ENCDIGIT if( defined $known_digits->{$encoded_digit} );

				print "  Could be $encoded_digit?\n";
				# test to see if $encoded_digit could be $digit
				# first, check they have the same number of segments
				if( scalar keys %{$MAP_MAP->[$digit]} != length( $encoded_digit ) ) {
					print "  rejected on length\n";
					next ENCDIGIT;
				}

				# all an input segments must match to each required output segment
				# make a copy of the required segment map for $digit
				# all targets ($req) must have a source
				my $req = {%{$MAP_MAP->[$digit]}};
print "Required segments for $digit\n";
print Dumper( $req );
				foreach my $segment_in_input ( sort split( //, $encoded_digit ) ) {
					my @could_be_output_segment = sort keys %{$seg_map->{$segment_in_input}};
					foreach my $output_segment ( @could_be_output_segment ) {
#print "$segment_in_input could map to $output_segment\n";
						delete $req->{$output_segment };
					}
				}
				if( %$req ) {
					print "  rejected; missed requirements of segments : ".join( "", sort keys %$req )."\n";
					next ENCDIGIT;
				}
				# all output segments in the digit must match to at least one required input segment
				# all sources must have a target
				$req = {};
				foreach my $segment_in_input ( split( //, $encoded_digit )) { $req->{$segment_in_input} = 1; }
print "Required source codes for $encoded_digit\n";
print Dumper( $req );
				foreach my $segment_in_input ( sort split( //, $encoded_digit ) ) {
					my @could_be_output_segment = sort keys %{$seg_map->{$segment_in_input}};
					foreach my $output_segment ( @could_be_output_segment ) {
#print "$segment_in_input could map from $output_segment\n";
						delete $req->{$segment_in_input };
					}
				}
				if( %$req ) {
					print "  rejected; missed requirements of segments : ".join( "", sort keys %$req )."\n";
					next ENCDIGIT;
				}
				
	
				print "  $encoded_digit is a candidate\n";
				# ok it's a candidate
				if( defined $digit_could_by_encoded_as ) {
					# dang, more than one candidate, skip this code for later;
					print "  2+ canidates, trying next unknown encoded digit\n";
					next DIGIT;
				}
				$digit_could_by_encoded_as = $encoded_digit;
			}
			if( !defined $digit_could_by_encoded_as ) {
				die "No candidates found for $digit";
			}

			print "yay, single candidate for $digit is $digit_could_by_encoded_as\n";
			exit;
		}			

		# for each unmapped code, see if it can only be one number, if so set it as that and repeat the hard bit until everything is known

		my $encoded_digit_could_mean = {};
		ENCDIGIT: foreach my $encoded_digit ( @{$combo->{examples}} ) {
			next ENCDIGIT if( defined $known_digits->{$encoded_digit} );
			# try this code against unknown digits only
			print " Considering: $encoded_digit\n";

			DIGIT: foreach my $digit ( keys %$unknown_digits ) {
				print "  Could be $digit?\n";
				# test to see if $encoded_digit could be $digit
				# first, check they have the same number of segments
				if( scalar keys %{$MAP_MAP->[$digit]} != length( $encoded_digit ) ) {
					print "  rejected on length\n";
					next DIGIT;
				}
				# an input segment must match to each required output segment
				# make a copy of the required segment map for $digit
				my $req = {%{$MAP_MAP->[$digit]}};
				foreach my $segment_in_input ( split( //, $encoded_digit ) ) {
					my @could_be_output_segment = keys %{$seg_map->{$segment_in_input}};
					foreach my $output_segment ( @could_be_output_segment ) {
						delete $req->{$output_segment };
					}
				}
				if( %$req ) {
					print "  rejected; missed requirements of segments : ".join( "", sort keys %$req )."\n";
					next DIGIT;
				}
	
				print "  $digit is a candidate\n";
				# ok it's a candidate
#				if( defined $encoded_digit_could_mean ) {
#					# dang, more than one candidate, skip this code for later;
#					print "  2+ canidates, trying next unknown encoded digit\n";
#					next ENCDIGIT;
#				}
				$encoded_digit_could_mean->{$encoded_digit}->{$digit} = 1;
			}
			if( !defined $encoded_digit_could_mean ) {
				die "No candidates found for $encoded_digit";
			}

		}			

		print Dumper( $encoded_digit_could_mean );
		exit;

#xxx

	}	
	exit;
}
	
exit;

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
	print sprintf( "       %7s\n", $text->{a} );
	print sprintf( "%7s       %7s\n", $text->{b},$text->{c} );
	print sprintf( "       %7s\n", $text->{d} );
	print sprintf( "%7s       %7s\n", $text->{e},$text->{f} );
	print sprintf( "       %7s\n", $text->{g} );
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
