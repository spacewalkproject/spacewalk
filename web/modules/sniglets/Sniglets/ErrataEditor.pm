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

  $pxt->register_callback('rhn:errata_editor:errata_publish_cb' => \&errata_publish_cb);
  $pxt->register_callback('rhn:errata_editor:select_channels_cb' => \&select_channels_cb);
  $pxt->register_callback('rhn:errata_editor:errata_delete_cb' => \&errata_delete_cb);
  $pxt->register_callback('rhn:errata_editor:delete_bug' => \&delete_bug);
  $pxt->register_callback('rhn:errata_editor:mail_notification_cb' => \&mail_notification_cb);
  $pxt->register_callback('rhn:update_errata_cache' => \&update_errata_cache);
  $pxt->register_callback('rhn:clone_specified_errata_cb' => \&clone_specified_errata_cb);
  $pxt->register_callback('rhn:delete_errata_cb' => \&delete_errata_cb);
}

sub errata_publish_cb {
  my $pxt = shift;

  my $eid = $pxt->param('eid') || 0;
  throw 'No eid!' unless $eid;

  throw "user '" . $pxt->user->id . "' does not own errata '$eid'"
    unless $pxt->user->verify_errata_admin($eid);

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  my @channels = ();

  my $channel_set = RHN::Set->lookup(-label => 'target_channels_list', -uid => $pxt->user->id);
  push @channels, $channel_set->contents;

  $channel_set->empty;
  $channel_set->commit;

  if (not $pxt->user->verify_channel_admin(@channels)) {
    warn sprintf("User '%d' attempted to assign unpublished errata '%d' to one or more channels (%s) without permission.",
		 $pxt->user->id, $eid, join(', ', @channels));
    $pxt->redirect('/errors/permission.pxt');
  }

  my $fail_redir = $pxt->dirty_param('fail_redirect');
  throw "Param 'fail_redir' needed but not provided." unless $fail_redir;

  my $id;
  my $dbh = RHN::DB->connect;
  eval {
    $id = RHN::ErrataEditor->publish_errata($errata, $dbh);
    RHN::ErrataEditor->assign_errata_to_channels($id, \@channels);
  };
  if ($@) {
    $dbh->rollback;
    if (ref $@ and catchable($@)) {
      my $E = $@;

      if ($E->constraint_value eq 'RHN_ERRATA_ADVISORY_UQ') {
	$pxt->push_message(local_alert => 'A published errata with this advisory already exists.');
      }
      elsif ($E->constraint_value eq 'RHN_ERRATA_ADVISORY_NAME_UQ') {
	$pxt->push_message(local_alert => 'A published errata with this advisory name already exists');
      }
      else {
	throw $E;
      }
      $pxt->redirect($fail_redir . "?eid=${eid}"); # still here?  redirect.
    }
    else {
      die $@;
    }
  }

  $dbh->commit;

  foreach my $cid (@channels) {
    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 0);
  }

  my $package_list_edited = $pxt->session->get('errata_package_list_edited') || { };
  $package_list_edited->{$eid} = 0;
  $pxt->session->set(errata_package_list_edited => $package_list_edited);

  $pxt->push_message(site_info => sprintf ('Errata <strong>%s</strong> has been successfully published to <strong>%d</strong> channel%s.', $errata->advisory_name, scalar(@channels), (scalar(@channels) == 1 ? '' : 's')));

  my $redir = $pxt->dirty_param('success_redirect');
  throw "param 'success_redirect' needed but not provided" unless $redir;

  $pxt->redirect($redir);

  return;
}

sub select_channels_cb {
  my $pxt = shift;

  my $eid = $pxt->param('eid') || 0;
  throw 'No eid!' unless $eid;

  throw "user '" . $pxt->user->id . "' does not own errata '$eid'"
    unless $pxt->user->verify_errata_admin($eid);

  my $errata = RHN::Errata->lookup(-id => $eid);

  my @channels = ();

  my $channel_set = RHN::Set->lookup(-label => 'target_channels_list', -uid => $pxt->user->id);
  push @channels, $channel_set->contents;

  $channel_set->empty;
  $channel_set->commit;

  if (not $pxt->user->verify_channel_admin(@channels)) {
        warn sprintf("User '%d' attempted to assign errata '%d' to one or more channels (%s) without permission.", 
		 $pxt->user->id, $eid, join(', ', @channels));
    $pxt->redirect('/errors/permission.pxt');
  }

  my @old_channels = RHN::Errata->channels($eid); #need to keep these!

  RHN::ErrataEditor->assign_errata_to_channels($eid, \@channels);

  my %all_channels = map { ($_, 1) } (@old_channels, @channels);
  my @all_affected_channels = keys %all_channels;

  foreach my $cid (@all_affected_channels) {
    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 3600);
  }

  my $package_list_edited = $pxt->session->get('errata_package_list_edited') || { };
  $package_list_edited->{$eid} = time;
  $pxt->session->set(errata_package_list_edited => $package_list_edited);

  $pxt->push_message(site_info => sprintf ('Errata <strong>%s</strong> has been successfully assigned to <strong>%d</strong> channel%s.', $errata->advisory_name, scalar(@channels), (scalar(@channels) == 1 ? '' : 's')));

  my $redir = $pxt->dirty_param('success_redirect');
  throw "param 'success_redirect' needed but not provided" unless $redir;

  $pxt->redirect($redir . "?eid=$eid");

  return;
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

sub delete_bug {
  my $pxt = shift;

  my $eid = $pxt->param('eid') || 0;
  my $bug_id = $pxt->dirty_param('bug_id') || 0;

  return unless ($eid && $bug_id);

  throw "user '" . $pxt->user->id . "' does not own errata '$eid'"
    unless $pxt->user->verify_errata_admin($eid);

  my $errata;

  $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  $errata->delete_bug($bug_id);

  $pxt->redirect($pxt->uri . sprintf('?eid=%d', $eid));
  return;
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
