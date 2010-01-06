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

package Sniglets::AppInstall;

use Params::Validate qw/validate/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::Exception qw/throw/;
use File::Spec;

use RHN::AppInstall::Parser;
use RHN::AppInstall::Session;
use RHN::AppInstall::Process::Step::ScheduleActions;

use Sniglets::Forms;
use Sniglets::Forms::Style;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-appinstall-start", \&appinstall_start);
  $pxt->register_tag("rhn-appinstall-check-requirements", \&appinstall_check_requirements);
  $pxt->register_tag("rhn-appinstall-ts-and-cs", \&appinstall_ts_and_cs);
  $pxt->register_tag("rhn-appinstall-engine", \&appinstall_engine);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:appinstall-engine-cb' => \&appinstall_engine_cb);
}

sub appinstall_start {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $fail_redir = $attr{fail_redir};
  my $version = $pxt->dirty_param('version');

  throw "(missing_attribute) The 'fail_redir' attribute is missing"
    unless $fail_redir;

  my $app = load_appinstall_instance($pxt, $attr{file});

  clear_frozen_session($pxt, $app, 'install');

  my @acl_mixins = $app->get_acl_mixins();
  my $acl_parser = new PXT::ACL (mixins => \@acl_mixins);

  foreach my $prereq ($app->get_prerequisites()) {
    unless ($acl_parser->eval_acl($pxt, $prereq->to_string)) {
      $pxt->redirect($fail_redir);
    }
  }

  my %subst = build_app_substitutions_hash($app);
 
  if ($version) {
    my $condensed_version = condensed_proxy_version($pxt, $version);
    if ( grep {$condensed_version eq $_} qw/400 410 415 420 511 520/) {
      $subst{"link"} = "/rhn/help/proxy/rhn${condensed_version}/en/s1-installation-install-config.jsp";
    }
    elsif ( grep {$condensed_version eq $_} qw/530/) {
      $subst{"link"} = "/rhn/help/proxy/rhn${condensed_version}/en-US/s1-installation-install-config.jsp";
    }
    else {
      $subst{"link"} = "s1-installation-install-config.jsp";
    }
  } else {
    $subst{"link"} = "s1-installation-install-config.html";
  }

  my $html = $attr{__block__};

  return PXT::Utils->perform_substitutions($html, \%subst);
}

# will return number like 420 for version 4.2
sub condensed_proxy_version {
  my $pxt = shift;
  my %attr = @_;
  $attr{'version'} = $pxt->dirty_param('version') unless $attr{'version'};

  if ($attr{'version'} eq "5.1") {
    # we did not ship docs with 5.1.0, only with 5.1.1;
    return '511';
  }
  $attr{'version'} = '4.2' if ($attr{'version'} eq "5.0");  #we have no doc for 5.0
  $attr{'version'} = '4.0' if ($attr{'version'} =~ /^3/);  #we have no doc for 3.7, let' use 4.0
  my $condensed_version = join('',split(/\./, $attr{'version'})) . '0';

  return $condensed_version;
}

sub appinstall_check_requirements {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $html = $attr{__block__};

  my $process = $attr{process};
  throw "(missing_attribute) The 'process' attribute is missing"
    unless $process;

  my $doc_link = $attr{'doc-link'};
  throw "(missing_attribute) The 'doc-link' attribute is missing"
    unless $doc_link;
  $doc_link = PXT::Utils->perform_substitutions($doc_link, { 'condensed_proxy_version' => condensed_proxy_version($pxt) });

  my $app = load_appinstall_instance($pxt, $attr{file});

  my $session = new RHN::AppInstall::Session (-app_instance => $app,
					      -process_name => $process,
					      -user => $pxt->user,
					      -server => RHN::Server->lookup(-id => $sid),
					     );

  my $step;

  while ($step = $session->advance_step) {
    if ($step->get_acl and not $session->eval_acl($step->get_acl)) {
      next;
    }

    last if ($step->isa('RHN::AppInstall::Process::Step::Requirements'));
  }

  return $html unless $step;

  my @errors;
  my $single_error_template = <<EOQ;
  <li>{error}</li>
EOQ

  while (my $current_req = $step->pop_requirement) {
    if (my $error = $session->check_requirement($current_req)) {
      push @errors, PXT::Utils->perform_substitutions($single_error_template, { error => $error });
    }
  }

  my $error_template = <<EOQ;
<p>This system does not meet the following requirements:</p>
<ul>
{errors}
</ul>
<p>
  You must satisfy all the requirements before installing {app_get_name} {app_get_version}.
</p>
<p>
  You should also ensure that the necessary actions are allowed on the
  system in question.  You can use the rhn-actions-control script to
  do so:
</p>
  <ul>
    <li>rhn-actions-control --enable-deploy</li>
    <li>rhn-actions-control --enable-run</li>
  </ul>
EOQ

  if (@errors) {
    unless ($doc_link =~ /http/) {
      $doc_link = $pxt->derelative_url($doc_link);
    }

    $html = PXT::Utils->perform_substitutions($error_template, { errors => join('', @errors),
							         doc_link => $doc_link,
							       });
  }

  my %subst = build_app_substitutions_hash($app);

  return PXT::Utils->perform_substitutions($html, \%subst);
}

