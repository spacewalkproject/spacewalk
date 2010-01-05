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

package RHN::Grail;

use RHN::DB::Grail;

sub components_for_user {
  my $class = shift;
  my $user = shift;

  return RHN::DB::Grail->components_for_user($user);
}

sub set_user_components {
  my $class = shift;

  RHN::DB::Grail->set_user_components(@_);
}

1;
