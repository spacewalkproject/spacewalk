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

package RHN::DB::UserActions;

use RHN::DB ();

sub assign_set_to_group {
  my $class = shift;
  my $set = shift;
  my $ugid = shift;
  die "Invalid format for ugid $ugid" if $ugid =~ /\D/;	# contain nondigit? die

  my $dbh = RHN::DB->connect();

  my $query = "delete from rhnSet where user_id = :user_id and label = :label";
  my $sth0 = $dbh->prepare($query);
  $sth0->execute_h(user_id=>$set->uid, label=>"user_group_list");

  my $sth1 = $dbh->prepare(<<EOQ);
INSERT INTO rhnSet (user_id, label, element, element_two)
SELECT :user_id, 'user_group_list', element, :ugid
  FROM rhnSet
 WHERE label = :label
   AND uid = :user_id
MINUS
SELECT :user_id, 'user_group_list', ugm.user_id, :ugid
  FROM rhnUserGroupMembers
 WHERE user_group_id = :ugid
EOQ
  $sth1->execute_h(label=>$set->label, user_id=>$set->uid, ugid=>$ugid);

  $dbh->call_procedure("rhn_user.add_users_to_usergroups", $set->uid);

  $sth0->execute_h(user_id=>$set->uid, label=>"user_group_list");
  $dbh->commit;
}

sub remove_set_from_group {
  my $class = shift;
  my $set = shift;
  my $ugid = shift;

  my $dbh = RHN::DB->connect();

  my $query = "delete from rhnSet where user_id = :user_id and label = :label";
  my $sth0 = $dbh->prepare($query);
  $sth0->execute_h(user_id=>$set->uid, label=>"user_group_list");

  my $sth1 = $dbh->prepare(<<EOQ);
INSERT INTO rhnSet (user_id, label, element, element_two)
SELECT :user_id, 'user_group_list', element, :ugid
  FROM rhnSet
 WHERE label = :label
   AND user_id = :user_id
EOQ
  $sth1->execute_h(label=>$set->label, user_id=>$set->uid, ugid=>$ugid);

  $dbh->call_procedure("rhn_user.remove_users_from_usergroups", $set->uid);

  $sth0->execute_h(user_id=>$set->id, label=>"user_group_list");
  $dbh->commit;
}

1;
