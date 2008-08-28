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

use strict;
use lib '/var/www/lib';

use Getopt::Long;

use POSIX qw/strftime/;
use RHN::SatelliteCert;
use RHN::CertUtils;
use RHN::DataSource::Channel;

# The RHN Keys:
#   pub  1024D/F24F1B08 2002-04-23 Red Hat, Inc (Red Hat Network) <rhn-feedback@redhat.com>
#   sub  2048g/F95A98CB 2002-04-23 [expires: 2004-04-22]
# and
#   pub  1024D/5A27881F 2003-12-16 Red Hat, Inc (Red Hat Network) <rhn-feedback@redhat.com>
#   sub  2048g/646E68AD 2003-12-16 [expires: 2007-12-15]

my $filename;
my $owner;
my $org_id;
my $signer;
my $no_passphrase;
my $expires;
my ($slots, $provisioning_slots);
my %channel_families;
my @roles;
my @sgroups;
my $sat_version = 1.0;
my $resign;
my $dsn = "phx";
my $generation = 2;

GetOptions("output=s" => \$filename, "orgid=n" => \$org_id, 
	   "owner=s" => \$owner, "signer=s" => \$signer, 
           "no-passphrase" => \$no_passphrase,
	   "role=s" => \@roles, "sgroup=s" => \@sgroups,
	   "expires=s" => \$expires, "slots=n" => \$slots, "provisioning-slots=n" => \$provisioning_slots,
	   "channel-family=n" => \%channel_families,
	   "dsn=s" => \$dsn,
	   "generation=s" => \$generation,
	   "resign=s" => \$resign, "satellite-version=s" => \$sat_version);

$filename = $resign if $resign and not $filename;

die "Usage: $0 --dsn <dsn> --orgid <org_id> --owner <owner_name> --role <role1> --role <role2> --sgroup <g1> --sgroup <g2> --signer <signer> --no-pass-phrase --output <dest> --expires <when> --slots <num> [ --provisioning-slots <num> ] [ --channel-family label=n ] [ --satellite-version X.Y ]"
  unless $filename && $signer && ($resign || ($expires && $slots && $owner));

my $passphrase = $no_passphrase ? undef : RHN::CertUtils->passphrase_prompt;

my $cert;
if ($resign) {
  use IO::File;
  my $fh = new IO::File "<$resign";
  die "Error opening cert to resign: $!" unless $fh;
  my $data = do { local $/; <$fh> };
  (undef, $cert) = RHN::SatelliteCert->parse_cert($data);
  $cert->set_field(issued => strftime("%Y-%m-%d %H:%M:%S", localtime
                         Date::Parse::str2time($cert->get_field('issued'))));
  $cert->set_field(expires => strftime("%Y-%m-%d %H:%M:%S", localtime 
                         Date::Parse::str2time($cert->get_field('expires'))));
  die "Error parsing satellite cert" unless $cert;
}
else {
  $cert = new RHN::SatelliteCert;

  $cert->set_field(product => "RHN-SATELLITE-001");
  $cert->set_field(owner => $owner);
  $cert->set_field(issued => strftime("%Y-%m-%d %H:%M:%S", 
                                      localtime time));
  $cert->set_field(expires => strftime("%Y-%m-%d %H:%M:%S", localtime 
                                       Date::Parse::str2time($expires)));
  $cert->set_field(slots => $slots);
  $cert->set_field('provisioning-slots' => $provisioning_slots)
    if $provisioning_slots;

  $cert->set_channel_family($_ => $channel_families{$_}) for keys %channel_families
}

if ($generation) {
  $cert->set_field(generation => $generation);
}
else {
  $cert->clear_field('generation');
}

$cert->set_field("satellite-version" => $sat_version) if $sat_version != 1.0;

my $ds = new RHN::DataSource::Channel(-dsn => $dsn, -mode => 'all_rh_channel_families_insecure');
my $results = $ds->execute_query;

my %seen_families;
for my $family ($cert->get_channel_families) {
  if (exists $seen_families{$family->[0]}) {
    warn "Duplicate family: $family->[0], continuing...\n";
  }
  $seen_families{$family->[0]}++;

  warn "Channel family '$family->[0]' not found in database, continuing...\n" unless grep { $family->[0] eq $_->{LABEL} } @$results;
}

#$cert->set_field("roles" => join(", ", @roles) || '');
#$cert->set_field("server_groups" => join(", ", @sgroups) || '');

$cert->write_to_file($filename, $passphrase, $signer);

my $cert_text;
open FH, "<$filename" or die "Can't re-open $filename: $!";
{ local $/; $cert_text = <FH>; }
close FH;

my ($new_signature, $new_cert) = RHN::SatelliteCert->parse_cert($cert_text);

my $result = $new_cert->check_signature($new_signature);
my $retval = 0;
if ($result) {
  print "Signatures signed by $result->{user} ($result->{keyid}).\n"
}
else {
  print "Signature validation failed.\n";
  $retval = 1;
}

print "Certificate saved as $filename\n";
exit $retval;
