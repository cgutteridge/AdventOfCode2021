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

############################################################
# End of boilerplate
############################################################

my $COST = { A=>1,B=>10,C=>100,D=>1000 };
my $HOME = { A=>[0,1], B=>[2,3], C=>[4,5], D=>[6,7] };
my $DONE =  "AABBCCDD.......";

my $start = "CDADBBCA......."; 
if( @ARGV && $ARGV[0] eq "test" ) { $start = "BACDBCDA......."; }
#$start =  "ADBBCC.D.......";
#$start =  ".ABBCC.D.....AD";
#$start =  ".ABBCCAD......D";
#$start =   ".ABBCC.....DDA.";
#$start =   ".ABBCCDA...D...";
#$start =   "ADBBCCAD.......";
#$start =   ".ABBCCAD.....D.";

#############
#.....D.D.A.#
###.#B#C#.###
  #A#B#C#.#
  #########


print_state( $start );
############################################################
# x        0  1  2  3  4  5  6  7  8  9  10    y
# hall     8  9     10    11    12    13 14    0
# outer          0     2     4     6           1
# inner          1     3     5     7           2

# work out distance from (outer) room spots to hall spots plus spots crossed
# inner is the same except one longer and crosses outer spot

my $xy = [
	[2,1], [2,2],
	[4,1], [4,2],
	[6,1], [6,2],
	[8,1], [8,2],
	[0,0],[1,0],[3,0],[5,0],[7,0],[9,0],[10,0] ];
my $xy_to_id={};
for(my $i=0; $i<scalar @$xy; ++$i ) {
	$xy_to_id->{$xy->[$i]->[0].",".$xy->[$i]->[1]}=$i;
}

# find distances and crossings from each room spot to each hall and room spot
my $routes = {};
for(my $y0=1; $y0<=2; ++$y0 ) {
	for( my $x0=2;$x0<=8;$x0+=2 ) {
		my $room_id = $xy_to_id->{"$x0,$y0"};
		my @crossed_up = ();
		if( $y0==2) { push @crossed_up, $xy_to_id->{"$x0,1"}; }
		# left from room
		my @crossed_left = @crossed_up;
		for( my $x=$x0; $x>=0; $x-- ) {
			my $xy = "$x,0";
			if( defined $xy_to_id->{$xy} ) {
				my $hall_id = $xy_to_id->{$xy};
				my $dist = $y0+abs($x0-$x);
				$routes->{$room_id}->{$hall_id} = {d=>$dist, c=>[@crossed_left]};
				push @crossed_left, $hall_id;
			}
			# into another room
			if( $x!=$x0 && defined $xy_to_id->{"$x,1"} ) {
				my $outer_room_id = $xy_to_id->{"$x,1"};
				my $inner_room_id = $xy_to_id->{"$x,2"};
				my $dist = $y0+abs($x0-$x);
				$routes->{$room_id}->{$outer_room_id} = {d=>$dist+1, c=>[@crossed_left]};
				$routes->{$room_id}->{$inner_room_id} = {d=>$dist+2, c=>[@crossed_left,$outer_room_id]};
			}	
		}
		# right from room
		my @crossed_right = @crossed_up;
		for( my $x=$x0; $x<=10; $x++ ) {
			my $xy = "$x,0";
			if( defined $xy_to_id->{$xy} ) {
				my $hall_id = $xy_to_id->{$xy};
				my $dist = $y0+abs($x0-$x);
				$routes->{$room_id}->{$hall_id} = {d=>$dist, c=>[@crossed_right]};
				push @crossed_right, $hall_id;
			}
			# into another room
			if( $x!=$x0 && defined $xy_to_id->{"$x,1"} ) {
				my $outer_room_id = $xy_to_id->{"$x,1"};
				my $inner_room_id = $xy_to_id->{"$x,2"};
				my $dist = $y0+abs($x0-$x);
				$routes->{$room_id}->{$outer_room_id} = {d=>$dist+1, c=>[@crossed_right]};
				$routes->{$room_id}->{$inner_room_id} = {d=>$dist+2, c=>[@crossed_right,$outer_room_id]};
			}	
		}
	}
}

if(0) {	
foreach my $room_id ( sort {$a<=>$b} keys %$routes ) {
	foreach my $c_id ( sort {$a<=>$b} keys %{$routes->{$room_id}} ) {
		my $r = $routes->{$room_id}->{$c_id};
		print sprintf( "%d->%d (%d)   x %s\n", $room_id, $c_id, $r->{d}, join( ",", @{$r->{c}}));
	}
}
exit;
}
############################################################

