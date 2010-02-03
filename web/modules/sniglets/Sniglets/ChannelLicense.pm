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

package Sniglets::ChannelLicense;

use PXT::Utils;
use RHN::Exception;
use RHN::ServerActions;

use File::Spec;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-channel-license-dialog", \&channel_license_dialog);
  $pxt->register_tag("rhn-channel-license-details", \&channel_license_details);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback("rhn:channel_license_dialog_cb", \&channel_license_dialog_cb);
}

sub get_license {
  my $channel = shift;

  my $license_path = File::Spec->catfile(PXT::Config->get('channel_licenses_path'), $channel->license_path);


  PXT::Debug->log(7, "license path:  $license_path");

#  warn "license_path: '$license_path'\n";
#  warn "no_upwards results:  " . join(', ', File::Spec::Unix->no_upwards($license_path));
#  warn "is_absolute_path:  " . File::Spec::Unix->file_name_is_absolute($license_path);

  if ($license_path =~ m{\.\./}) {
    throw "DON'T PUT ../'s IN THE CHANNEL LICENSE PATH!  License path:  $license_path";
  }

  if (! -e $license_path) {
    throw "channel license missing:  " . $license_path;
  }

  open MYFILE, ($license_path) || throw "could not open file:  " . $license_path;

  my $f = join('', <MYFILE>);

  close MYFILE;

  return $f;
}

