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
		print "\nHB LOOP needs to resolve: ".join( ",", sort keys %$unknown_digits )."\n";

		DIGIT: foreach my $digit ( keys %$unknown_digits ) {
			# looking and the output digits we've not yet got a mapping for
			my $code_could_be;
			ENCDIGIT: foreach my $encoded_digit ( @{$combo->{examples}} ) {
				next ENCDIGIT if( defined $known_digits->{$encoded_digit} );

				# is there a combination of allowed things in the $seg_map that gets us from  $encoded_digit to the codes required for $digit
				my $source = [ sort split( //, $encoded_digit ) ];
				my $target = [ sort keys %{$MAP_MAP->[$digit]} ];
				next ENCDIGIT if( scalar @$source != scalar @$target );
				print sprintf( "could %s map to %s?\n", join( ",", @$source),join( ",",@$target ));

				my $result = could_it_map( $source, $target, $seg_map );
				print "...".$result."\n";	
exit;
			}
		}
		exit;
	}

#xxx

}
	
exit;

sub could_it_map {
	my( $sources, $targets, $map ) = @_;
print "cim(".join( "", @$sources ).")(". join( "", @$targets ).")\n";
:q
	# if the lists are empty then they can map. yay.
	return 1 if scalar @$sources == 0;

	my $ok = 0;
	my @sources_tail = @$sources;
	my $sources_head = shift @sources_tail;

	# this matches if the head matches to anything AND the tail matches to the targets minus the thing the head matches to
	foreach my $source_segment ( sort keys %{ $map->{$sources_head}} ) {
		my $target_to_remove = $map->{$sources_head}->{$source_segment};
		my $sources2 = [];
		my $targets2 = [];
print "(".join( "", @$sources2 ).")(". join( "", @$targets2 ).")($source_segment )($target_to_remove )\n";
		foreach my $source ( @$sources ) { push @$sources2, $source  unless $source eq $source_segment; }
		foreach my $target ( @$targets ) { push @$targets2, $target  unless $target eq $target_to_remove; }
		if( could_it_map( $sources2, $targets2, $map ) ) {
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
