#!/usr/bin/perl


my $f={};
for my $a (1..3) {
for my $b (1..3) {
for my $c (1..3) {
	$f->{$a+$b+$c}++;
}}}

foreach my $k ( sort {$a<=>$b} keys %$f) {
	print "$k=>".$f->{$k}."\n";
}
