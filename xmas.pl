use strict;
use warnings;

# read a file and return it as lines with the CR stripped
sub readfile {
	my( $filename ) = @_;

	open( my $fh, "<", $filename ) || die " can't read filename: $!";
	my @data = ();
	while( my $line = readline( $fh ) ) {
		chomp $line;
		push @data, $line;
	}
	return @data;
}


1;
		
