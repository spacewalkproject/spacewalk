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

use strict;

package RHN::DB::ServerActions;

use RHN::DB ();

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub assign_set_to_group {
  my $class = shift;
  my $set = shift;
  my $sgid = shift;
  die "Invalid format for sgid $sgid" if $sgid =~ /\D/;	# contain nondigit? die

  my $query = <<EOQ;
BEGIN
  rhn_server.insert_set_into_servergroup(:server_group_id,:user_id,:label);
END;
EOQ
  my $label = $set->label;
  my $uid = $set->uid;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare($query);

  $sth->execute_h(server_group_id => $sgid, label => $set->label, user_id => $set->uid);

  $dbh->commit;
}

sub remove_set_from_group {
  my $class = shift;
  my $set = shift;
  my $sgid = shift;

  my $dbh = RHN::DB->connect();
  $dbh->call_procedure('rhn_server.delete_set_from_servergroup', $sgid, $set->uid, 'system_list');

  $dbh->commit;
}


1;
