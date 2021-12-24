#!/usr/bin/perl
print process( 1 )."\n";
print process( 3 )."\n";
print process( -5 )."\n";

sub process {
my @digits = @_;

$x = shift @digits;
$x = $x * -1;
return $x;
}

1
