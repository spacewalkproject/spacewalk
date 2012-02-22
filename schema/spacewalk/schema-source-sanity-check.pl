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

sub check_file_content {
	my $filename = shift;
	return if $filename =~ /^upgrade/;
	return if $filename =~ /qrtz\.sql$/;
	return if $filename =~ /dual\.sql$/;
	my ($type, $name) = ($filename =~ m!.*/(.+)/(.+?)(_foreignkeys)?\.(sql|pks|pkb)$!);
	return if not defined $type;
	return if $type eq 'class';
	return if $type eq 'packages';

	local *FILE;
	open FILE, '<', $filename or do {
		die "Error reading [$filename]: $!\n";
	};
	my $content;
	{
		local $/ = undef;
		$content = <FILE>;
	}
	close FILE;
	# print "[$filename] [$type] [$name]\n";
	if ($type eq 'tables') {
		if (not $content =~ /^(--.*\n
					|\s*\n
					|(create|alter|comment\s+on)\s+table\s+$name\b[^;]+;
					|create\s+(unique\s+)?index\s+\w+\s+on\s+$name[^;]+;
					|create\s+sequence[^;]+;
					|comment\s+on\s+column\s+$name\.[^;]+;
					)+$/ix) {
			print "Bad $type content [$filename]\n";
			$error = 1;
		}
	} elsif ($type eq 'views') {
		if (not $content =~ /^(--.*\n
					|\s*\n
					|create(\s+or\s+replace)?\s+view\s+$name\b[^;]+;
					)+$/ix) {
			print "Bad $type content [$filename]\n";
			$error = 1;
		}
	} elsif ($type eq 'data') {
		if (not $content =~ /^(--.*\n
					|\s*\n
					|insert\s+into\s+$name\b[^;]+(values|select)('[^;]+(;[^;]*)*'|[^';])+;
					|commit;
					)+$/ix) {
			print "Bad $type content [$filename]\n";
			$error = 1;
		}
	} elsif ($type eq 'procs') {
		if (not $content =~ m!^(--.*\n
					|\s*\n
					|create(\s+or\s+replace)?\s+(procedure|function)\s+$name\b
						((?s:.+?);\n/\n
						|[^\$]+\$\$(?s:.+?)\s\$\$
							\s+language\s+(plpgsql|sql)(\s+(strict\s+)?immutable|\s+stable)?;)
					|show\s+errors;?\n
					)+$!ix) {
			print "Bad $type content [$filename]\n";
			$error = 1;
		}
	} elsif ($type eq 'synonyms') {
		if (not $content =~ m!^(--.*\n
					|\s*\n
					|create(\s+or\s+replace)?\s+synonym\s+$name\b\s+for[^;]+;
					|create(\s+or\s+replace)?\s+synonym\s+${name}s?_recid_seq\s+for[^;]+;
					)+$!ix) {
			print "Bad $type content [$filename]\n";
			$error = 1;
		}
	} elsif ($type eq 'triggers') {
		if (not $content =~ m!^(?:--.*\n
					|\s*\n
					|create(?:\s+or\s+replace)?\s+function\s+(\w+)(?s:.+?)\s+language\s+plpgsql;
						\s+create(\s+or\s+replace)?\s+trigger[^;]+\s+on\s+$name\b[^;]+execute\s+procedure\s+\1\(\);
					|create(\s+or\s+replace)?\s+trigger[^;]+\s+on\s+$name\b(?s:.+?);\n/\n
					|show\s+errors;?\n
					)+$!ix) {
			print "Bad $type content [$filename]\n";
			$error = 1;
		}
	} else {
		print "Unknown type [$type] for [$filename]\n";
	}
}

for my $c (sort keys %{ $files{common} }) {
	next unless $c =~ /\.(sql|pks|pkb)$/;
	check_file_content($files{common}{$c});
	for my $o (qw( oracle postgres )) {
		if (exists $files{$o}{$c}) {
			print "Common file [$c] is also in $o\n";
			$error = 1;
		}
	}
	my $oracle_sha1 = eval { get_first_line_sha1($files{common}{$c}) };
	if ($@) {
		print $@;
		$error = 1;
	} elsif (defined $oracle_sha1) {
		print "Common file [$c] specifies SHA1 of Oracle source but it should not\n";
		$error = 1;
	}
}

for my $c (sort keys %{ $files{oracle} }) {
	next unless $c =~ /\.(sql|pks|pkb)$/;
	check_file_content($files{oracle}{$c});
	if (not exists $files{postgres}{$c}) {
		if (not $c =~ /^synonyms|^triggers/) {
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
		$error = 1;
	} elsif (defined $oracle_sha1) {
		print "Oracle file [$c] specifies SHA1 of Oracle source but it should not\n";
		$error = 1;
	}
}

for my $c (sort keys %{ $files{postgres} }) {
	next unless $c =~ /\.(sql|pks|pkb)$/;
	check_file_content($files{postgres}{$c});
	my $oracle_sha1 = eval { get_first_line_sha1($files{postgres}{$c}) };
	if ($@) {
		print $@;
		$error = 1;
		next;
	}
	if (not defined $oracle_sha1) {
		print "PostgreSQL file [$c] does not specify SHA1 of Oracle source nor none\n";
		$error = 1;
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

