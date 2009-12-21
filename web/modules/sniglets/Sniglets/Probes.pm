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

package Sniglets::Probes;

use Data::Dumper;

use RHN::Command;
use RHN::CommandParameter;
use RHN::ContactGroup;
use RHN::DataSource;
use RHN::Exception;
use RHN::Probe;
use RHN::ProbeParam;
use RHN::Server;

use RHN::Form::Widget::Checkbox;
use RHN::Form::Widget::Hidden;
use RHN::Form::Widget::Literal;
use RHN::Form::Widget::Password;
use RHN::Form::Widget::Select;
use RHN::Form::Widget::Submit;
use RHN::Form::Widget::Text;

use PXT::Utils;
use PXT::HTML;

use Sniglets::Forms;
use Sniglets::Navi::Style;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-probe-state-summary", \&probe_state_summary);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:system_probe_creation_cb' => \&system_probe_creation_cb);
  $pxt->register_callback('rhn:system_probe_edit_cb' => \&system_probe_edit_cb);
}

######################################
sub build_system_probe_creation_form {
######################################
  my $pxt = shift;
  my %params = @_;

  my $finished;
  my $probe_command_id;

  my $sid = $pxt->param('sid');
  throw "no sid" unless $sid;

  my $probe_command_group = $pxt->dirty_param('probe_command_group') || 'linux';

  my $form = new RHN::Form::ParsedForm(name => 'System Probe',
				       label => 'system_probe',
				       action => $params{action},
				      );

  my $command_groups = RHN::Command->list_groups();
  my @group_options = map { { value => $_->{COMMAND_GROUP_NAME}, label => $_->{COMMAND_GROUP_LABEL} } } @{$command_groups};
  throw "no command groups!" unless @group_options;

  $form->add_widget(new RHN::Form::Widget::Select(name => 'Probe Command Group',
						  label => 'probe_command_group',
						  size => 1,
						  value => $probe_command_group ? $probe_command_group : 'tools',
						  options => [ @group_options ],
						  auto_submit => 1,
						  requires => {response => 1}) );

  my $group_commands;

  if ($probe_command_group eq 'all') {
    my @commands = ();

    for my $group_label (map { $_->{COMMAND_GROUP_NAME} } @{$command_groups}) {

      my $tmp_commands = RHN::Command->list_commands_by_group($group_label);
      push @commands, (@{$tmp_commands});
    }

    # sort per bugzilla 107149
    @commands = sort { $a->{COMMAND_NAME} cmp $b->{COMMAND_NAME} } @commands;

    $group_commands = \@commands;
  }
  else {
    $group_commands = RHN::Command->list_commands_by_group($probe_command_group);
  }

  my @command_options = map {{ value => $_->{ID},
				 label => $_->{COMMAND_NAME} }} @{$group_commands};
  throw "no group commands!" unless @command_options;


  if ($pxt->dirty_param('probe_command_id')) {
    ($probe_command_id) = grep { $_ eq $pxt->dirty_param('probe_command_id') } map { $_->{ID} } @{$group_commands};
  }

  if (not $probe_command_id) {
    $probe_command_id = $command_options[0]->{value};
  }

  my $command_obj = RHN::Command->lookup(id => $probe_command_id);


  $form->add_widget(new RHN::Form::Widget::Select(name => 'Probe Command',
						  label => 'probe_command_id',
						  size => 1,
						  value => $command_options[0]->{value},
						  options => [ @command_options ],
						  auto_submit => 1,
						  requires => {response => 1}));

  #use the sat_clusters defined for the users org in the select box
  my @scout_options = $pxt->user->org->get_scout_options();
  if (not @scout_options) {
    $pxt->push_message(local_alert => "No monitoring scouts defined for your organization.");
  }

  $form->add_widget(new RHN::Form::Widget::Select(name => 'Monitoring Scout',
						  label => 'scout_id',
						  size => 1,
						  value => $scout_options[0]->{label},
						  options => [ @scout_options	],
						  requires => {response => 1}));

  if ($command_obj->requirements_description()) {
    $form->add_widget(new RHN::Form::Widget::Literal(name => 'Probe Requirements',
						     value => $command_obj->requirements_description()));
  }

  if ($command_obj->version_support()) {
    $form->add_widget(new RHN::Form::Widget::Literal(name => 'Supported Versions',
						     value => $command_obj->version_support()));
  }

  #need to figure out how to change default description when a new command_group or command is selected
  # my $default_desc = $command_obj->command_class();

  $form->add_widget(new RHN::Form::Widget::Text(name => 'Probe Description',
						label => 'probe_description',
						size => 50,
#						value => $default_desc,
						maxlength => 100,
						requires => {response => 1}));


  # pxt_passthrough doesn't really know how to set "checked" so we have to keep track
  # ourselves.
  my $probe_notifications = $pxt->dirty_param('probe_notifications') || 0;
  $form->add_widget(new RHN::Form::Widget::Checkbox(name => 'Probe Notifications',
						    label => 'probe_notifications',
						    auto_submit => 1,
                                                    value => 1,
						    checked => $probe_notifications ));

  my @intervals =  ( { value => '1', label => '1 minute' },
                     { value => '5', label => '5 minutes' },
                     { value => '10', label => '10 minutes' },
                     { value => '15', label => '15 minutes' },
                     { value => '30', label => '30 minutes' },
                     { value => '45', label => '45 minutes' },
                     { value => '60', label => '1 hour' },
                     { value => '120', label => '2 hours' },
                     { value => '360', label => '6 hours' },
                     { value => '720', label => '12 hours' },
                     { value => '1440', label => '24 hours' }
		   );

  if ($probe_notifications) {

    # We're taking advantage of the fact that we've kept the name of the contact group and the
    # one member contact method in sync to present the contact group name which the user will
    # assume is the contact method.
    my $contact_groups = RHN::ContactGroup->list_groups($pxt->user, $sid);
    my @contact_group_options = map {{ value => $_->{ID},
				       label => $_->{CONTACT_GROUP_NAME} }} @{$contact_groups};

    if (not @contact_group_options) {
      # setting the param to 0 effectively unchecks the checkbox.  So here we uncheck the
      # checkbox and issue a message indicating that theres nothing to select.
      $pxt->dirty_param('probe_notifications', 0);
      $pxt->push_message(local_alert => "No notification methods have been defined.");
    }
    else {
      $form->add_widget(new RHN::Form::Widget::Select(name => 'Notification Interval',
                                                  label => 'probe_notification_interval_min',
                                                  size => 1,
                                                  value => '5',
                                                  options => [ @intervals ],
                                                  requires => {response => 1}));

      $form->add_widget(new RHN::Form::Widget::Select(name => 'Notification Method',
						      label => 'cgid',
						      size => 1,
						      value => $contact_group_options[0]->{value},
						      options => [ @contact_group_options ],
						      requires => {response => 1}));
    }
  }

  $form->add_widget(new RHN::Form::Widget::Select(name => 'Probe Check Interval',
						  label => 'probe_check_interval_min',
						  size => 1,
						  value => '5',
						  options => [ @intervals ], 
						  requires => {response => 1}));



  my $command_params = RHN::CommandParameter->list_by_command($probe_command_id);

  # add the command_id to the prefix so that the param names will be unique 
  # across the auto_submits
  my $formvar_prefix = $probe_command_id .'_param_';

  # XXX FIXME:  this is probably woefully incomplete...
  my %validation_methods = ( float => [regexp => '^(\d+(\.(\d)+)?)?$'],
			     integer => [numeric => 1],
			     probestate => [regexp => '(OK|WARNING|CRITICAL|UNKNOWN)'],
			   );

  foreach my $param (@{$command_params}) {
    if ($param->{FIELD_VISIBLE}) {

      my $param_value = $pxt->dirty_param($param->{PARAM_NAME}) || $param->{DEFAULT_VALUE};

      my $field_type = $param->{FIELD_WIDGET_NAME};

      if ($field_type eq 'text') {
	my $data_type = $param->{DATA_TYPE_NAME};
	my @extra_requirements = exists $validation_methods{$data_type} ? @{$validation_methods{$data_type}} : ();

	my $mandatory = $param->{MANDATORY} ? 1 : 0;
	my $requires = { ($mandatory ? (response => 1) : ()), @extra_requirements};

	if ($data_type eq 'password') {
	  $form->add_widget(new RHN::Form::Widget::Password(name => $param->{DESCRIPTION},
							    label => $formvar_prefix . $param->{PARAM_NAME},
							    default => $param_value,
							    size => $param->{FIELD_VISIBLE_LENGTH},
							    maxlength => $param->{FIELD_MAXIMUM_LENGTH},
							    requires => $requires
							   ));
	}
	else {
	  $form->add_widget(new RHN::Form::Widget::Text(name => $param->{DESCRIPTION},
							label => $formvar_prefix . $param->{PARAM_NAME},
							size => $param->{FIELD_VISIBLE_LENGTH},
							maxlength => $param->{FIELD_MAXIMUM_LENGTH},
							#default => $param->{DEFAULT_VALUE},
							value => $param_value,
							requires => $requires
						       ));
	}
      }
      elsif ($field_type eq 'checkbox') {
	$form->add_widget(new RHN::Form::Widget::Checkbox(name => $param->{DESCRIPTION},
							  label => $formvar_prefix . $param->{PARAM_NAME},
							  value => 1,
							  checked => $param_value));
      }
      else {
	throw 'unknown widget type';
      }
    }
    else {
      # if we got here, that means that the param is nonvisible tot he user, and we should just use the default value for it 
      $form->add_widget(new RHN::Form::Widget::Hidden(name => $formvar_prefix . $param->{PARAM_NAME},
						      value => $param->{DEFAULT_VALUE}
						     ));
    }
  }

  $form->add_widget(new RHN::Form::Widget::Submit(name => 'Create Probe'));
  $form->add_widget(new RHN::Form::Widget::Hidden(name => 'sid', value => $sid));

  $form->add_widget(new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:system_probe_creation_cb'));

  return $form;
}

##############################
sub system_probe_creation_cb {
##############################
  my $pxt = shift;

  unless ($pxt->dirty_param('Create Probe')) {
    # don't do any creation stuff unless they actually hit the create button
    return;
  }

  my $form = build_system_probe_creation_form($pxt);
  my $response = $form->prepare_response;

  my $errors = Sniglets::Forms::load_params($pxt, $response);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $sid = $pxt->param('sid');
  throw "no sid" unless $sid;

  my $command_id = $pxt->dirty_param('probe_command_id');
  throw "no command id" unless $command_id;

  my $probe_description = $pxt->dirty_param('probe_description');
  throw "no probe description" unless $probe_description;

  #set probe_notifications to 0 if the param is undef
  my $probe_notifications = $pxt->dirty_param('probe_notifications') || 0;

  my $probe_check_interval_min = $pxt->dirty_param('probe_check_interval_min');

  #use a default setting of 5min for notif interval for probes that won't notify, 
  #as this field is a NOT NULL
  my $probe_notification_interval_min = $pxt->dirty_param('probe_notification_interval_min') || 5;

  my $contact_group_id = $pxt->param('cgid');

  my @param_formvars = grep { m/param_/ } $pxt->param();
  my %probe_params;

  # now strip off the formvar_prefix we added to the parameters
  for my $param_formvar (@param_formvars) {
    my $param_name = $param_formvar;
    $param_name =~ s/^\Q${command_id}_param_//;

    $probe_params{$param_name} = $pxt->dirty_param($param_formvar);
  }

  my $scout_id = $pxt->param('scout_id');

  my $probe = RHN::Probe->create;

  #set all the needed fields for the new probe object
  $probe->probe_type('check');
  $probe->max_attempts('1');
  $probe->command_id($command_id);
  $probe->description($probe_description);
  $probe->notify_critical($probe_notifications);
  $probe->notify_warning($probe_notifications);
  $probe->notify_unknown($probe_notifications);
  $probe->notify_recovery($probe_notifications);
  $probe->check_interval_minutes($probe_check_interval_min);
  $probe->notification_interval_minutes($probe_notification_interval_min);
  $probe->retry_interval_minutes($probe_check_interval_min);
  $probe->host_id($sid);
  $probe->sat_cluster_id($scout_id);
  $probe->last_update_user($pxt->user->id);
  $probe->customer_id($pxt->user->org_id);
  $probe->contact_group_id($contact_group_id) || 0;

  my $transaction = RHN::DB->connect();
  $transaction->nest_transactions();

  eval {
    $probe->commit;
    $probe->insert_check_probe;
    $probe->insert_probe_params(%probe_params);
  };

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

  my $escaped = PXT::Utils->escapeHTML($probe->description());

  $pxt->push_message(site_info => "System Probe <strong>$escaped</strong> created.");

  my $pid = $probe->recid();
  $pxt->redirect("/network/systems/details/probes/details.pxt?sid=$sid&probe_id=$pid");

}

##################################
sub build_system_probe_edit_form {
##################################
  my $pxt = shift;
  my %params = @_;

  my $finished;

  my $sid = $pxt->param('sid');
  throw "no sid" unless $sid;

  my $probe_id = $pxt->param('probe_id');
  throw "no probe_id" unless $probe_id;

  my $probe = RHN::Probe->lookup(-recid => $probe_id);

  my $command = RHN::Command->lookup(id => $probe->command_id);

  my $form = new RHN::Form::ParsedForm(name => 'System Probe',
				       label => 'system_probe',
				       action => $params{action},
				      );

  $form->add_widget( new RHN::Form::Widget::Literal(name => 'Probe Command', value => $command->description) );

  my $scout_description = $probe->scout_for_probe($probe_id);
  $form->add_widget( new RHN::Form::Widget::Literal(name => 'Monitoring Scout', value => $scout_description) );

  if ($command->requirements_description) {
    $form->add_widget(new RHN::Form::Widget::Literal(name => 'Probe Requirements',
						     value => $command->requirements_description));
  }

  if ($command->version_support) {
    $form->add_widget(new RHN::Form::Widget::Literal(name => 'Supported Versions',
						     value => $command->version_support));
  }

  $form->add_widget(new RHN::Form::Widget::Text(name => 'Probe Description',
						label => 'probe_description',
						size => 50,
						value => $probe->description,
						maxlength => 100,
						requires => {response => 1}));

  my $probe_notifications =  $pxt->dirty_param('probe_notifications');
  # This relies on the edit_callback defining the value as 0 if it was a
  # javascript submit.
  if (not defined $probe_notifications) {
    $probe_notifications = $probe->notify_critical;
  }
  $form->add_widget(new RHN::Form::Widget::Checkbox(name => 'Probe Notifications',
						    label => 'probe_notifications',
						    auto_submit => 1,
                                                    value => 1,
						    checked => $probe_notifications));
  my @intervals =  ( { value => '1', label => '1 minute' },
                     { value => '5', label => '5 minutes' },
                     { value => '10', label => '10 minutes' },
                     { value => '15', label => '15 minutes' },
                     { value => '30', label => '30 minutes' },
                     { value => '45', label => '45 minutes' },
                     { value => '60', label => '1 hour' },
                     { value => '120', label => '2 hours' },
                     { value => '360', label => '6 hours' },
                     { value => '720', label => '12 hours' },
                     { value => '1440', label => '24 hours' }
                   );


  if ($probe_notifications) {
    # We're taking advantage of the fact that we've kept the name of the contact group and the
    # one member contact method in sync to present the contact group name which the user will
    # assume is the contact method.
    my $contact_groups = RHN::ContactGroup->list_groups($pxt->user, $sid);
    my @contact_group_options = map {{ value => $_->{ID},
				       label => $_->{CONTACT_GROUP_NAME} }} @{$contact_groups};

    if (not @contact_group_options) {
      # setting the param to 0 effectively unchecks the checkbox.  So here we uncheck the
      # checkbox and issue a message indicating that theres nothing to select.
      $pxt->dirty_param('probe_notifications', 0);
      $pxt->push_message(local_alert => "No notification methods have been defined.");
    }
    $form->add_widget(new RHN::Form::Widget::Select(name => 'Notification Interval',
						    label => 'probe_notification_interval_min',
						    size => 1,
						    value => $probe->notification_interval_minutes,
						    options => [ @intervals ],
						    requires => {response => 1}));

    $form->add_widget(new RHN::Form::Widget::Select(name => 'Notification Method',
						    label => 'cgid',
						    size => 1,
						    value => $probe->contact_group_id,
						    options => [ @contact_group_options ],
						    requires => {response => 1}));
  }

  $form->add_widget(new RHN::Form::Widget::Select(name => 'Probe Check Interval',
						  label => 'probe_check_interval_min',
						  size => 1,
						  value => $probe->check_interval_minutes,
						  options => [ @intervals ],
						  requires => {response => 1}));


  my $command_params = RHN::CommandParameter->list_by_command($probe->command_id);

  my $saved_params = RHN::ProbeParam->list_probe_param_values($probe_id, $probe->command_id);

  my $formvar_prefix = 'param_';

  # XXX FIXME:  this is probably woefully incomplete...
  my %validation_methods = ( float => [regexp => '^(\d+(\.(\d)+)?)?$'],
			     integer => [numeric => 1],
			     probestate => [regexp => '(OK|WARNING|CRITICAL|UNKNOWN)'],
			   );

  foreach my $param (@{$command_params}) {
    next unless $param->{FIELD_VISIBLE};

    my $param_value = $pxt->dirty_param($param->{PARAM_NAME});

    foreach my $saved (@{$saved_params}) {
      if ($param->{PARAM_NAME} eq $saved->{PARAM_NAME}) {
	$param_value = $saved->{VALUE};
      }
    }

    my $field_type = $param->{FIELD_WIDGET_NAME};
    if ($field_type eq 'text') {

      my $data_type = $param->{DATA_TYPE_NAME};
      my @extra_requirements = exists $validation_methods{$data_type} ? @{$validation_methods{$data_type}} : ();

      if ($data_type eq 'password') {
	$form->add_widget(new RHN::Form::Widget::Password(name => $param->{DESCRIPTION},
							  label => $formvar_prefix . $param->{PARAM_NAME},
							  default => $param_value,
							  size => $param->{FIELD_VISIBLE_LENGTH},
							  maxlength => $param->{FIELD_MAXIMUM_LENGTH},
							  requires => [{response => $param->{MANDATORY} ? 1 : 0},
								       @extra_requirements]
							 ));
      }
      else {
	$form->add_widget(new RHN::Form::Widget::Text(name => $param->{DESCRIPTION},
						      label => $formvar_prefix . $param->{PARAM_NAME},
						      size => $param->{FIELD_VISIBLE_LENGTH},
						      maxlength => $param->{FIELD_MAXIMUM_LENGTH},
						      #default => $param->{DEFAULT_VALUE},
						      value => $param_value,
						      requires => [{response => $param->{MANDATORY} ? 1 : 0},
								   @extra_requirements]
						     ));
      }
    }
    elsif ($field_type eq 'checkbox') {
      $form->add_widget(new RHN::Form::Widget::Checkbox(name => $param->{DESCRIPTION},
							label => $formvar_prefix . $param->{PARAM_NAME},
                                                        value => 1,
							#checked => $param->{DEFAULT_VALUE} ? 1 : 0,
							checked => $param_value));
    }
    else {
      throw 'unknown widget type';
    }
  }

  $form->add_widget(new RHN::Form::Widget::Submit(name => 'Update Probe'));
  $form->add_widget(new RHN::Form::Widget::Hidden(name => 'sid', value => $sid));
  $form->add_widget(new RHN::Form::Widget::Hidden(name => 'probe_id', value => $probe_id));

  $form->add_widget(new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:system_probe_edit_cb'));

  return $form;

}

###########################
sub system_probe_edit_cb {
###########################
  my $pxt = shift;

  #It's likely that we're here because of a javascript submit.  Make sure that for
  #this case $pxt->('probe_notifications') is defined so that the checkbox knows what to do.
  if (not defined $pxt->dirty_param('probe_notifications')) {
    $pxt->param(probe_notifications => 0);
  }

  unless ($pxt->dirty_param('Update Probe')) {
    #return w/o doing anything if the update probe button wasn't pushed
    return;
  }

  my $form = build_system_probe_edit_form($pxt);
  my $response = $form->prepare_response;

  my $errors = Sniglets::Forms::load_params($pxt, $response);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $sid = $pxt->param('sid');
  throw "no sid" unless $sid;

  my $probe_id = $pxt->param('probe_id');
  throw "no probe id" unless $probe_id;

  my $probe = RHN::Probe->lookup(recid => $probe_id);

  my $probe_description = $pxt->dirty_param('probe_description');
  if ($probe_description ne $probe->description) {
    $probe->description($probe_description);
  }

  my $probe_notifications = $pxt->dirty_param('probe_notifications') || 0;

  if ($probe_notifications ne $probe->notify_critical) {
    $probe->notify_critical($probe_notifications);
    $probe->notify_warning($probe_notifications);
    $probe->notify_unknown($probe_notifications);
    $probe->notify_recovery($probe_notifications);
  }

  my $contact_group_id = $pxt->param('cgid');
  if ($contact_group_id ne $probe->contact_group_id) {
    $probe->contact_group_id($contact_group_id);
  }

  my $probe_check_interval_min = $pxt->dirty_param('probe_check_interval_min');
  if ($probe_check_interval_min ne $probe->check_interval_minutes) {
    $probe->check_interval_minutes($probe_check_interval_min);
    $probe->retry_interval_minutes($probe_check_interval_min);
  }

  #as the notif interval is a NOT NULL field, must default to something if notifs 
  #are dropped from the probe configuration.
  my $probe_notification_interval_min = $pxt->dirty_param('probe_notification_interval_min') || 5;
  if ($probe_notification_interval_min ne $probe->notification_interval_minutes) {
    $probe->notification_interval_minutes($probe_notification_interval_min);
  }

  my $saved_params = RHN::ProbeParam->list_probe_param_values($probe_id, $probe->command_id);

  my @param_formvars = grep { m/param_/ } $pxt->param();
  my %modified_params;

  foreach my $param_formvar (@param_formvars) {
    my $param_name = $param_formvar;
    $param_name =~ s{^param_}{};

    # test the params to see if they've changed
    foreach my $saved (@{$saved_params}) {
      if ($param_name eq $saved->{PARAM_NAME} && ($saved->{VALUE} ne $pxt->dirty_param($param_formvar))) {
	$modified_params{$param_name} = $pxt->dirty_param($param_formvar);
      }
    }
  }

  ## Can we move probes from one scout to another?
  #if ($probe->sat_cluser_id ne $scout_id) {
  #  $probe->sat_cluster_id($scout_id);
  #}

  if ($probe->last_update_user ne $pxt->user->id) {
    $probe->last_update_user($pxt->user->id);
  }

  my $transaction = RHN::DB->connect();
  $transaction->nest_transactions();

  my $params_to_update = RHN::ProbeParam->create;

  eval {
    $probe->commit;
    $params_to_update->update_probe_param_values($probe_id, %modified_params);
  };

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

  my $escaped = PXT::Utils->escapeHTML($probe->description());

  $pxt->push_message(site_info => "System Probe <strong>$escaped</strong> updated.");
}


sub probe_state_summary {
  my $pxt = shift;
  my %params = @_;

  # my $ds = new RHN::DataSource::Simple(-querybase => 'probe_queries', -mode => 'probe_state_summary');
  my $ds = new RHN::DataSource::Simple(-querybase => 'probe_queries', -mode => 'probe_state_count_by_state_and_user');

  my $probe_state_summary = { total => 0 };
  

  my @states = qw/ok warning critical unknown pending/;

  # process the data looking for states that we recognize and rolling up the total
  # number of probes configured.
  foreach my $state (@states) {
    my $data = $ds->execute_query(-user_id => $pxt->user->id, -state => uc($state));
    foreach my $row (@{$data}) {
      $probe_state_summary->{$state} = $row->{STATE_COUNT};
      $probe_state_summary->{total} += $row->{STATE_COUNT};
    }
  }

  my @probe_state_display = ( 
			      { label => 'critical',
				name  => 'Critical',
                                icon  => '/img/rhn-mon-down.gif',
				value => ($probe_state_summary->{critical} || 0),
				mode  => 'critical' },
			      { label => 'warning',
				name  => 'Warning',
                                icon  => '/img/rhn-mon-warning.gif',
				value => ($probe_state_summary->{warning} || 0),
				mode  => 'warning' },
			      { label => 'unknown',
				name  => 'Unknown',
                                icon  => '/img/rhn-mon-unknown.gif',
				value => ($probe_state_summary->{unknown} || 0),
				mode  => 'unknown' },
			      { label => 'pending',
				name  => 'Pending',
                                icon  => '/img/rhn-mon-pending.gif',
				value => ($probe_state_summary->{pending} || 0),
				mode  => 'pending' },
                              { label => 'ok',
				name  => 'OK',
                                icon  => '/img/rhn-mon-ok.gif',
				value => ($probe_state_summary->{ok} || 0),
				mode  => 'ok' },
			      { label => 'all',
				name  => 'All',
				value => $probe_state_summary->{total},
				mode  => 'all' },
			    );

  if (($probe_state_summary->{total} == 0) and (not defined $params{no_probes_message})) {
    return;
  }

  my $navbar = Sniglets::Navi::Style->new('contentnav');

  my $level = 0;
  my $html .= $navbar->pre_nav;
  $html .= $navbar->pre_level($level);
  my $selected_mode = $params{"selected_mode"};

  foreach my $attrib (@probe_state_display) {
    my $active = ((defined $selected_mode) and ($selected_mode =~ /^$attrib->{mode}/));
    my $link_style = $active ? $navbar->link_style_active($level) : $navbar->link_style($level);
    my $mode_url = $params{"link_url"};
    $mode_url =~ s/\{mode\}/$attrib->{mode}/eg;

    my $link_content;
    if (defined $attrib->{icon}) {
      $link_content .= "<span class=\"toolbar\">";
      $link_content .= PXT::HTML->img( -src => $attrib->{icon} ); 
      #leave out alt and title since the text is right next to it.
      #, -alt => $attrib->{name}, -title => $attrib->{name} );
      $link_content .= "</span>";
    }
    $link_content .= $attrib->{name} . " (" . $attrib->{value} . ")";

    $html .= $navbar->pre_item($pxt, $active, $level);

    $html .= PXT::HTML->link($mode_url, $link_content, $link_style);

    $html .= $navbar->post_item;

  }

  if ($probe_state_summary->{total} == 0) {
    my $msg = $params{no_probes_message};

    $html .= <<EOQ;
<li class="graydata"><strong>$msg</strong></li>
EOQ
  }

  $html .= $navbar->post_level;
  $html .= $navbar->post_nav($pxt);

  return $html;
}


1;
