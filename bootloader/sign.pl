#!/usr/bin/perl

open(DATA, $ARGV[0]) or die "open $ARGV[0]: $!";
$n = sysread(DATA,$buf,1000);
if($n > 510)
{
	print STDERR "boot block too large: $n bytes(max 510)\n";
	exit 1;
}
print STDERR "boot block is $n bytes\n";
$buf .= "\0" x (510-$n);
print STDERR "0: (510-$n) bytes\n";
$buf .="\x55\xAA";

open(DATA,">$ARGV[0]") or die "open > $ARGV[0]: $!";
print DATA $buf;
close DATA;
