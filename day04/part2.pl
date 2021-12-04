#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper;
require "../xmas.pl";

my $w = 5;
my $h = 5;
my @rows = readfile( "data" );

#nb. top row of bingo board is 0, bottom is 4

my @calls = ();
foreach(split( /,/, shift @rows )) {
	push @calls, $_+0;
}


my @boards = ();
while( @rows ) {
	shift @rows; # consume blank line
	my $grid = [];
	for( my $y=0;$y<$h;++$y ) {
		my $row = shift @rows;
		$row =~ s/\s+$//;
		$row =~ s/^\s+//;
		$grid->[$y]=[];
		foreach( split( / +/, $row ) ) {
			push @{$grid->[$y]}, $_+0; # force ints
		}
	}
	push @boards, BingoBoard->new( $grid );
}

my $winner;
my $lastcall;
CALL: foreach my $call ( @calls ) {
	print "---------------\n";
	print "CALL: $call\n";
	print "---------------\n";

	my @notwon = ();
	foreach my $board ( @boards ) {
		$board->call( $call );
		print $board->draw;
		print "\n";
		if( !$board->won ) { 
			push @notwon, $board;
		}
		elsif( scalar @boards == 1 ) { 
			$winner = $boards[0];
			$lastcall = $call;
			last CALL;
		}
	}
	@boards = @notwon;
}

print "---------------\n";
print "WINNER\n";
print "---------------\n";
print $winner->draw;
print "\n";
my $sum = 0;
foreach my $n ( $winner->unmarked ) {
	print "$n\n";
	$sum+=$n;
}
print "$sum\n";
print sprintf( "PART 2 = %d\n", $sum * $lastcall );
exit;



package BingoBoard;

sub new {
	my( $class, $grid ) = @_;

	my $self = {
		grid => $grid,
		map => {},
		marked => []
	};
	for( my $y=0;$y<$h;++$y ) {
		for( my $x=0;$x<$w;++$x ) {
			$self->{marked}->[$y]->[$x] = 0;
			$self->{map}->{$grid->[$y]->[$x]} = [$x,$y];
		}
	}
	return bless $self, $class;
}

sub call { 
	my( $self, $call ) = @_;
	
	if( $self->{map}->{$call} ) {
		$self->{marked}->[$self->{map}->{$call}->[1]]->[$self->{map}->{$call}->[0]] = 1;
	}
}

sub won {
	my( $self ) = @_;

	ROW: for( my $y=0;$y<$h;++$y ) {
		for( my $x=0;$x<$w;++$x ) {
			if( !$self->{marked}->[$y]->[$x] ) { next ROW; }
		}
		return 1;
	}
	COL: for( my $x=0;$x<$w;++$x ) {
		for( my $y=0;$y<$h;++$y ) {
			if( !$self->{marked}->[$y]->[$x] ) { next COL; }
		}
		return 1;
	}
	return 0;
}

sub unmarked {
	my( $self ) = @_;

	my @l = ();
	for( my $y=0;$y<$h;++$y ) {
		for( my $x=0;$x<$w;++$x ) {
			if( !$self->{marked}->[$y]->[$x]) {
				push @l, $self->{grid}->[$y]->[$x];
			}
		}
	}
	return @l;
}

sub draw {
	my( $self ) = @_;

	my $r = "";
	for( my $y=0;$y<$h;++$y ) {
		for( my $x=0;$x<$w;++$x ) {
			$r .= ($self->{marked}->[$y]->[$x]?"(":" ");
			$r .= sprintf( "%02d", $self->{grid}->[$y]->[$x] );
			$r .= ($self->{marked}->[$y]->[$x]?")":" ");
		}
		$r .= "\n";
	}	
	return $r;
}	
