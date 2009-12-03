#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use File::Basename ();

my ($self_dir) = ($0 =~ m!(.*/)!);
if (not $self_dir) {
	$self_dir = './';
}

my $cdup = `git rev-parse --show-cdup`;
if (defined $cdup) {
	$cdup =~ s/\n.*//s;
}

my @files;
if (@ARGV) {
	for my $name (@ARGV) {
		my $path = "${self_dir}packages/$name";
		if (-f $path) {
			push @files, $path;
		} else {
			print STDERR "$name: file ${self_dir}packages/$name does not exist.\n";
		}
	}
} else {
	@files = sort < ${self_dir}packages/* >;
}
for my $file (@files) {
	local *FILE;
	open FILE, $file or die "Error reading [$file]: $!\n";
	my $line = <FILE>;
	close FILE;
	my $name = File::Basename::basename($file);
	my ($version, $dir) = split /\s/, $line;
	my @changes = `git log --pretty=format:'%h %s (%ae)' $name-$version..HEAD -- $cdup$dir`;
	if (@changes) {
		print "$name-$version..HEAD:\n";
		print @changes, "\n";
        print "------------------------------------------\n";
	}
}

