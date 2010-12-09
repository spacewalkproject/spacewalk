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
use lib '/var/www/lib';

use RHN::SatelliteCert;

use Getopt::Long;

my $keyring = "/etc/webapp-keyring.gpg";
my $quiet;
my $required_version;
my $show_help;
my $nosig;
my $allow_old;

GetOptions("keyring=s", \$keyring, "quiet" => \$quiet, "nosig" => \$nosig, "allow-old" => \$allow_old,
           "required-version=s" => \$required_version, "help" => \$show_help) or die $usage;

if ($show_help) {
  print "See 'man validate-sat-cert' for details on usage.\n";
  exit 1;
}

my $data = join("", <>);

my ($signature, $cert) = RHN::SatelliteCert->parse_cert($data);

if (not $cert->get_field('generation') and not $allow_old) {
  print "Error: Your satellite certificate is no longer valid.  Please contact your support representative.\n";
  exit 3;
}

if ($required_version and $required_version ne $cert->version) {
  printf "Error: certificate and satellite version mismatch ('%s' vs '%s')\n",
	      $required_version, $cert->version;
  exit 2;
}

$cert->check_required_fields();

if ($nosig) {
  print "GPG signature *not* checked.\nCertificate parsed correctly.\n"
    unless $quiet;
  exit 0;
}

my $result = $cert->check_signature($signature, $keyring);

if ($result == 1) {
    print "Certificate validated successfully.\n"
      unless $quiet;
}
else {
  print "Error: Your satellite certificate signature is not valid.  Please contact your support representative.\n";
  exit 3;
}


