#!/usr/bin/perl

use strict;
use warnings;

my @IGNORE = (
	'W: no-version-in-last-changelog',
	'W: filename-too-long-for-joliet',
);
my %IGNORE = map { my ($letter) = /^(\S)/; ( $_ => $letter ) } @IGNORE;

my $ignore = 0;
if (@ARGV and $ARGV[0] eq '--ignore') {
	shift;
	$ignore = 1;
}

if (not $ignore) {
	print <STDIN>;
	exit;
}

my %ignored;
while (<STDIN>) {
	if (eof(STDIN)) {
		my ($start, $errors, $warnings) = /^(.+; )(\d+)\serrors,\s(\d+)\swarnings\.$/;
		if (defined $ignored{'W'}) {
			$warnings -= $ignored{'W'};
		}
		if (defined $ignored{'E'}) {
			$errors -= $ignored{'E'};
		}
		print "$start$errors errors, $warnings warnings.\n";
		last;
	}
	my ($id) = /^\S+:\s([EW]:\s\S+)/;
	if (defined $IGNORE{$id}) {
		$ignored{ $IGNORE{$id} }++;
	} else {
		print;
	}
}

