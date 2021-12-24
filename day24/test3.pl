#!/usr/bin/perl

for(0..15) { 
	print sprintf( "%2d .. %s\n",$_,process( $_ ));
	print "\n";
}


sub process {
my @digits = @_;

my( $w,$x,$y,$z ) = (0,0,0,0);

$w = shift @digits;

$z = $z + $w;
$z = $z % 2;
$w = int($w / 2);
#print "$w,$x,$y,$z)\n";

$y = $y + $w;
$y = $y % 2;
$w = int($w / 2);
#print "$w,$x,$y,$z)\n";

$x = $x + $w;
$x = $x % 2;
$w = int($w / 2);
#print "$w,$x,$y,$z)\n";

$w = $w % 2;
#print "$w,$x,$y,$z)\n";

return "$w,$x,$y,$z";
}

1
