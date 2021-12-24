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

# answer 50190
############################################################
# End of boilerplate
############################################################

my $COST = [1,10,100,1000];
my $ttl = 100000;
my $cache_count = 0;

my $real = "CDDDACBDBBABCACA......."; 
my $test = "BDDACCBDBBACDACA......."; 
my $start = $real;
if( @ARGV && $ARGV[0] eq "test" ) { $start = $test; }
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


############################################################
# x        0  1  2  3  4  5  6  7  8  9  10    y
# hall     16 17    18    19    20    21 22
# room0          0     4     8     12          1
# room1          1     5     9     13          2
# room2          2     6     10    14          2
# room3          3     7     11    15          2

# work out distance from (outer) room spots to hall spots plus spots crossed
# inner is the same except one longer and crosses outer spot


my $hall_xy=[ [0,0],[1,0],[3,0],[5,0],[7,0],[9,0],[10,0] ];
my $xy = [
	[2,1], [2,2], [2,3], [2,4],
	[4,1], [4,2], [4,3], [4,4],
	[6,1], [6,2], [6,3], [6,4],
	[8,1], [8,2], [8,3], [8,4],
	@{$hall_xy} ];
my $xy_to_id={};
for(my $i=0; $i<scalar @$xy; ++$i ) {
	$xy_to_id->{$xy->[$i]->[0].",".$xy->[$i]->[1]}=$i;
}

my $routes = {};
for(my $room_i=0;$room_i<4;++$room_i ) {
	my $room_x = $room_i*2+2;
	my $room_o = $room_i*4;
	# find routes to each hall location and location in other rooms
	foreach my $hall_loc ( @$hall_xy ) {
		my $hall_dist = abs($hall_loc->[0]-$room_x);
		my $hall_id = $xy_to_id->{$hall_loc->[0].",".$hall_loc->[1]};
		my( $min,$max ) = sort{$a<=>$b} ( $room_x, $hall_loc->[0] );
		my @hall_crosses = ();
		foreach my $hall_loc2 ( @$hall_xy ) {
			push @hall_crosses, $xy_to_id->{$hall_loc2->[0].",".$hall_loc2->[1]} if( $hall_loc2->[0] > $min && $hall_loc2->[0] < $max );
		}
		$routes->{$room_o+0}->{$hall_id} = $routes->{$hall_id}->{$room_o+0} = [ $hall_dist+1 , [ @hall_crosses ] ];
		$routes->{$room_o+1}->{$hall_id} = $routes->{$hall_id}->{$room_o+1} = [ $hall_dist+2 , [ @hall_crosses, $room_o+0 ] ];
		$routes->{$room_o+2}->{$hall_id} = $routes->{$hall_id}->{$room_o+2} = [ $hall_dist+3 , [ @hall_crosses, $room_o+0, $room_o+1 ] ];
		$routes->{$room_o+3}->{$hall_id} = $routes->{$hall_id}->{$room_o+3} = [ $hall_dist+4 , [ @hall_crosses, $room_o+0, $room_o+1, $room_o+2 ] ];
	}
}
		
	



if(0) {	
foreach my $room_id ( sort {$a<=>$b} keys %$routes ) {
	foreach my $c_id ( sort {$a<=>$b} keys %{$routes->{$room_id}} ) {
		my $r = $routes->{$room_id}->{$c_id};
		print sprintf( "%d->%d (%d)   x %s\n", $room_id, $c_id, $r->[0], join( ",", @{$r->[1]}));
	}
}
exit;
}
############################################################

if(0) {
	#my @moves = legal_moves( "CDDD ACBD BBAB CACA ......." );
        my $try = "AAAD.BBBCCCCDADDB......";
	my $state = string_to_state($try);	
	print_state( $state );

	my @moves = legal_moves( $state );
	foreach my $move ( @moves ) {
		print sprintf( "%d->%d (%d)\n", @$move );
	}
	exit 1;
}
#$start = "DAAA.BBBCCCCADDDB......";

my $state = string_to_state($start);	

print_state( $state );

my $next_report_t = time()+1;
$n= lowest_cost( $state, 0,"" );


############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART2 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;

############################################################

