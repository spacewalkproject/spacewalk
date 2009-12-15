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

# return 0 if the version is allowed, otherwise dies with the version

sub check_db_version {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  my ($v, $c);

  $dbh->call_procedure('dbms_utility.db_version', \$v, \$c);

  my $version = join('', (split(/\./, $v))[0 .. 2]);

  throw "Invalid db version: ($v, $c)" unless
    grep { $version == $_ } @allowed_db_versions;

  return 0;
}

# Find the default tablespace name for the given (oracle) user.
sub get_default_tablespace_name {
  my $class = shift;
  my $db_user = shift;

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT UU.default_tablespace
  FROM user_users UU
 WHERE UU.username = upper(:uname)
EOQ

  $sth->execute_h(uname => $db_user);

  my ($ts) = $sth->fetchrow();
  $sth->finish;

  throw "No tablespace found for user '$db_user'"
    unless $ts;

  return $ts;
}

sub check_db_privs {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT DISTINCT privilege
  FROM (
          SELECT USP.privilege
            FROM user_sys_privs USP
        UNION
          SELECT RSP.privilege
            FROM role_sys_privs RSP,
                 user_role_privs URP
           WHERE RSP.role = URP.granted_role
        UNION
          SELECT RSP.privilege
            FROM role_sys_privs RSP,
                 role_role_privs RRP,
                 user_role_privs URP1,
                 user_role_privs URP2
           WHERE URP1.granted_role = RRP.role
             AND RRP.role = URP2.granted_role
             AND URP2.granted_role = RSP.role
       )
 WHERE privilege = :priv
EOQ

  my @required_privs =
    ('ALTER SESSION',
     'CREATE SEQUENCE',
     'CREATE SYNONYM',
     'CREATE TABLE',
     'CREATE VIEW',
     'CREATE PROCEDURE',
     'CREATE TRIGGER',
     'CREATE TYPE',
     'CREATE SESSION',
    );

  foreach my $priv (@required_privs) {
    $sth->execute_h(priv => $priv);
    my ($got_priv) = $sth->fetchrow();

    unless ($got_priv) {
      throw "Missing privilege: $priv";
    }

    $sth->finish;
  }

  return 0;
}

# returns 0 if the tablespace settings are good, dies with error(s) otherwise
sub check_db_tablespace_settings {
  my $class = shift;

  my $oracle_user = shift;
  my $tablespace_name = $class->get_default_tablespace_name($oracle_user);

  $class->check_db_privs();

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT UT.status, UT.contents, UT.logging
  FROM user_tablespaces UT
 WHERE UT.tablespace_name = :tname
EOQ

  $sth->execute_h(tname => $tablespace_name);
  my $row = $sth->fetchrow_hashref;
  $sth->finish;

  unless (ref $row eq 'HASH' and (%{$row})) {
    throw "tablespace $tablespace_name does not appear to exist";
  }

  my %expectations = (STATUS => 'ONLINE',
		      CONTENTS => 'PERMANENT',
		      LOGGING => 'LOGGING',
		     );
  my @errs = ();

  foreach my $column (keys %expectations) {
    if ($row->{$column} ne $expectations{$column}) {
      push @errs, sprintf("tablespace %s has %s set to %s where %s is expected",
			  $tablespace_name, $column, $row->{$column}, $expectations{$column});
    }
  }

  if (@errs) {
    throw "Tablespace errors: " . join(';', @errs);
  }

  return 0;
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

my @ALLOWED_CHARSETS = qw/UTF8 AL32UTF8/;

# returns 0 if the db is using UTF8, dies with actual character set otherwise.
sub check_db_charsets {
  my $class = shift;

  my %nls_database_parameters = $class->get_nls_database_parameters();

  unless (exists $nls_database_parameters{NLS_CHARACTERSET} and
	  grep { $nls_database_parameters{NLS_CHARACTERSET} eq $_ } @ALLOWED_CHARSETS) {
    throw "DB is using an invalid (non-UTF8) character set: (NLS_CHARACTERSET = "
      . $nls_database_parameters{NLS_CHARACTERSET} . ")";
  }

  return 0;
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

sub create_satellite_org {
  my $class = shift;
  my $org_name = shift;

  my $dbh = RHN::DB->connect;

  my ($org_id) = $class->get_satellite_org_id;

  if (defined $org_id) {
    throw "Attempt create an org on satellite when one already exists";
  }

  $dbh->call_procedure("create_first_org", $org_name, PXT::Utils->random_password(16));

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
