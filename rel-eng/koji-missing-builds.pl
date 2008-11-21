#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use File::Basename ();

my $tag = shift;
if (not defined $tag) {
	die "usage: $0 koji-tag-to-check\n";
}

my @brew_data = sort map { /^(\S+)/ and $1 } `koji -c ~/.koji/spacewalk-config list-tagged --quiet --latest $tag`;

my ($self_dir) = ($0 =~ m!(.*/)!);
if (not $self_dir) {
	$self_dir = './';
}

my @tagged_data;
for my $file (sort < ${self_dir}packages/* >) {
	local *FILE;
	open FILE, $file or die "Error reading [$file]: $!\n";
	my $line = <FILE>;
	close FILE;
	my $version;
	($version) = ($line =~ /^(\S+)/)
		and push @tagged_data, File::Basename::basename($file) . "-" . $version;
}

exit diff_it(\@brew_data, \@tagged_data);

sub diff_it {
	my ($brew_data, $tagged_data) = @_;
	my ($bi, $ti) = (0, 0);
	my (@extra, @missing);
	while ($bi < @$brew_data) {
		if (not defined $tagged_data->[$ti]) {
			push @extra, $brew_data->[$bi++];
			next;
		}
		my $b = $brew_data->[$bi];
		$b =~ s/\.el\d$//;
		my $t = $tagged_data->[$ti];
		$t =~ s/^(buildsys-macros-.+)\.sw$/$1/;
		if ($b lt $t) {
			push @extra, $brew_data->[$bi++];
		} elsif ($b gt $t) {
			push @missing, $tagged_data->[$ti++];
		} else {
			$bi++;
			$ti++;
		}
	}
	if ($ti < @$tagged_data) {
		push @missing, @{$tagged_data}[$ti .. $#$tagged_data];
	}
	if (@extra) {
		print "Extra builds in koji:\n";
		print map "\t$_\n", @extra;
	}
	if (@missing) {
		print "Builds missing in koji:\n";
		print map "\t$_\n", @missing;
	}
	if (@extra or @missing) {
		return 1;
	}
	return 0;
}

