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

package Sniglets::ContactMethod;

use RHN::ContactMethod;
use RHN::ContactGroup;
use RHN::Exception;
use PXT::Utils;
use Mail::RFC822::Address;

use Carp;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-contact-method-edit-form' => \&contact_method_edit_form);
  $pxt->register_tag('rhn-contact-method-name' => \&contact_method_name);
  $pxt->register_tag('rhn-if-method-dependencies' => \&if_contact_method_dependencies);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:contact-method-edit-cb' => \&contact_method_edit_cb);
  $pxt->register_callback('rhn:contact-method-create-cb' => \&contact_method_edit_cb);
  $pxt->register_callback('rhn:contact-method-delete-cb' => \&contact_method_delete_cb);
}

sub if_contact_method_dependencies {
  my $pxt = shift;
  my %attr = @_;

  my $method_id = $pxt->param('cmid');
  die "No method id." unless $method_id;

  my $block = $attr{__block__};

  # return the block if the "value" attribute of this tag matches the outcome.
  my $render_if = defined($attr{value}) && (lc($attr{value}) eq "true");

  # check to see if there are any probes pointing to this contact method.
  my $depends =  RHN::ContactMethod->has_probe_dependencies( -method_id => $method_id); # Get the number of probes associated with this method.

  if ($depends == $render_if) {
    return $pxt->prefill_form_values($block);
  }
  return;
}

sub contact_method_name {
  my $pxt = shift;

  my $cmid = $pxt->param('cmid');
  die "no contact method id" unless $cmid;

  my $cmethod = RHN::ContactMethod->lookup( recid => $cmid);
  die "no valid contact method" unless $cmethod;

  return PXT::Utils->escapeHTML($cmethod->method_name);
}

sub contact_method_edit_form {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $cmid = $pxt->param('cmid');

  my $cmethod = RHN::ContactMethod->lookup( recid => $cmid);

  my %subs;
  $subs{method_name} = $cmethod->method_name;

  my $method_type_info = RHN::ContactMethod->get_method_type_info("Pager");
  my $use_pager_type =  (( $method_type_info->{method_type_id} eq $cmethod->method_type_id) ? '1' : '');

  $subs{use_pager_type} = $use_pager_type;
  if ($use_pager_type) {
    $subs{method_email} = $cmethod->pager_email;
  }
  else {
    $subs{method_email} = $cmethod->email_address;
  }
  $subs{uid} = $pxt->param('uid');

  $block = PXT::Utils->perform_substitutions($block, \%subs);

  return $block;
}


