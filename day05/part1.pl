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

my @lines = ();
foreach my $row ( @rows ) { 
	my( $start_text, $end_text ) = split( / -> /, $row );
	my @start = split(/,/, $start_text);
	my @end = split(/,/, $end_text);
	# convert to ints
	my $start_point = Point->new( @start );
	my $end_point = Point->new( @end );

	my $line = Line->new( $start_point, $end_point );
	push @lines, $line;
}

my $grid = Grid->new;
foreach my $line ( @lines ) {
	if( $line->horizontal || $line->vertical ) { 
		#print "* ".$line->text." -> ";
		#print "p=".(scalar $line->points )." ";
		foreach my $point ( $line->points ) {
			$grid->inc( $point );
		}
	}
}
$grid->draw if $file =~ m/^test/;

my $n = $grid->overlapping_points;

print sprintf( "PART 1 (%s) = %d\n", $file, $n );
exit;

############################################################

package Grid;

sub new {
	my( $class ) = @_;

	return bless { grid=>[], width=>0, height=>0 }, $class;
}

sub overlapping_points {
	my( $self ) = @_;

	my $n = 0;
	for( my $y=0;$y<$self->{height};$y++ ) {
		for( my $x=0;$x<$self->{width};$x++ ) {
			if( defined $self->{grid}->[$y] ) {
				my $cell = $self->{grid}->[$y]->[$x];
				$n++ if defined $cell && $cell > 1;
			}
		}
	}
	return $n;
}

sub inc {
	my( $self, $point ) = @_;

	$self->{grid}->[$point->y]=[] if( !defined $self->{grid}->[$point->y] );
	$self->{grid}->[$point->y]->[$point->x]=0 if( !defined $self->{grid}->[$point->y]->[$point->x] );
	$self->{grid}->[$point->y]->[$point->x]++;
	$self->{height} = $point->y+1 if( $point->y+1>$self->{height} );
	$self->{width}  = $point->x+1 if( $point->x+1>$self->{width} );
}

sub draw {
	my( $self ) = @_;

	for( my $y=0;$y<$self->{height};$y++ ) {
		for( my $x=0;$x<$self->{width};$x++ ) {
			my $cell = $self->{grid}->[$y]->[$x];
			if( !defined $cell ) {
				print ".";
			} else {
				print "$cell";
			}
		}
		print "\n";
	}
}

sub print_cells {
	my( $self ) = @_;

	for( my $y=0;$y<$self->{height};$y++ ) {
		for( my $x=0;$x<$self->{width};$x++ ) {
			my $cell = $self->{grid}->[$y]->[$x];
			if( !defined $cell ) {
				print ".";
			} else {
				print "$cell";
			}
			print "\n";
		}
		print "\n";
	}
}



############################################################

package Point;

sub new {
	my( $class, $x, $y ) = @_;

	return bless { x=>$x+0, y=>$y+0 }, $class;
}

sub y { return $_[0]->{y}; }
sub x { return $_[0]->{x}; }

############################################################

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
		my @ys = sort { $a <=> $b } ( $self->{start}->y , $self->{end}->y );
		for( my $y=$ys[0]; $y<=$ys[1]; $y++ ) {
			push @points, Point->new( $self->{start}->x, $y );
		}
	} 
	elsif( $self->horizontal ) {
		my @xs = sort { $a <=> $b } ( $self->{start}->x , $self->{end}->x );
		for( my $x=$xs[0]; $x<=$xs[1]; $x++ ) {
			push @points, Point->new( $x, $self->{start}->y );
		}
	} 
	else {
		die "not on the straight or level";
	}
	return @points;
}
	
