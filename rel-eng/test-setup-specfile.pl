#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

my ($IN, $SHA1, $DIR, $TAR_GZ) = @ARGV;
open IN, $IN or die "Error reading [$IN]\n";
my @lines = <IN>;
close IN;


my ($have_release, $have_source, $have_setup) = (0, 0, 0);
my $i = 0;
for (@lines) {
	no warnings 'uninitialized';
	if (s/^(Release:\s*)(.+?)(%{\?dist})?\s*\n$/$1$2.git.$SHA1$3\n/i) {
		if ($have_release) {
			die "Duplicate Release line found in [$IN] at line [$i]\n";
		}
		$have_release++;
	}
	if (defined $TAR_GZ and s/^(Source0?:\s*)(.+?)\n$/$1$TAR_GZ\n/i) {
		if ($have_source) {
			die "Duplicate Source (or Source0) line found in [$IN] at line [$i]\n";
		}
		$have_source++;
	}
	if (defined $DIR and /^%setup/) {
		if (not s/\s+-n\s+\S+(\s*)/ -n $DIR$1/) {
			s/\n/ -n $DIR\n/;
		}
		$have_setup++;
	}
	$i++;
}
if (not $have_release) {
	die "The specfile [$IN] does not seem to have Release: line we could use\n";
}
if (defined $TAR_GZ and not $have_source) {
	die "The specfile [$IN] does not seem to have Source: line we could use\n";
}
if (defined $DIR and not $have_setup) {
	die "The specfile [$IN] does not seem to have %setup line we could use\n";
}

my $OUT = "$IN.$SHA1";
open OUT, "> $OUT" or die "Error writing [$OUT]\n";
print OUT @lines;
close OUT;

rename $OUT, $IN;

