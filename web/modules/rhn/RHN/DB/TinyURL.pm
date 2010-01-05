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

package RHN::DB::TinyURL;
use strict;

use PXT::Utils;
use RHN::Utils;
use RHN::DB;
use RHN::Exception qw/throw/;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use URI::URL;

sub lookup {
  my $class = shift;
  my %params = validate(@_, {token => 1});
  my $token = $params{token};

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT url FROM rhnTinyURL
 WHERE token = :token
   AND expires > sysdate
   AND enabled = 'Y'
EOS
  $sth->execute_h(token => $token);

  my ($result) = $sth->fetchrow;
  $sth->finish;

  return $result;
}

sub create {
  my $class = shift;
  my $url = shift;
  my $expires = shift;

  $expires ||= RHN::Date->now->long_date;

  my $token;
  while (1) {
    $token = $class->random_url_string(8);
    my $exists = $class->lookup(-token => $token);
    last unless $exists;
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
INSERT INTO rhnTinyURL
  (token, url, enabled, expires)
VALUES
  (:token, :url, 'Y', TO_DATE(:expires, 'YYYY-MM-DD HH24:MI:SS') + 1/6)
EOS
  $sth->execute_h(token => $token, url => $url, expires => $expires);
  $dbh->commit;

  return $token;
}

my @encode_chars = ('a' .. 'z', 'A' .. 'Z', 0 .. 9, '_', '-');
sub random_url_string {
  my $class = shift;
  my $length = shift;

  my $bytes = PXT::Utils->random_bits($length * 6); # six bits of entropy per byte, requested $length bytes, ergo...
  my $bits = unpack("b*", $bytes);

  my $result = '';
  while ($bits) {
    my $chunk = substr($bits, 0, 6);
    substr($bits, 0, 6) = '';

    $result .= $encode_chars[ord pack("b*", $chunk)];
  }

  return $result;
}

1;
