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

package Sniglets::Channel;
use strict;

use RHN::Channel;
use RHN::Exception;
use PXT::Config;
use PXT::Utils;

use RHN::Form::Widget::Checkbox;
use RHN::Form::Widget::Hidden;
use RHN::Form::Widget::Literal;
use RHN::Form::Widget::Submit;

use Date::Parse;

use Carp;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-channel-details' => \&channel_details);

  $pxt->register_tag('rhn-channel-gpg-key' => \&channel_gpg_key);

  $pxt->register_tag('rhn-tri-state-channel-list', => \&tri_state_channel_list);
  $pxt->register_tag('rhn-resubscribe-warning-ssm' => \&resubscribe_warning_ssm, 3);


  $pxt->register_tag('rhn-sscd-base-channel-alteration' => \&sscd_base_channel_alteration);
  $pxt->register_tag('viewed_channel_name' => \&viewed_channel_name, -10);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  # sscd
  $pxt->register_callback('rhn:sscd_alter_channel_membership_cb' => \&sscd_alter_channel_membership_cb);
  $pxt->register_callback('rhn:globally_subscribable_cb' => \&globally_subscribable_cb);
}

my $SUBSCRIBE = 1;
my $UNSUBSCRIBE = 2;

sub resubscribe_warning_ssm {
  my $pxt = shift;
  my %params = @_;

  if ($pxt->pnotes('resubscribe_warning')) {
    return $params{__block__};
  }

  return '';
}



sub sscd_base_channel_alteration {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my @system_set_base_channels = RHN::Server->system_set_base_channels($pxt->user->id);

  my $ds = new RHN::DataSource::System (-mode => 'systems_in_set_with_no_base_channel');
  my $systems_without_base_channel = $ds->execute_query(-user_id => $pxt->user->id);

  if (@{$systems_without_base_channel}) {
    unshift @system_set_base_channels, [ 0, '(none)', scalar @{$systems_without_base_channel} ];
  }

  $block =~ m{<base_channel>(.*?)</base_channel>}ism;
  my $channel_block = $1;

  my @subscribable_base_channels = RHN::Channel->user_subscribable_base_channels(user_id => $pxt->user->id,
										 org_id => $pxt->user->org_id);

  my $no_change_opt = ['No Change', '__no_change__', 1];
  my $default_opt = [ 'Default RH Base Channel', '__default__', undef ];
  my @base_channels = map { [ $_->[1], $_->[0] ] } @subscribable_base_channels;

  my $channels = '';
  foreach my $base_channel (@system_set_base_channels) {

    my %current;

    my @options = ($no_change_opt);

    my $can_sub_ds = new RHN::DataSource::Channel(-mode => 'can_subscribe_to_default_in_set');
    my $can_sub_results = $can_sub_ds->execute_full(-user_id => $pxt->user->id);
    if (@$can_sub_results and $can_sub_results->[0]->{CHANNEL_ID}) {
      push @options, $default_opt;
    }

    push @options, @base_channels;

    my @filtered_options = grep { $_->[1] ne $base_channel->[0] } @options;
    my $drop_down_box = PXT::HTML->select(-name => "desired_base_channel_from-" . $base_channel->[0],
					  -options => \@filtered_options);

    $current{base_channel_id} = $base_channel->[0];
    $current{base_channel_name} = $base_channel->[1];
    $current{system_count} = $base_channel->[2];
    $current{drop_down_box} = $drop_down_box;

    $channels .= PXT::Utils->perform_substitutions($channel_block, \%current);
  }

  $block =~ s{<base_channel>.*?</base_channel>}{$channels}ism;

  return $block;
}

