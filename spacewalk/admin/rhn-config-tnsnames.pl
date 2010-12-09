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

my $usage = "usage: $0 --target=<target_file> --sid=<sid> --address=<proto,host,port> "
  . "[ --address=<proto,host,port> ] [ --help ]\n";

my $target = '';
my $sid = '';
my @options = ();
my $help = '';

GetOptions("target=s" => \$target, "sid=s" => \$sid, "address=s" => \@options, "help" => \$help) or die $usage;

if ($help) {
  die $usage;
}

unless ($target and $sid and (@options)) {
  die $usage;
}

my @addresses = parse_addresses(@options);
my $tnsdata = generate_tnsnames($sid, \@addresses);

if (-e $target) {
  rename($target, $target . ".orig") or die "Could not rename $target to ${target}.orig: $OS_ERROR";
}

open(TARGET, "> $target") or die "Could not open $target: $OS_ERROR";
select(TARGET);

print $tnsdata;

close(TARGET);

exit 0;

sub parse_addresses {
  my @options = @_;
  my @addresses;

  foreach my $opt (@options) {
    my @line = split(/,/, $opt);
    push @addresses, { protocol => $line[0],
		       host => $line[1],
		       port => $line[2],
		     };
  }

  return @addresses;
}

sub generate_tnsnames {
  my $sid = shift;
  my $addresses = shift;

  my $tnsnames_template =<<EOQ;
%s =
  (DESCRIPTION =
    (ADDRESS_LIST =
%s
    )
    (CONNECT_DATA =
      (SID = %s)
    )
  )
EOQ

  my $address_template = (' ' x 6) . '(ADDRESS = (PROTOCOL = %s)(HOST = %s)(PORT = %s))';

  my @address_lines;

  foreach my $address (@{$addresses}) {
    push @address_lines,
      sprintf($address_template, $address->{protocol}, $address->{host}, $address->{port});
  }

  my $tnsnames = sprintf($tnsnames_template, $sid, join("\n", @address_lines), $sid);

  return $tnsnames;
}


