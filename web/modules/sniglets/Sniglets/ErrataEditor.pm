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

package Sniglets::ErrataEditor;

use RHN::Errata;
use RHN::ErrataEditor;
use RHN::Exception;
use RHN::ChannelEditor;
use RHN::Package;
use RHN::DB;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-if-var' => \&if_var, -5);
  $pxt->register_tag('rhn-unless-var' => \&unless_var, -5);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:update_errata_cache' => \&update_errata_cache);
}

sub update_errata_cache {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  die "ErrataEditor::update_errata_cache called without eid"
    unless $eid;

  foreach my $cid (RHN::Errata->channels($eid)) {
    unless ($pxt->user->verify_channel_admin($cid)) {
      $pxt->redirect("/errors/permission.pxt");
    }

    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid);
  }

  my $package_list_edited = $pxt->session->get('errata_package_list_edited');
  $package_list_edited->{$eid} = 0;
  $pxt->session->set(errata_package_list_edited => $package_list_edited);

  $pxt->redirect($pxt->uri . "?eid=$eid");
}

sub if_var {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  return unless $pxt->passthrough_param($attr{formvar});

  return $block;

}

sub unless_var {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  return if $pxt->passthrough_param($attr{formvar});

  return $block;

}

1;
