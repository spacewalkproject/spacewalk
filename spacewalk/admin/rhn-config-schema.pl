#!/usr/bin/perl
#
# Copyright (c) 2008--2010 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
#
# $Id$

use strict;
use warnings;

use Getopt::Long;
use English;

$ENV{PATH} = '/bin:/usr/bin';

my $usage = "usage: $0 --source=<source_file> --target=<target_file> "
	. "--tablespace-name=<tablespace> [ --help ]\n";

my $source = '';
my $target = '';
my $tablespace_name = '';
my $help = '';

GetOptions("source=s" => \$source, "target=s" => \$target,
		 "tablespace-name=s" => \$tablespace_name, "help" => \$help) or die $usage;

if ($help or not ($source and $target and $tablespace_name)) {
	die $usage;
}

my $backend = 'oracle';
if ($source =~ m!/postgres(ql)?/!) {
	$backend = 'postgresql';
}

open(SOURCE, "< $source") or die "Could not open $source: $OS_ERROR";
open(TARGET, "> $target") or die "Could not open $target for writing: $OS_ERROR";

my $subdir_name = 'schema-override';
my $exception_dir;
($exception_dir = $source) =~ s!/[^/]+$!/$subdir_name!;

my %exception_files;
my @exception_queue = ( '' );
while (@exception_queue) {
	my $d = shift @exception_queue;
	if ($d ne '') {
		$d .= '/';
	}
	my $full_path = "$exception_dir/$d";
	if (-d $full_path) {
		if (opendir DIR, $full_path) {
			for (sort readdir DIR) {
				next if /^\.\.?$/;
				if (-d "$full_path$_") {
					push @exception_queue, "$d$_";
				} else {
					$exception_files{"$d$_"} = 1;
				}
			}
			closedir DIR;
		}
	}
}

my $marker_re = qr/^-- Source: (.+?)$|^select '(.+?)' sql_file from dual;$/;
my $line;

my %exception_seen;
while ($line = <SOURCE>) {
	if ($line =~ $marker_re) {
		my $filename = $1;
		if (not defined $filename) {
			$filename = $2;
			$filename =~ s!^.+/([^/]+/[^/]+)$!$1!;
		}
		my $full_file = undef;
		if (exists $exception_files{"$filename.$backend"}) {
			$full_file = "$exception_dir/$filename.$backend";
		} elsif (exists $exception_files{$filename}) {
			$full_file = "$exception_dir/$filename";
		}
		if (defined $full_file) {
			for my $e ( '', '.oracle', '.postgresql' ) {
				$exception_seen{"$filename$e"}++ if exists $exception_files{"$filename$e"};
			}
			open OVERRIDE, $full_file or die "Error reading file [$full_file]: $!\n";
			print TARGET "-- Source: $subdir_name/$filename\n\n";
			while (<OVERRIDE>) {
				s/\[\[.*\]\]/$tablespace_name/g;
				s/__.*__/$tablespace_name/g;
				print TARGET $_;
			}
			close OVERRIDE;
			while ($line = <SOURCE>) {
				if ($line =~ $marker_re) {
					last;
				}
			}
			print TARGET "\n";
			redo;
		}
	}
	$line =~ s/\[\[.*\]\]/$tablespace_name/g;
	$line =~ s/__.*__/$tablespace_name/g;

	print TARGET $line;
}

close(SOURCE);
close(TARGET);

my $error = 0;
for (sort keys %exception_seen) {
	if ($exception_seen{$_} > 1) {
		warn "Schema source [$source] loaded override [$_] more than once.\n";
		$error = 1;
	}
}
for (sort keys %exception_files) {
	if (not exists $exception_seen{$_}) {
		warn "Schema source [$source] did not use override [$_].\n";
		$error = 1;
	}
}
exit $error;

=pod

=head1 NAME

rhn-config-schema.pl - utility to populate Spacewalk database tablespacee.

=head2 SYNOPSIS

B<rhn-config-schema.pl> B<--source=SOURCE> B<--target=TARGET> B<--tablespace-name=TABLESPACE>

B<rhn-config-schema.pl> [B<--help>]

=head1 DESCRIPTION

This script is intended to run from inside of B<spacewalk-setup>. You do not want to run
it directly unless you really knows what are you doing.

=head1 OPTIONS

=over 5

=item B<--source=SOURCE>

Full path to main.sql file. Usually /etc/sysconfig/rhn/I<backend>/main.sql

=item B<--target=TARGET>

Full path to deploy.sql. Usually /etc/sysconfig/rhn/universe.deploy.sql

=item B<--tablespace-name=TABLESPACE>

Which tablespace will be populated. This does nothing with database itself,
this script just substitute template variables with given value of I<TABLESPACE>.

=item B<--help>

Display allowed parameters.

=back

=head1 SEE ALSO

B<rhn-schema-version>(8), B<satellite-debug>(8), B<send-satellite-debug>(8)

=cut
