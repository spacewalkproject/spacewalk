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

package Sniglets::ActivationKeys;

use RHN::User;
use RHN::Org;
use RHN::Token;
use RHN::DataSource::Channel;
use RHN::Exception;
use RHN::Form::Widget;
use RHN::Entitlements;
use RHN::Form::Widget::CheckboxGroup;
use RHN::ServerGroup;

use PXT::HTML;
use Storable qw/dclone/;

use Data::Dumper;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-token-details' => \&token_details);
  $pxt->register_tag('rhn-token-edit' => \&edit_token);
  $pxt->register_tag('rhn-token-channels' => \&edit_token_channels);
  $pxt->register_tag('rhn-token-packages' => \&edit_token_packages);
  $pxt->register_tag('rhn-token-groups' => \&edit_token_groups);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:edit_token_cb' => \&edit_token_cb);
  $pxt->register_callback('rhn:edit_token_channels_cb' => \&edit_token_channels_cb);
  $pxt->register_callback('rhn:edit_token_packages_cb' => \&edit_token_packages_cb);
  $pxt->register_callback('rhn:edit_token_groups_cb' => \&edit_token_groups_cb);

  $pxt->register_callback('rhn:delete_token_cb' => \&delete_token_cb);
}

sub edit_token {
  my $pxt = shift;
  my %attr = @_;

  my $html = $attr{__block__};
  my $tid = $pxt->param('tid');
  my $token;

  if ($tid) {
    $token = RHN::Token->lookup(-id => $tid);
  }
  else {
    $token = RHN::Token->blank_token;
    $token->user_id($pxt->user->id);
    $token->org_id($pxt->user->org_id);
    $token->activation_key_token(PXT::Config->get('satellite') ? '' : 'Will be generated when key is created');
  }

  throw "no token found - tid = '$tid'" unless $token;
  throw "not an activation key admin - uid = '" . $pxt->user->id . "'" unless $pxt->user->is('activation_key_admin');
  throw "org does not own this token - tid = '$tid', uid = '" . $pxt->user->id . "'"
    unless ($pxt->user->org_id == $token->org_id);

  #do the easy ones first
  foreach my $field (qw/note activation_key_token usage_limit/) {
    my $val = $token->$field() || $pxt->dirty_param("token:$field") || '';
    $html =~ s/\{token:$field\}/PXT::Utils->escapeHTML($val)/ge;
  }

  my $deploy_val = $token->deploy_configs() || $pxt->dirty_param('deploy_configs') || '';
  my $deploy = PXT::HTML->checkbox(-name => 'deploy_configs',
				   -checked => $deploy_val eq 'Y' ? 1 : 0);

  $html =~ s/\{token:deploy_configs\}/$deploy/g;

  $html =~ s/\{tid\}/$token->id || 0/ge;

  my %token_entitlements = map { ( $_->{LABEL}, $_ ) } $token->entitlements;
  my @selected_entitlements = $pxt->dirty_param('addon_entitlements');

  if (not defined $pxt->dirty_param('addon_entitlements')) {
    @selected_entitlements = keys %token_entitlements;
  }

  my @all_entitlements = RHN::Entitlements->valid_system_entitlements_for_org($pxt->user->org_id);

  my @options =
    map { { label => $pxt->user->org->slot_name($_->{LABEL}),
	    value => $_->{LABEL} } }
      grep { $_->{IS_BASE} eq 'N' } @all_entitlements;

  my $boxes = new RHN::Form::Widget::CheckboxGroup (name => 'Add-On Entitlements',
						    label => 'addon_entitlements',
						    default => \@selected_entitlements,
						    options => \@options);

  my $entitlement_select = join("<br/>\n", $boxes->render) || 'None Available';
  # entitlement
  $html =~ s(\{token:entitlement\})($entitlement_select);

  my $org_default_val = $token->org_default || $pxt->dirty_param('org_default') || 0;
  # org default select
  my $def_select = PXT::HTML->select(-name => 'org_default',
				     -options => [ [ 'No', 0, $org_default_val ],
						   [ 'Yes, use this token for all normal registrations', 1, $org_default_val ] ]);
  $html =~ s(\{token:org_default_select\})($def_select);

  # base_channels
  my @channel_list = good_token_channels($pxt->user->org_id);
  my %token_channel = map { ($_, 1) } $token->channels;

  @channel_list = grep { $_->{DEPTH} == 1 } @channel_list;

  unless (PXT::Config->get('satellite')) { # filter out non-org base channels
    my $org_id = $pxt->user->org_id;
    @channel_list = grep { $_->{ORG_ID} == $org_id } @channel_list;
  }

  my $token_base_cid = $pxt->dirty_param('token_base_channel') || 0;

  if ($token_base_cid) {
    die "illegal token base channel" unless $pxt->user->verify_channel_access($token_base_cid);
  }

  %token_channel = map { ($_, 1) } ($token->channels, $token_base_cid);

  my $has_base;
  foreach my $chan (@channel_list) {
    if (exists $token_channel{$chan->{ID}}) {
      $chan->{SELECTED} = 1;
      $has_base = $chan;
    }
  }

  my $channel_select = PXT::HTML->select(-name => 'token_base_channel',
					 -options => [ map { [ $_->{NAME}, $_->{ID}, $_->{SELECTED} ] }
						       ({NAME => 'Red Hat Default', ID => 0, SELECTED => 0}, @channel_list) ]);

  $html =~ s/\{base_channel_select\}/$channel_select/;

  if ($token->org_default and $has_base) {
    $pxt->push_message(local_alert => <<EOM);
Note: This activation key is the universal default, but has a base
channel selected.  <strong>All systems, regardless of architecture or
operating system, that are registered without an explicit activation
key will be assigned this base channel.</strong>
EOM
  }

  return $html;
}

