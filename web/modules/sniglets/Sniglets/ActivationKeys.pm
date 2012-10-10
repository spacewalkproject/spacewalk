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

use strict;

package Sniglets::ActivationKeys;

use RHN::Token;
use RHN::Exception qw(throw);
use PXT::Utils;

sub register_tags {
  my $class = shift;
  my $pxt = shift;
}



sub create_token {
  my $class = shift;
  my $pxt = shift;

  my $token = RHN::Token->create_token;
  $token->user_id($pxt->user->id);
  $token->org_id($pxt->user->org_id);

  return $token;
}

1;
