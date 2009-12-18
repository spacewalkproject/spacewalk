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

  $pxt->register_tag('rhn-if-errata-package-list-modified' => \&if_errata_package_list_modified);

  $pxt->register_tag('rhn-if-var' => \&if_var, -5);
  $pxt->register_tag('rhn-unless-var' => \&unless_var, -5);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:errata_editor:mail_notification_cb' => \&mail_notification_cb);
  $pxt->register_callback('rhn:update_errata_cache' => \&update_errata_cache);
  $pxt->register_callback('rhn:clone_specified_errata_cb' => \&clone_specified_errata_cb);
  $pxt->register_callback('rhn:delete_errata_cb' => \&delete_errata_cb);
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

sub load_package_set {
  my $uid = shift;
  my $eid = shift;

  my $set = RHN::Set->lookup(-label => 'errata_package_list', -uid => $uid);
  $set->empty;
  $set->commit;

  my @packages_in_errata =
    RHN::ErrataEditor->packages_in_errata($eid);

  $set->add(@packages_in_errata);

  $set->commit;

  return 1;
}

sub if_errata_package_list_modified {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $eid = $pxt->param('eid');
  return unless $eid;

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  return if $errata->isa('RHN::DB::ErrataTmp'); #don't cache temp errata!

  my $package_list_edited = $pxt->session->get('errata_package_list_edited');
  my $edited = $package_list_edited->{$eid} || 0;

  if ((time - $edited) < 3600) {
    return $block;
  }

  return '';
}

sub mail_notification_cb {
  my $pxt = shift;

  my $eid = $pxt->param('eid');

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);
  throw "Errata '$eid' not published." if ($errata->isa('RHN::DB::ErrataTmp'));

  RHN::ErrataEditor->update_notification_queue($eid, 0);

  $pxt->push_message(site_info => sprintf('An errata mail update has been scheduled for <strong>%s</strong>.', $errata->synopsis));

  return;
}

sub clone_specified_errata_cb {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  throw "No eid" unless $eid;

  my $set_label = 'clone_errata_list';
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  $set->empty;
  $set->add($eid);
  $set->commit;

  my $redir = $pxt->dirty_param('redir');
  throw "param redir needed" unless $redir;

  $pxt->redirect($redir . "?set_label=${set_label}");

  return;
}

sub delete_errata_cb {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);
  my $advisory = $errata->advisory;

  RHN::ErrataEditor->delete_errata($eid);

  $pxt->push_message(site_info => "Deleted errata <strong>$advisory</strong>.");
  $pxt->redirect('/network/errata/manage/list/published.pxt');
}

1;
