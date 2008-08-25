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

use RHN::Exception;
use RHN::ConfigChannel;
use RHN::ConfigRevision;
use RHN::DataSource::ConfigChannel;

use Sniglets::Forms;
use Sniglets::Forms::Style;
use Sniglets::ActivationKeys;
use RHN::Form::ParsedForm;
use RHN::Form::Widget::File;
use RHN::Form::Widget::RadiobuttonGroup;

use Params::Validate qw/validate/;

use File::Spec;

# constant representing the 16kb limit for editable config files
use constant max_edit_size => 16384;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  # use -150 for priority since we need to set a {foo} that is consumed by a the navi tag



  $pxt->register_tag('rhn-cfg-mtime-import-defaults' => \&cfg_mtime_import_defaults);

  $pxt->register_tag('rhn-config-channel-edit-form' => \&config_channel_edit_form, -150);
  $pxt->register_tag('rhn-config-channel-details' => \&config_channel_details, -150);
  $pxt->register_tag('rhn-config-channels-select-type' => \&config_channels_select_type);
  $pxt->register_tag('rhn-config-channel-list-typed-include' => \&config_channel_list_typed_include);


  $pxt->register_tag('rhn-sdc-configfile-details' => \&sdc_configfile_details);

  $pxt->register_tag('rhn-configfile-details' => \&configfile_details, -150);
  $pxt->register_tag('rhn-configfile-delimiters' => \&configfile_delimiters, -140);
  $pxt->register_tag('rhn-configfile-latest-check' => \&configfile_latest_check, -160);
  $pxt->register_tag('rhn-configfile-file-details' => \&configfile_file_details, -150);

  $pxt->register_tag('rhn-act-key-config-channels-form' => \&act_key_config_channels_form);
  $pxt->register_tag('rhn-system-config-channels-form' => \&system_config_channels_form);
  $pxt->register_tag('rhn-ssm-config-channels-form' => \&ssm_config_channels_form);
  $pxt->register_tag('rhn-ssm-config-channels-confirmation-form' => \&ssm_config_channels_confirmation_form);

  $pxt->register_tag('rhn-upload-configfile-form' => \&upload_configfile_form);
  $pxt->register_tag('rhn-configfile-name' => \&configfile_name);
  $pxt->register_tag('rhn-configfile-links' => \&configfile_links);
  $pxt->register_tag('rhn-configfile-raw-contents' => \&configfile_raw_contents);
  $pxt->register_tag('rhn-configfile-edit-form' => \&configfile_edit_form);
  $pxt->register_tag('rhn-configfile-not-latest' => \&configfile_not_latest);

  $pxt->register_tag('rhn-system-specific-config-channel-details' => \&system_specific_config_channel_details);
  $pxt->register_tag('rhn-configfile-diff-sentinel' => \&configfile_diff_sentinel);
  $pxt->register_tag('rhn-configfile-diff' => \&configfile_diff);
  $pxt->register_tag('rhn-actionconfigfile-details' => \&actionconfigfile_details);

  $pxt->register_tag('rhn-config-system-barrier' => \&config_system_barrier, -200);

  $pxt->register_tag('rhn-system-config-stats' => \&system_config_stats);
  $pxt->register_tag('rhn-system-last-verification' => \&system_last_verified);
  $pxt->register_tag('rhn-org-quota-details' => \&org_quota_details);
  $pxt->register_tag('rhn-maximum-config-file-size' => \&maximum_config_file_size);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:cfg-import-type-cb' => \&cfg_import_type_cb);
  $pxt->register_callback('rhn:cfg-schedule-mtime-import-cb' => \&cfg_schedule_mtime_import_cb);

  $pxt->register_callback('rhn:config-channel-edit-cb' => \&config_channel_edit_cb);
  $pxt->register_callback('rhn:config-channel-delete-cb' => \&config_channel_delete_cb);

  $pxt->register_callback('rhn:act-key-config-channels-cb' => \&act_key_config_channels_cb);
  $pxt->register_callback('rhn:system-config-channels-cb' => \&system_config_channels_cb);
  $pxt->register_callback('rhn:ssm-config-channels-confirmation-cb' => \&ssm_config_channels_confirmation_cb);


  $pxt->register_callback('rhn:upload-configfile-cb' => \&upload_configfile_cb);
  $pxt->register_callback('rhn:configfile-file-delete-cb' => \&configfile_file_delete_cb);
  $pxt->register_callback('rhn:configfile-edit-cb' => \&configfile_edit_cb);
  $pxt->register_callback('rhn:configfile-toggle-binary-cb' => \&configfile_toggle_binary_cb);

  $pxt->register_callback('rhn:configfile_copy_files_cb' => \&configfile_copy_files_cb);
  $pxt->register_callback('rhn:configfile-sandbox-delete-files-cb' => \&configfile_sandbox_delete_files_cb);
}


sub cfg_schedule_mtime_import_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');

  my $after_date = Sniglets::ServerActions->parse_date_pickbox($pxt, prefix => "after");
  my $before_date = Sniglets::ServerActions->parse_date_pickbox($pxt, prefix => "before");
  my $earliest_date = Sniglets::ServerActions->parse_date_pickbox($pxt);


  my @white_list = split /(\r\n)+/, $pxt->dirty_param('search_paths');
  if (not @white_list) {
    push @white_list, '/';
  }

  my @black_list = split /(\r\n)+/, $pxt->dirty_param('ignore_paths');

  my $import_contents = $pxt->dirty_param('import_contents');

  my ($action_id) = RHN::Scheduler->schedule_mtime_upload(-org_id => $pxt->user->org_id,
							  -user_id => $pxt->user->id,
							  -earliest => $earliest_date,
							  -after => $after_date,
							  -before => $before_date,
							  -server_id => $sid,
							  -action_name => undef,
							  -white_list => [@white_list],
							   -black_list => [@black_list],
							  -import_contents => $import_contents,
							 );

  $pxt->push_message(site_info => "Import scheduled");
  $pxt->redirect("/rhn/systems/details/configuration/ViewModifySandboxPaths.do?sid=$sid");
}

sub cfg_import_type_cb {
  my $pxt = shift;
  my $sid = $pxt->param('sid');
  my $import_type = $pxt->dirty_param('import_type');
  $pxt->redirect("/rhn/systems/details/configuration/addfiles/ImportFile.do?sid=$sid");
}




sub cfg_mtime_import_defaults {
  my $pxt = shift;
  my %params = @_;

  my %subst = (white_list_defaults => '/',
	       black_list_defaults => '',
	      );
  return PXT::Utils->perform_substitutions($params{__block__}, \%subst);
}


sub last_action {
  my %params = validate(@_, {user => 1, server => 1, action_type => 1, status => 0});

  my $action = $params{server}->get_latest_action(-action_type => $params{action_type},
						  -status => $params{status},
						 );

  my %ret;

  if ($action) {
    $ret{action} = $action;

    my $event = RHN::Server->server_event_simple_action($params{server}->id, $action->id);
    my $login = $event->{LOGIN} ? PXT::Utils->escapeHTML($event->{LOGIN}) : qq{<span class="no-details">(unknown)</span>};

    $ret{info} = $params{user}->convert_time($event->{COMPLETION_TIME});

    $ret{info} .= "<br />\nby <strong>" . $login . "</strong>";
  }

  return \%ret;
}

sub system_last_verified {
  my $pxt = shift;
  my %params = @_;

  my $sid = $pxt->param('sid');
  die 'no sid' unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server for sid $sid" unless $server;

  my %subs;

  my $last_verify = last_action (user => $pxt->user,
				 server => $server,
				 status => ['Completed', 'Failed'],
				 action_type => 'configfiles.diff',
				);
  if (%{$last_verify}) {
    $subs{info} = $last_verify->{info};

    my $ds = new RHN::DataSource::Simple(-querybase => "config_queries",
					 -mode => 'diff_action_info');

    my $revisions = $ds->execute_query(-sid => $sid, -hid => $last_verify->{action}->id);
    my $total = scalar @{$revisions};
    my $differences = scalar grep {$_->{STATUS} and $_->{STATUS} eq 'Differences exist'} @{$revisions};
    my $failures = scalar grep {$_->{FAILURE_REASON}} @{$revisions};

    if ($differences) {
      $subs{results} = PXT::HTML->link2(text => "$differences of $total files",
					 url => "/network/systems/details/history/event.pxt?sid=$sid&amp;hid=" . $last_verify->{action}->id,
					);
      $subs{results} .= " differ from the config channel version";
    }
    else {
      $subs{results} = '<span class="no-details">(none)</span>';
    }

    if ($failures) {
      $subs{results} .= "<br /><br />\n";
      $subs{results} .= PXT::HTML->link2(text => "$failures of $total files",
					 url => "/network/systems/details/history/event.pxt?sid=$sid&amp;hid=" . $last_verify->{action}->id,
					);

      $subs{results} .= " were not able to be diffed";
    }
  }
  else {
    $subs{info} = '<span class="no-details">(never)</span>';
    $subs{results} = '<span class="no-details">(none)</span>';
  }


  return PXT::Utils->perform_substitutions($params{__block__}, \%subs);
}


