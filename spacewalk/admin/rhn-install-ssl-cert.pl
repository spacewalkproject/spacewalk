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

use File::Spec;

$ENV{PATH} = '/bin:/usr/bin';

my $usage = "usage: $0 --dir=<directory> [ --help ]\n";

my $dir = '';
my $help = '';

GetOptions("dir=s" => \$dir, "help" => \$help) or die $usage;

if ($help or not $dir) {
  die $usage;
}

unless (-d $dir) {
  die "$dir is not a directory";
}

my $latest_file = File::Spec->catfile($dir, 'latest.txt');

unless (-r $latest_file) {
  die "Could not read ${latest_file}.";
}

my @rpms;

open(LATEST, $latest_file) or die "Could not open '$latest_file' for reading: $OS_ERROR";

while (my $line = <LATEST>) {
  chomp $line;
  push @rpms, $line
    if ($line =~ /(?<!src)\.rpm$/);
}

close(LATEST);

foreach my $rpm (@rpms) {
  my $rpm_file = File::Spec->catfile($dir, $rpm);
  die "Could not read $rpm_file" unless (-r $rpm_file);

  my $ret = system('/bin/rpm', '-Uv', $rpm_file);

  if ($ret) {
    die "Could not install $rpm_file";
  }
}

exit 0;