sub token_details {
  my $pxt = shift;
  my %attr = @_;

  throw "not an activation key admin - uid = '" . $pxt->user->id . "'" unless $pxt->user->is('activation_key_admin');

  my $html = $attr{__block__};
  my $tid = $pxt->param('tid');
  my $token;


  if ($tid) {
    throw "org does not own this token - tid = '$tid', uid = '" . $pxt->user->id . "'"
      unless ($pxt->user->verify_token_access($tid));

    $token = RHN::Token->lookup(-id => $tid);
  }
  else {
    $token = RHN::Token->blank_token;
    $token->user_id($pxt->user->id);
    $token->org_id($pxt->user->org_id);
    $token->activation_key_token(PXT::Config->get('satellite') ? '' : 'Will be generated when key is created');
  }


  #do the easy ones first
  foreach my $field (qw/note activation_key_token usage_limit/) {
    my $val = $token->$field() || $pxt->dirty_param("token:$field") || '';
    $html =~ s/\{token:$field\}/PXT::Utils->escapeHTML($val)/ge;
  }

  my $deploy_val = $token->deploy_configs() || $pxt->dirty_param('deploy_configs') || '';
  $html =~ s/\{token:deploy_configs\}/$deploy_val eq 'Y' ? 'Yes' : 'No'/ge;
  $html =~ s/\{tid\}/$token->id || 0/ge;

  my $org_default_val = $token->org_default || $pxt->dirty_param('org_default') || 0;
  $html =~ s/\{token:org_default\}/$org_default_val ? 'Yes' : 'No'/ge;

  return $html;
}