sub system_config_stats {
  my $pxt = shift;
  my %params = @_;

  my $sid = $pxt->param('sid');
  die 'no sid' unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);
  die "no server for sid $sid" unless $server;

  my $no_details = '<span class="no-details">(none)</span>';

  my %subs;

  # get the last deploy, regardless of success, because deploys can be partially successful
  my $last_deploy = last_action(user => $pxt->user,
				server => $server,
				status => ['Completed', 'Failed'],
				action_type => 'configfiles.deploy',
			       );

  $subs{last_deployment} = %{$last_deploy} ? $last_deploy->{info} : $no_details;

  my $revisions = [ ];

  my $simple_info;
  if ($last_deploy->{action}) {
    my $deploy_revs_ds = new RHN::DataSource::Simple(-querybase => "config_queries",
						     -mode => 'config_action_revisions');

    $revisions = $deploy_revs_ds->execute_query(-sid => $sid, -aid => $last_deploy->{action}->id);
    $simple_info = RHN::DB::Server->server_event_simple_action($sid, $last_deploy->{action}->id);
  }

  my $total = scalar @{$revisions};
  my $failures = scalar grep {$_->{FAILURE_REASON}} @{$revisions};
  my $successes = $total - $failures;


  if ($simple_info) {
    if ($simple_info->{STATUS} eq 'Completed') {
      if ($successes) {
	$subs{last_deployment} .= "<br /><br />\n";
	$subs{last_deployment} .= PXT::HTML->link2(text => "$successes of $total config files",
					       url => "/network/systems/details/history/event.pxt?sid=$sid&amp;hid=" . $last_deploy->{action}->id);
	$subs{last_deployment} .= " successfully deployed";
      }
    }
    else {
      $subs{last_deployment} .= "<br /><br />\n";
      $subs{last_deployment} .= "<strong>Failed:</strong>  " . $simple_info->{RESULT_MSG};
    }

    if ($failures) {
      $subs{last_deployment} .= "<br /><br />\n";
      $subs{last_deployment} .= PXT::HTML->link2(text => "$failures of $total config files",
					       url => "/network/systems/details/history/event.pxt?sid=$sid&amp;hid=" . $last_deploy->{action}->id);
      $subs{last_deployment} .= " failed to deploy";
    }
  }


  my $last_verify = last_action (user => $pxt->user,
				 server => $server,
				 status => ['Completed', 'Failed'],
				 action_type => 'configfiles.diff',
				);

  $subs{last_verified} = %{$last_verify} ? $last_verify->{info} : $no_details;

  $revisions = [ ];

  if ($last_verify->{action}) {
    my $diff_revs_ds = new RHN::DataSource::Simple(-querybase => "config_queries",
						   -mode => 'diff_action_revisions');

    $revisions = $diff_revs_ds->execute_query(-sid => $sid, -aid => $last_verify->{action}->id);


    $total = scalar @{$revisions};
    $failures = scalar grep {$_->{FAILURE_REASON}} @{$revisions};
    my $differences = scalar grep {$_->{STATUS} and $_->{STATUS} eq 'Differences exist'} @{$revisions};

    if ($differences) {
      $subs{last_verified} .= "<br /><br />\n";
      $subs{last_verified} .= PXT::HTML->link2(text => "$differences of $total files",
					     url => "/network/systems/details/history/event.pxt?sid=$sid&amp;hid=" . $last_verify->{action}->id,
					    );
      $subs{last_verified} .= " differ from the config channels' versions";
    }
    else {
      $subs{last_verified} .= "<br /><br />\nNo existing files differed from the config channels' versions";
    }

    if ($failures) {
      $subs{last_verified} .= "<br /><br />\n";
      $subs{last_verified} .= PXT::HTML->link2(text => "$failures of $total files",
					       url => "/network/systems/details/history/event.pxt?sid=$sid&amp;hid=" . $last_verify->{action}->id,
					      );

      $subs{last_verified} .= " were not able to be diffed";
    }
  }


  my $num_resolved_files = scalar $server->get_resolved_files();

  if ($num_resolved_files) {
    $subs{managed_files_count} = PXT::HTML->link2(text => "$num_resolved_files file" . ($num_resolved_files > 1 ? 's':''),
						  url => "/rhn/systems/details/configuration/DeployFile.do?sid=$sid",
						 );
  }
  else {
    $subs{managed_files_count} = $no_details;
  }


  my $num_config_channels = scalar $server->config_channels();

  if ($num_config_channels) {
    $subs{config_channels} = PXT::HTML->link2(text => "$num_config_channels config channel" . ($num_config_channels > 1 ? 's':''),
					      url => "/rhn/systems/details/configuration/ConfigChannelList.do?sid=$sid",
					     );
  }
  else {
    $subs{config_channels} = $no_details;
  }


  my $num_overrides;
  my $override_ccid = RHN::ConfigChannel->vivify_server_config_channel($server->id, 'local_override');

  if ($override_ccid) {
    $num_overrides = scalar (RHN::ConfigChannel->latest_revisions($override_ccid));
  }

  if ($num_overrides) {
    $subs{system_overrides} = PXT::HTML->link2(text => "$num_overrides override file" . ($num_overrides > 1 ? 's':''),
					      url => "/rhn/systems/details/configuration/ViewModifyLocalPaths.do?sid=$sid",
					     );
  }
  else {
    $subs{system_overrides} = $no_details;
  }
  $subs{system_overrides} .= "<br /><br />\n";
  $subs{system_overrides} .= PXT::HTML->link2(text => "Work with system config file overrides",
					      url => "/rhn/systems/details/configuration/ViewModifyLocalPaths.do?sid=$sid",
					     );



  my $num_uploads;
  my $upload_ccid = RHN::ConfigChannel->vivify_server_config_channel($server->id, 'server_import');

  if ($upload_ccid) {
    $num_uploads = scalar (RHN::ConfigChannel->latest_revisions($upload_ccid));
  }

  if ($num_uploads) {
    $subs{system_uploads} = PXT::HTML->link2(text => "$num_uploads file" . ($num_uploads > 1 ? 's':''),
					      url => "/rhn/systems/details/configuration/ViewModifySandboxPaths.do?sid=$sid",
					     );
  }
  else {
    $subs{system_uploads} = $no_details;
  }
  $subs{system_uploads} .= "<br /><br />\n";
  $subs{system_uploads} .= PXT::HTML->link2(text => "View system config file sandbox",
					    url => "/rhn/systems/details/configuration/ViewModifySandboxPaths.do?sid=$sid",
					   );


  return PXT::Utils->perform_substitutions($params{__block__}, \%subs);
}

sub config_system_barrier {
  my $pxt = shift;

  if ($pxt->param('sid') and not $pxt->param('ccid')) {
    my $local_ccid = RHN::ConfigChannel->vivify_server_config_channel($pxt->param('sid'), 'local_override');
    $pxt->redirect("files.pxt", ccid => $local_ccid);
  }
}

sub config_channel_details {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  my $ccid = $pxt->param('ccid');
  return '' unless $ccid;

  my $cc = RHN::ConfigChannel->lookup(-id => $ccid);

  my %subst;

  foreach my $method (qw/id org_id name description/) {
    $subst{"config_channel_$method"} = $cc->$method || '';
  }
  PXT::Utils->escapeHTML_multi(\%subst);

  @subst{qw/config_channel_presentation_label config_channel_presentation config_channel_nav_type config_channel_name config_channel_systems_link/}
    = get_channel_type_presentation($cc);

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub configfile_latest_check {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  my $crid = $pxt->param('crid');
  throw "No config revision id" unless $crid;

  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  if ($cr->latest eq 'N') {
    return "<strong>Note: There are " .
      PXT::HTML->link2(-text => "newer revisions", -url => "/rhn/configuration/file/FileDetails.do", -params => { crid => $cr->latest_id }) .
	  " of this file.</strong>";
  }

  return;
}

sub configfile_delimiters {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  my $crid = $pxt->param('crid');
  throw "No config revision id" unless $crid;

  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  # we only do substitution on non-binary config files
  return '' if $cr->is_binary();

  my %subst;
  $subst{delim_start} = $cr->delim_start();
  $subst{delim_end} = $cr->delim_end();

  return PXT::Utils->perform_substitutions($block, \%subst);
}


sub sdc_configfile_details {
  my $pxt = shift;
  my %attr = @_;

  my $crid = $pxt->param('crid');
  throw "No config revision id" unless $crid;

  my $sid = $pxt->param('sid');
  throw "no server id" unless $sid;

  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  my $local_override_ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, 'local_override');

  my $can_edit = $cr->config_channel_id == $local_override_ccid ? 1 : 0;


  if ($can_edit) {
      my $form = build_configfile_edit_form($pxt, %attr);
      my $rform = $form->realize;
      undef $form;

      Sniglets::Forms::load_params($pxt, $rform);

      my $type = ucfirst $cr->filetype;

      my $ret = "<h2>" . PXT::HTML->img(-src => '/img/rhn-config_namespace.gif') . "Edit $type Details</h2>";
      $ret .= $rform->render(new Sniglets::Forms::Style);

      return $ret;
  }
  else {
      return configfile_details($pxt, %attr);
  }
}


sub configfile_details {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  my $crid = $pxt->param('crid');
  throw "No config revision id" unless $crid;

  my $cr = RHN::ConfigRevision->lookup(-id => $crid);
  my %subst;

# base configfile fields
  foreach my $method (qw/id path revision md5sum org_id config_channel_id filetype/) {
    $subst{"configfile_${method}"} = $cr->$method || '';
  }

  if ($cr->is_binary) {
    $subst{configfile_contents} = "(binary file, contents hidden)";
  }
  else {
    $subst{configfile_contents} = $cr->contents;
  }

# configfile info fields
  foreach my $method (qw/file_size username groupname filemode/) {
    $subst{"configfile_${method}"} = $cr->$method || '(not set)';
  }

# date fields
  foreach my $method (qw/created modified/) {
    $subst{"configfile_${method}"} = $pxt->user->convert_time($cr->$method || '');
  }

# namespace fields

  $subst{configfile_config_channel_description} = $cr->config_channel->description || '';

  my ($vol, $dirs, $name) = File::Spec->splitpath($cr->path);
  $subst{"configfile_filename"} = $name || '';
  $subst{"configfile_dir"} = $dirs || '';
  $subst{"configfile_file_id"} = $cr->config_file_id;
 
  PXT::Utils->escapeHTML_multi(\%subst);

  $subst{configfile_is_binary} = ($cr->is_binary ? 'Yes' : 'No');

  $subst{configfile_binary_toggle} =
    ($cr->is_binary ? 'Yes' : 'No') .
      " - " .
	PXT::HTML->link2(-url => "details.pxt",
			 -params => { crid => $cr->id, "pxt:trap" => "rhn:configfile-toggle-binary-cb" },
			 -text => "Toggle");

  $subst{configfile_too_big} =
    ((not length($cr->contents) < max_edit_size) ? '(too large to edit)' : '');

  @subst{qw/configfile_channel_presentation_label configfile_channel_presentation configfile_channel_nav_type configfile_channel_name configfile_channel_id/}
    = get_channel_type_presentation($cr->config_channel);

  $block = PXT::Utils->perform_substitutions($block, \%subst);

  return $block;
}

