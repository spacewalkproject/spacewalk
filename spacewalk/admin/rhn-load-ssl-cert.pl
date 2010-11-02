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
use File::Find;
use Archive::Tar;

use RHN::ProxyInstall;

$ENV{PATH} = '/bin:/usr/bin';

my $usage = "usage: $0 --ssl-dir=<ssl_directory> --hostname=<hostname> " .
  "--channel=<target_config_channel> --org-id=<org_id> --version=<version> [ --help ]\n";

my $ssl_dir = '';
my $hostname = '';
my $channel = '';
my $version = '';
my $org_id;
my $help;

GetOptions("ssl-dir=s" => \$ssl_dir, "hostname=s" => \$hostname,
	   "channel=s" => \$channel, "org-id=i" => \$org_id, "version=s" => \$version, "help" => \$help);

if ($help or not ($ssl_dir and $hostname and $channel and $org_id)) {
  die $usage;
}

unless (-d $ssl_dir) {
  die "$ssl_dir is not a directory";
}

my $system_name = extract_system_name($hostname);
my $system_ssl_dir = File::Spec->catfile($ssl_dir, $system_name);

my %files_to_get = ('server.crt' => File::Spec->catfile($system_ssl_dir, 'server.crt'),
		    'server.key' => File::Spec->catfile($system_ssl_dir, 'server.key'),
		    'server.csr' => File::Spec->catfile($system_ssl_dir, 'server.csr'),
		    'RHN-ORG-TRUSTED-SSL-CERT' => File::Spec->catfile($ssl_dir, 'RHN-ORG-TRUSTED-SSL-CERT'),
		   );

my $trusted_rpm;
File::Find::find(sub { $trusted_rpm = $_ if /rhn-org-trusted.*noarch\.rpm/ }, $ssl_dir);

if ($trusted_rpm) {
  $files_to_get{$trusted_rpm} = File::Spec->catfile($ssl_dir, $trusted_rpm);
}

my $tar = new Archive::Tar;
$tar->add_files(values %files_to_get);

my ($ca_cert, $ca_rpm) = RHN::ProxyInstall->extract_ssl_cert(-target_config_channel => $channel,
							     -tardata => $tar->write(),
							     -org_id => $org_id,
                   -version => $version,
							    );

print "$ca_cert\n$ca_rpm\n";

exit 0;

sub extract_system_name {
  my $hostname = shift;

  my @hostname_parts = split(/\./, $hostname);
  my $system_name;

  if (scalar @hostname_parts > 2) {
    $system_name = join('.', splice(@hostname_parts, 0, -2));
  }
  else {
    $system_name = join('.', @hostname_parts);
  }

  return $system_name;
}