sub appinstall_ts_and_cs {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $app = load_appinstall_instance($pxt, $attr{file});

  my %subst = build_app_substitutions_hash($app);
  my $html = $attr{__block__};

  return PXT::Utils->perform_substitutions($html, \%subst);
}

sub appinstall_engine {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $process = $attr{process};
  my $error_redir = $attr{"error-page"};

  throw "No process parameter" unless $process;
  throw "No error-page parameter" unless $error_redir;

  my $app = load_appinstall_instance($pxt, $attr{file});
  my $session = lookup_frozen_session($pxt, $app, $process); # Is there a session in progress?

  unless ($session) {
    $session = new RHN::AppInstall::Session (-app_instance => $app,
					     -process_name => $process,
					     -user => $pxt->user,
					     -server => RHN::Server->lookup(-id => $sid),
					    );
  }

  my $step_number = $pxt->dirty_param('step');

  if (defined $step_number) {
    $session->set_step_number($step_number - 1);
  }

  while (my $step = $session->advance_step) {
    if ($step->get_acl and not $session->eval_acl($step->get_acl)) {
      freeze_session($pxt, $app, $session);
      next;
    }

    if ($step->isa('RHN::AppInstall::Process::Step::CollectData')) {
      my $html = $attr{__block__};
      my %subst;

      foreach my $field (qw/get_description get_header get_footer/) {
	$subst{"step_$field"} = $step->$field;
      }

      $subst{"step_render_body"} = render_step_form($pxt, $step, $session, $attr{file});

      return PXT::Utils->perform_substitutions($html, \%subst);;
    }
    elsif ($step->isa('RHN::AppInstall::Process::Step::Requirements')) {
      my @errors;

      while (my $current_req = $step->pop_requirement) {
	if (my $error = $session->check_requirement($current_req)) {
	  push @errors, $error;
	  $pxt->push_message(local_alert => "Requirement not met: $error");
	}
      }

      if (@errors) {
	$pxt->redirect($error_redir);
      }
    }
    elsif ($step->isa('RHN::AppInstall::Process::Step::Activity')) {
      while (my $current_action = $step->shift_action) {

	if (my $error = $session->run_action($current_action)) {
	  $pxt->push_message(local_alert => "Could not " . $step->get_description() . ". Error: $error");

	  clear_frozen_session($pxt, $app, $process);
	  $pxt->redirect($error_redir);
	}
      }
    }
    elsif ($step->isa('RHN::AppInstall::Process::Step::ScheduleActions')) {
      my $aid;
      while (my $current_action = $step->shift_action) {
	my %extra_params;
	if ($aid) {
	  $extra_params{-prerequisite} = $aid;
	}

	my $ret = $session->schedule_action($current_action, %extra_params) || 0;

	# We either got back an action id, or an error message.
	if ($ret =~ /\D/) {
	  my $error = $ret;
	  $pxt->push_message(local_alert => "Could not " . $step->get_description() . ". Error: $error");

	  clear_frozen_session($pxt, $app, $process);
	  $pxt->redirect($error_redir);
	}

	my $new_aid = $ret;
	# This is the top of the action chain
	if ($new_aid and not $aid) {
	  $session->param('__first_scheduled_action__', $new_aid);
	}

	# Do not break action chain if no action was scheduled.
	$aid = $new_aid if $new_aid;
      }
    }
    elsif ($step->isa('RHN::AppInstall::Process::Step::ActionStatus')) {
      my $html = $attr{__block__};
      my %subst;

      foreach my $field (qw/get_description get_header get_footer/) {
	$subst{"step_$field"} = $step->$field;
      }

      $subst{"step_render_body"} = render_action_status($pxt, $step, $session);

      return PXT::Utils->perform_substitutions($html, \%subst);
    }
    elsif ($step->isa('RHN::AppInstall::Process::Step::Redirect')) {
      unless ($step->save_session) {
	clear_frozen_session($pxt, $app, $process);
      }

      $pxt->redirect($step->get_url);
    }
    else {
      throw "(no_such_step) I don't know how to deal with '$step'";
    }

    freeze_session($pxt, $app, $session);
  }

  my $html = <<EOQ;
<div class="page-content">
  <p>All done.</p>
</div>
EOQ

  clear_frozen_session($pxt, $app, $session->get_process_name());

  return $html;
}