sub configfile_toggle_binary_cb {
  my $pxt = shift;
  my $crid = $pxt->param('crid');
  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  $cr->is_binary(!$cr->is_binary);
  $cr->commit_binary_flag;

  $pxt->redirect("details.pxt", crid => $cr->id);
}

sub get_channel_type_presentation {
  my $cc = shift;

  if ($cc->type_label eq 'local_override') {
    my $sid = $cc->find_overriding_system;
    my $server = RHN::Server->lookup(-id => $sid);

    return ("System",
	    PXT::HTML->link(sprintf("/rhn/systems/details/Overview.do?sid=%d", $server->id),
			    $server->name),
            "system_config_channel",
            $server->name,
            $cc->id);

  }
  else {
    return ("Config Channel",
	    PXT::HTML->link(sprintf("/rhn/configuration/GlobalConfigChannelList.do?ccid=%d", $cc->id),
			    $cc->name),
            "namespace",
            $cc->name,
            $cc->id);
  }
}

sub configfile_file_details {
  my $pxt = shift;
  my %attr = @_;
  my $block = $attr{__block__};

  my $cfid = $pxt->param('cfid');
  throw "No config file id" unless $cfid;

  my $path = RHN::ConfigFile->file_id_to_path($cfid);
  my $cc = RHN::ConfigChannel->lookup(-cfid => $cfid);

  my %subst;
  $subst{"configfile_channel_name"} = $cc->name;
  $subst{"configfile_channel_id"} = $cc->id;
  $subst{"configfile_file_path"} = $path;
  $subst{"configfile_file_id"} = $cfid;

  PXT::Utils->escapeHTML_multi(\%subst);

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub configfile_diff_sentinel {
  my $pxt = shift;
  my %attr = @_;

  my $crid = $pxt->param('crid');
  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  if ($cr->is_binary) {
    $pxt->push_message(local_alert => sprintf("This revision of %s is a binary file; it cannot be diff'd.", $cr->path));
    return '';
  }

  return $attr{__block__};
}


sub configfile_diff {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  my $crid = $pxt->param('crid');
  throw "No config file id" unless $crid;

  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  my %subst;
# base configfile fields
  foreach my $method (qw/id path revision md5sum contents org_id config_channel_id/) {
    $subst{"configfile_${method}"} = $cr->$method || '';
  }

# namespace fields
  foreach my $ns_method (qw/name description/) {
    $subst{"configfile_config_channel_${ns_method}"} = $cr->config_channel->$ns_method || '';
  }

  my $target_crid = $pxt->param('target_crid');
  throw "No config file id" unless $target_crid;

  my $target_cr = RHN::ConfigRevision->lookup(-id => $target_crid);

  for my $rev ($cr, $target_cr) {
    if ($rev->is_binary) {
      $pxt->push_message(local_alert => sprintf("Revision %d of %s in %s is a binary file; it cannot be diff'd.",
						$rev->revision, $rev->path, $rev->config_channel->name));
      return '';
    }
  }

# base target_configfile fields
  foreach my $method (qw/id path revision md5sum contents org_id config_channel_id/) {
    $subst{"target_configfile_${method}"} = $target_cr->$method || '';
  }

# namespace fields
  foreach my $ns_method (qw/name description/) {
    $subst{"target_configfile_config_channel_${ns_method}"} = $target_cr->config_channel->$ns_method || '';
  }

  PXT::Utils->escapeHTML_multi(\%subst);

  my $diff = RHN::ConfigRevision->diff_config_revisions(-file_1 => $cr, -file_2 => $target_cr, -user => $pxt->user);
  $subst{configfiles_diff} = PXT::HTML->htmlify_text($diff);

  $subst{select_target_revision} = select_revision_widgets($pxt, $target_cr);

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub select_revision_widgets {
  my $pxt = shift;
  my $cr = shift;

  my $revisions = $cr->sibling_revisions;

  my @widgets;

  for (@$revisions) {
    $_->{REVISION} = "$_->{REVISION} (binary}"
      if $_->{IS_BINARY} eq 'Y'
  }
  push @widgets,
    new RHN::Form::Widget::Select(name => 'Select Target Revision', label => 'target_crid', default => $cr->id,
				  options => [ map { {label => $_->{REVISION}, value => $_->{ID}} } @{$revisions}]);

  push @widgets,
    new RHN::Form::Widget::Submit(name => 'View Diff');

  push @widgets,
    new RHN::Form::Widget::Hidden(name => 'crid', value => $pxt->param('crid'));

  return join(" ", map { $_->render } @widgets);
}

sub config_channel_edit_shield {
  my $pxt = shift;

  my $ccid = $pxt->param('ccid');
  return '' unless $ccid;

  my $cc = RHN::ConfigChannel->lookup(-id => $ccid);

  # can't view edit page for anything besides a 'normal' config channel
  if ($cc->type_label ne 'normal') {
    $pxt->redirect("files.pxt", ccid => $cc->id);
  }

  return '';
}

sub config_channel_edit_form {
  my $pxt = shift;
  my %attr = @_;

  config_channel_edit_shield($pxt);

  my $form = build_config_channel_edit_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

sub build_config_channel_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ccid = $pxt->param('ccid');
  my $verb = $ccid ? 'Edit' : 'Create';

  my $ns;
  if ($ccid) {
    $ns = RHN::ConfigChannel->lookup(-id => $ccid);
  }

  my $form = new RHN::Form::ParsedForm(name => "$verb Config Channel",
				       label => 'edit_namespace',
				       action => $attr{action},
				      );

  $form->add_widget( new RHN::Form::Widget::Text(name => 'Name',
						 label => 'ns_name',
						 size => 36,
						 maxlength => 128,
						 default => ($ns ? $ns->name : '')) );
  $form->lookup_widget('ns_name')->add_require({'min-length' => 3});
  $form->lookup_widget('ns_name')->add_filter('remove_blanks');

  $form->add_widget(new RHN::Form::Widget::Text(name => 'Label',
						 label => 'ns_label',
						 size => 36,
						 maxlength => 128,
						 default => ($ns ? $ns->label : '')));
  $form->lookup_widget('ns_label')->add_require({'min-length' => 3});
  $form->lookup_widget('ns_label')->add_require({ label => 1 });
  $form->lookup_widget('ns_label')->add_filter('remove_blanks');

  $form->add_widget (new RHN::Form::Widget::TextArea(name => 'Description',
						     label => 'ns_description',
						     rows => 6,
						     cols => 80,
						     default => ($ns ? $ns->description : '')) );

  $form->lookup_widget('ns_description')->add_require({response => 1,
						       'max-length' => 1024});

  $form->lookup_widget('ns_description')->add_filter('remove_blanks');

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:config-channel-edit-cb') );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ccid', value => $ccid) );
  $form->add_widget( new RHN::Form::Widget::Submit(name => "$verb Config Channel") );

  return $form;
}

sub sort_by_priority {
  my $pxt = shift;
  return sort {
    my $val_a = $pxt->dirty_param("proposed-order-$a");
    my $val_b = $pxt->dirty_param("proposed-order-$b");
    if ( defined $val_a and defined $val_b) {
      return $val_a <=> $val_b;
    }
    elsif ($val_a) {
      return 1;
    }
    else {
      return 0;
    }
  } @_;
}


sub build_config_channel_widget {
  my %params = validate(@_, {current => 1, available => 1, template => 1, ignore_current => 0});

  return '<strong>No defined config channels</strong>' unless @{$params{available}};

  my $available_template = PXT::Utils->get_subtag_body('available-channel', $params{template});
  die "no available config channel template" unless $available_template;

  my $current_template = PXT::Utils->get_subtag_body('current-channel', $params{template});
  die "no current config channel template" unless $current_template;

  my $separator = PXT::Utils->get_subtag_body('separator', $params{template});
  die "no separator" unless $separator;

  my $html = $params{template};

  my %seen_config_channels;

  my @current;

  my $counter = 0;

  if (not $params{ignore_current}) {
    foreach my $current (@{$params{current}}) {

      next if ($current->{TYPE} eq 'server_import'); #ignore for now

      $counter++;
      $seen_config_channels{$current->{ID}} = 1;

      my %subs;
      $subs{odd_even} = ($counter % 2) ? 'list-row-odd' : 'list-row-even';
      $subs{id} = $current->{ID};

      # $subs{rank} = $current->{POSITION};

      $subs{rank} = $counter;
      $subs{name} = PXT::Utils->escapeHTML($current->{NAME});
      $subs{label} = PXT::Utils->escapeHTML($current->{LABEL});

      if ($current->{TYPE} eq 'normal') {
	push @current, PXT::Utils->perform_substitutions($current_template, \%subs);
      }
      elsif ($current->{TYPE} eq 'local_override') {
	# ugh.  for now, handling this specially...
	push @current, qq!<tr class="$subs{odd_even}"><td class="first-column">$subs{rank}</td><td class="last-column" colspan="2">Local System Config Channel</td></tr> ! ;
      }
      else {
	die "don't know how to deal with config channel type:  " . $current->{TYPE};
      }
    }

    if (@current) {
      $html = PXT::Utils->replace_subtag('current-channel', $html, join("\n", @current));
    }
    else {
      my $no_current = qq{<tr class="list-row-odd"><td align="center" colspan="2">No ranked config channels</td></tr>};
      $html = PXT::Utils->replace_subtag('current-channel', $html, $no_current);
    }
  }
  else {
    $html = PXT::Utils->replace_subtag('current-channel', $html, '');
  }


  my @available;
  $counter = 0;
  foreach my $available (@{$params{available}}) {

    next if $seen_config_channels{$available->{ID}};
    $counter++;

    my %subs;
    $subs{odd_even} = ($counter % 2) ? 'list-row-odd' : 'list-row-even';
    $subs{id} = $available->{ID};

    $subs{rank} = "";
    $subs{name} = PXT::Utils->escapeHTML($available->{NAME});
    $subs{label} = PXT::Utils->escapeHTML($available->{LABEL});
    $available->{SYSTEM_COUNT} ||= '0';
    $subs{system_count} = "<a href=\"/rhn/configuration/channel/ChannelSystems.do?ccid=" . $available->{ID} . "\">" . $available->{SYSTEM_COUNT} . "</a>";
    push @available, PXT::Utils->perform_substitutions($available_template, \%subs);
  }

  if (@available) {

    if ($params{ignore_current}) {
      $html = PXT::Utils->replace_subtag('separator', $html, '');
    }
    else {
      # need the separator...
      $html = PXT::Utils->replace_subtag('separator', $html, $separator);
    }

    $html = PXT::Utils->replace_subtag('available-channel', $html, join("\n", @available));
  }
  else {
    $html = PXT::Utils->replace_subtag('separator', $html, '');
    $html = PXT::Utils->replace_subtag('available-channel', $html, '');
  }

  return $html;
}