#print Dumper( legal_moves ( ".A....A........" ));exit;

$n= lowest_cost( $start, {},0,[] );


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;

############################################################

sub lowest_cost {
	my( $s, $cache ) = @_;

	if( $s eq $DONE ) {
		return 0;
	}
	return $cache->{$s} if defined $cache->{$s};
	my $lowest;
	my @moves = legal_moves( $s );
	MOVE: foreach my $move ( @moves ) {
		my $new_s = $s;
		my $species = substr( $s, $move->[0], 1 );
		substr($new_s,$move->[0],1) = ".";
		substr($new_s,$move->[1],1) = $species;
		my $cost = lowest_cost( $new_s, $cache, );
		next MOVE if !defined $cost;
		my $score = $move->[2] + $cost;
		if( !defined $lowest || $score<$lowest ) {
			$lowest=$score;
		}
	}
	$cache->{$s} = $lowest;

	return $lowest;
}

sub legal_moves {
	my( $s ) = @_;
	my @s = split( //, $s );

	my @moves = ();
	# rooms 0-7
	# hall  8-14
	# only Amphipods in rooms can move to hall locations
	ROOM: for( my $room_id=0; $room_id<=7; $room_id++ ) {
		next if( $s[$room_id] eq "." );
		my $species = $s[$room_id];

#		# first of all, is it already comfy
#		# comfy is we are in our home and the other home location is . or our species
		my $home = $HOME->{$species};
		next ROOM if( $room_id == $home->[1] && ($s[$home->[0]] eq "." || $s[$home->[0]] eq $species ) );
		next ROOM if( $room_id == $home->[0] && ($s[$home->[1]] eq "." || $s[$home->[1]] eq $species ) );

		# consider each hall location
		HALL: for( my $hall_id=8; $hall_id<=14; ++$hall_id ) {
			my $r = $routes->{$room_id}->{$hall_id};
			# if there's things in the way the move isn't legal, plus the actual target location
			foreach my $cross_id ( @{$r->{c}}, $hall_id ) {
				next HALL if( $s[$cross_id] ne "." );
			}
			# OK, it's a legal move. nice.
			push @moves,[$room_id,$hall_id,$r->{d} * $COST->{$species}];
		}
	}

	# Amphipods can only move into rooms if they would be cozy and are not already cozy
	# and obviously they should move to the end room if it's empty
					
	LOC: for( my $id=8; $id<=14; ++$id ) {
		next if( $s[$id] eq "." );
		my $species = $s[$id];
		my $home = $HOME->{$species};

		# if it's home and cozy skip
		next LOC if( $id == $home->[1] && ($s[$home->[0]] eq "." || $s[$home->[0]] eq $species ) );
		next LOC if( $id == $home->[0] && ($s[$home->[1]] eq "." || $s[$home->[1]] eq $species ) );

		# if it's home isn't cozy, skip
		
		next LOC if( $s[$home->[0]] ne "." && $s[$home->[0]] ne $species );
		next LOC if( $s[$home->[1]] ne "." && $s[$home->[1]] ne $species );

		# aim for the deepest empty spot
		my $room_id = $home->[0];
		$room_id = $home->[1] if( $s[$home->[1]] eq "." );

		my $r = $routes->{$room_id}->{$id};
		# either this is a valid move or it's not. There's no other moves allowed from the hall
		foreach my $cross_id ( @{$r->{c}} ) {
			next LOC if( $s[$cross_id] ne "." );
		}
		# OK, it's a legal move. nice.
if( !defined $r->{d} ) { print "$room_id.. $id\n"; print Dumper( $r ); die; }
		push @moves,[$id,$room_id,$r->{d} * $COST->{$species}];
	}
		
	return @moves;	
}

sub print_state {
	my( $s ) = @_;

	my @s = split( //, $s );
	print sprintf( "#############\n#%s%s.%s.%s.%s.%s%s#\n###%s#%s#%s#%s###\n  #%s#%s#%s#%s#\n  #########\n",
		$s[8], $s[9],    $s[10],    $s[11],    $s[12],    $s[13], $s[14],
		            $s[0],     $s[2],     $s[4],     $s[6],
		            $s[1],     $s[3],     $s[5],     $s[7] );
	print "\n";
}
