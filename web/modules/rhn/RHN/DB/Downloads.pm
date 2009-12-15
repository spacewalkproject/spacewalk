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

package RHN::DB::Downloads;

use strict;
use RHN::DB;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

sub record_download {
  my $class = shift;
  my %params = validate(@_, { file_id => 1, location => 1, token => 1, ip => 1, user_id => 1 });

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnFileDownload
  (file_id, location, token, requestor_ip, start_time, user_id)
VALUES
  (:file_id, :location, :token, :ip, sysdate, :user_id)
EOQ
  $sth->execute_h(map { $_ => $params{$_} } keys %params);
  $dbh->commit;
}

# bump the order of a given category up in the list
sub bump_channel_category {
  my $class = shift;
  my %params = validate(@_, { channel_id => 1, category => 1 });

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT 1
  FROM rhnDownloads D
 WHERE D.id IN (SELECT CD.downloads_id
                  FROM rhnChannelDownloads CD
                 WHERE CD.channel_id = :cid)
   AND D.category = :category
EOQ

  $sth->execute_h(cid => $params{channel_id}, category => $params{category});
  my ($row) = $sth->fetchrow;

  unless ($row) {
    die sprintf('Could not find a category named "%s" for channel id "%d"',
		$params{category}, $params{channel_id});
  }

  $sth = $dbh->prepare(<<EOQ);
UPDATE rhnDownloads D
   SET D.ordering = D.ordering + 50
 WHERE D.id IN (SELECT CD.downloads_id
                  FROM rhnChannelDownloads CD
                 WHERE CD.channel_id = :cid)
   AND NOT D.category = :category
EOQ

  $sth->execute_h(cid => $params{channel_id}, category => $params{category});
  $dbh->commit;

  return;
}

sub get_file_id {
  my $class = shift;
  my $file_path = shift;

  my $dbh = RHN::DB->connect();

  my $sth = $dbh->prepare(<<EOQ);
SELECT id FROM rhnFile WHERE path = :file_path
EOQ

  $sth->execute_h(file_path => $file_path);
  my ($file_id) = $sth->fetchrow;
  $sth->finish;

  return $file_id;
}

1;
