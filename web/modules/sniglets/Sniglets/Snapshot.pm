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

  $pxt->register_tag('rhn-snapshot-tag-details' => \&snapshot_tag_details);
  $pxt->register_tag('rhn-snapshot-details' => \&snapshot_details);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:system_snapshot_rollback_cb' => \&system_snapshot_rollback_cb);
  $pxt->register_callback('rhn:add_system_tag_cb' => \&add_system_tag_cb);
  $pxt->register_callback('rhn:add_system_tag_bulk_cb' => \&add_system_tag_bulk_cb);
}


sub snapshot_tag_details {
  my $pxt = shift;
  my %params = @_;

  my $tag_id = $pxt->param('tag_id');
  die 'no tag id' unless $tag_id;

  my $tag = RHN::Tag->lookup(-id => $tag_id);

  my %sub;
  $sub{tag_name} = $tag->name;

  return PXT::Utils->perform_substitutions($params{__block__}, \%sub);
}

sub snapshot_details {
  my $pxt = shift;
  my %params = @_;

  my $sid = $pxt->param('sid');
  die "no sid" unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);

  my $snapshot_id = $pxt->param('ss_id');
  die 'no snapshot_id' unless $snapshot_id;

  my $snapshot = RHN::SystemSnapshot->lookup(-id => $snapshot_id);
  die 'no snapshot' unless $snapshot;

  my %subs;


  $subs{snapshot_created} = $snapshot->created;
  $subs{snapshot_modified} = $snapshot->modified;


  my $invalid_reason_label = $snapshot->invalid_reason_label;

  my @errors;

  if ($invalid_reason_label) {

    if ($invalid_reason_label eq 'sg_removed') {
      push @errors, <<EOM;
One or more of the system groups from the snapshot has been deleted.<br />
This may have some effect upon who may manage the system upon rollback.
EOM
    }
    elsif ($invalid_reason_label eq 'channel_removed') {
      push @errors, <<EOM;
One or more of the channels from the snapshot has been deleted.<br />
This might affect the ability of the system to rollback to the snapshot package set.
EOM
    }
    elsif ($invalid_reason_label eq 'channel_modified') {
      # hm.  when would this happen?  package deletion?
      push @errors, <<EOM;
One or more of the channels from the snapshot has been modified.<br />
This might affect the ability of the system to rollback to the snapshot package set.
EOM
    }
    elsif ($invalid_reason_label eq 'ns_removed') {
      push @errors, <<EOM;
One or more of the namespaces from the snapshot has been deleted.<br />
This may have an effect upon the configuration files that will be deployed upon rollback.
EOM
    }
    else {
      push @errors, $snapshot->invalid_reason_name;
    }
  }


  if (not $snapshot->package_list_is_servable()) {
    push @errors, sprintf(<<EOM, $sid, $snapshot_id);
The snapshot package list has <a href="unservable_packages.pxt?sid=%s&amp;ss_id=%s">unservable packages</a>; do not attempt to rollback.
EOM
  }

  if (@errors) {
    $subs{snapshot_invalid_reason} = "<div class=\"local-alert\">". join("\n", map {('<p>', $_, '</p>')} @errors) ."</div>";
  }
  else {
    $subs{snapshot_invalid_reason} = '';
  }


  my $can_deploy = $server->client_capable('configfiles.deploy');
  my $can_delta = $server->client_capable('packages.runTransaction');

  if ($can_deploy and not $can_delta) {
    $subs{snapshot_invalid_reason} = 'This system does not appear to support package transactions.  Your package list will <strong>not</strong> be able to be affected upon rollback.';
  }

  my $size;
  my $size_str;
  my @diffs;

  @diffs = $snapshot->group_diffs($pxt->user->org_id);
  $size = scalar @diffs;
  $size_str = $size > 1 ? 's' : '';

  $subs{snapshot_group_diffs_count} = $size ? "<strong>$size change$size_str</strong>" : 'no changes';

  @diffs = $snapshot->channel_diffs;
  $size = scalar @diffs;
  $size_str = $size > 1 ? 's' : '';
  $subs{snapshot_channel_diffs_count} =  $size ? "<strong>$size change$size_str</strong>" : 'no changes';

  @diffs = $snapshot->config_channel_diffs;
  $size = scalar @diffs;
  $size_str = $size > 1 ? 's' : '';
  $subs{snapshot_namespace_diffs_count} = $size ? "<strong>$size change$size_str</strong>" : 'no changes';

  @diffs = $snapshot->package_diffs;

  if ($can_delta) {

    # an upgrade/downgrade is one difference...
    my %package_name_ids;
    foreach my $diff (@diffs) {
      my ($name_id) = split /[|]/, ((keys %{$diff})[0]);

      if ($package_name_ids{$name_id}) {
	$package_name_ids{$name_id}++;
      }
      else {
	$package_name_ids{$name_id} = 1;
      }
    }

    $size = scalar keys %package_name_ids;
    $size_str = $size > 1 ? 's' : '';
    $subs{snapshot_package_diffs_count} = $size ? "<strong>$size change$size_str</strong>" : 'no changes';
  }
  else {
    $subs{snapshot_package_diffs_count} = 'no changes (no transaction support)';
  }


  return PXT::Utils->perform_substitutions($params{__block__}, \%subs);
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