sub channel_license_details {
  my $pxt = shift;
  my %params = @_;

  my %subst;
  my $block = $params{__block__};

  $subst{channel_id} = $pxt->param('cid');
  throw "no cid" unless (defined $subst{channel_id});

  my $channel = RHN::Channel->lookup(-id => $subst{channel_id});
  throw "no channel" unless ($channel);
  $subst{channel_name} = $channel->name();

  $subst{channel_license} = get_license($channel);
  throw "no license" unless (defined $subst{channel_license});

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub channel_license_dialog {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $cid = $pxt->param('current_channel');

  if (not $cid and $pxt->dirty_param('cdc')) {
    $cid = $pxt->param('cid');
  }

  throw "no cid" unless ($cid);

  my $channel = RHN::Channel->lookup(-id => $cid);
  throw "no channel" unless ($channel);

  my $channel_name = $channel->name;

  if (not $pxt->user->verify_channel_subscribe($cid)) {
    my $error_msg = <<EOM;
You no longer have subscription permission to the $channel_name channel.
EOM
    $pxt->push_message(local_alert => $error_msg);

    my $sid = $pxt->param('sid');

    if ($sid) {
      $pxt->redirect("/network/systems/details/channels.pxt?sid=$sid");
    }
    elsif ($pxt->dirty_param('cdc')) {
      $pxt->redirect("/network/software/channels/details.pxt?cid=$cid");
    }

    $pxt->redirect("/network/systems/ssm/channels/index.pxt");
  }

  my $license = get_license($channel) || '';

  my @additional_channels = $pxt->param('additional_channel');
  my $additional_channels_str = '';

  if (@additional_channels) {
    $additional_channels_str = PXT::HTML->hidden(-name => 'current_channel', -value => $additional_channels[0]);

    if (@additional_channels > 1) {
      foreach my $xtra_cid (@additional_channels[1..-1]) {
	$additional_channels_str .= "\n" . PXT::HTML->hidden(-name => "additional_channel", -value => $xtra_cid);
      }
    }
  }

  my %subs;

  $subs{channel_license} = $license;
  $subs{channel_name} = $channel->name;
  $subs{channel_id} = $cid;

  PXT::Utils->escapeHTML_multi(\%subs);

  $subs{additional_channels} = $additional_channels_str; # don't escape me

  $block = PXT::Utils->perform_substitutions($block, \%subs);
  return $block;
}

sub channel_license_dialog_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  my $system_set;
  my $server;
  my $channel_set;
  my $system_entitlement;

  if ($sid) {
    $server = RHN::Server->lookup(-id => $sid);
    $system_entitlement = $server->is_entitled;
  }
  else {
    my $set_label = $pxt->dirty_param('set_label') || 'system_list';
    $system_set = RHN::Set->new($set_label, $pxt->user->id);
  }

  my $cid = $pxt->param('cid');
  throw "no channel id to subscribe to..." unless ($cid);
  my $channel = RHN::Channel->lookup(-id => $cid);
  throw "no channel" unless ($channel);

  my $channel_name = $channel->name;

  if (not $pxt->user->verify_channel_subscribe($cid)) {
    my $error_msg = <<EOM;
You no longer have subscription permission to the $channel_name channel.
EOM
    $pxt->push_message(local_alert => $error_msg);

    if ($sid) {
      $pxt->redirect("/network/systems/details/channels.pxt?sid=$sid");
    }
    elsif ($pxt->dirty_param('cdc')) {
      $pxt->redirect("/network/software/channels/details.pxt?cid=$cid");
    }

    $pxt->redirect("/network/systems/ssm/channels/index.pxt");
  }


  if ($pxt->dirty_param('accept')) {

    eval {
      my $transaction;

      if ($server) {
	$transaction = $server->channel_license_consent($pxt->user->id, $channel->id, $transaction);
	$transaction = $server->subscribe_to_channel($channel->label, $transaction);

	# hrm.  w/out heavily rearchitecting eula's, gotta snapshot each acceptance...
	if ($server->has_feature('ftr_snapshotting')) {
	  $transaction = RHN::Server->snapshot_server(-server_id => $server->id,
						      -reason => "Channel subscription alterations",
						      -transaction => $transaction);
	}

      }
      else {

	# handle stupid case of multiple licenses, hitting cancel for one, going back, and accepting...
	if ($pxt->dirty_param('ssm')) {

	  $channel_set = RHN::Set->new('channel_list', $pxt->user->id);

	  unless ($channel_set->contains($cid)) {
	    $channel_set->add("$cid|1");
	    $channel_set->commit;
	  }
	}

	$transaction = RHN::ServerActions->channel_license_consent_for_set($system_set, $channel->id, $pxt->user->id, $transaction);

	# in this case, don't actually subscribe to the channel, this will be handled later.
	# might have to worry about giving consent w/out subscribing to channel.
	#$transaction = RHN::ServerActions->subscribe_set_to_channel($system_set, $channel->id, $transaction);
      }

      $transaction->commit;

      if ($server) {
	$pxt->push_message(site_info => "<strong>" . $server->name . "</strong> subscribed to <strong>" . $channel->name . "</strong>");
      }
    };


    if ($@) {
      my $E = $@;
      PXT::Debug->log(9, "error:  $E");
      if (ref $E and catchable($E)) {
	if ($E->is_rhn_exception('channel_family_no_subscriptions')) {
	  $pxt->push_message(local_alert => "This assignment would exceed your allowed subscriptions in one or more channels.");
	  return;
	}
	elsif ($E->constraint_value eq 'RHN_CFL_CONSENT_CF_S_UQ'){
	  # consent was given to the channel family for the server through another channel... 
	  # do everything except ignore the license consent stuff
	  PXT::Debug->log(7, "passing through consent because consent was already given for " . $channel->id);

	  eval {
	    if ($server) {
	      $server->subscribe_to_channel($channel->label);

	      if ($server->has_feature('ftr_snapshotting')) {
		RHN::Server->snapshot_server(-server_id => $server->id,
					     -reason => "Channel subscription alterations",
					    );
	      }

	    }
	    else {
	      if ($pxt->dirty_param('ssm')) {

		$channel_set = RHN::Set->new('channel_list', $pxt->user->id);

		unless ($channel_set->contains($cid)) {
		  $channel_set->add("$cid|1");
		  $channel_set->commit;
		}
	      }
	      RHN::ServerActions->channel_license_consent_for_set($system_set, $channel->id, $pxt->user->id);
	    }
	  };

	  if ($@) {

	    my $E = $@;

	    # this is happening with people trying to subscribe to k12ltsp channel + general edu channel...
	    if (ref $E and catchable($E)) {
	      if ($E->is_rhn_exception('channel_family_no_subscriptions')) {
		$pxt->push_message(local_alert => "Could not subscribe to " . $channel->name . "; insufficient channel entitlements");
	      }
	    }
	    else {
	      die $@;
	    }
	  }
	}
	else {
	  throw $E;
	}
      }
      else {
	PXT::Debug->log_dump(7, $E);
	die $E;
      }
    }
  }
  elsif ($pxt->dirty_param('cancel')) {

    PXT::Debug->log(7, "cancel...");

    if ($pxt->dirty_param('cdc')) {
      $pxt->redirect("/network/software/channels/target_systems.pxt?cid=$cid");
    }

    if ($system_set) {
      # remove the current channel from the channel list

      $channel_set = RHN::Set->new('channel_list', $pxt->user->id);

      $channel_set->remove("$cid|1");
      $channel_set->commit;
    }
  }

  PXT::Debug->log(7, "are we done?");

  # canceled, if there aren't any other eulas to deal with, return to system channel list?
  if (not $pxt->param('current_channel')) {
    if ($server) {
      $pxt->redirect("/network/systems/details/channels.pxt?sid=$sid");
    }
    elsif ($pxt->dirty_param('ssm')) {
      $pxt->redirect("/network/systems/ssm/channels/alter_subscriptions_conf.pxt");
    }
    elsif ($pxt->dirty_param('cdc')) {
      $pxt->redirect(sprintf("/network/software/channels/subscribe_confirm.pxt?cid=%d&set_label=%s", $pxt->param('cid'), $pxt->dirty_param('set_label')));
    }
    else {
      die "shouldn't have gotten here...";
    }
  }
  else {
    warn "current channel:  " . $pxt->param('current_channel');
  }
}

1;
