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

my $usage = "usage: $0 --target=<target_file> --option=<key,value> "
  . "[ --option=<key,value> ] [ --help ]\n";

my $target = '';
my @options = ();
my $help = '';

GetOptions("target=s" => \$target, "option=s" => \@options, "help" => \$help);

if ($help) {
  die $usage;
}

unless ($target and (@options)) {
  die $usage;
}

my %options = map { split(/=/,$_, 2) } @options;

my $tmpfile = $target . ".bak.${PID}";

open(TARGET, "< $target") or die "Could not open $target: $OS_ERROR";
open(TMP, "> $tmpfile") or die "Could not open $tmpfile for writing: $OS_ERROR";

while (my $line = <TARGET>) {
  if ($line =~ /\[prompt\]/ or $line =~ /^#/) {
    print TMP $line;
    next;
  }

  foreach my $opt_name (keys %options) {
    if ($line =~ /^(\S*)\Q$opt_name\E( *)=( *)/) {
      my $prefix = defined $1 ? $1 : '';
      my $s1 = $2 || '';
      my $s2 = $3 || '';
      chomp($options{$opt_name});
      $line = "${prefix}${opt_name}${s1}=${s2}" . $options{$opt_name} . "\n";
      delete $options{$opt_name};
    }
  }

  print TMP $line;
}

# For the options that didn't exist in the file
# we need to append these to the end.
foreach my $opt_name (keys %options) {
    print $opt_name . "\n";
    chomp($options{$opt_name});
    my $line = "$opt_name=$options{$opt_name}\n\n";
    print TMP "#option generated from rhn-config-satellite.pl\n";
    print TMP $line;
    
}

close(TMP);
close(TARGET);

if (-e $target . ".orig") {
    unlink($target . ".orig") or die "Could not remove $target to ${target}.orig prior to new backup: $OS_ERROR";
}
link($target, $target . ".orig") or die "Could not rename $target to ${target}.orig: $OS_ERROR";
rename($tmpfile, $target) or die "Could not rename $tmpfile to $target: $OS_ERROR";;

exit 0;


