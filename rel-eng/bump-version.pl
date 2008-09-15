#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

my $command = shift @ARGV;
if (not defined $command
	or ($command ne 'bump-version' and $command ne 'bump-release')) {
	usage();
}
my $specfile = 0;
if (@ARGV and $ARGV[0] eq '--specfile') {
	$specfile = 1;
	shift @ARGV;
}
if (not @ARGV) {
	usage();
}

sub usage {
	die "usage: $0 { bump-version | bump-release } [--specfile] file [ files ... ]\n";
}

my $newfile;
my @content;
while (<ARGV>) {
	if ($specfile) {
		if ($command eq 'bump-version') {
			s/^(version:\s*)(.+)/ $1 . bump_version($2) /ei;
			s/^(release:\s*)(.+)/ $1 . reset_release($2) /ei;
		} else {
			s/^(release:\s*)(.+)/ $1 . bump_version($2) /ei;
		}
		push @content, $_;
	} else {
		chomp;
		my ($version, $release, $rest) = split /\s/, $_, 3;
		if ($command eq 'bump-version') {
			$version = bump_version($version);
			$release = reset_release($release);
		} else {
			$release = bump_version($release);
		}
		if (defined $rest) {
			$release .= ' ' . $rest;
		}
		push @content, "$version $release\n";
		# slurp the rest of the file
		while (not eof(ARGV)) {
			push @content, scalar <ARGV>;
		}
	}

} continue {
	if (eof(ARGV)) {
		local *OUT;
		undef $newfile;
		if ($ARGV eq '-') {
			*OUT = \*STDOUT;
		} else {
			$newfile = $ARGV . ".$$";
			open OUT, "> $newfile" or die "Error writing [$newfile]: $!\n";
		} 
		print OUT @content;
		if (defined $newfile) {
			close OUT;
			rename $newfile, $ARGV;
		}
	}
}

sub bump_version {
	local $_ = shift;
	no warnings 'uninitialized';
	s/^(.+\.)?([0-9]+)(\.|%|$)/$1 . ($2 + 1) . $3/e;
	$_;
}

sub reset_release {
	local $_ = shift;
	s/(^|\.)([.0-9]+)(\.|%|$)/${1}1$3/;
	$_;
}

__END__ {
	if (defined $newfile and -f $newfile) {
		unlink $newfile;
	}
}

1;

