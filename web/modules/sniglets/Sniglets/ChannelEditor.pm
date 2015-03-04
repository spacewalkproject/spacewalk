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

use strict;

package Sniglets::ChannelEditor;

use RHN::ChannelEditor;
use RHN::Channel;
use RHN::Exception;
use PXT::Utils;
use Sniglets::Channel;

use RHN::DataSource::Package;
use RHN::DataSource::Channel;
use RHN::Form::ParsedForm ();
use RHN::Form::Widget::RadiobuttonGroup;
use RHN::Form::Widget::Select;


sub register_tags {
  my $class = shift;
  my $pxt = shift;
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:channel_view_cb' => \&channel_view_cb);
  $pxt->register_callback('rhn:channel_edit_cb' => \&channel_edit_cb);
  $pxt->register_callback('rhn:update_channel_cache' => \&update_channel_cache);
  $pxt->register_callback('rhn:clone_channel_cb' => \&clone_channel_cb);
}

sub channel_view_cb {
  my $pxt = shift;

  my $cid = $pxt->param('cid') || 0;
  my $eid = $pxt->param('eid') || 0;
  my $view_channel = $pxt->param('view_channel') || 0;

  die "Missing formvar 'view_channel'."
    unless $view_channel;

  my $url = $pxt->uri . "?view_channel=${view_channel}";

  if ($cid) {
    $url .= "&cid=${cid}";
  }
  elsif ($eid) {
    $url .= "&eid=${eid}";
  }
  elsif ($pxt->dirty_param('clone_errata')) {
    my $show_all = $pxt->dirty_param('show_all_errata') || 0;

    if ($show_all) {
      $url .= "&show_all_errata=1";
    }
  }
  else { # Package manager - Need to clear the deletable package list
    my $set = RHN::Set->lookup(-label => 'deletable_package_list', -uid => $pxt->user->id);
    $set->empty;
    $set->commit;
  }

  $pxt->redirect($url);
}

