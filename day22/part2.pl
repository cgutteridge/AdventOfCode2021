#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );
use POSIX;
require "../xmas.pl";
my $t0 = [gettimeofday];
my $n=0;

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

my $set = {};
my $rules = [];
#on x=-30..22,y=-28..20,z=-17..37
foreach my $row ( @rows ) {
	my $rule = {};
	$row =~ m/^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$/;
	( $rule->{mode}, $rule->{x}->{min}, $rule->{x}->{max}, $rule->{y}->{min}, $rule->{y}->{max}, $rule->{z}->{min}, $rule->{z}->{max} ) = ( $1,$2,$3,$4,$5,$6,$7 );
	push @$rules,$rule;
}
foreach my $rule ( @$rules ) {
print Dumper( $rule);
	for(my $z=$rule->{z}->{min};$z<=$rule->{z}->{max};++$z) {
		next if( abs($z)>50);
		print "z=$z\n";
		for(my $y=$rule->{y}->{min};$y<=$rule->{y}->{max};++$y) {
			next if( abs($y)>50);
			for(my $x=$rule->{x}->{min};$x<=$rule->{x}->{max};++$x) {
				next if( abs($x)>50);
				if( $rule->{mode} eq "off" ) {
					delete $set->{"$x,$y,$z"};
				} else {
					$set->{"$x,$y,$z"}=1;
				}
			}
		}
	}
}	
$n = scalar keys %$set;


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

