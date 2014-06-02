#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

package Sniglets::Snapshot;
use strict;

use PXT::Utils;

use RHN::Action;
use RHN::Server;
use RHN::SystemSnapshot;
use RHN::DataSource::Channel;
use RHN::Exception;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:add_system_tag_bulk_cb' => \&add_system_tag_bulk_cb);
}


sub add_system_tag_bulk_cb {
  my $pxt = shift;
  my $tagname = $pxt->dirty_param('tag');

  if (length($tagname) > 256) {
    $pxt->push_message(local_alert => 'Tag names must be no more than 256 characters.');
    $pxt->redirect("/network/systems/ssm/provisioning/tag_systems.pxt");
  }

  my $transaction = RHN::DB->connect;

  eval {
    $transaction = RHN::SystemSnapshot->bulk_snapshot_tag(user_id => $pxt->user->id,
							  org_id => $pxt->user->org_id,
							  set_label => 'system_list',
							  tag_name => $tagname,
							  transaction => $transaction,
							 );
  };

  if ($@) {
    $transaction->rollback;
    die $@;
  }

  $transaction->commit;

  $pxt->push_message(site_info => 'Tag added.');
  $pxt->redirect("/network/systems/ssm/provisioning/tag_systems.pxt");
}

1;
