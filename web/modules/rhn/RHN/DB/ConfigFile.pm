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

package RHN::DB::ConfigFile;
use RHN::DB;

# given a config file id, return the crid of the latest revision, if any
sub id_to_latest_revision_crid {
  my $class = shift;
  my $cf_id = shift;

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare('SELECT CFt.latest_config_revision_id FROM rhnConfigFile CFt WHERE CFT.id = :cf_id');
  $sth->execute_h(cf_id => $cf_id);

  my ($ret) = $sth->fetchrow;
  $sth->finish;

  return $ret;
}

# given a path, return the rhnConfigFileName id
sub path_to_id {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  return $dbh->call_function('lookup_config_filename', @_);
}

# given an id, return the rhnConfigFileName path
sub file_name_id_to_path {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT path FROM rhnConfigFileName WHERE id = ?");
  $sth->execute(@_);

  my ($ret) = $sth->fetchrow;
  $sth->finish;

  return $ret;
}

# given an rhnConfigFile id, delete it
sub delete_file_path {
  my $self = shift;
  my $cfid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->call_procedure('rhn_config.delete_file', $cfid);
  $dbh->commit;
}

# given a config file id, find the path
sub file_id_to_path {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT config_file_name_id FROM rhnConfigFile WHERE id = ?");
  $sth->execute(@_);

  my ($ret) = $sth->fetchrow;
  $sth->finish;
  return $class->file_name_id_to_path($ret);
}

1;
