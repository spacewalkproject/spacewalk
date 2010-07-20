#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Find ();

my %files;

for my $dir (qw( common oracle postgres )) {
	File::Find::find(sub {
		my $name = $File::Find::name;
		if ($name eq $dir) {
			return;
		}
		if (not -f $_) {
			return;
		}
		if (substr($name, 0, length($dir) + 1) ne "$dir/") {
			die "In dir [$dir] we got [$name]\n";
		}
		my $rname = substr($name, length($dir) + 1);
		$files{$dir}{$rname} = $_;
		}, $dir);
}

my $error = 0;
for my $c (sort keys %{ $files{common} }) {
	for my $o (qw( oracle postgres )) {
		next unless $o =~ /\.sql$/;
		if (exists $files{$o}{$c}) {
			print "Common file [$c] is also in $o\n";
			$error = 1;
		}
	}
}

exit $error;

