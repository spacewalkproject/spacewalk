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
use RHN::Access::CustomInfo;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-edit-custominfo-key' => \&edit_key_details);
  $pxt->register_tag('rhn-system-value-details' => \&system_value_details);
  $pxt->register_tag('rhn-system-value-edit' => \&system_value_edit);
  $pxt->register_tag('rhn-no-system-custom-info' => \&no_system_custom_info);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:edit_cik_cb' => \&edit_key_cb);
  $pxt->register_callback('rhn:edit_system_value_cb' => \&edit_value_cb);
  $pxt->register_callback('rhn:delete_custominfo_key_cb' => \&delete_key);
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

  $pxt->redirect("/network/systems/ssm/misc/index.pxt");
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

  $pxt->redirect("/network/systems/ssm/misc/index.pxt");
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
  $pxt->redirect("/network/systems/details/custominfo/index.pxt?sid=$sid");
}

sub system_value_edit {
  my $pxt = shift;
  my %params = @_;

  my %subs;

  my $key_id = $pxt->param('cikid');
  my $sid = $pxt->param('sid');

  my $server = RHN::Server->lookup(-id => $sid);
  my $key = RHN::CustomInfoKey->lookup(-id => $key_id);

  my $data_ref = RHN::Server->get_custom_value(-server_id => $sid,
					       -key_id => $key_id);

  if ($data_ref) {
    $subs{value_created} = $data_ref->{CREATED} . " by " . PXT::Utils->escapeHTML($data_ref->{CREATED_BY});
    $subs{value_modified} = $data_ref->{LAST_MODIFIED} . " by " . PXT::Utils->escapeHTML($data_ref->{LAST_MODIFIED_BY});
    $subs{key_label} = PXT::Utils->escapeHTML($data_ref->{KEY});
    $subs{value} = $data_ref->{VALUE};
  }
  else {
    $server->set_custom_value(-user_id => $pxt->user->id,
			      -key_label => $key->label(),
			      -value => undef);

    $pxt->redirect("/network/systems/details/custominfo/edit.pxt?sid=$sid&cikid=$key_id");
  }

  return PXT::Utils->perform_substitutions($params{__block__}, \%subs);
}

sub no_system_custom_info {
  my $pxt = shift;
  my %attr = @_;

  my $ds = new RHN::DataSource::System(-mode => 'custom_vals_for_server');
  my $data = $ds->execute_query(-sid => $pxt->param('sid'));

  return (scalar @{$data} ? '' : $attr{__block__});
}

sub edit_value_cb {
  my $pxt = shift;

  my $value = $pxt->dirty_param('value');
  if (defined $value) {
    $value =~ s/\r\n/\n/g; # wash textarea input
  }

  my $key_id = $pxt->param('cikid');
  die "no key id" unless $key_id;

  my $sid = $pxt->param('sid');
  die "no system id" unless $sid;

  # anti-jkt code...
  if (length($value) > 4000) {
    $pxt->push_message(local_alert => "Custom values must be fewer than 4000 characters.");
    $pxt->redirect("/network/systems/details/custominfo/edit.pxt?sid=$sid&cikid=$key_id");
  }

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server object" unless $server;

  my $key = RHN::CustomInfoKey->lookup(-id => $key_id);
  die "no key object" unless $key;

  if (Scalar::Util::tainted($pxt->user->id)) {
    die "user id tainted!";
  }

  if (Scalar::Util::tainted($key->label())) {
    die "key label tainted!!";
  }

  PXT::Utils->untaint(\$value);
  if (Scalar::Util::tainted($value)) {
    die "value tainted";
  }

  $server->set_custom_value(-user_id => $pxt->user->id,
			    -key_label => $key->label(),
			    -value => $value,
			   );

  $pxt->push_message(site_info => "Value for <strong>" . $key->label() . "</strong> changed.");
  $pxt->redirect("/network/systems/details/custominfo/index.pxt?sid=$sid");
}

sub system_value_details {
  my $pxt = shift;
  my %params = @_;

  my $ds = new RHN::DataSource::System(-mode => 'custom_vals_for_server');
  my $data = $ds->execute_query(-sid => $pxt->param('sid'));

  my $ret = '';

  foreach my $cv (@{$data}) {

    my %subs = (label => $cv->{KEY}, value => $cv->{VALUE}, key_id => $cv->{ID});
    $ret .= PXT::Utils->perform_substitutions($params{__block__}, \%subs);
  }

  return $ret;
}

sub delete_key {
  my $pxt = shift;

  my $key_id = $pxt->param('cikid');
  die "no key id" unless $key_id;

  my $key = RHN::CustomInfoKey->lookup(-id => $key_id);

  unless ($pxt->user->can_delete_custominfokey($key_id)) {
    $pxt->push_message(local_alert => "Only org admins or a key's creator may delete a key.");
    $pxt->redirect("/network/systems/custominfo/edit.pxt?cikid=$key_id");
  }

  my $transaction = RHN::DB->connect();

  eval {
    $transaction = RHN::CustomInfoKey->delete_key(key_id => $key_id,
						  user_id => $pxt->user->id,
						  transaction => $transaction,
						 );
  };

  if ($@) {
    my $E = $@;

    $transaction->rollback();

    if ($E->constraint_value eq 'RHN_SCDV_KID_FK') {
      $pxt->push_message(local_alert => 'Other systems have values for this key; deletion request denied.');
      $pxt->redirect("/network/systems/custominfo/edit.pxt?cikid=$key_id");
    }
 
    die $E;
  }

  $transaction->commit();

  $pxt->push_message(site_info => "Custom info key <strong>" . $key->label() . "</strong> deleted.");

  $pxt->redirect("/rhn/systems/customdata/CustomDataList.do");
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

sub edit_key_cb {
  my $pxt = shift;

  my $kid = $pxt->param('cikid');
  my $key;

  if ($kid) {
    warn "loading key...";
    $key = RHN::CustomInfoKey->lookup(-id => $kid);
  }
  else {
    warn "creating from blank key...";
    $key = RHN::CustomInfoKey->blank_key();
    $key->created_by($pxt->user->id);
    $key->last_modified_by($pxt->user->id);
    $key->org_id($pxt->user->org_id);

    # only allow label on initial key creation...
    $key->label($pxt->dirty_param('key_label')) if not $kid;
  }

  $key->description($pxt->dirty_param('key:description'));
  $key->last_modified_by($pxt->user->id);

  eval {
    $key->commit;
  };

  if ($@) {
    my $E = $@;

    if ($E->constraint_value('RHN_CDATAKEY_LABEL_UQ')) {
      $pxt->push_message(local_alert => "A key already exists with that label.  Please choose another label.");
      #$pxt->redirect("/network/systems/custominfo/edit.pxt");
      return;
    }

    die $E;
  }

  if ($kid) {
    $pxt->push_message(site_info => PXT::Utils->escapeHTML($key->label) . " details updated.");
  }
  else {
    $pxt->push_message(site_info => "New key " . PXT::Utils->escapeHTML($key->label) . " created.");
  }

  $pxt->redirect('/network/systems/custominfo/index.pxt');
}

1;