sub edit_token_channels {
  my $pxt = shift;
  my %params = @_;

  my $html = '';
  my $tid = $pxt->param('tid');
  my $token = RHN::Token->lookup(-id => $tid);

  # find the one channel, if any, that is set as the base channel
  my ($current_base) = grep { not defined $_->{PARENT_CHANNEL} } $token->fancy_channels;

  # child channels
  my @channel_list = good_token_channels($pxt->user->org_id);
  my %token_channel = map { ($_, 1) } $token->channels;

  if ($current_base) {
    @channel_list = grep { defined $_->{PARENT_CHANNEL} and $_->{PARENT_CHANNEL} == $current_base->{ID} } @channel_list;
  }

  foreach my $chan (@channel_list) {
    if (exists $token_channel{$chan->{ID}}) {
      $chan->{SELECTED} = 1;
    }
    if ($chan->{DEPTH} == 1) {
      $chan->{OPTGROUP} = 1;
    }
  }

  my $channel_select;

  if ($current_base) {
    $channel_select = "The following child channels of <b>$current_base->{NAME}</b> can be associated with this activation key.<br/><br/>";
  }

  my @options =
    map { [ $_->{NAME}, $_->{ID}, $_->{SELECTED}, $_->{OPTGROUP} ] }
      grep { $_->{CHILDREN} || $_->{DEPTH} > 1} @channel_list;

  $channel_select .= PXT::HTML->select(-name => 'token_child_channels',
				       -multiple => 1,
				       -size => 6,
				       -options => \@options);

  return @options > 0 ? $channel_select : "There are no child channels suitable for this key.";
}

sub edit_token_groups {
  my $pxt = shift;

  my $tid = $pxt->param('tid');
  my $token = RHN::Token->lookup(-id => $tid);

  my @org_groups = RHN::ServerGroup->server_group_list($pxt->user->org_id);
  my %token_group = map { ($_, 1) } $token->groups;

  my $select = PXT::HTML->select(-name => 'token_groups',
				 -multiple => 1,
				 -size => 6,
				 -options => [ map { [ PXT::Utils->escapeHTML($_->[0]),
						       $_->[1],
						       exists($token_group{$_->[1]}) ? 1 : 0 ]
						   } @org_groups ]);

}

sub edit_token_cb {
  my $pxt = shift;
  throw "not an activation key admin - uid = '" . $pxt->user->id . "'" unless $pxt->user->is('activation_key_admin');

  my $tid = $pxt->param('tid');
  my $token;

  if ($tid) {
    $token = RHN::Token->lookup(-id => $tid);
  }
  else {
    $token = Sniglets::ActivationKeys->create_token($pxt);
  }

  my $new_key = $token->activation_key_token || RHN::Token->generate_random_key;
  if (PXT::Config->get('satellite')) {
    $new_key = $pxt->dirty_param('token:key') || RHN::Token->generate_random_key;
  }

  if ($new_key =~ /,/) {
    $pxt->push_message(local_alert => 'Activation keys cannot contain commas.  Please enter a new key.');
    return;
  }

  $token->activation_key_token($new_key);

  throw "no token found - tid = '$tid'" unless $token;
  throw "org does not own this token - tid = '$tid', uid = '" . $pxt->user->id . "'"
    unless ($pxt->user->org_id == $token->org_id);

  # entitlement level
  my @entitlements = $pxt->dirty_param('addon_entitlements');
  push @entitlements, 'enterprise_entitled';

  # make sure we don't allow both virtualization entitlements when creating
  # an activation key
  my $virthost = grep { $_ eq 'virtualization_host' } @entitlements;
  my $virthostplat = grep { $_ eq 'virtualization_host_platform' } @entitlements;
  if ($virthost and $virthostplat) {
    $pxt->push_message(local_alert => 'Activation keys cannot contain both Virtualization and Virtualization Platform.  Please choose one or the other.');
    return;
  }

  my $provisioning = (grep { $_ eq 'provisioning_entitled' } @entitlements) ? 1 : 0;

  # easy ones
  $token->note($pxt->dirty_param("token:note") || 'None');

  my $usage_limit = $pxt->dirty_param("token:usage_limit");
  $usage_limit =~ tr/0-9//cd;
  $token->usage_limit($usage_limit);

  # Clear out deploy configs setting if we're creating a new key, or if we're not provisioning
  unless ($provisioning and $tid) {
    $token->deploy_configs('N');
  }

  #create the token - have to do this here and now, so we don't violate contraints when setting channels and groups
  eval {
    $token->commit;

    unless ($provisioning) {
      # might have switched down from Provisioning to Management, clear
      # out these features...
      $token->set_packages();
      $token->set_config_channels();
    }
  };
  if (catchable($@)) {
    my $E = $@;
    if ($E->is_rhn_exception('RHN_ACT_KEY_TOKEN_UQ')) {
      $pxt->push_message(local_alert => "A key with that label already exists");

      return;
    }
    else {
      die $E;
    }
  }

  # Now we can commit the entitlements
  $token->set_entitlements(@entitlements);

  # handle base channels.  first grab already existing child channels,
  # then add in the base channel chosen in this pass
  my @channels = grep { defined $_->{PARENT_CHANNEL} } $token->fancy_channels;

  my ($current_base) = grep { not defined $_->{PARENT_CHANNEL} } $token->fancy_channels;
  my $new_base = $pxt->dirty_param('token_base_channel') || 0;

  if ($new_base) {
    die "illegal token base channel" unless $pxt->user->verify_channel_access($new_base);
  }

  # picked a base channel that wasn't the same as the old?  clear the subchannels, then
  if ($current_base and $new_base and $current_base->{ID} != $new_base) {
    $token->set_channels(-channels => [ ($new_base) ]);
  }
  else {
    $token->set_channels(-channels => [ ( $new_base, map { $_->{ID} } @channels ) ]);
  }

  $token->org_default($pxt->dirty_param('org_default') ? 1 : 0);

  if ($tid) {
    $pxt->push_message(site_info => sprintf('Activation Key <strong>%s</strong> has been modified.', PXT::Utils->escapeHTML($token->note)));

    my $redir = sprintf 'edit.pxt?tid=%d', $token->id;
    $pxt->redirect($redir);
  }
  else {
    $pxt->push_message(site_info => sprintf('Activation Key <strong>%s</strong> has been created.', PXT::Utils->escapeHTML($token->note)));
    $pxt->redirect("list.pxt");
  }
}

