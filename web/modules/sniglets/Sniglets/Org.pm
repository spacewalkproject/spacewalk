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

package Sniglets::Org;

use POSIX qw/strftime/;
use RHN::Channel;
use RHN::API::Types;
use RHN::SatelliteCert;
use Carp;

use RHN::Exception qw/throw/;

sub reset_form {
  my $pxt = shift;

    $pxt->session->unset('new_cert_info');
    reset_and_commit_set($pxt->user->id, 'new_cert_channel_set');
    reset_and_commit_set($pxt->user->id, 'new_cert_add_channel_set');
    reset_and_commit_set($pxt->user->id, 'new_cert_service_set');
}

sub reset_and_commit_set {
  my $uid = shift;
  my $label = shift;

  my $set = RHN::Set->lookup(-label => $label, -uid => $uid);
  $set->empty();
  $set->commit();
}

1;