sub act_key_config_channels_form {
  my $pxt = shift;
  my %attr = @_;

  my $tid = $pxt->param('tid');

  my $token = RHN::Token->lookup(-id => $tid);

  my @config_channels = sort { $a->{POSITION} <=> $b->{POSITION} } $token->fancy_config_channels;

  my $ds = new RHN::DataSource::ConfigChannel (-mode => 'namespaces_visible_to_org');
  my $org_namespaces = $ds->execute_query(-org_id => $pxt->user->org_id);

  return build_config_channel_widget(current => [@config_channels],
				     available => $org_namespaces,
				     template => $attr{__block__},
				    );
}


sub system_config_channels_form {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $ds = new RHN::DataSource::ConfigChannel (-mode => 'namespaces_for_system');
  my $system_namespaces = $ds->execute_query(-sid => $sid);

  $ds = new RHN::DataSource::ConfigChannel (-mode => 'namespaces_visible_to_org');
  my $org_namespaces = $ds->execute_query(-org_id => $pxt->user->org_id);

  return build_config_channel_widget(current => $system_namespaces,
				     available => $org_namespaces,
				     template => $attr{__block__},
				    );
}


sub ssm_config_channels_form {
  my $pxt = shift;
  my %attr = @_;

  my $ds = new RHN::DataSource::ConfigChannel (-mode => 'namespaces_visible_to_org');
  my $org_namespaces = $ds->execute_full(-org_id => $pxt->user->org_id, -user_id => $pxt->user->id);

  return build_config_channel_widget(current => [],
				     available => $org_namespaces,
				     template => $attr{__block__},
				     ignore_current => 1,
				    );
}

sub ssm_config_channels_confirmation_form {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $action = $pxt->dirty_param('action');

  $block = PXT::Utils->perform_substitutions($block, {action => $action});

  my $confirm_set = RHN::Set->lookup(-label => 'ssm_namespace_confirm_subs',
                                     -uid => $pxt->user->id);

  my $rank_set = RHN::Set->lookup(-label => 'ssm_namespace_subs_rankings',
                                  -uid => $pxt->user->id);

  my @ordered_config_channels;
  my %seen;
  my %rank_hash = $rank_set->output_hash;
  foreach my $rank (sort keys %rank_hash) {
     $seen{$rank_hash{$rank}} = 1;
     push @ordered_config_channels, $rank_hash{$rank};
  }

  my @server_ids = $confirm_set->contents;
  my %config_info;
  my @tables;
  my $table_template =  PXT::Utils->get_subtag_body('table-data', $block);
  my $row_template =  PXT::Utils->get_subtag_body('table-row', $table_template);

  foreach my $sid (@server_ids) {

    my $server = RHN::Server->lookup(-id => $sid);
    my $nds = new RHN::DataSource::ConfigChannel (-mode => 'namespaces_for_system');
    my $system_namespaces = $nds->execute_query(-sid => $sid);

    my %subs;
    $subs{sid} = $server->id;
    $subs{system_name} = $server->name;
  

     my %current_list;
     my $idx = 1;
     my @new_list;

     # add local-override
     foreach my $ns (@{$system_namespaces}) {
       if ($ns->{TYPE} eq 'local_override') {
         push @new_list, $ns->{ID};
         $current_list{$ns->{ID}} = $idx++;
       }
     }

     # add as high-ranked configs
     # adds to new list
     if ($action eq 'Add with Highest Rank') {
       push @new_list, @ordered_config_channels;
     }

     # add the existing config chans
     # adds to both new list (only if not in newly ranked
     # config channels) and current list
     foreach my $ns (@{$system_namespaces}) {
       if ($ns->{TYPE} eq 'normal') {
         push @new_list, $ns->{ID} unless $seen{$ns->{ID}};
         $current_list{$ns->{ID}} = $idx++;
       }
     }

  
     # add as low-ranked configs
     # adds to new list
     if ($action eq 'Add with Lowest Rank') {
       push @new_list, @ordered_config_channels;
     }

     my @rows;

     $idx = 1;
     foreach my $ccid (@new_list) {
       my %row_subs;
       if (not exists $config_info{$ccid}) {
         my $chan_info = RHN::ConfigChannel->lookup(-id => $ccid);
         if ($chan_info->type_label eq "local_override") {
           $config_info{$ccid}->{label} = "Local System Config Channel";
           $config_info{$ccid}->{override} = 1;
         }
         else{
           $config_info{$ccid}->{label} = $chan_info->name;
           $config_info{$ccid}->{override} = 0;
         }
       }
       $row_subs{label} = $config_info{$ccid}->{label};
       if ($config_info{$ccid}->{override}) {
         $row_subs{config_link} = '/rhn/systems/details/configuration/ViewModifyLocalPaths.do?sid=' . $sid;
       }
       else {
         $row_subs{config_link} = '/rhn/configuration/ChannelOverview.do?ccid=' . $ccid;
       }

       $row_subs{odd_even} = ($idx % 2) ?'list-row-odd' : 'list-row-even';
       $row_subs{old_rank} = exists $current_list{$ccid} ? $current_list{$ccid} : "-";
       $row_subs{new_rank} = $idx++;
       
       push @rows, PXT::Utils->perform_substitutions($row_template, \%row_subs);
     }
     my $table = PXT::Utils->replace_subtag('table-row', $table_template, join("\n", @rows));
     push @tables, PXT::Utils->perform_substitutions($table, \%subs);

  }

  $block = PXT::Utils->replace_subtag('table-data', $block, join("\n", @tables));


  return $block;
}

sub upload_configfile_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_upload_configfile_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

sub build_upload_configfile_form {
  my $pxt = shift;
  my %attr = @_;

  my $ccid = $pxt->param('ccid');
  my $crid = $pxt->param('crid');
  my $sid = $pxt->param('sid');
  my $mode = $attr{mode} || '';

  my $form = new RHN::Form::ParsedForm(name => "Upload Config File",
				       label => 'upload_configfile',
				       action => $attr{action},
				       enctype => 'multipart/form-data',
				      );

  if ($mode eq 'upload-new') {
    $form->add_widget( new RHN::Form::Widget::Text(name => 'Deploy File Path',
						 label => 'file_path',
						 size => 64,
						 ) );
    $form->lookup_widget('file_path')->add_require( {response => 1} );
  }

  $form->add_widget( new RHN::Form::Widget::File(name => 'Local File',
						 label => 'config_file',
						 ) );

  $form->lookup_widget('config_file')->add_require( {response => 1} );

  if ($mode eq 'upload-new') {
    add_fileinfo_widgets(form => $form, type => 'file');
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:upload-configfile-cb') );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ccid', value => $ccid) ) if $ccid;
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'crid', value => $crid) ) if $crid;
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'sid', value => $sid) ) if $sid;
  $form->add_widget( new RHN::Form::Widget::Submit(name => "Upload File") );

  return $form;
}

# looks up a configfile name based upon configfilename.id
sub configfile_name {
  my $pxt = shift;
  my %attr = @_;

  my $cfnid = $pxt->dirty_param('cfnid');
  my $path = RHN::ConfigFile->file_name_id_to_path($cfnid);

  return PXT::Utils->perform_substitutions($attr{__block__}, {configfile_path => $path || ''});
}

sub configfile_links {
  my $pxt = shift;
  my %attr = @_;

  my $crid = $pxt->param('crid');
  return unless $crid;

  my $edit_url = $attr{edit} or die "param 'edit' needed but not provided";
  my $download_url = $attr{download} or die "param 'download' needed but not provided";
  my $view_url = $attr{view} or die "param 'view' needed but not provided";

  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  my $html;
  $html .= "<br/>\n" . PXT::HTML->link($download_url, 'download');
  $html .= "<br/>\n" . PXT::HTML->link($view_url, 'view');

  if (not $cr->is_binary and length($cr->contents) < max_edit_size) { # limit to 16kb for edits
    $html .= "<br/>\n";
    $html .= PXT::HTML->link($edit_url . '?crid=' . $cr->id, 'edit');
  }

  return $html;
}