sub edit_token_channels_cb {
  my $pxt = shift;

  throw "not an activation key admin - uid = '" . $pxt->user->id . "'" unless $pxt->user->is('activation_key_admin');

  my $tid = $pxt->param('tid');
  my $token = RHN::Token->lookup(-id => $tid);

  #set the token's channels - first we make sure the org has permissions to the channel
  my @good_channel_list = good_token_channels($pxt->user->org_id);

  # kindof messy, but don't worry too much about the dirty_param(token_child_channels) bit,
  # as long as it's protected by the @good_channel_list = grep {} @good_channel_list filter
  # below
  my %selected_channels = map { ($_, 1) } ($pxt->dirty_param('token_child_channels'));

  # preserve the base channel associated with token; grab the current
  # tokens, find the base channel, and make sure it ends up in
  # selected_channels
  my ($base_token_channel) = grep { not defined $_->{PARENT_CHANNEL} } $token->fancy_channels;
  $selected_channels{$base_token_channel->{ID}} = 1
    if $base_token_channel;

  @good_channel_list = grep { exists $selected_channels{$_->{ID}} } @good_channel_list;

  $token->set_channels( -channels => [ map { $_->{ID} } @good_channel_list ]);
  $pxt->push_message(site_info => sprintf('Activation Key <strong>%s</strong> has been modified.', PXT::Utils->escapeHTML($token->note)));
}

sub edit_token_groups_cb {
  my $pxt = shift;

  throw "not an activation key admin - uid = '" . $pxt->user->id . "'" unless $pxt->user->is('activation_key_admin');

  my $tid = $pxt->param('tid');
  my $token = RHN::Token->lookup(-id => $tid);

  #set the token's groups - just like channels...
  my %org_groups = map { ($_->[1], 1) } RHN::ServerGroup->server_group_list($pxt->user->org_id);
  my @groups = grep { $org_groups{$_} } $pxt->dirty_param('token_groups');

  $token->set_groups(@groups);

  #all done.  Commit.
  $token->commit;
  $pxt->push_message(site_info => sprintf('Activation Key <strong>%s</strong> has been modified.', PXT::Utils->escapeHTML($token->note)));
}

