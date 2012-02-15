#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Find ();
use Getopt::Long ();
use Digest::SHA ();

my %files;
my $show_ignored = 0;
Getopt::Long::GetOptions('I' => \$show_ignored) or exit 9;

for my $dir (qw( common oracle postgres upgrade )) {
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
		if ($dir eq 'upgrade') {
			my $generic = $name;
			my $db = 'common';
			if ($generic =~ s/\.(oracle|postgresql)$//) {
				$db = $1;
				$db = 'postgres' if $db eq 'postgresql';
			}
			$files{$db}{$generic} = $name;
		} else {
			my $rname = substr($name, length($dir) + 1);
			$files{$dir}{$rname} = $name;
		}
		}, $dir);
}

my $error = 0;
sub get_first_line_sha1 {
	my $filename = shift;
	local *FILE;
	open FILE, '<', $filename or do {
		die "Error reading [$filename]: $!\n";
	};
	my $first_line = <FILE>;
	close FILE;
	if (not defined $first_line or not $first_line =~ /^-- oracle equivalent source (?:(none)|sha1 ([0-9a-f]{40}))$/) {
		return;
	}
	if (defined $1) {
		return $1;
	}
	return $2;
}

for my $c (sort keys %{ $files{common} }) {
	next unless $c =~ /\.(sql|pks|pkb)$/;
	for my $o (qw( oracle postgres )) {
		if (exists $files{$o}{$c}) {
			print "Common file [$c] is also in $o\n";
			$error = 1;
		}
	}
	my $oracle_sha1 = eval { get_first_line_sha1($files{common}{$c}) };
	if ($@) {
		print $@;
	} elsif (defined $oracle_sha1) {
		print "Common file [$c] specifies SHA1 of Oracle source but it should not\n";
		$error = 1;
	}
}

for my $c (sort keys %{ $files{oracle} }) {
	next unless $c =~ /\.(sql|pks|pkb)$/;
	if (not exists $files{postgres}{$c}) {
		if ($c =~ /^upgrade|^packages|^tables|^class|^data/) {
			print "Oracle file [$c] is not in PostgreSQL variant\n";
			$error = 1;
		} else {
			print "Oracle file [$c] is not in postgres (ignoring for now)\n" if $show_ignored;
			# $error = 1;
		}
	}
	my $oracle_sha1 = eval { get_first_line_sha1($files{oracle}{$c}) };
	if ($@) {
		print $@;
	} elsif (defined $oracle_sha1) {
		print "Oracle file [$c] specifies SHA1 of Oracle source but it should not\n";
		$error = 1;
	}
}

for my $c (sort keys %{ $files{postgres} }) {
	next unless $c =~ /\.(sql|pks|pkb)$/;
	my $oracle_sha1 = eval { get_first_line_sha1($files{postgres}{$c}) };
	if ($@) {
		print $@;
		$error = 1;
		next;
	}
	if (not defined $oracle_sha1) {
		print "PostgreSQL file [$c] does not specify SHA1 of Oracle source nor none\n" if $show_ignored or $c !~ /^procs/;
		$error = 1 if $c !~ /^procs/;
		next;
	}
	if ($oracle_sha1 eq 'none') {
		# the PostgreSQL source says there is no Oracle equivalent
		if (exists $files{oracle}{$c}) {
			print "PostgreSQL file [$c] claims it has no Oracle equivalent, but it exists\n";
			$error = 1;
		}
		next;
	}
	if (not exists $files{oracle}{$c}) {
		print "Postgres file [$c] is not in oracle\n";
		$error = 1;
		next;
	}
	open FILE, '<', $files{oracle}{$c} or do {
		print "Error reading Oracle [$files{oracle}{$c}] to verify SHA1: $!\n";
		$error = 1;
		next;
	};
	my $sha1 = new Digest::SHA(1);
	$sha1->addfile(\*FILE);
	my $sha1_hex = $sha1->hexdigest();
	close FILE;
	if ($oracle_sha1 ne $sha1_hex) {
		print "PostgreSQL file [$c] says SHA1 of Oracle source should be [$oracle_sha1] but it is [$sha1_hex]\n";
		$error = 1;
	}
}

exit $error;

