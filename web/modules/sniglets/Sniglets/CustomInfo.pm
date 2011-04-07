#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package Sniglets::CustomInfo;

use PXT::Utils;
use RHN::CustomInfoKey;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-edit-custominfo-key' => \&edit_key_details);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:remove_system_value_cb' => \&remove_system_value);
  $pxt->register_callback('rhn:ssm_set_custom_values_cb' => \&ssm_set_values);
  $pxt->register_callback('rhn:ssm_remove_custom_values_cb' => \&ssm_remove_values);
}

sub ssm_set_values {
  my $pxt = shift;

  my $key_id = $pxt->param('cikid');
  die "no key id" unless $key_id;

  my $key = RHN::CustomInfoKey->lookup(-id => $key_id);
  die "no key" unless $key;

  my $value = $pxt->dirty_param('value');
  if (defined $value) {
    $value =~ s/\r\n/\n/g; # wash textarea input
  }
  # anti-jkt code...
  if (length($value) > 4000) {
    $pxt->push_message(local_alert => "Custom values must be fewer than 4000 characters.");
    $pxt->redirect("/network/systems/ssm/misc/set_value.pxt?cikid=$key_id");
  }

  my $total_count = RHN::Server -> system_list_count($pxt->user->id);
  my $success_count = RHN::Server->bulk_set_custom_value(-set_label => 'system_list',
				     -key_label => $key->label(),
				     -value => $value,
				     -user_id => $pxt->user->id);

  if ($success_count > 0) {
	$pxt->push_message(site_info => "Value set for <strong>" . $key->label() . "</strong> for ". $success_count ." systems.");  	
  }  
  
  if ($total_count != $success_count) {
  		$pxt->push_message(site_info => "Value <strong>" . $key->label() . "</strong> could not be set for ". ($total_count - $success_count) . " systems because they do not have provisioning entitlements.");
  }

  $pxt->redirect("/rhn/systems/ssm/misc/Index.do");
}

sub ssm_remove_values {
  my $pxt = shift;

  my $key_id = $pxt->param('cikid');
  die "no key id" unless $key_id;

  my $key = RHN::CustomInfoKey->lookup(-id => $key_id);
  die "no key" unless $key;

  RHN::Server->bulk_remove_custom_value(-set_label => 'system_list',
					-key_id => $key_id,
					-user_id => $pxt->user->id);

  $pxt->push_message(site_info => "Value removed for <strong>" . $key->label() . "</strong> from selected systems.");

  $pxt->redirect("/rhn/systems/ssm/misc/Index.do");
}

sub remove_system_value {
  my $pxt = shift;

  my $key_id = $pxt->param('cikid');
  die "no key id" unless $key_id;
  my $sid = $pxt->param('sid');
  die "no server id" unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server object" unless $server;

  my $key = RHN::CustomInfoKey->lookup(-id => $key_id);
  die "no key object" unless $key;

  $server->remove_custom_value($key->id());

  $pxt->push_message(site_info => "Value for <strong>" . $key->label() . "</strong> removed for this system.");
  $pxt->redirect("/rhn/systems/details/ListCustomData.do?$sid");
}

sub edit_key_details {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $kid = $pxt->param('cikid');
  my $key;

  if ($kid) {
    $key = RHN::CustomInfoKey->lookup(-id => $kid);
  }
  else {
    $key = RHN::CustomInfoKey->blank_key();
    $key->created_by($pxt->user->id);
    $key->last_modified_by($pxt->user->id);
    $key->org_id($pxt->user->org_id);
  }

  my %subs;


  if ($kid) {
    my $none = '<span class="no-details">(none)</span>';
    my $creator = RHN::User->lookup(-id => $key->created_by());
    my $modifier = RHN::User->lookup(-id => $key->last_modified_by());

    $subs{"key_id"} = PXT::Utils->escapeHTML($key->id());
    $subs{key_created} = $key->created() . " by " .  ($creator ? PXT::Utils->escapeHTML($creator->login()) : $none);
    $subs{key_modified} = $key->modified() . " by " . ($modifier ? PXT::Utils->escapeHTML($modifier->login()) : $none);
    $subs{key_idformvar} = PXT::HTML->hidden(-name => 'cikid', -value => $kid);
    $subs{key_label} = PXT::Utils->escapeHTML($key->label());
    $subs{key_description} = PXT::Utils->escapeHTML($key->description());
  }
  else {
    $subs{key_idformvar} = '';
    $subs{key_label} = PXT::HTML->text(-name => 'key_label', -value => 'Enter key label here.', -size => 30, -length => 64);
    $subs{key_description} = 'Enter key description here.';
  }

  return PXT::Utils->perform_substitutions($block, \%subs);
}

1;

