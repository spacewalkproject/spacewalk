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

  # hosted always has schema
  return 1 unless PXT::Config->get("satellite");

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT object_name
  FROM user_objects
 WHERE NOT object_name = 'PLAN_TABLE'
EOQ

  $sth->execute;
  my ($row) = $sth->fetchrow;
  $sth->finish;

  return 0 unless $row;

  $sth = $dbh->prepare(<<EOQ);
SELECT 1
  FROM user_objects
 WHERE object_name = 'PXTSESSIONS'
EOQ

  $sth->execute;
  ($row) = $sth->fetchrow;
  $sth->finish;

  return $row ? 1 : 0;
}

sub get_nls_database_parameters {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT NDP.parameter, NDP.value
  FROM nls_database_parameters NDP
EOQ

  $sth->execute();

  my %nls_database_parameters;

  while (my ($param, $value) = $sth->fetchrow()) {
    $nls_database_parameters{$param} = $value;
  }

  return %nls_database_parameters;
}

sub clear_db {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  if (grep { $dbh->{Name} eq $_ } qw/webdev webqa web phx live prod/) {
    throw "No!  Attempt to clear db: '" . $dbh->{Name} . "'\n";
  }

  my $select_sth = $dbh->prepare(<<EOQ);
  SELECT 'drop ' || UO.object_type ||' '|| UO.object_name AS DROP_STMT
    FROM user_objects UO
   WHERE UO.object_type NOT IN ('TABLE', 'INDEX', 'TRIGGER', 'LOB')
UNION
  SELECT 'drop ' || UO.object_type ||' '|| UO.object_name
         || ' cascade constraints' AS DROP_STMT
    FROM user_objects UO
   WHERE UO.object_type = 'TABLE'
     AND UO.object_name NOT LIKE '%$%'
EOQ

  $select_sth->execute();

  while (my ($drop_stmt) = $select_sth->fetchrow()) {
    my $drop_sth = $dbh->prepare($drop_stmt);
    $drop_sth->execute();
  }

  $dbh->commit;

  return;
}

sub schema_version {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
   SELECT VI.label,
          VI.name_id,
          VI.evr_id,
          PN.name,
          PE.evr.as_vre_simple() AS VRE
     FROM rhnPackageName PN,
          rhnPackageEVR PE,
          rhnVersionInfo VI
    WHERE PN.id = VI.name_id
      AND PE.id = VI.evr_id
EOQ

  $sth->execute();

  my $version;

  while (my $row = $sth->fetchrow_hashref()) {

    if ($row->{LABEL} eq 'schema') {
      $version = $row->{VRE};
      last;
    }
  }

  $sth->finish;

  return $version;
}

sub update_monitoring_config {
  my $class = shift;
  my $mon_config = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
    UPDATE rhn_config_macro
    SET    definition = :definition,
           last_update_user = 'installer',
           last_update_date = sysdate
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

sub valid_cert_countries {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
  SELECT VC.code AS VALUE,
         nvl(TL.short_name_tl, VC.short_name) AS LABEL
    FROM valid_countries VC,
         valid_countries_tl TL
   WHERE TL.lang (+) = 'en'
     AND TL.code (+)= VC.code
ORDER BY VC.short_name
EOQ

  $sth->execute;

  my @rows;

  while (my $row = $sth->fetchrow_hashref()) {
    my $conv;
    $conv->{$_} = $row->{uc($_)} foreach qw/value label/;
    push @rows, $conv;
  }

  return @rows;
}

1;