sub appinstall_engine_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  my $file = $pxt->dirty_param('file');
  my $app_label = $pxt->dirty_param('app_label');
  my $app_version = $pxt->dirty_param('app_version');
  my $process = $pxt->dirty_param('process_name');
  my $cancel = $pxt->dirty_param('cancel');
  my $continue_redir = $pxt->dirty_param('continue_redir');

  my $app = load_appinstall_instance($pxt, $file);
  my $session = lookup_frozen_session($pxt, $app, $process); # Is there a session in progress?

  unless ($session) {
    throw sprintf(<<EOQ, $app_label, $app_version, $process, $pxt->user->id);
(session_lookup_error) Could not look up appinstall session (%s, %s, %s) for user (%s)
EOQ
  }

  if ($cancel) {
    clear_frozen_session($pxt, $app, $process);
    $pxt->push_message(site_info => "Installation of <strong>" . $app->get_name() . "</strong> cancelled.");
    $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid");
  }

  if ($continue_redir) {
    unless ($pxt->dirty_param('save_session')) {
      clear_frozen_session($pxt, $app, $process);
    }

    $pxt->redirect($continue_redir . "?sid=" . $sid);
  }

  my $step = $session->advance_step();
  my $pform = build_step_form($pxt, $step, $session, $file);

  unless ($pform) {
    $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid");
  }

  my $form = $pform->prepare_response;
  undef $pform;

  my $errors = Sniglets::Forms::load_params($pxt, $form);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }

    appinstall_redir($pxt, $session->get_step_number);
  }

  my $upload_data;
  if ($pxt->upload) {
    my $fh = $pxt->upload->fh;
    $upload_data = do { local $/; <$fh> };
  }

  foreach my $widget ($form->widgets()) {
    next unless ($widget->editable or $widget->isa('RHN::Form::Widget::Hidden'));

    if ($widget->can('accept')) { # ie, a File upload widget
      if (not $upload_data) {
	$pxt->push_message(local_alert => "Could not read file for '" . $widget->name . "'\n");

	appinstall_redir($pxt, $session->get_step_number);
      }

      $session->param($widget->label(), $widget->value || '0', $upload_data);
    }
    else {
      $session->param($widget->label(), $pxt->passthrough_param($widget->label()) || '0');
    }
  }

  freeze_session($pxt, $app, $session);

  appinstall_redir($pxt, $session->get_step_number + 1);
}

sub appinstall_redir {
  my $pxt = shift;
  my $step_number = shift;

  my $sid = $pxt->param('sid');
  my $version = $pxt->dirty_param('version');
  my $url = $pxt->uri . "?sid=$sid&version=$version";

  if ($step_number) {
    $url .= "&step=$step_number";
  }

  $pxt->redirect($url);
}

sub load_appinstall_instance {
  my $pxt = shift;
  my $file = shift;

  throw "(missing_parameter) The 'file' parameter was needed but not provided."
    unless $file;

  # load the application install object
  $file = File::Spec->catfile($pxt->document_root, $file);
  my $app = RHN::AppInstall::Parser->parse_file($file);

  my ($vol, $dir) = File::Spec->splitpath($file);
  $app->set_app_dir($dir);

  $app->commit;

  return $app;
}

sub lookup_frozen_session {
  my $pxt = shift;
  my $app = shift;
  my $process = shift;

  my $server = RHN::Server->lookup(-id => $pxt->param('sid'));
  my $session = RHN::AppInstall::Session->lookup_or_new(-user => $pxt->user, -server => $server,
							-app_instance => $app, -process_name => $process);

  return $session;
}

sub freeze_session {
  my $pxt = shift;
  my $app = shift;
  my $session = shift;

  $session->commit;

  return;
}

sub clear_frozen_session {
  my $pxt = shift;
  my $app = shift;
  my $process = shift;

  RHN::AppInstall::Session->clear_session(-user_id => $pxt->user->id, -server_id => $pxt->param('sid'),
					  -app_instance_id => $app->get_id, -process => $process);

  return;
}

sub build_app_substitutions_hash {
  my $app = shift;

  my %subst;

  foreach my $field (qw/get_name get_version get_label get_ts_and_cs/) {
    $subst{"app_$field"} = $app->$field();
  }

  return %subst;
}

sub render_step_form {
  my $pxt = shift;
  my $step = shift;
  my $session = shift;
  my $file = shift;

  my $form = build_step_form($pxt, $step, $session, $file);

  unless ($form) {
    $pxt->redirect("/rhn/systems/details/Overview.do?sid=" . $pxt->param('sid'));
  }

  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style('standard');
  my $html = $rform->render($style);

  return $html;
}

