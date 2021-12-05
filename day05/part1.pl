#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );
# end xmas boilerplate



my @lines = ();
foreach my $row ( @rows ) { 
	my( $start_text, $end_text ) = split( / -> /, $row );
	my $start = [split(/,/, $start_text)];
	my $end = [split(/,/, $end_text)];
	# convert to ints
	$start->[0]+=0;
	$start->[1]+=0;
	$end->[0]+=0;
	$end->[1]+=0;
	push @lines, Line->new( $start, $end );
}

my $grid = Grid->new;
foreach my $line ( @lines ) {
	if( $line->horizontal or $line->vertical ) { 
		foreach my $point ( $line->points ) {
			$grid->inc( $point );
		}
	}
}

$grid->draw if $file eq "test";

my $n = $grid->overlapping_points;

print sprintf( "PART 1 (%s) = %d\n", $file, $n );
exit;


package Grid;

sub new {
	my( $class ) = @_;

	return bless [], $class;
}

sub overlapping_points {
	my( $self ) = @_;

	my $n = 0;
	foreach my $grid_row ( @$self ) {
		next if !defined $grid_row;
		foreach my $cell ( @$grid_row ) {
			$n++ if defined $cell && $cell > 1;
		}
	}
	return $n;
}

sub inc {
	my( $self, $point ) = @_;

	$self->[$point->[1]]=[] if( !defined $self->[$point->[1]] );
	$self->[$point->[1]]->[$point->[0]]=0 if( !defined $self->[$point->[1]]->[$point->[0]] );
	$self->[$point->[1]]->[$point->[0]]++;
}

sub draw {
	my( $self ) = @_;

	foreach my $grid_row ( @$self ) {
		if( !defined $grid_row ) {
			print "...\n" ;
			next;
		}
		foreach my $cell ( @$grid_row ) {
			if( !defined $cell ) {
				print ".";
			} else {
				print "$cell";
			}
		}
		print "\n";
	}
}

package Line;

sub new {
	my( $class, $start,$end ) = @_;

	my $self = { start=>$start, end=>$end};
	return bless $self, $class;
}

sub vertical {
	my( $self ) = @_;

	return $self->{start}->[0] == $self->{end}->[0];
}

sub horizontal {
	my( $self ) = @_;

	return $self->{start}->[1] == $self->{end}->[1];
}

sub points {
	my( $self ) = @_;

	my @points = ();

	if( $self->vertical ) {
		my @ys = sort ( $self->{start}->[1] , $self->{end}->[1] );
		for( my $y = $ys[0]; $y<=$ys[1]; $y++ ) {
			push @points, [ $self->{start}->[0], $y ];
		}
	} 
	elsif( $self->horizontal ) {
		my @xs = sort ( $self->{start}->[0] , $self->{end}->[0] );
		for( my $x = $xs[0]; $x<=$xs[1]; $x++ ) {
			push @points, [ $x,$self->{start}->[1] ];
		}
	} 
	else {
		die "not on the straight or level";
	}
	return @points;
}
	