sub contact_method_edit_cb {
  my $pxt = shift;
  my $cmethod;
  my $cgroup;
  my $cmid = $pxt->param('cmid') || 0;

  # note that in this case we are also creating/editing a contact group behind the
  # scenes whose only member is the contact method being created/edited.

  if ($cmid) { # editing existing contact method
    $cmethod = RHN::ContactMethod->lookup( recid => $cmid);

    # get contact groups this method belongs to - note that there should only be
    # one contact method per group at this point.
    my $cgroups = $cmethod->contact_groups;
    $cgroup = $cgroups->[0];

  }
  else { # creating a new contact method.
    $cmethod = RHN::ContactMethod->create;
    $cgroup = RHN::ContactGroup->create;
  }

  my $uid = $pxt->param('uid') || $cmethod->contact_id || $pxt->user->id;
  my $name = $pxt->dirty_param('method_name') || '';

  # verify that the e-mail is actually an e-mail address.
  my $email = $pxt->dirty_param('method_email') || '';
  my $use_pager_type = $pxt->dirty_param('use_pager_type');
  my $redirect = $pxt->dirty_param('redirect_to');

  unless ($name && $email) {
      $pxt->push_message(local_alert => 'Both the method name and Email are required for contact methods.');
      return;
  }

  if (check_method_name($name, $cmid)) {
      $pxt->push_message(local_alert => 'Method name in use, please choose another.');
      return;
  }

  # make sure that the e-mail address conforms with address semantics.
  if (not Mail::RFC822::Address::valid($email)) {
      $pxt->push_message(local_alert =>'Email address is not valid.');
      return;
  }
  # the lesser of the group name and the method name.
  if (length($name) > 20) {
      $pxt->push_message(local_alert => 'Method name cannot exceed 20 characters.');
      return;
  }
  if (length($email) > 50) {
      $pxt->push_message(local_alert => 'Method email cannot exceed 50 characters.');
      return;
  }



  # Set appropriate values on the contact method's persistent object.

  # Only a monitoring_admin can create a contact method on a user other than themselves.
  if ($uid != $pxt->user->id and not $pxt->user->is('monitoring_admin')) {
    $cmethod->contact_id($pxt->user->id);
  }
  else {
    $cmethod->contact_id($uid);
  }

  $cmethod->method_name($name);
  $cmethod->last_update_user($pxt->user->id);

  # method_type_info is a bit of a hack to get appropriate lookup values
  # from the de-normalized lookup tables.
  my $method_type_info;
  if ($use_pager_type) {
    $method_type_info = RHN::ContactMethod->get_method_type_info("Pager");
    $cmethod->pager_email($email);
    $cmethod->email_address(undef);
  }
  else {
    $method_type_info = RHN::ContactMethod->get_method_type_info("Email");
    $cmethod->pager_email(undef);
    $cmethod->email_address($email);
  }

  $cmethod->method_type_id($method_type_info->{method_type_id});
  $cmethod->notification_format_id($method_type_info->{method_format_id});
  $cgroup->strategy_id($method_type_info->{strategy_id});
  $cgroup->notification_format_id($method_type_info->{group_format_id});

  # Set appropriate values on teh contact group's persistent object.
  $cgroup->contact_group_name($name);
  $cgroup->customer_id($pxt->user->org->id);
  $cgroup->last_update_user($pxt->user->id);

  my $transaction = RHN::DB->connect();
  $transaction->nest_transactions();

  eval {
      $cmethod->commit;
      $cgroup->commit;
      $cgroup->set_groups_methods($pxt->user->id, $cmethod->recid );
      #$cgroup->add_method_to_group($cmethod->recid, $pxt->user->id);
  };
  # handle any errors from trying to commit the change.
  if ($@ and catchable($@)) {
    my $E = $@;
    $transaction->nested_rollback();
    throw $E;
  }
  elsif ($@) {
    $transaction->nested_rollback();
    die $@;
  }
  $transaction->nested_commit();

  my $escaped = PXT::Utils->escapeHTML($cmethod->method_name());

  if ($cmid) { # edited
      $pxt->push_message(site_info => "Contact method <strong>$escaped</strong> modified.");
  }
  else { # created
      $pxt->push_message(site_info => "Contact method <strong>$escaped</strong> created.");
  }

  my $redir = $pxt->dirty_param('redirect_to');
  if ($redir) {
      $pxt->redirect($redir);
  }
}

sub check_method_name {
  my $name = shift;
  my $id = shift;

  my $dbh = RHN::DB->connect;
  my ($sth, $query);

  $query = <<EOQ;
SELECT 1 FROM rhn_contact_methods
      WHERE method_name = :method_name AND recid <> :id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(method_name => $name, id => $id);
  my ($ret) = $sth->fetchrow;
  $sth->finish;

  return $ret;

}

sub contact_method_delete_cb {
  my $pxt = shift;
  my $cmethod;
  my $cgroup;
  my $cmid = $pxt->param('cmid');

  die "No contact method id" unless $cmid;

  $cmethod = RHN::ContactMethod->lookup( recid => $cmid);

  my $cgroups = $cmethod->contact_groups;
  $cgroup = $cgroups->[0];

  my $transaction = RHN::DB->connect();
  $transaction->nest_transactions();

  eval {
      # deletion of the contact group cacaded into the contact group member records.
      #$cgroup->remove_method_from_group($cmethod->recid, $pxt->user->id);
      $cgroup->delete;
      $cmethod->delete;
  };
  # handle any errors from trying to commit the change.
  if ($@ and catchable($@)) {
    my $E = $@;
    $transaction->nested_rollback();
    throw $E;
  }
  elsif ($@) {
    $transaction->nested_rollback();
    die $@;
  }
  $transaction->nested_commit();

  my $escaped = PXT::Utils->escapeHTML($cmethod->method_name());
  $pxt->push_message(site_info => "Contact method <strong>$escaped</strong> deleted.");

  my $redir = $pxt->dirty_param('success_redirect');
  if ($redir) {
      $pxt->redirect($redir);
  }
}


1;