sub build_step_form {
  my $pxt = shift;
  my $step = shift;
  my $session = shift;
  my $file = shift;

  return unless ($step->can('get_form'));

  my $form = $step->get_form;

  $form->add_widget(submit => {label => "Continue", name => 'continue'});

  unless ($step->get_no_cancel) {
    $form->add_widget(submit => {label => "Cancel", name => 'cancel'});
  }

  $form->add_widget(hidden => {label => "sid",
			       default => $pxt->param('sid')});
  $form->add_widget(hidden => {label => "app_label",
			       default => $session->get_app_instance->get_label()});
  $form->add_widget(hidden => {label => "app_version",
			       default => $session->get_app_instance->get_version()});
  $form->add_widget(hidden => {label => "process_name",
			       default => $session->get_process_name()});
  $form->add_widget(hidden => {label => "file",
			       default => $file});
  $form->add_widget(hidden => {label => "pxt:trap",
			       value => "rhn:appinstall-engine-cb"});
  $form->add_widget(hidden => {label => "version",
			       default => $session->get_app_instance->get_version()});

  foreach my $widget ($form->widgets) {
    next unless $widget->acl;

    unless ($session->eval_acl($widget->acl)) {
      $form->remove_widget($widget->label);
    }
  }

  return $form;
}

sub render_action_status {
  my $pxt = shift;
  my $step = shift;
  my $session = shift;

  my $action_name = $step->get_action->get_name;
  my $sid = $pxt->param('sid');
  my $server = RHN::Server->lookup(-id => $sid);

  my $target_action = $server->get_latest_action_named($action_name);

  unless ($target_action) {
    throw "(missing_action) Could not find an action named '$action_name' for system '$sid'\n";
  }

  my $current_action = $target_action->get_top_of_action_chain();

  my $html;
  my $row = qq(<li><a href="/network/systems/details/history/event.pxt?sid=%d&amp;hid=%d">%s</a> - %s</li>\n);

  my ($failed, $complete) = (0,1); # flags - has the chain failed or is it complete?

  my $extra_failed_message = '';

  while ($current_action) {
    my $status = $current_action->get_full_server_status($server->id);

    my $action_display_name = $current_action->name || $current_action->action_type_name;
    my $status_msg = $status->{STATUS_NAME};

    unless ($status->{STATUS_NAME} eq 'Completed') {
      $complete = 0;
    }

    if ($status->{STATUS_NAME} eq 'Failed') {
      $failed = 1;

      if ($status->{RESULT_MSG}) {
	$status_msg .= ' (<strong>' . $status->{RESULT_MSG} . '</strong>)';
      }

      my $type_label = $current_action->action_type_label;
      my @known_types = qw/script.run configfiles.deploy/;
      if ((grep { $type_label eq $_ } @known_types)
	  and $status->{RESULT_CODE}
	  and $status->{RESULT_CODE} == 42) {
	my ($dir_name, $perm_name) = split(/\./, $type_label);

	$extra_failed_message =<<EOQ;
<p>
  You can enable the <strong>$type_label</strong> action type by
  running the rhn-actions-control command as root on the target
  system:
  <div class="page-content">
    <code>
      rhn-actions-control --enable-$perm_name
    </code>
  </div>
</p>
EOQ
      }
    }

    $html .= sprintf($row,
		     $sid,
		     $current_action->id,
		     $action_display_name,
		     $status_msg,
		    );


    $current_action = $current_action->next_action_in_chain;
  }

  if ($html) {
    $html = "<ol>\n$html\n</ol>\n";
  }

  my $complete_msg = $step->get_complete_msg || <<EOQ;
The installation is complete.
EOQ

  my $failed_msg = $step->get_failed_msg || <<EOQ;
The installation has failed.  Click on the failed action for more
details, and try your installation again.
EOQ

  $failed_msg .= $extra_failed_message;

  my $inprogress_msg = $step->get_inprogress_msg || '';

  if ($complete) {
    $html .= "<p>$complete_msg</p>";
  }
  elsif ($failed) {
    $session->set_step_number($session->get_step_number - 1);
    freeze_session($pxt, $session->get_app_instance, $session);

    $html .= "<p>$failed_msg</p>";
  }
  else {
    $session->set_step_number($session->get_step_number - 1);
    freeze_session($pxt, $session->get_app_instance, $session);

    $html .= "<p>$inprogress_msg</p>";
  }

  return $html;
}

sub find_session_in_progress {
  my $pxt = shift;
  my %attr = validate(@_, { file => 1,
			    process => 1,
			  } );

  my $app = load_appinstall_instance($pxt, $attr{file});
  my $session = lookup_frozen_session($pxt, $app, $attr{process});

  if ($session and (not $session->get_id or not $session->eval_acl($session->current_process->get_acl))) {
    $session = undef;
  }

  return $session;
}

1;
