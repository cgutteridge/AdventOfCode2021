use strict; 
use warnings;

sub process {
my( $depth, @digits ) = @_;
my $nb = join(",",@digits );
my( $w,$x,$y,$z ) = (0,0,0,0);
my $debug=0;
if( $debug ) { 
	print "DEBUG: ".join( "",@digits )."\n";
}

# 1
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 1);
$x = $x + 10;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 13;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==1;

# 2
print "$z\n" if $debug;
$w = shift @digits;
if( !defined $w ) { die "depth was $depth - $nb"; }
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 1);
$x = $x + 13;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 10;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==2;

# 3
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 1);
$x = $x + 13;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 3;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==3;

# 4
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 26);
$x = $x + -11;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 1;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==4;

# 5
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 1);
$x = $x + 11;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 9;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==5;

# 6
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 26);
$x = $x + -4;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 3;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==6;

# 7
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 1);
$x = $x + 12;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 5;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==7;

# 8
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 1);
$x = $x + 12;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 1;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==8;

# 9
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 1);
$x = $x + 15;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 0;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==9;

# 10
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 26);
$x = $x + -2;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 13;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==10;

# 11
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 26);
$x = $x + -5;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 7;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==11;

# 12
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 26);
$x = $x + -11;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 15;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==12;

# 13
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 26);
$x = $x + -13;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 12;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==13;

# 14
print "$z\n" if $debug;
$w = shift @digits;
$x = $x * 0;
$x = $x + $z;
$x = $x % 26;
$z = int($z / 26);
$x = $x + -10;
$x = $x == $w ? 1:0;
$x = $x == 0 ? 1:0;
$y = $y * 0;
$y = $y + 25;
$y = $y * $x;
$y = $y + 1;
$z = $z * $y;
$y = $y * 0;
$y = $y + $w;
$y = $y + 8;
$y = $y * $x;
$z = $z + $y;
return $z if $depth==14;

die;
}
1;