sub channel_gpg_key {
  my $pxt = shift;
  my %params = @_;

  my $cid = $pxt->param('cid');

  die "No cid!" unless defined $cid;
  die "no permission for channel $cid!" unless $pxt->user->org->has_channel_permission($cid);

  my $block = $params{__block__};
  my $channel = RHN::Channel->lookup(-id => $cid);

  my %subst;
  $subst{channel_gpg_key_url} = PXT::Utils->escapeHTML($channel->gpg_key_url() || '');

  return '' unless $subst{channel_gpg_key_url};

  if ($subst{channel_gpg_key_url} =~ m{^http(s)?://}) {
    $subst{channel_gpg_key_url} = "<a href=\"".$pxt->derelative_url($subst{channel_gpg_key_url}, 'https')."\">".$subst{channel_gpg_key_url}."</a>";
  }

  $subst{channel_gpg_info_url} = $pxt->derelative_url("/network/software/channels/gpg_info.pxt?cid=$cid", 'https');
  $subst{channel_gpg_key_id} = $channel->gpg_key_id() || 'unknown';
  $subst{channel_gpg_key_fp} = $channel->gpg_key_fp() || 'unknown';


  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub sscd_alter_channel_membership_cb {
  my $pxt = shift;


  PXT::Debug->log(7, "in sscd_alter_channel_membership_cb...");

  my @to_subscribe;
  my @to_unsubscribe;
  my $channel_set = new RHN::DB::Set 'channel_list', $pxt->user->id;

  my @params = $pxt->param;

  # warn "setting channel_list for un/subscriptions...";
  PXT::Debug->log(7, "setting channel_list for un/subscriptions...");

  $channel_set->empty;
  $channel_set->commit;
  foreach my $param (grep {m/(\d)+?/} @params) {
    my $value = $pxt->dirty_param($param);

    push @to_subscribe, $param if ($value eq 'subscribe');
    push @to_unsubscribe, $param if ($value eq 'unsubscribe');
  }


  # see if any of the requested channels are no longer allowed to be subscribed,
  # also protects against forged requests...
  if (not $pxt->user->verify_channel_subscribe(@to_subscribe)) {
    my $error_msg = <<EOM;
You no longer have subscription access to some of the channels you selected.<br />
Please review your selections and try again.
EOM
    $pxt->push_message(local_alert => $error_msg);
    $pxt->redirect("/network/systems/ssm/channels/index.pxt");
  }

  $channel_set->add( map { [ $_, $SUBSCRIBE ] } @to_subscribe );
  $channel_set->add( map { [ $_, $UNSUBSCRIBE ] } @to_unsubscribe );
  $channel_set->commit;

  PXT::Debug->log(7, "channel set committed...");
  PXT::Debug->log_dump(7, \$channel_set);

  my @license_channels = RHN::Channel->available_channels_with_license($pxt->user->org_id);
  my %consent_required = map { $_->[0] => 1 } @license_channels;

  my @channels_needing_consent;

  foreach my $channel_to_subscribe (@to_subscribe) {
    if ($consent_required{$channel_to_subscribe}) {
      push @channels_needing_consent, $channel_to_subscribe;
    }
  }

  my $cid;
  if (@channels_needing_consent) {
    my $cid = pop @channels_needing_consent;
    my $params = $cid;

    if (@channels_needing_consent) {
      $params .= "&additional_channel=" . join("&additional_channel=", @channels_needing_consent);
    }
    $pxt->redirect("/network/systems/ssm/channels/license.pxt?cid=$cid&current_channel=$params");
  }
}


sub tri_state_channel_list {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $html = '';

  my $counter = 1;

  my @channels = RHN::Channel->tri_state_channel_list($pxt->user->org_id, $pxt->user->id);

  $pxt->pnotes(channel_total => scalar @channels);


  my $resubscribe_warning;
  foreach my $channel (@channels) {

    $counter++;
    my %subst;

    $subst{channel_id} = $channel->{ID};
    $subst{channel_name} = $channel->{NAME};
    $subst{class} = ($counter % 2) ? "list-row-even" : "list-row-odd";

    PXT::Utils->escapeHTML_multi(\%subst);

    # do this bit after the HTML escape for obvious reason...
    if (defined $channel->{MAY_SUBSCRIBE}) {
      $subst{subscribe_column} = PXT::HTML->radio_button(-name => $channel->{ID},
							 -value => 'subscribe');
    }
    else {
      # no permission to resubscribe channels, show the warning stuff...
      $subst{subscribe_column} = PXT::HTML->img(-src => '/img/rhn-listicon-alert.gif',
						-title => 'Insufficient Subscription Permissions');
      $resubscribe_warning = 1;
    }

    $html .= PXT::Utils->perform_substitutions($block, \%subst);
  }

  $pxt->pnotes('resubscribe_warning' => 1) if $resubscribe_warning;

  return $html;
}

sub channel_details {
  my $pxt = shift;
  my %params = @_;
  my $systems_link = $params{systems_link} || 'subscribed_systems.pxt';
  my $packages_link = $params{packages_link} || 'packages.pxt';

  my $block = $params{__block__};

  my $cid = $pxt->param('cid');

  unless ($cid) {
    $block =~ s/\{channel_name\}/New Channel/g;
    return $block;
  }

  die "no permission for channel $cid!" unless $pxt->user->org->has_channel_permission($cid);

  my $channel = RHN::Channel->lookup(-id => $cid);

  my $no_data = '<span class="no-details">(none)</span>';

  my $parent_channel = $no_data;

  if ($channel->parent and $pxt->user->verify_channel_access($channel->parent->id)) {
    $parent_channel = sprintf '<a href="/network/software/channels/details.pxt?cid=%d">%s</a>',
                        $channel->parent->id, $channel->parent->name;
  }
  elsif ($channel->parent) {
    $parent_channel = $channel->parent->name;
  }

  my @servers = RHN::Channel->servers($cid);
  my $trusted_subscribed = 0;
  foreach my $sid(@servers) {
    my $server = RHN::Server->lookup(-id => $sid);
    $trusted_subscribed += 1 if $server->org_id != $channel->org_id;
  }

  my $channel_family_data = $channel->family;
  my %subst;
  
  $subst{trusted_subscribed} = $trusted_subscribed;
  $subst{channel_name} = $channel->name;
  $subst{channel_id} = $channel->id;
  $subst{channel_label} = $channel->label;
  $subst{channel_family_name} = $channel_family_data->{NAME};
  $subst{channel_arch_name} = $channel->arch_name;
  $subst{channel_base_dir} = $channel->basedir;
  $subst{channel_summary} = $channel->summary;
  $subst{channel_last_modified} = $pxt->user->convert_time($channel->last_modified);

  $subst{channel_eol} = $channel->end_of_life;
  $subst{trusted_orgs} = $channel->trusted_orgs;

  PXT::Utils->escapeHTML_multi(\%subst);

  $subst{systems_subscribed} = $pxt->user->systems_subscribed_to_channel($cid) || 0;
  $subst{channel_applicable_package_count} = $channel->applicable_package_count || 0;
  $subst{channel_raw_package_count} = $channel->package_count;

  if ($subst{systems_subscribed} > 0) {
    $subst{systems_link} = sprintf('<a href="%s?cid=%d">%d</a>',
					 $systems_link, $channel->id, $subst{systems_subscribed} );
  }
  else {
    $subst{systems_link} = '0';
  }

  if ($subst{channel_applicable_package_count} > 0) {
    $subst{packages_link} = sprintf('<a href="%s?cid=%d">%d</a>',
					 $packages_link, $channel->id, $subst{channel_applicable_package_count} );
  }
  else {
    $subst{packages_link} = '0';
  }

  $subst{channel_description} = PXT::Utils->escapeHTML($channel->description || '') || $no_data;
  $subst{parent_channel} = $parent_channel; # don't escape

  my ($globally_subscribable_checkbox, $globally_subscribable_message, $globally_subscribable_submit)
    = globally_subscribable_checkbox($pxt, $channel->id);

  $subst{globally_subscribable_checkbox} = $globally_subscribable_checkbox->render;
  $subst{globally_subscribable_message} = $globally_subscribable_message;
  $subst{globally_subscribable_submit} = $globally_subscribable_submit;

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub globally_subscribable_checkbox {
  my $pxt = shift;
  my $channel_id = shift;

# Note the inverted logic.
  my $current_status = ! ($pxt->user->org->org_channel_setting($channel_id, 'not_globally_subscribable'));

  my $subscribable_checkbox =
    new RHN::Form::Widget::Checkbox(name => 'globally_subscribable',
				    value => 1,
				    checked => $current_status);

  my $submit_html = RHN::Form::Widget::Submit->new(name => 'Update')->render;

  $submit_html =<<EOQ;
  <div align="right">
    <hr />
    $submit_html
  </div>
EOQ

  $submit_html .= RHN::Form::Widget::Hidden->new(name => 'pxt:trap', value => 'rhn:globally_subscribable_cb')->render;
  $submit_html .= RHN::Form::Widget::Hidden->new(name => 'cid', value => $channel_id)->render;

  my $message = $current_status ? 'All users in your organization may subscribe to this channel.'
    : 'Only selected users in your organization may subscribe to this channel.';

  unless ($pxt->user->verify_channel_admin($channel_id) or $pxt->user->is('org_admin') or $pxt->user->is('channel_admin')) {
    $subscribable_checkbox = new RHN::Form::Widget::Literal(value => $current_status ? 'Yes.' : 'No.');
    $submit_html = '';
  }

  return ($subscribable_checkbox, $message, $submit_html);
}

sub viewed_channel_name {
  my $pxt = shift;
  my %params = @_;

  my $html = $params{__block__};

  my $view_cid = $pxt->param('view_channel');

  return '' unless $view_cid;
  $view_cid =~ s/^channel_//;

  unless (PXT::Config->get('satellite')) {
    throw sprintf("User '%d' has no access to channel '%d'.", $pxt->user->id, $view_cid)
      unless $pxt->user->verify_channel_access($view_cid);
  }

  my $channel = RHN::Channel->lookup(-id => $view_cid);
  my $name = $channel->name;

  $html =~ s/\{viewed_channel_name\}/$name/;

  return $html;
}

sub globally_subscribable_cb {
  my $pxt = shift;

  update_global_subscription_pref($pxt);

  $pxt->redirect($pxt->uri . "?cid=" . $pxt->param('cid'));

  return;
}

sub update_global_subscription_pref {
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  die "No 'cid' param" unless $cid;

  unless ($pxt->user->verify_channel_admin($cid) or $pxt->user->is('channel_admin')) {
    throw "User '" . $pxt->user->id . "' attempted to modify channel subscription pref for '$cid'\n";
  }

  my $globally_subscribable = $pxt->dirty_param('globally_subscribable') ? 1 : 0;
# Note the inverted logic.
  my $current_status = ! ($pxt->user->org->org_channel_setting($cid, 'not_globally_subscribable'));

  if ($current_status != $globally_subscribable) {
    if ($globally_subscribable) {
      $pxt->user->org->remove_org_channel_setting($cid, 'not_globally_subscribable');
    }
    else {
      $pxt->user->org->add_org_channel_setting($cid, 'not_globally_subscribable');
    }

    my $message = $globally_subscribable ? 'This channel is now available for subscription by any of your users.'
      : 'This channel will now be subscribable on a per-user basis.';

    $pxt->push_message(site_info => $message);
  }

  return;
}

1;
