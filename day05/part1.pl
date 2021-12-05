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
	my @start = split(/,/, $start_text);
	my @end = split(/,/, $end_text);
	# convert to ints
	my $start_point = Point->new( @start );
	my $end_point = Point->new( @end );

	my $line = Line->new( $start_point, $end_point );
	print "* ".$line->text."\n";
	push @lines, $line;
}

my $grid = Grid->new;
foreach my $line ( @lines ) {
	if( $line->horizontal or $line->vertical ) { 
		foreach my $point ( $line->points ) {
			$grid->inc( $point );
		}
	}
}

$grid->draw if $file =~ m/^test/;

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

	$self->[$point->y]=[] if( !defined $self->[$point->y] );
	$self->[$point->y]->[$point->x]=0 if( !defined $self->[$point->y]->[$point->x] );
	$self->[$point->y]->[$point->x]++;
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

package Point;

sub new {
	my( $class, $x, $y ) = @_;

	return bless { x=>$x, y=>$y }, $class;
}

sub y { return $_[0]->{y}; }
sub x { return $_[0]->{x}; }

package Line;

sub new {
	my( $class, $start,$end ) = @_;

	my $self = { start=>$start, end=>$end};
	return bless $self, $class;
}

sub text {
	my( $self ) = @_;

	return sprintf( "(%d,%d)->(%d,%d)", 
		$self->{start}->x,
		$self->{start}->y,
		$self->{end}->x,
		$self->{end}->y );
}


sub vertical {
	my( $self ) = @_;

	return $self->{start}->x == $self->{end}->x;
}

sub horizontal {
	my( $self ) = @_;

	return $self->{start}->y == $self->{end}->y;
}

sub points {
	my( $self ) = @_;

	my @points = ();

	if( $self->vertical ) {
		my @ys = sort ( $self->{start}->y , $self->{end}->y );
		for( my $y = $ys[0]; $y<=$ys[1]; $y++ ) {
			push @points, Point->new( $self->{start}->x, $y );
		}
	} 
	elsif( $self->horizontal ) {
		my @xs = sort ( $self->{start}->x , $self->{end}->x );
		for( my $x = $xs[0]; $x<=$xs[1]; $x++ ) {
			push @points, Point->new( $x,$self->{start}->y );
		}
	} 
	else {
		die "not on the straight or level";
	}
	return @points;
}
	