sub configfile_raw_contents {
  my $pxt = shift;

  my $path = File::Spec->canonpath($pxt->path_info);
  $path =~ s(^/)();

  my ($mode, $crid, $name) = split(m(/), $path, 3);
  ($mode, $crid, $name) = ("text", $mode, $crid)
    if $mode =~ /\d/;

  return unless $crid;

  if ($mode eq 'binary') {
    $pxt->content_type('application/octet-stream');
    $pxt->header_out('Content-disposition', "attachment; filename=$name");
  }
  else {
    $pxt->content_type('text/plain');
  }

  $pxt->manual_content(1);
  $pxt->send_http_header;

  unless ($pxt->user->verify_config_revision_access($crid)) {
    die sprintf("User %s (%d) has no access to config file '%s'",
		$pxt->user->login, $pxt->user->id, $crid);
  }

  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  $pxt->print($cr->contents);
}

sub configfile_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_configfile_edit_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

sub build_configfile_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $type = $attr{type};

  my $crid = $pxt->param('crid');
  my $sid = $pxt->param('sid');

  my $verb = $crid ? 'Edit' : 'Create';

  my $cr;
  if ($crid) {
    $cr = RHN::ConfigRevision->lookup(-id => $crid);
    # If we are editing an existing config revision, make
    # sure we reset the type var.
    $type = $cr->filetype;
  }


  my $form = new RHN::Form::ParsedForm(name => "$verb Configfile",
				       label => 'edit_configfile',
				       action => $attr{action},
				      );

  my $path_widget;

  if ($cr) {
    $path_widget = new RHN::Form::Widget::Literal(name => 'Path',
						  label => 'configfile_path',
						  value => $cr->path);
  }
  else {
    $path_widget = new RHN::Form::Widget::Text(name => 'Path',
					       label => 'configfile_path',
					       size => 36,
					       maxlength => 256,
					       default => '');
    $path_widget->add_require({response => 1,
			       'max-length' => 256});
    $path_widget->add_filter('remove_blanks');
  }

  $form->add_widget($path_widget);

  add_fileinfo_widgets(form => $form, config_revision => $cr, type => $type);

  if ((not $cr or not $cr->is_binary()) and (uc $type eq "FILE")) {
      $form->add_widget( new RHN::Form::Widget::Text(name => 'Macro Start Delimiter',
						     label => 'delim_start',
						     size => 2,
						     maxlength => 2,
						     default => $cr ? $cr->delim_start() : PXT::Config->get('config_delim_start')) );

      $form->add_widget( new RHN::Form::Widget::Text(name => 'Macro End Delimiter',
						     label => 'delim_end',
						     size => 2,
						     maxlength => 2,
						     default => $cr ? $cr->delim_end() : PXT::Config->get('config_delim_end')) );

      if ($cr and (length($cr->contents) >= max_edit_size)) {
	  $form->add_widget( new RHN::Form::Widget::Literal(name => 'Contents',
							    label => 'configfile_contents',
							    value => PXT::HTML->htmlify_text($cr->contents())) );
      }
      else {
	  $form->add_widget( new RHN::Form::Widget::TextArea(name => 'Contents',
							     label => 'configfile_contents',
							     rows => 24,
							     cols => 80,
							     default => $cr ? $cr->contents : '') );
      }

      $form->lookup_widget('configfile_contents')->add_require({'max-length' => max_edit_size});
  }

  my $ccid = $pxt->param('ccid');

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:configfile-edit-cb') );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'crid', value => $crid) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'sid', value => $sid) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'type', value => $type) );

  $form->add_widget(hidden => {name => 'ccid', value => $ccid})
    if $ccid;

  if (uc $type eq "DIRECTORY") { #This is a directory
      $form->add_widget( new RHN::Form::Widget::Submit(name => "$verb Config Directory") );
  }
  else { #make file the default
      $form->add_widget( new RHN::Form::Widget::Submit(name => "$verb Config File") );
  } 

  return $form;
}

sub add_fileinfo_widgets {
  my %params = validate(@_, {form => 1, config_revision => 0, type => 1});
  my $form = $params{form};
  my $cr = $params{config_revision};
  my $type = $params{type};

  $form->add_widget(text => {name => 'User',
			     label => 'configfile_username',
			     size => 32,
			     maxlength => 32,
			     default => $cr ? $cr->username : 'root'});

  $form->add_widget(text => {name => 'Group',
			     label => 'configfile_groupname',
			     size => 32,
			     maxlength => 32,
			     default => $cr ? $cr->groupname : 'root'});

  my $mode = $type eq 'file' ? '600' : '700';
  my $perm = $type eq 'file' ? 3 : 4;

  if (defined $cr) {
    $mode = $cr->filemode;
  }

  $form->add_widget(text => {name => 'Mode',
			     label => 'configfile_filemode',
			     size => $perm,
			     maxlength => $perm,
			     default => $mode });

  return;
}

sub configfile_not_latest {
  my $pxt = shift;
  my %attr = @_;

  my $crid = $pxt->param('crid');
  return unless $crid;

  my $cr = RHN::ConfigRevision->lookup(-id => $crid);

  my $block = $attr{__block__} || '';

  return $block unless ($cr->latest eq 'Y');

  return;
}

sub system_specific_config_channel_details {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $local_ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, 'local_override');
  my $upload_ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, 'server_import');

  my %subst;

  $subst{local_override_config_channel_id} = $local_ccid;
  $subst{server_import_config_channel_id} = $upload_ccid;

  return PXT::Utils->perform_substitutions($attr{__block__}, \%subst);
}

sub actionconfigfile_details {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $acrid = $pxt->param('acrid');

  my $block = $attr{__block__};

  my $acr_data = RHN::ConfigRevision->lookup_action_data(-acrid => $acrid);

  throw "no action config revision data" unless $acr_data;

  my %subst;
  $subst{actionconfigfile_revision} = $acr_data->{REVISION};


  $subst{actionconfigfile_path} =
      PXT::HTML->link('/rhn/configuration/file/FileDetails.do?crid=' . $acr_data->{CONFIG_REVISION_ID},
		      PXT::Utils->escapeHTML($acr_data->{PATH}));

  $subst{actionconfigfile_config_channel_name} =
      PXT::HTML->link('/rhn/configuration/ChannelOverview.do?ccid=' . $acr_data->{CONFIG_CHANNEL_ID},
		      PXT::Utils->escapeHTML($acr_data->{CONFIG_CHANNEL_NAME}));

  $subst{actionconfigfile_result} = $acr_data->{RESULT} ? PXT::HTML->htmlify_text($acr_data->{RESULT}) : '<span class="no-details">(none)</span>';

  return PXT::Utils->perform_substitutions($block, \%subst);
}

# CALLBACKS #
sub ssm_config_channels_confirmation_cb {

  my $pxt = shift;

  my $action = $pxt->dirty_param("action");
  my $next = $pxt->dirty_param("next");

  if ($next eq 'Back') {
     $pxt->push_message(site_info => 'Config channel subscription canceled.');
  }
  elsif ($next eq 'Continue') {
     my $confirm_set = RHN::Set->lookup(-label => 'ssm_namespace_confirm_subs',
                                        -uid => $pxt->user->id);
    
     my $rank_set = RHN::Set->lookup(-label => 'ssm_namespace_subs_rankings',
                                     -uid => $pxt->user->id);
    
     my @ordered_config_channels;
     my %rank_hash = $rank_set->output_hash;
     foreach my $rank (sort keys %rank_hash) {
        push @ordered_config_channels, $rank_hash{$rank};
     }
    
     my @server_ids = $confirm_set->contents;

     ssm_subscribe_config_channels($action, $pxt->user->id, 0, \@server_ids, \@ordered_config_channels); 
     $pxt->push_message(site_info => 'Config channels updated.');
    
  }
  else {
     $pxt->push_message(site_info => 'No action taken.');
  }
  $pxt->redirect('/rhn/systems/ssm/config/Subscribe.do');
}


sub config_channel_edit_cb {
  my $pxt = shift;

  my $form = build_config_channel_edit_form($pxt);
  my $response = $form->prepare_response;
  undef $form;

  my $errors = Sniglets::Forms::load_params($pxt, $response);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $ns_name = $response->lookup_widget('ns_name')->value;
  my $ns_label = $response->lookup_widget('ns_label')->value;
  my $ns_description = $response->lookup_widget('ns_description')->value;

  my $ccid = $pxt->param('ccid');
  my $ns;

# XXX catch exceptions!
eval {
  if ($ccid) { # editing existing namespace
    $ns = RHN::ConfigChannel->lookup(-id => $ccid);
    if ($ns->type_label ne 'normal') {
      die "can't edit non-normal config channel, forshame";
    }

    $ns->name($ns_name);
    $ns->label($ns_label);
    $ns->description($ns_description);

    $ns->commit;

    $pxt->push_message(site_info => sprintf('Updated <strong>%s</strong>.', $ns->name));
  }
  else { # creating new namespace

    $ns = RHN::ConfigChannel->create_config_channel();

    $ns->org_id($pxt->user->org_id);
    $ns->name($ns_name);
    $ns->label($ns_label);
    $ns->description($ns_description);

    $ns->set_type('normal');
 
    $ns->commit;
    $ccid = $ns->id;

    $pxt->push_message(site_info => sprintf('Created <strong>%s</strong>.', $ns->name));
  }
};

  if ($@) {
    my $E = $@;

    if ($E =~ /RHN_CONFCHAN_OID_LABEL_NAME_UQ/) {
      $pxt->push_message(local_alert => 'A config channel with that label/name combination already exists.');
    }

    if ($E =~ /RHN_CONFCHAN_OID_LABEL_UQ/) {
      $pxt->push_message(local_alert => 'A config channel with that label already exists.');
      return;
    }

    die $E
  }
  my $url = $pxt->uri;
  $pxt->redirect($url . "?ccid=${ccid}");

  return;
}

