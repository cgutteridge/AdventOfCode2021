#!/usr/bin/perl 

############################################################
# Boilerplate
############################################################

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );
require "../xmas.pl";
my $t0 = [gettimeofday];
my $n=0;

my $file = "data";
if( @ARGV ) { $file = $ARGV[0]; }
my @rows = readfile( $file );

############################################################
# End of boilerplate
############################################################

my $cave =[];
foreach my $row ( @rows ) {
	my $crow = [];
	foreach my $v ( split( //, $row )) {
		push @$crow, $v+0;
	}
	push @$cave, $crow;
}
#print Dumper( $cave );
my $W = scalar @{$cave->[0]};
my $H = scalar @$cave;

# assume only right and down movement

# process as diagonals
my @order = ();
for( my $i=1;$i<$W;++$i ) {
	for(my $y=0;$y<=$i;$y++) {
		my $x=$i-$y;
		push @order,[$x,$y];
	}
}	
for( my $i=1;$i<$H;++$i ) {
	for(my $y=$i;$y<$H;$y++) {
		my $x=$W-1 +$i -$y;
		push @order,[$x,$y];
	}
}	
print "".(scalar @order )."\n";
#print Dumper(\@order);

my $mindist = [[0]];
my $dir = [["."]];
foreach my $coord ( @order ) {
	my( $x,$y ) = @$coord;
	my $v = 0;
	if( $x==0 ) { $v += $mindist->[$y-1]->[$x]; $dir->[$y]->[$x] = "v";}
	if( $y==0 ) { $v += $mindist->[$y]->[$x-1]; $dir->[$y]->[$x] = ">";}
	if( $x>0 && $y>0 ) {
		my $v1 = $mindist->[$y-1]->[$x];
		my $v2 = $mindist->[$y]->[$x-1];
		$v += ($v1<$v2 ? $v1 : $v2 );
		$dir->[$y]->[$x] = ($v1<$v2?"v":">" );
	}
	$v += $cave->[$y]->[$x];
	$mindist->[$y]->[$x] = $v;
}
my $found =1;
while( $found ) {
	# look for faster routes
	$found = 0;
	for( my $y=0;$y<$H;++$y) {	
	for( my $x=0;$x<$W;++$x) {	
		# neighbours
		my $nebs = [ [$x-1,$y], [$x+1,$y], [$x,$y-1], [$x,$y+1] ];
		NEB: foreach my $neb ( @$nebs ) {
			my( $x1,$y1 ) = @$neb;
			next NEB if $x1==-1;
			next NEB if $y1==-1;
			next NEB if $x1==$W;
			next NEB if $y1==$H;
			if( $mindist->[$y]->[$x] > $mindist->[$y1]->[$x1]+$cave->[$y]->[$x] ) {
				$mindist->[$y]->[$x] = $mindist->[$y1]->[$x1]+$cave->[$y]->[$x] ;
				$found = 1;
			}
		}
	}}
}

my $route = {};
my $rx=$W-1;
my $ry=$H-1;
while( $rx!=0 || $ry!=0 ) {
	$route->{"$rx,$ry"}=1;
print "$rx,$ry\n";
	if( $dir->[$ry]->[$rx] eq "v" ) { 
		$ry--;
	} elsif( $dir->[$ry]->[$rx] eq ">" ) { 
		$rx--;
	} else {
		die;
	}
}
print Dumper($route);
	
	

for(my $y=00;$y<$H;$y++) { for(my $x=00;$x<$W;$x++) { my $v= $mindist->[$y]->[$x]; $v = 999 unless defined $v; print sprintf( " %3d:%d:%s", $v,$cave->[$y]->[$x],$dir->[$y]->[$x] ); } print "\n"; }

print "<pre>";
for(my $y=00;$y<$H;$y++) { for(my $x=00;$x<$W;$x++) { my $v= $mindist->[$y]->[$x]; $v = 999 unless defined $v; 
if( $route->{"$x,$y"} ) { print "<b>"; }
print sprintf( " %3d:%d:%s", $v,$cave->[$y]->[$x],$dir->[$y]->[$x] ); 
if( $route->{"$x,$y"} ) { print "</b>"; }
} print "\n"; }
print "</pre>";

$n = $mindist->[$H-1]->[$W-1];	


# 510 wrong
############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART1 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################
