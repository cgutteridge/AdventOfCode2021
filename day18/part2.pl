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

my $data = [];
foreach my $row ( @rows ) {
	my $t = [];
	my @stack = ($t);
	while( $row ne "" ) {
		if( $row =~ s/^(\d+)// ) {
			push @{$stack[-1]}, $1;
			next;
		}
		my $c = substr($row,0,1);
		$row = substr($row,1);
		next if( $c eq "," );
		if( $c eq "[" ) {
			my $pair = [];
			push @{$stack[-1]}, $pair;
			push @stack, $pair;
			next;
		}
		if( $c eq "]" ) {
			pop @stack;
			next;
		}
		die $c;
	}
	push @$data,$t->[0];
}

my $max;
for( my $l1=0;$l1<scalar @$data;++$l1 ) {
for( my $l2=0;$l2<scalar @$data;++$l2 ) {
	next if( $l1==$l2 );

	my $nums =[clone( $data->[$l1]), clone($data->[$l2]) ];

	printTree2( $nums->[0] );
	print " + ";
	printTree2( $nums->[1] );
	print " => ";
# reduce
REDUCE: while( 1 ) {

	#printTree( $nums->[0] );

	# convert the list into an order
	my @list = flatten( $nums->[0] );

	for( my $i=0; $i<@list; ++$i ) {
		my @r=@{$list[$i]->{r}};
		if( scalar @r == 5 ) {
			if( scalar @{$list[$i+1]->{r}} != 5 ) {
				die;
			}
			my( $a,$b ) = ($list[$i]->{v},$list[$i+1]->{v});
			if( $i-1>=0 ) {
				setAtRoute( $nums->[0], $list[$i-1]->{r}, $list[$i-1]->{v} + $a );
			}
			if( $i+2<scalar @list ) {
				setAtRoute( $nums->[0], $list[$i+2]->{r}, $list[$i+2]->{v} + $b );
			}

			my @pair_route = @r;
			pop @pair_route;
			setAtRoute( $nums->[0], \@pair_route, 0 );

			next REDUCE;
		}
	}

	for( my $i=0; $i<@list; ++$i ) {
		if( $list[$i]->{v}>=10 ) {
			# time to split
			setAtRoute( $nums->[0], $list[$i]->{r}, [ floor($list[$i]->{v}/2), ceil($list[$i]->{v}/2) ] );		
			next REDUCE;
		}
	}

	last if( scalar @$nums == 1 );

	my $a = shift @$nums;
	my $b = shift @$nums;
	unshift( @$nums, [$a,$b] );

}


#printTree( $nums->[0] );

$n = magnitude( $nums->[0] );	
print "$n\n";
$max = $n if( !defined $max || $n > $max );
}}
$n=$max;
############################################################
# Output
############################################################
my  $elapsed = tv_interval ( $t0, [gettimeofday]);
print sprintf( "PART2 => %d\n", $n );
print sprintf( "Elapsed time => %fs\n", $elapsed );
exit;
############################################################

sub magnitude {
	my( $tree ) = @_;

	if( ref($tree) eq "ARRAY" ) {
		return 3*magnitude( $tree->[0] ) + 2*magnitude( $tree->[1] );
	}
	else
	{
		return $tree;
	}
}

sub setAtRoute {
	my( $tree, $route, $v ) = @_;

	while( scalar @$route > 1 ) {
		$tree=$tree->[shift @$route];
	}
	$tree->[$route->[0]]=$v;
}

sub printTree {
	my( $tree ) = @_;
	printTree2( $tree );
	print "\n";
}
sub clone {
	my( $tree ) = @_;
	if( ref($tree) eq "ARRAY" ) {
		return [ clone( $tree->[0] ), clone( $tree->[1] ) ];
	}
	else
	{
		return $tree;
	}
}
sub printTree2 {
	my( $tree ) = @_;
	if( ref($tree) eq "ARRAY" ) {
		print "[";
		printTree2( $tree->[0] );
		print ",";
		printTree2( $tree->[1] );
		print "]";
	}
	else
	{
		print $tree;
	}
}


sub flatten {
	my( $tree, @route ) = @_;

	if( ref($tree) eq "ARRAY" ) {
		return( flatten( $tree->[0], @route,0 ), flatten( $tree->[1], @route,1 ) );
	}
	return( {v=>$tree, r=>[@route] } );
}
	