sub get_ordered_config_chans {
  my $pxt = shift;

  my @rank_params = grep {m{rank-(\d+)}} $pxt->param();

  my %config_by_rank;

  foreach my $rank_param (@rank_params) {
    $rank_param =~ m/rank-(\d+)/;
    my $config_chan_id = $1;

    my $rank = $pxt->dirty_param($rank_param);

    # don't worry, we'll be testing permissions to the config channels below...
    push @{$config_by_rank{$rank}}, $config_chan_id if $rank ne '';
  }

  my @ret;

  foreach my $rank (sort keys %config_by_rank) {
    foreach my $chan_id (@{$config_by_rank{$rank}}) {
      push @ret, $chan_id;
    }
  }

  unless ($pxt->user->verify_config_channel_access(@ret)) {
    $pxt->redirect("/errors/permission.pxt");
  }

  return @ret;
}

sub maximum_config_file_size {
  my $pxt = shift;

  return PXT::Utils->humanify(PXT::Config->get('maximum_config_file_size'));
}


sub add_rhntools_channel {
    my $pxt = shift;
    my $tid = $pxt->param('tid');
    my $token = RHN::Token->lookup(-id => $tid);

    # find the one channel, if any, that is set as the base channel
    my ($current_base) = grep { not defined $_->{PARENT_CHANNEL} } $token->fancy_channels;
    
    my @channel_list = Sniglets::ActivationKeys::good_token_channels($pxt->user->org_id);
    my @rhn_tool_channels = ();
    # 
    # If no base channel add all RHN Tools channel
    # If base channel, then add child RHN Tools channel
    #
    foreach my $chan (@channel_list) {
        if (index($chan->{NAME}, "Red Hat Network Tools") ne -1 ) {
            if ( ($current_base eq undef) 
                    or ($current_base->{ID} eq $chan->{PARENT_CHANNEL}) ) { 
                push @rhn_tool_channels, $chan
            }
        }
    }
    #
    #Don't erase current token channels.  
    #Add our channels with no duplicates
    #
    my @current_channels = $token->fancy_channels;
    my @token_channels = @current_channels;
    foreach my $rhn_chan (@rhn_tool_channels) {
        my $found = 0;
        foreach my $cur_chan (@current_channels) {
            if ($cur_chan->{ID} eq $rhn_chan->{ID}) {
                $found = 1;
                last;
            }
        }
        if ($found eq 0) {
            push @token_channels, $rhn_chan;
        }
    }
    $token->set_channels( -channels => [ map { $_->{ID} } @token_channels ]);
}


sub act_key_config_channels_cb {
  my $pxt = shift;

  my $tid = $pxt->param('tid');
  die "no tid" unless $tid;

  my $token = RHN::Token->lookup(-id => $tid);
  die "no token" unless $token;

  # set the config channels
  my @ordered_config_channels = get_ordered_config_chans($pxt);
  $token->set_config_channels(@ordered_config_channels);

  $pxt->push_message(site_info => 'Config channels updated.');

  # set the 'deploy configuration' switch
  $token->deploy_configs($pxt->dirty_param('deploy_configs') ? 'Y' : 'N');

  # if we're deploying configs, make sure rhncfg is added to the package list of the token...
  if ($token->deploy_configs eq 'Y') {
    # need client, config-libs
    my %pkgs = map {$_->{NAME} => $_->{NAME_ID}} $token->fancy_packages();

    my $added_package;

    foreach my $cfg_pn (qw/rhncfg rhncfg-client rhncfg-actions/) {
      unless (exists $pkgs{$cfg_pn}) {
	$added_package = 1;
	$pkgs{$cfg_pn} = RHN::Package->lookup_package_name_id($cfg_pn);
      }
    }

    $token->set_packages(values %pkgs);
    #Add a child channel that contains the rhncfg* packages.
    add_rhntools_channel($pxt);


    $pxt->push_message(site_info => "Added needed packages to activation key for config deployment.")
      if $added_package;
  }
  $token->commit;

  $pxt->redirect("/network/account/activation_keys/namespaces.pxt?tid=$tid");

  return;
}


sub system_config_channels_cb {
  my $pxt = shift;

  # set the config channels
  my @ordered_config_channels = get_ordered_config_chans($pxt);


  my $sid = $pxt->param('sid');
  die 'no sid' unless $sid;

  RHN::Server->set_normal_config_channels(-server_ids => [$sid],
					  -config_channel_ids => [@ordered_config_channels],
					 );

  $pxt->push_message(site_info => 'Config channels updated.');

  $pxt->redirect("/rhn/systems/details/configuration/ConfigChannelList.do?sid=$sid");

  return;
}

sub ssm_subscribe_config_channels {
  my $action = shift;
  my $uid = shift;
  my $check_reorder = shift;
  my $server_ids = shift;
  my $ordered_config_channels = shift;
  my %needs_confirmation;

  # build seen list
  my %seen;
  foreach my $ccid (@{$ordered_config_channels}) {
    $seen{$ccid} = 1;
  }

  my $confirm_set = RHN::Set->lookup(-label => 'ssm_namespace_confirm_subs',
                                     -uid => $uid);
  $confirm_set->empty;
  
  my %new_lists;

  foreach my $sid (@{$server_ids}) {
    my $nds = new RHN::DataSource::ConfigChannel (-mode => 'namespaces_for_system');
    my $system_namespaces = $nds->execute_query(-sid => $sid);
    my @current_list;
    my @new_list;

    # add as high-ranked configs
    # adds to new list
    if ($action eq 'Add with Highest Rank') {
      push @new_list, @{$ordered_config_channels};
    }

    # add the existing config chans
    # adds to both new list (only if not in newly ranked
    # config channels) and current list
    foreach my $ns (@{$system_namespaces}) {
      if ($ns->{TYPE} eq 'normal') {
        push @new_list, $ns->{ID} unless $seen{$ns->{ID}};
        push @current_list,  $ns->{ID};
      }
    }

 
    # add as low-ranked configs
    # adds to new list
    if ($action eq 'Add with Lowest Rank') {
      push @new_list, @{$ordered_config_channels};
    }

    $new_lists{$sid} = \@new_list;

    if ($check_reorder) {
      for (my $i=0; $i <= $#current_list; $i++) {
        if ($current_list[$i] ne $new_list[$i]) {
           $confirm_set->add($sid);
           $needs_confirmation{$sid} = 1;
           last;
        }
      }
    }
  }

  $confirm_set->commit;

  my $ret = 0;

  if ($confirm_set->contents) {
    # save off the new rankings
    my $rank_set = RHN::Set->lookup(-label => 'ssm_namespace_subs_rankings',
                                     -uid => $uid);
    $rank_set->empty;
    my $counter = 0;
    foreach my $ccid (@{$ordered_config_channels}) {
      $rank_set->add([$counter++, $ccid]);
    }
    $rank_set->commit;
    $ret = -1
  }

  foreach my $sid (@{$server_ids}) {
    if (not exists $needs_confirmation{$sid}) {
      my @server_list = ($sid);
      my @arr = @{$new_lists{$sid}};
      RHN::Server->set_normal_config_channels(-server_ids => [@server_list],
			  -config_channel_ids => [@arr],
			 );
    }
    
  }

  return $ret;
}


sub config_channel_delete_cb {
  my $pxt = shift;

  my $ccid = $pxt->param('ccid');
  return unless $ccid;

  my $ns = RHN::ConfigChannel->lookup(-id => $ccid);

  my $name = $ns->name;
  $ns->delete_config_channel;
  undef $ns;

  $pxt->push_message(site_info => sprintf('Deleted <strong>%s</strong>.', $name));

  my $redir = $pxt->dirty_param('redirect_to');
  throw "Param 'redirect_to' needed but not provided."
    unless $redir;

  $pxt->redirect($redir);

  return;
}