sub lowest_cost {
	my( $s, $depth, $msg, $budget  ) = @_;

	if( time() >= $next_report_t ) {
		$next_report_t = time()+1;
		print "$msg\n";
	}

	# s[$i] is always sorted
	my $done = 1;
	DONETEST: for(my $species_i=0;$species_i<4;$species_i++) {
		if( $s->[$species_i]->[0] != $species_i*4+0
		 || $s->[$species_i]->[1] != $species_i*4+1 
		 || $s->[$species_i]->[2] != $species_i*4+2 
		 || $s->[$species_i]->[3] != $species_i*4+3 ) {
			$done = 0;
			last DONETEST;
		}
	}
	if( $done ) {
		return 0;
	}

	#exit if($ttl--<=0 );

	my $lowest;
	my @moves = legal_moves( $s );
	my $move_i=0;
	MOVE: foreach my $move ( sort { $a->[2] <=> $b->[2] } @moves ) {
		$move_i++;

		# no point trying sub routes if this isn't the best route
		if( defined $budget && $move->[2] > $budget ) {
			last MOVE 
		}

		my $new_s = [];
	
		for my $species ( 0..3 ) {
			my $changed = 0;
			my $row = [];
			for my $i ( 0..3 ) { 
				if( $s->[$species]->[$i] == $move->[0] ) { 
					push @$row, $move->[1];
					$changed = 1;
				} else {
					push @$row, $s->[$species]->[$i];
				}
			}
			push @$new_s, ( $changed ? [sort {$a<=>$b} @$row] : $row );
		}				
		my $cost;

		my $sub_budget;
		if( defined $lowest ) { 
			$sub_budget = $lowest;
		} elsif( defined $budget ) {
			$sub_budget = $budget-$move->[2];
		}

		my $c =  "$move_i/".scalar(@moves);
		$cost = lowest_cost( $new_s, $depth+1,$msg." ".$c, $sub_budget );

		next MOVE if !defined $cost;
		my $score = $move->[2] + $cost;
		if( !defined $lowest || $score<$lowest ) {
			$lowest=$score;
		}
	}

	return $lowest;
}

sub legal_moves {
	my( $s ) = @_;

	# log which homes are snug
	my $homes_snug = [ 1,1,1,1 ];
	my $pos = [];
	foreach my $species ( 0..3 ) {
		foreach my $loc ( @{$s->[$species]} ) {
			$pos->[$loc] = $species;
			next if $loc>15;
			my $home_of = ($loc - $loc%4)/4;
			if( $home_of != $species ) {
				$homes_snug->[$home_of] = 0;
			}	
		}
	}

	my @moves = ();
	foreach my $species ( 0..3 ) {
		LOC: foreach my $start_id ( @{$s->[$species]} ) {
		
			next LOC if( $homes_snug->[$species] && $start_id>=$species*4 && $start_id<=$species*4+3 );
	
			my @home_targets = ();
	
			if( $homes_snug->[$species] ) { 
				# find deepest empty location in home
				my $deepest;
				I: for( my $i=3; $i>=0; $i-- ) {
					my $in_room_loc = $pos->[$species*4+$i];
					if( !defined $in_room_loc ) {
						$deepest = $species*4+$i;
						last I;
					}
				}
				if( !defined $deepest ) {
					die "shouldn't get here undefined";
				}
				push @home_targets, $deepest;
			}

			TARGET: foreach my $target_id ( 16,17,18,19,20,21,22, @home_targets ) {
				my $move = $routes->{$start_id}->{$target_id};
				next TARGET unless defined $move;
				next TARGET unless ! defined $pos->[$target_id]; # check destination is clear
				foreach my $step ( @{$move->[1]} ) {
					next TARGET if( defined $pos->[$step] );
				}
				push @moves, [$start_id,$target_id,$move->[0] * $COST->[$species] ];
			}
		}
	}
	return @moves;	
}

sub string_to_state {
	my( $string ) = @_;

	my $l = [];
	my @s = split( //, $string );
	for( my $i=0;$i<@s;++$i ) {
		if( $s[$i] ne "." ) {
			push @{$l->[ord($s[$i])-65]}, $i;
		}
	}
	$l = [ 
		[sort {$a<=>$b} @{$l->[0]}], 
		[sort {$a<=>$b} @{$l->[1]}], 
		[sort {$a<=>$b} @{$l->[2]}], 
		[sort {$a<=>$b} @{$l->[3]}]
	];
	return $l;
}

sub print_state {
	my( $state ) = @_;

	my @s = ();
	for(my $i=0;$i<=22;++$i ) { $s[$i]="."; }
	for(my $species=0;$species<4;++$species ) {
		foreach my $loc ( @{$state->[$species]} ) {
			$s[$loc] = chr(65+$species);
		}
	}
	print sprintf( "             \n %s%s.%s.%s.%s.%s%s \n   %s %s %s %s   \n   %s %s %s %s \n   %s %s %s %s \n   %s %s %s %s \n           \n",
		$s[16], $s[17],    $s[18],    $s[19],    $s[20],    $s[21], $s[22],
		            $s[0],       $s[4],     $s[8],     $s[12],
		            $s[1],       $s[5],     $s[9],     $s[13],
		            $s[2],       $s[6],     $s[10],    $s[14],
		            $s[3],       $s[7],     $s[11],    $s[15] );
	print "\n";
}
