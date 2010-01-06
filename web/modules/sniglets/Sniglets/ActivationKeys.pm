#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
  $pxt->register_tag('rhn-token-channels' => \&edit_token_channels);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;
  $pxt->register_callback('rhn:edit_token_channels_cb' => \&edit_token_channels_cb);
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
    $token->activation_key_token('');
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


1;