sub upload_configfile_cb {
  my $pxt = shift;

  my %attr;
  my $path = $pxt->dirty_param('file_path');

  if (defined $path) {
    my $errmsg = RHN::ConfigFile->validate_path_name($path);

    if ($errmsg) {
      $pxt->push_message(local_alert => $errmsg);
      return;
    }

    $attr{mode} = 'upload-new';
  }

  my $form = build_upload_configfile_form($pxt, %attr);
  my $response = $form->prepare_response;
  undef $form;

  my $errors = Sniglets::Forms::load_params($pxt, $response);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $new_revision;
  my $cc;
  my $crid = $response->lookup_widget_value('crid');
  my $sid = $pxt->param('sid');

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions();

  my $old_cr;

  my $error;

  eval {
    if ($crid) {
      $old_cr = RHN::ConfigRevision->lookup(-id => $crid);
      $new_revision = $old_cr->copy_revision;
    }
    else {
      my $ccid = $pxt->param('ccid');
      if (not $ccid) {
	# if in sdc, lookup ccid. otherwise set to default.
	if ($sid) {
	  $ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, 'local_override');
	}
	else {
	  $ccid = $response->lookup_widget_value('ccid');
	}
      }

      $cc = RHN::ConfigChannel->lookup(-id => $ccid);
      my $cfid = $cc->vivify_file_existence($response->lookup_widget_value('file_path'));

      my $old_cr_id = RHN::ConfigFile->id_to_latest_revision_crid($cfid);
      if ($old_cr_id) {
	$old_cr = RHN::ConfigRevision->lookup(-id => $old_cr_id);
      }

      $new_revision = new RHN::ConfigRevision;
      $new_revision->config_file_id($cfid);
      $new_revision->path($response->lookup_widget_value('file_path'));
    }

    my $contents;
    if ($pxt->upload) {
      my $fh = $pxt->upload->fh;
      $contents = do { local $/; <$fh> };
    }
    else {
      $contents = '';

      # we didn't receive anything so let's bail.
      # it could be a zero length file or
      # permissions problem.

      $error = 'Your browser failed to upload the file contents properly; please check permissions on the file you are uploading or ensure the file is larger than 0 bytes.';

      $transaction->nested_rollback;

      return;
    }

    if (length $contents >= PXT::Config->get('maximum_config_file_size')) {
      $error = sprintf('Config files may be no larger than %s.',
		       PXT::Utils->humanify(PXT::Config->get('maximum_config_file_size')));

      $transaction->nested_rollback;

      return;
    }

    my ($owner, $group, $mode) =
      ($pxt->dirty_param('configfile_username'), $pxt->dirty_param('configfile_groupname'), $pxt->dirty_param('configfile_filemode'));

    # lousy, non-utf8 friendly hueristic for detecting binary data
    if ($contents =~ /[\200-\377]/ms) {
      $new_revision->is_binary(1);
    }

    # only ever upload a file
    my $type = 'file';

    if ($old_cr) {
      if (uc $type ne uc $old_cr->filetype) {
	if (uc $type eq 'FILE') {
	  throw "(illegal_directory_file_revision)";
	}
	elsif (uc $type eq 'DIRECTORY') {
	  throw "(illegal_file_directory_revision)";
	}
	else {
	  die "unknown config file type:  $type";
	}
      }
    }

    $new_revision->filetype($type);

    $new_revision->delim_start(PXT::Config->get('config_delim_start'));
    $new_revision->delim_end(PXT::Config->get('config_delim_end'));
    $new_revision->username($owner) if $owner;
    $new_revision->groupname($group) if $group;
    $new_revision->filemode($mode) if $mode;
    $new_revision->contents($contents);

    $new_revision->commit;
  };

  if ($error) {
    $pxt->push_message(local_alert => $error);

    return;
  }

  # check to see if we are over quota, if so let user know
  if ($@) {
    my $E = $@;

    $transaction->nested_rollback;

    die $E unless (ref $E and $E->isa('RHN::Exception'));

    if ($E->is_rhn_exception('not_enough_quota')) {
      $pxt->push_message(local_alert => 'Insufficient available quota for the specified action!');
    }
    elsif ($E->is_rhn_exception('illegal_file_directory_revision')) {
      $pxt->push_message(local_alert => sprintf("Previous revision of %s was a file; new revisions must be files, not directories.", $path));
    }
    elsif ($E->is_rhn_exception('illegal_directory_file_revision')) {
      $pxt->push_message(local_alert => sprintf("Previous revision of %s was a directory; new revisions must be directories, not files.", $path));
    }
    else {
      throw $E;
    }

    return;
  }

  $transaction->nested_commit;

  if ($new_revision->revision == 1) {
    $pxt->push_message(site_info => sprintf('Configuration file <strong>%s</strong> added to <strong>%s</strong>.',
					    $new_revision->path, $cc->name));
    if ($sid) {
        $pxt->redirect('/rhn/configuration/file/FileDetails.do', crid => $new_revision->id, sid => $sid);
    }
    else {
        $pxt->redirect("/rhn/configuration/file/FileDetails.do", crid => $new_revision->id);
    }
  }
  elsif ($response->lookup_widget('ccid')) {
    $pxt->push_message(site_info => sprintf('Configuration file <strong>%s</strong> updated to revision <strong>%d</strong>.',
					    $new_revision->path, $new_revision->revision));
    if ($sid) {
      $pxt->redirect('/rhn/configuration/file/FileDetails.do', crid => $new_revision->id, sid => $sid); 
    } 
    else {
      $pxt->redirect("/rhn/configuration/ChannelFiles.do", ccid => $cc->id);
    }
  }
  else {
    $pxt->push_message(site_info => sprintf('Configuration file <strong>%s</strong> updated to revision <strong>%d</strong>.',
					    $new_revision->path, $new_revision->revision));
    if ($sid) {
        $pxt->redirect('/rhn/configuration/file/FileDetails.do', crid => $new_revision->id, sid => $sid);
    }
    else {
        $pxt->redirect("/rhn/configuration/file/FileDetails.do", crid => $new_revision->id);
    }
  }

  return;
}

sub configfile_file_delete_cb {
  my $pxt = shift;

  my $cfid = $pxt->param('cfid');
  return unless $cfid;

  my $path = RHN::ConfigFile->file_id_to_path($cfid);
  my $cc = RHN::ConfigChannel->lookup(-cfid => $cfid);

  RHN::ConfigFile->delete_file_path($cfid);

  $pxt->push_message(site_info =>
		     sprintf('All revisions of <strong>%s</strong> have been deleted from <strong>%s</strong>.',
			     $path, $cc->name));

  my $redir = $pxt->dirty_param('redirect_to');
  throw "Param 'redirect_to' needed but not provided."
    unless $redir;

  $pxt->redirect($redir, ccid => $cc->id);

  return;
}

sub validate_contents {
  my %params = validate(@_, {contents => 1, start_delim => 1, end_delim => 1, pxt => 1});

  my $contents = $params{contents};
  my $start = $params{start_delim};
  $start =~ s{([^\s\w])}{"\\" . $1}egism;
  my $end = $params{end_delim};
  $end =~ s{([^\s\w])}{"\\" . $1}egism;

  while ($contents =~ m{${start}\s*(.*?)\s*${end}}gsm) {
    my $match = $1;

    if ($match =~ m{^([^=\(\)]+)(\((.*?)\))?(=(.*))?$}ism) {
      my $fn_name = $1;
      my $args_str = $3;
      my $def_value = $5;

      # need to at least have something like rhn.sytem.foo
      unless ($fn_name) {
	$params{pxt}->push_message(local_alert => "Unable to determine macro function name between delimiters:  " . PXT::Utils->escapeHTML($match));
	return;
      }

      unless ($fn_name =~ m/^rhn\.system\.[\w._]+$/) {
	$params{pxt}->push_message(local_alert => "Invalid macro function name in file contents:  " . PXT::Utils->escapeHTML($fn_name));
	return;
      }

      if ($args_str) {
	unless ($args_str =~ m/^\s*[A-Za-z\d\s_]+\s*$/) {
	  my $mesg = sprintf("Invalid arguments to function %s in file contents:  %s",
			     PXT::Utils->escapeHTML($fn_name),
			     PXT::Utils->escapeHTML($args_str));

	  $params{pxt}->push_message(local_alert => $mesg);
	  return;
	}
      }

      # can't really think of good check for def_value, it just gets blindly replaced...
    }
    else {
      $params{pxt}->push_message(local_alert => "Invalid macro token in file contents:  " . PXT::Utils->escapeHTML($match));
      return;
    }
  }

  return 1;
}

sub configfile_edit_cb {

  my $pxt = shift;

  my $crid = $pxt->param('crid');
  my $sid = $pxt->param('sid');

  my $type = $pxt->dirty_param('type') || '';

  if (not $type or (uc $type ne "DIRECTORY" and uc $type ne "FILE")) {
      $type = "file"; #default to file
  }

  my $new_contents = $pxt->dirty_param('configfile_contents') || '';
  $new_contents =~ s/\r//g;

  my $path = $pxt->dirty_param('configfile_path');

  unless ($crid) { # validate the path if this is a new file
    my $errmsg = RHN::ConfigFile->validate_path_name($path);

    if ($errmsg) {
      $pxt->push_message(local_alert => $errmsg);
      return;
    }
  }


  if (length $new_contents >= PXT::Config->get('maximum_config_file_size')) {
    $pxt->push_message(local_alert => sprintf('Config files may be no larger than %dK',
					      PXT::Config->get('maximum_config_file_size') / 1024));
    return;
  }

  my @formvars = qw/configfile_username configfile_groupname configfile_filemode delim_start delim_end/;
  my ($owner, $group, $mode, $delim_start, $delim_end) = map { $pxt->dirty_param($_) } @formvars; 

  $delim_start = PXT::Config->get('config_delim_start') unless $delim_start;
  $delim_end = PXT::Config->get('config_delim_end') unless $delim_end;

  $owner =~ s/^\s*(.*?)\s*$/$1/i;

  if (not $owner or (length($owner) > 32) or not (  $owner =~ m/^([a-zA-Z0-9_\-]+?)$/i)) {
    $pxt->push_message(local_alert => "User must be a valid Linux username of no more than 32 characters");
    return;
  }

  if (not $group or (length($group) > 32) or not (  $group =~ m/^([a-zA-Z0-9_\-]+?)$/i)) {
    $pxt->push_message(local_alert => "Group must be a valid Linux username of no more than 32 characters");
    return;
  }

  if (not $mode or not ($mode =~ m/^[0-7]?[0-7][0-7][0-7]$/)) {
    $pxt->push_message(local_alert => "Mode must be a valid Linux file mode, 000 to 777, or possibly 0000 to 7777 for directories");
    return;
  }

  if (not $delim_start or (length($delim_start) != 2) or ($delim_start =~ m/\%/)) {
      $pxt->push_message(local_alert => "Start delimiter must be 2 characters long, containing no percent sign characters");
      return;
  }

  if (not $delim_end or (length($delim_end) != 2) or ($delim_end =~ m/\%/)) {
      $pxt->push_message(local_alert => "End delimiter must be 2 characters long, containing no percent sign characters");
      return;
  }

  # this will pxt->message appropriately
  if ($new_contents) {
    return unless validate_contents(contents => $new_contents,
				    start_delim => $delim_start,
				    end_delim => $delim_end,
				    pxt => $pxt);
  }

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions;

  my $new_revision;
  my $old_cr;

  eval {
    if ($crid) {
      $old_cr = RHN::ConfigRevision->lookup(-id => $crid);
      $new_revision = $old_cr->copy_revision;
    }
    else {
      my $ccid = $pxt->param('ccid');

      if (not $ccid) {
	# gotta be in the sdc interface, if not, error
	throw "no sid" unless $sid;
	$ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, 'local_override');
      }

      my $cc = RHN::ConfigChannel->lookup(-id => $ccid);

      my $cfid = $cc->vivify_file_existence($path);

      my $old_cr_id = RHN::ConfigFile->id_to_latest_revision_crid($cfid);
      $old_cr = RHN::ConfigRevision->lookup(-id => $old_cr_id);

      $new_revision = new RHN::ConfigRevision;
      $new_revision->path($path);
      $new_revision->config_file_id($cfid);
    }

    $new_revision->username($owner);
    $new_revision->groupname($group);
    $new_revision->filemode($mode);


    if ($old_cr) {
      if (uc $type ne uc $old_cr->filetype) {
	if (uc $type eq 'FILE') {
	  throw "(illegal_directory_file_revision)";
	}
	elsif (uc $type eq 'DIRECTORY') {
	  throw "(illegal_file_directory_revision)";
	}
	else {
	  die "unknown config file type:  $type";
	}
      }
    }

    $new_revision->filetype($type);

    # only alter these fields when we would have presented widget that allowed you to change them
    if (not $new_revision->is_binary()) {
      $new_revision->delim_start($delim_start);
      $new_revision->delim_end($delim_end);
      $new_revision->contents($new_contents);
    }

    $new_revision->commit;
  };

  # check to see if we are over quota, if so let user know
  if ($@) {
    my $E = $@;

    $transaction->nested_rollback;

    die $E unless (ref $E and $E->isa('RHN::Exception'));

    if ($E->is_rhn_exception('not_enough_quota')) {
      $pxt->push_message(local_alert => 'Insufficient available quota for the specified action!');
    }
    elsif ($E->is_rhn_exception('illegal_file_directory_revision')) {
      $pxt->push_message(local_alert => sprintf("Previous revision of %s was a file; new revisions must be files, not directories.", $path));
    }
    elsif ($E->is_rhn_exception('illegal_directory_file_revision')) {
      $pxt->push_message(local_alert => sprintf("Previous revision of %s was a directory; new revisions must be directories, not files.", $path));
    }
    else {
      throw $E;
    }

    return;
  }

  $transaction->nested_commit;

  $pxt->push_message(site_info => sprintf('Revision <strong>%d</strong> of <strong>%s</strong> created.',
					  $new_revision->revision, $new_revision->path));

  if ($sid) {
      $pxt->redirect('/rhn/systems/details/configuration/ViewModifyLocalPaths.do', sid => $sid);
  }
  else {
      $pxt->redirect('/rhn/configuration/file/FileDetails.do?', crid => $new_revision->id);
  }
}

