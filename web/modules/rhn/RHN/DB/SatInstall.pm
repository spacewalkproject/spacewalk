#
# Copyright (c) 2008--2011 Red Hat, Inc.
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

package RHN::DB::SatInstall;

use strict;

use RHN::DB;

use RHN::Exception qw/throw/;

# The DB side of RHN::SatInstall.

my @allowed_db_versions = qw/920 817/;

sub test_db_connection {
  my $class = shift;
  my $dbh = RHN::DB->soft_connect;

  return 1 if $dbh;
}

sub test_db_schema {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  return eval {
  my $sth = $dbh->prepare(<<EOQ) or return;
SELECT 1
  FROM PXTSESSIONS
 WHERE 1 = 0
EOQ

  $sth->execute() or return;
  $sth->finish;
  return 1;
  };
}

sub update_monitoring_config {
  my $class = shift;
  my $mon_config = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
    UPDATE rhn_config_macro
    SET    definition = :definition,
           last_update_user = 'installer',
           last_update_date = current_timestamp
    WHERE  name = :name
EOQ

  foreach my $name (keys %{$mon_config}) {
    $sth->execute_h(name => $name, definition => $mon_config->{$name});
  }

  $dbh->commit;

  return;
}

sub get_satellite_org_id {
  my $class = shift;
  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare("SELECT MIN(id) FROM web_customer");
  $sth->execute;
  my ($org_id) = $sth->fetchrow;

  return $org_id;
}

1;
