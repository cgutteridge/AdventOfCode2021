#!/usr/bin/perl

print process( 1, 3 )."\n";
print process( 3, 3 )."\n";
print process( 9, 3 )."\n";
print process( 3, 1 )."\n";
print process( 3, 9 )."\n";

sub process {
my @digits = @_;

$z = shift @digits;
$x = shift @digits;
$z = $z * 3;
$z = $z == $x?1:0;
return $z;
}

1