sub config_channels_select_type {
  my $pxt = shift;

  my $html;
  my $widget =
    new RHN::Form::Widget::Select(name => 'Show Channel Type',
				  label => 'config_channel_type',
				  size => 1,
				  value => $pxt->dirty_param('config_channel_type') || 'normal',
				  options => [ { value => 'normal', label => 'Global Config Channels' },
					       { value => 'local_override', label => 'System Config Channels' }],
				  auto_submit => 1
				 );
  $html .= $widget->render;
  $html .= RHN::Form::Widget::Submit->new(name => 'Show')->render;

  return $html;
}

sub config_channel_list_typed_include {
  my $pxt = shift;
  my %params = @_;

  my $type = $pxt->dirty_param($params{var}) || 'normal';
  my %types = (normal => 1, local_override => 1);
 if (exists $types{$type}) { 	 
     return '';
  }
  else {
    return 'Error.';
  }
}

sub config_managed_systems_cb {
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

  my $label = $action{label} || '';

  if ($label eq 'copy_configfile') {

    my $transaction = RHN::DB->connect;
    $transaction->nest_transactions;

    my $set_label = $pxt->dirty_param('set_label');
    my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

    my $cr = RHN::ConfigRevision->lookup(-id => $pxt->param('crid'));

    my $count = scalar $set->contents;

    foreach my $sid ($set->contents) {
      my $ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, 'local_override');
      my $cc = RHN::ConfigChannel->lookup(-id => $ccid);

      my $cfid = $cc->vivify_file_existence($cr->path);

      my $new_revision = $cr->copy_revision;
      $new_revision->revision(undef);
      $new_revision->config_file_id($cfid);
      eval {
        $new_revision->commit;
      };

      # check to see if we are over quota, if so let user know
      if ($@) {
        my $E = $@;
                                                                                                                        
        $transaction->nested_rollback;
                                                                                                                        
        die $E unless (ref $E and $E->isa('RHN::Exception'));
                                                                                                                        
        if ($E->is_rhn_exception('not_enough_quota')) {
          $pxt->push_message(local_alert => 'Insufficient available quota for the specified action!');
        }
        else {
          throw $E;
        }
                                                                                                                        
        return;
      }
    }

    $set->empty;
    $set->commit;

    $transaction->nested_commit;

    if ($count) {
      $pxt->push_message(site_info => sprintf('<strong>%s</strong> copied to <strong>%d</strong> system config channel%s.', $cr->path, $count, $count == 1 ? '' : 's'));
    }
  }

  return 1;
}

sub configfile_copy_files_cb {
  my $pxt = shift;
  my $mode = $pxt->dirty_param('copy_mode') || '';

  my $sid = $pxt->param('sid');

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions;

  my (@dest_chan, @redir_params);
  my $success_target_string;
  if ($mode eq 'system_local_override') {
    my $ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, 'local_override');
    push @dest_chan, RHN::ConfigChannel->lookup(-id => $ccid);
    @redir_params = (sid => $sid, ccid => RHN::ConfigChannel->vivify_server_config_channel($sid, 'server_import'));

    my $server = RHN::Server->lookup(-id => $sid);
    $success_target_string = sprintf "the local config channel for <strong>%s</strong>", $server->name;
  }
  elsif ($mode eq 'normal_channel') {
    my $set = RHN::Set->lookup(-label => $pxt->dirty_param('set_label'), -uid => $pxt->user->id);
    @redir_params = (sid => $sid);
    push @redir_params, ccid => $pxt->param('ccid')
      if $pxt->param('ccid');

    for my $ccid ($set->contents) {
      push @dest_chan, RHN::ConfigChannel->lookup(-id => $ccid);
    }

    $success_target_string = sprintf "%d global config channel%s", scalar @dest_chan, scalar @dest_chan > 1 ? 's' : '';
  }
  else {
    die "Unknown configfile_copy_files_cb mode $mode";
  }

  my $source_set_label = $pxt->dirty_param('source_set');
  my $set = RHN::Set->lookup(-label => $source_set_label, -uid => $pxt->user->id);

  my $file_count = 0;
  for my $crid ($set->contents) {
    my $cr = RHN::ConfigRevision->lookup(-id => $crid);

    # don't copy metadata-only stuff... can happen from sandbox
    next unless ($cr->contents() or (uc $cr->filetype eq "DIRECTORY"));

    $file_count++;

    for my $dest_chan (@dest_chan) {
      my $cfid = $dest_chan->vivify_file_existence($cr->path);

      my $new_revision = $cr->copy_revision;
      $new_revision->revision(undef);
      $new_revision->config_file_id($cfid);
      eval {
        $new_revision->commit;
      };

      # check to see if we are over quota, if so let user know
      if ($@) {
        my $E = $@;
                                                                                                                        
        $transaction->nested_rollback;
                                                                                                                        
        die $E unless (ref $E and $E->isa('RHN::Exception'));
                                                                                                                        
        if ($E->is_rhn_exception('not_enough_quota')) {
          $pxt->push_message(local_alert => 'Insufficient available quota for the specified action!');
        }
        else {
          throw $E;
        }
                                                                                                                        
        return;
      }
    }
  }

  if ($file_count != (scalar $set->contents())) {
    $pxt->push_message(site_info => "Some of the requested files were meta-data only, and could not be copied.");
  }

  $set->empty;
  $set->commit;

  $transaction->nested_commit;

  if ($file_count) {
    $pxt->push_message(site_info =>
		       sprintf('<strong>%s</strong> file%s copied to %s.',
			       $file_count, $file_count == 1 ? '' : 's', $success_target_string));
  }

  $pxt->redirect($pxt->dirty_param('success_redirect'), @redir_params);
}

sub configfile_sandbox_delete_files_cb {
  my $pxt = shift;

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions;

  my $source_set_label = $pxt->dirty_param('source_set');
  my $set = RHN::Set->lookup(-label => $source_set_label, -uid => $pxt->user->id);

  my ($server, $ccid, $success_target_string);
  if ($pxt->param('sid')) {
    $server = RHN::Server->lookup(-id => $pxt->param('sid'));
    $ccid = RHN::ConfigChannel->vivify_server_config_channel($server->id, $pxt->context('source-channel-type'));
    $success_target_string = sprintf "the %s for <strong>%s</strong>.", $pxt->context('deletion-type'), $server->name;
  }
  else {
    $ccid = $pxt->param('ccid');
  }

  my $cc = RHN::ConfigChannel->lookup(-id => $ccid);
  $success_target_string ||= sprintf "<strong>%s</strong>.", $cc->name;

  my $file_count = 0;
  for my $crid ($set->contents) {
    my $cr = RHN::ConfigRevision->lookup(-id => $crid);
    throw "no config revision for crid $crid" unless $cr;
    my $cfid = $cc->vivify_file_existence($cr->path);

    RHN::ConfigFile->delete_file_path($cfid);
    $file_count++;
  }
  $set->empty;
  $set->commit;

  $transaction->nested_commit;

  $pxt->push_message(site_info =>
		     sprintf('<strong>%s</strong> file%s been deleted from %s',
			     $file_count, $file_count == 1 ? ' has' : 's have', $success_target_string));

  $pxt->redirect($pxt->dirty_param('success_redirect'),
		 ($server ? (sid => $server->id) : ()),
		 ccid => $cc->id);
}

my %units = (mb => { divisor => 1024 * 1024,
		     format => '%.2f' },
	     kb => { divisor => 1024,
		     format => '%.1f' },
	     bytes => { divisor => 1,
			format => '%d' },
	     );

sub org_quota_details {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};
  die "No block for org quota details" unless $block;

  my %subst;

  my $quota_data = $pxt->user->org->quota_data;

  foreach my $field (qw/total bonus used limit available/) {
    foreach my $unit (keys %units) {
      $subst{"quota-${field}-${unit}"} =
	sprintf($units{$unit}->{format}, $quota_data->{uc($field)} / $units{$unit}->{divisor});
    }
  }

  return PXT::Utils->perform_substitutions($block, \%subst);
}

1;