sub channel_edit_cb {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  $cid = '' if $cid =~ /\D/;

  my $new_channel = $cid ? 0 : 1;

  my $parent_id = $pxt->dirty_param('channel_parent');
  die "illegal parent id" unless $pxt->user->verify_channel_subscribe($parent_id);

  my $channel;

  if ($pxt->dirty_param('delete')) {
    my $delete_redirect = $pxt->dirty_param('delete_redirect');
    throw "param 'delete_redirect' needed but not provided" unless $delete_redirect;
    $pxt->redirect("$delete_redirect?cid=$cid");
  }

  if ($cid) {

    unless ($pxt->user->verify_channel_admin($cid)) {
      $pxt->redirect("/errors/permission.pxt");
    }

    $channel = RHN::Channel->lookup(-id => $cid);
  } else {
    die "Must be a channel admin to create a channel"
      unless $pxt->user->is('channel_admin');
  }

  my $channel_label = $pxt->dirty_param('new_channel_label') || (ref $channel ? $channel->label : '');
  my $channel_name = $pxt->dirty_param('channel_name') || '';
  my $channel_summary = $pxt->dirty_param('channel_summary') || '';

  my $clone_from = $pxt->dirty_param('clone_from') || '';
  die "attempt to clone illegal channel" unless $pxt->user->verify_channel_access($clone_from);

  my $from_channel;

  if ($clone_from) {
    $from_channel = RHN::Channel->lookup(-id => $clone_from);
  }

  my $clone_type = $pxt->dirty_param('clone_type') || '';

  my $errors = 0;

  if ($channel_name =~ /^(rhn|red\s*hat)/i) {
    $pxt->push_message(local_alert => "Channel name cannot begin with '<strong>$1</strong>'");
    $errors++;
  }

  if ($channel_label =~ /^(rhn|red\s*hat)/i) {
    $pxt->push_message(local_alert => "Channel label cannot begin with '<strong>$1</strong>'");
    $errors++;
  }
  # bugzilla: 161517 - allow _ and / in channel labels
  # bugzilla: 459827 - disallow names longer than 64 characters
  unless ($channel_name =~ /^[a-z][\w\d\s\-\.\'\(\)\/\_]*$/i and length($channel_name) >= 6 and length($channel_name) <= 256) {
    $pxt->push_message(local_alert => "Invalid channel name '" .
    PXT::Utils->escapeHTML($channel_name) . "' - must be at least 6 characters long and not longer than 256 characters, begin with a letter, and contain only letters, digits, spaces, parentheses, '-', ' / ', '_' and '.'");
    $errors++;
  }

  # bugzilla: 161517 - allow _ in channel labels
  unless ($channel_label =~ /^[a-z\d][a-z\d\-\.\_]*$/ and length($channel_label) >= 6 and length($channel_label) <= 128) {
    $pxt->push_message(local_alert => "Invalid channel label '$channel_label' - must be at least 6 characters long and not longer than 128 characters, begin with a letter or digit, and contain only lowercase letters, digits, '-', '_', and '.'");
    $errors++;
  }

  my $gpg_fp = $pxt->dirty_param('channel_gpg_key_fp');
  if ($gpg_fp ne '' and not $gpg_fp =~ m(^(\s*[0-9A-F]{4}\s*){10}$)) {
    $pxt->push_message(local_alert => "Invalid GPG fingerprint, must be of form 'CA20 8686 2BD6 9DFC 65F6 ECC4 2191 80CD DB42 A60E'");
    $errors++;
  }

  my $gpg_id = $pxt->dirty_param('channel_gpg_key_id');
  if ($gpg_id ne '' and not $gpg_id =~ m(^[0-9A-F]{8}$)) {
    $pxt->push_message(local_alert => "Invalid GPG key ID, must be of form 'DB42A60E'");
    $errors++;
  }

  my $gpg_url = $pxt->dirty_param('channel_gpg_key_url');
  if ($gpg_url ne '' and not $gpg_url =~ m(^(https?|file)://.*?$)) {
    $pxt->push_message(local_alert => "GPG Key URL invalid - please enter a valid URL");
    $errors++;
  }

  unless ($channel_summary) {
    $pxt->push_message(local_alert => "Invalid channel summary '$channel_summary' - cannot be empty.");
    $errors++;
  }

  if ($clone_from) {
    throw "Attempt to clone unauthorized channel '$clone_from' by user '". $pxt->user->id . "'."
      unless $pxt->user->verify_channel_access($clone_from);

    if ($parent_id and not $from_channel->parent_channel) {
      $pxt->push_message(local_alert => "You cannot clone a base channel as the child of another channel.");
      $errors++;
    }
    elsif (not $parent_id and $from_channel->parent_channel) {
      $pxt->push_message(local_alert => "The clone of a child channel must have a parent channel.");
      $errors++;
    }
  }

  #bugzilla  175845 - restrict child channels arches
  if($new_channel and $parent_id){
          my $parent_channel = RHN::Channel->lookup(-id => $parent_id);
          my $archmap = RHN::ChannelEditor->channel_base_arch_map;

          my $parent_arch = $archmap->{$parent_channel->channel_arch_id}->{NAME};
          my $child_arch = $archmap->{$pxt->dirty_param("channel_arch")}->{NAME};

          if(verify_arch_compat($parent_arch, $child_arch) == 0){
                $pxt->push_message(local_alert => "The child channel arch $child_arch is not compatible with a parent channel arch of $parent_arch");
                $errors++;
          }
   }

  return if $errors;

  my $transaction = RHN::DB->connect; #do channel creation in one transaction...
  $transaction->nest_transactions;


  # cannonize how we store gpg fingerprints in the db
  if ($gpg_fp ne '') {
    $gpg_fp =~ s{\s}{}g;
    my @segments;
    while ($gpg_fp =~ m/([0-9A-Z]{4})/g) {
      push @segments, $1;
    }
    $gpg_fp = sprintf("%s %s %s %s %s  %s %s %s %s %s", @segments);
  }

  eval {
    if ($cid) {

      # fingerprint is "special"
      $channel->gpg_key_fp($gpg_fp);

      $channel->$_($pxt->dirty_param("channel_$_")) foreach qw/name summary description gpg_key_url gpg_key_id/;

      Sniglets::Channel::update_global_subscription_pref($pxt);
      $channel->commit;
    } else {
      $channel = RHN::Channel->create_channel;

      # fingerprint is "special"
      $channel->gpg_key_fp($gpg_fp);

      $channel->$_($pxt->dirty_param("channel_$_")) foreach qw/name summary description gpg_key_url gpg_key_id/;
      $channel->label($pxt->dirty_param('new_channel_label'));
      my $caid = $pxt->dirty_param("channel_arch");
      $channel->channel_arch_id($caid);
      $channel->org_id($pxt->user->org_id);
      $channel->parent_channel($parent_id or undef);

      if($from_channel){
          $channel->product_name_id($from_channel->product_name_id);
      }

      $channel->basedir('/dev/null');

      $channel->commit();

      if ($clone_from) {
        if ($clone_type eq 'current') {
          RHN::ChannelEditor->clone_channel_packages($clone_from, $channel->id);
          my ($data, $special_handling) = RHN::ChannelEditor->clone_all_errata(-from_cid => $clone_from, -to_cid => $channel->id, -org_id => $pxt->user->org_id);
        }
        elsif ($clone_type eq 'original') {
          RHN::ChannelEditor->clone_original_channel_packages($clone_from, $channel->id);
        }
        elsif ($clone_type eq 'select_errata') {
          RHN::ChannelEditor->clone_original_channel_packages($clone_from, $channel->id);
        }

        $channel->set_cloned_from($clone_from);
      }

      #adopt the channel into the user's org's channelfamily
      my @cf_ids = RHN::Org->get_channel_family($pxt->user->org_id);

      $channel->adopt_into_family(\@cf_ids);

      $cid = $channel->id;
      RHN::Channel->refresh_newest_package_cache($cid, 'web.channel_created');
      #load packes from cloned channel, if any
    }

  };
  if ($@) {
    $transaction->nested_rollback;
    if (ref $@ and catchable($@)) {
      my $E = $@;

      if ($E->constraint_value eq '"RHNCHANNEL"."LABEL"') {
        $pxt->push_message(local_alert => 'Channel label must be non-empty');
        return;
      }
      elsif ($E->constraint_value eq 'RHN_CHANNEL_LABEL_UQ') {
        $pxt->push_message(local_alert => 'That channel label already exists in our database.  Please choose another.');
        return;
      }
      elsif ($E->constraint_value eq '"RHNCHANNEL"."SUMMARY"') {
        $pxt->push_message(local_alert => 'Channel summary must not be empty');
        return;
      }
      elsif ($E->constraint_value eq 'RHN_CHANNEL_NAME_UQ') {
        $pxt->push_message(local_alert => 'That channel name already exists in our database.  Please choose another.');
        return;
      }
      else {
        throw $E;
      }
    } else {
      die $@;
    }
  }

  $transaction->nested_commit;

  # use the new java page
  my $url = '/rhn/channels/manage/Edit.do';

  #If we just cloned a channel, 'flow' the user into the errata cloning page for that channel....
  if ($clone_type eq 'select_errata') {
    $pxt->push_message(site_info => sprintf('<strong>%s</strong> has been cloned as <strong>%s</strong>.  You may now wish to clone the errata associated with <strong>%s</strong>', $from_channel->name, $channel->name, $from_channel->name));
    $url = '/network/software/channels/manage/errata/clone.pxt';
  }
  elsif ($clone_type) {
    $pxt->push_message(site_info => sprintf('<strong>%s</strong> has been cloned as <strong>%s</strong>.', $from_channel->name, $channel->name));
  }
  elsif ($new_channel) {
    $pxt->push_message(site_info => sprintf('Channel <strong>%s</strong> created.', $channel->name));
  }
  else {
    $pxt->push_message(site_info => sprintf('Channel <strong>%s</strong> updated.', $channel->name));
  }

  $url .= "?cid=$cid";
  $pxt->redirect($url);
}

sub populate_channel_list {
  my $org_id = shift;

  my @channel_list = ();
  my @base_channel_list = RHN::ChannelEditor->base_channels_visible_to_org($org_id);
  foreach my $base (@base_channel_list) {
    push (@channel_list, { NAME => $base->{NAME},
                    ID => $base->{ID},
                    DEPTH => 1});
    my @child_channel_list = RHN::ChannelEditor->child_channels_visible_to_org_from_base($org_id, $base->{ID});
    foreach my $child (@child_channel_list) {
      push (@channel_list, { NAME => $child->{NAME},
                      ID => $child->{ID},
                      DEPTH => 2});
    }
  }

  return @channel_list
}

sub clone_channel_cb {
  my $pxt = shift;

  my $clone_from = $pxt->dirty_param('clone_from');
  my $clone_type = $pxt->dirty_param('clone_type');

  throw "Attempt to clone unauthorized channel '$clone_from' by user '". $pxt->user->id . "'."
    unless $pxt->user->verify_channel_access($clone_from);

  throw "Invalid clone type: $clone_type" unless grep { $clone_type eq $_ } qw/current original select_errata/;

  $pxt->redirect(sprintf('edit.pxt?clone_from=%d&clone_type=%s', $clone_from, $clone_type));
}

sub update_channel_cache {
  my $pxt = shift;
  my $channel = $pxt->param('cid');

  my $package_list_edited = $pxt->session->get('package_list_edited');

  my @channels = ($channel);

  unless (defined $channel) {
    @channels = keys %{$package_list_edited};
  }

  foreach my $cid (@channels) {

    unless ($pxt->user->verify_channel_admin($cid)) {
      warn "User '",$pxt->user->id,"' attempted to update errata cache for channel '$cid'\n";
      $pxt->redirect("/errors/permission.pxt");
    }

    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 0);

    $package_list_edited->{$cid} = 0;
  }

  $pxt->session->set(package_list_edited => $package_list_edited);

  my $uri = $pxt->uri;

  $uri .= "?cid=$channel"
    if ($channel);

  $pxt->redirect($uri);
}

sub verify_arch_compat {
        my $parent_arch = shift;
        my $child_arch = shift;

        my @compatible_arch_list = RHN::ChannelEditor->compatible_child_channel_arches($parent_arch);
        foreach my $compatible_arch (@compatible_arch_list) {
            if ($compatible_arch->{NAME} eq $child_arch) {
                return 1;
            }
        }
        return 0;
}

1;
