#!/usr/bin/perl
#
# Copyright (c) 2008 Red Hat, Inc.
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
  . "--tablespace-name=<tabelspace> [ --help ]\n";

my $source = '';
my $target = '';
my $tablespace_name = '';
my $help = '';

GetOptions("source=s" => \$source, "target=s" => \$target,
	   "tablespace-name=s" => \$tablespace_name, "help" => \$help);

if ($help or not ($source and $target and $tablespace_name)) {
  die $usage;
}

open(SOURCE, "< $source") or die "Could not open $source: $OS_ERROR";
open(TARGET, "> $target") or die "Could not open $target for writing: $OS_ERROR";

while (my $line = <SOURCE>) {
  $line =~ s/\[\[.*\]\]/$tablespace_name/g;
  $line =~ s/__.*__/$tablespace_name/g;

  print TARGET $line;
}

close(SOURCE);
close(TARGET);

exit 0;
