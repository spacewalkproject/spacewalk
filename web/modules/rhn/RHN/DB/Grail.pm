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

package RHN::DB::Grail;
use RHN::DB;

sub components_for_user {
  my $class = shift;
  my $user_id = shift;

  my $dbh = RHN::DB->connect;
  my $query = "SELECT component_pkg, component_mode FROM rhnGrailComponentChoices WHERE user_id = ? ORDER BY ordering";
  my $sth = $dbh->prepare($query);
  $sth->execute($user_id);

  my @ret;
  while (my ($pkg, $mode) = $sth->fetchrow) {
    push @ret, [ $pkg, $mode ];
  }

  return @ret;
}

sub set_user_components {
  my $class = shift;
  my $uid = shift;
  my @components = @_;

  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
DELETE FROM rhnGrailComponentChoices WHERE user_id = ?
EOQ
  my $sth = $dbh->prepare($query);
  $sth->execute($uid);

  $query = <<EOQ;
INSERT INTO   rhnGrailComponentChoices
     SELECT   ?, ?, component_pkg, component_mode
       FROM   rhnGrailComponents GC
      WHERE   GC.id = ?
EOQ
  $sth = $dbh->prepare($query);

  my $i = 0;
  foreach (@components) {
    $sth->execute($uid, $i++, $_);
  }

  $dbh->commit;

}

1;