sub delete_token_cb {
  my $pxt = shift;

  my $tid = $pxt->param('tid');

  my $token = RHN::Token->lookup(-id => $tid);

  throw "not an activation key admin - uid = '" . $pxt->user->id . "'" unless $pxt->user->is('activation_key_admin');
  throw "no token found - tid = '$tid'" unless $token;
  throw "org does not own this token - tid = '$tid', uid = '" . $pxt->user->id . "'"
    unless ($pxt->user->org_id == $token->org_id);

  my $note = PXT::Utils->escapeHTML($token->note);

  $token->purge;

  $pxt->push_message(site_info => "Activation Key <strong>$note</strong> has been deleted");

  my $redir = $pxt->dirty_param('redirect_to');
  throw "Redirect needed but not specified" unless $redir;
  $pxt->redirect($redir);
}

#given an org_id, return a list of 'tokenable' channels.
sub good_token_channels {
  my $org_id = shift;

  my $ds = new RHN::DataSource::Channel (-mode => 'token_channels_tree');
  my $all_channels = $ds->execute_query(-org_id => $org_id);

  #filter out channels which require a license agreement:
  my @channel_list = grep { not defined $_->{LICENSE_PATH} } @{$all_channels};

  #filter out proxy and satellite channels:
  @channel_list = grep { ($_->{CHANNEL_FAMILY_LABEL} ne 'rhn-satellite')
			  and ($_->{CHANNEL_FAMILY_LABEL} ne 'rhn-proxy') } @channel_list;

  #filter out channels which have a parent that isn't in this list.
  my %available = map { ($_->{ID}, 1) } @channel_list;
  @channel_list = grep { not defined $_->{PARENT_CHANNEL} or $available{$_->{PARENT_CHANNEL}} } @channel_list;

  return @channel_list;
}

sub create_token {
  my $class = shift;
  my $pxt = shift;

  my $token = RHN::Token->create_token;
  $token->user_id($pxt->user->id);
  $token->org_id($pxt->user->org_id);

  return $token;
}

sub edit_token_packages {
  my $pxt = shift;

  my $tid = $pxt->param('tid');
  my $token = RHN::Token->lookup(-id => $tid);

  my @packages = $token->fancy_packages;
  my $pkg_count = scalar @packages;
  my $pkg_string = join("\n", map { $_->{NAME} } @packages);

  my $widget = new RHN::Form::Widget::TextArea(name => 'Packages',
					       label => 'packages',
					       cols => 64,
					       rows => $pkg_count < 4 ? 6 : $pkg_count + 1,
					       default => ($pkg_string || ''));
  return $widget->render;
}

sub edit_token_packages_cb {
  my $pxt = shift;

  my $tid = $pxt->param('tid');
  my $token = RHN::Token->lookup(-id => $tid);

  my $pkg_string = $pxt->dirty_param('packages');
  $pkg_string =~ s(\r)()g;
  # remove whitespace from beginning and end
  $pkg_string =~ s/^\s+//;
  $pkg_string =~ s/\s+$//;
  my @package_names = split /\n+/, $pkg_string;

  my %seen;
  my @packages;
  for my $name (@package_names) {
    if (exists $seen{$name}) {
      $pxt->push_message(local_alert => "Package '$name' appears multiple times.");
      return;
    }
    $seen{$name}++;

    my $pkg_id = RHN::Package->lookup_package_name_id($name);

    push @packages, $pkg_id;
  }

  $token->set_packages(@packages);
  $pxt->push_message(site_info => sprintf('Activation Key <strong>%s</strong> has been modified.', PXT::Utils->escapeHTML($token->note)));
}

1;