sub add_system_tag_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  my $ss_id = $pxt->param('ss_id');

  die "no sid" unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server obj" unless $server;

  my $tagname = $pxt->dirty_param('tag');

  if (length($tagname) > 256) {
    $pxt->push_message(local_alert => 'Tag names must be no more than 256 characters.');

    if ($ss_id) {
	$pxt->redirect("/network/systems/details/history/snapshots/add_snapshot_tag.pxt?sid=$sid&ss_id=$ss_id");
    }
    else {
	$pxt->redirect("/network/systems/details/history/snapshots/add_system_tag.pxt?sid=$sid");
    }
  }

  my $transaction = RHN::DB->connect;

  eval {
    $server->add_system_tag(tagname => $tagname, ss_id => $ss_id);
  };

  if ($@) {
    my $E = $@;
    $transaction->rollback;

    if ($E->constraint_value eq 'RHN_SS_TAG_SID_TID_UQ'
	or $E->constraint_value eq 'RHN_SS_TAG_SSID_TID_UQ') {
      my $msg = "That tag already exists for this system.  Please choose another tag name.";
      $pxt->push_message(local_alert => $msg);

      if ($ss_id) {
	  $pxt->redirect("/network/systems/details/history/snapshots/add_snapshot_tag.pxt?sid=$sid&ss_id=$ss_id");
      }

      $pxt->redirect("/network/systems/details/history/snapshots/add_system_tag.pxt?sid=$sid");
    }
    else {
      die $@;
    }
  }

  $transaction->commit;


  if ($ss_id) {
      $pxt->push_message(site_info => 'Tag added to snapshot.');
      $pxt->redirect("/network/systems/details/history/snapshots/snapshot_tags.pxt?sid=$sid&ss_id=$ss_id");
  }

  $pxt->push_message(site_info => 'Tag added to system.');
  $pxt->redirect("/network/systems/details/history/snapshots/system_tags.pxt?sid=$sid");
}




sub system_snapshot_rollback_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  die "no sid" unless $sid;
  PXT::Utils->untaint(\$sid);

  my $snapshot_id = $pxt->param('ss_id');
  die "no snapshot id" unless $snapshot_id;
  PXT::Utils->untaint(\$snapshot_id);

  my %results;
  my $trans = RHN::DB->connect;
  $trans->nest_transactions;

  eval {
    %results = RHN::SystemSnapshot->rollback_to_snapshot(user_id => $pxt->user->id,
							 org_id => $pxt->user->org_id,
							 server_id => $sid,
							 snapshot_id => $snapshot_id,
							);
    $trans->nested_commit;
  };

  if ($@) {
    $trans->nested_rollback;
    my $E = $@;
    if ($E->is_rhn_exception('channel_family_no_subscriptions')) {
      $pxt->push_message(local_alert => "Insufficient channel subscriptions to complete rollback; aborted.");
    }
    else {
      throw $E;
    }
  }
  else {
    $pxt->push_message(site_info => "Channels and groups changed.");
    $pxt->push_message(site_info => "Package delta scheduled.") if $results{is_some_pkg_delta};
    $pxt->push_message(site_info => "Config files scheduled for deployment.") if $results{deployed_config_files};
    $pxt->redirect("/network/systems/details/history/pending.pxt?sid=$sid");
  }
}

1;
