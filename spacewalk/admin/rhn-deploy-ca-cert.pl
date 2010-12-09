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

my $usage = "usage: $0 --source-dir=<source-directory> --target-dir=<target-directory> [ --help ]\n";

my $source_dir = '';
my $target_dir = '';
my $help = '';

GetOptions("source-dir=s" => \$source_dir, "target-dir=s" => \$target_dir, "help" => \$help) or die $usage;

if ($help or not ($source_dir and $target_dir)) {
  die $usage;
}

foreach my $dir ($source_dir, $target_dir) {
  unless (-d $dir) {
    die "$dir is not a directory";
  }
}

my $latest_file = File::Spec->catfile($source_dir, 'latest.txt');

unless (-r $latest_file) {
  die "Could not read ${latest_file}.";
}

my $rpm;
my $cert;

open(LATEST, $latest_file) or die "Could not open '$latest_file' for reading: $OS_ERROR";

while (my $line = <LATEST>) {
  chomp($line);

  $rpm = File::Spec->catfile($source_dir, $line)
    if ($line =~ /(?<!src)\.rpm$/);
  $cert = File::Spec->catfile($source_dir, $line)
    if ($line =~ /CERT$/);
}

close(LATEST);

unless ($cert) {
  die "Could not find cert file in $latest_file";
}

unless ($rpm) {
  die "Could not find cert rpm in $latest_file";
}

my $ret = system('cp', $cert, $target_dir);

if ($ret) {
  die "Could not copy $cert to $target_dir";
}

$ret = system('cp', $rpm, $target_dir);

if ($ret) {
  die "Could not copy $rpm to $target_dir";
}

exit 0;
