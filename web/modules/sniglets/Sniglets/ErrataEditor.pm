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

package Sniglets::ErrataEditor;

use RHN::Errata;
use RHN::ErrataEditor;
use RHN::Exception;
use RHN::ChannelEditor;
use RHN::Package;
use RHN::DB;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-if-errata-package-list-modified' => \&if_errata_package_list_modified);

  $pxt->register_tag('rhn-if-var' => \&if_var, -5);
  $pxt->register_tag('rhn-unless-var' => \&unless_var, -5);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:errata_editor:errata_edit_cb' => \&errata_edit_cb);
  $pxt->register_callback('rhn:errata_editor:errata_publish_cb' => \&errata_publish_cb);
  $pxt->register_callback('rhn:errata_editor:verify_errata_packages_in_channels' => \&verify_errata_packages_in_channels);
  $pxt->register_callback('rhn:errata_editor:select_channels_cb' => \&select_channels_cb);
  $pxt->register_callback('rhn:errata_editor:errata_delete_cb' => \&errata_delete_cb);
  $pxt->register_callback('rhn:errata_editor:delete_bug' => \&delete_bug);
  $pxt->register_callback('rhn:errata_editor:mail_notification_cb' => \&mail_notification_cb);
  $pxt->register_callback('rhn:update_errata_cache' => \&update_errata_cache);
  $pxt->register_callback('rhn:clone_specified_errata_cb' => \&clone_specified_errata_cb);
  $pxt->register_callback('rhn:delete_errata_cb' => \&delete_errata_cb);
}

my @errata_fields = qw/id org_id synopsis advisory_name advisory_rel advisory_type product buglist
                       topic description solution keywords refers_to notes/;

my $errata_data = {
		   id => {display => 0,
			  edit => 0 },
		   advisory_name => {display => 'Advisory',
				     edit => 'text',
				     size => 20,
				     maxlength => 27,
				     required => 1 },
		   advisory_rel => {display => 'Advisory Release',
				    edit => 'text',
				    size => 4,
				    maxlength => 4,
				    required => 1,
				    default => '1' },
		   advisory_type => {display => 'Advisory Type',
				     edit => 'select',
				     required => 1,
				     options => [ RHN::Errata->get_advisory_types ],
				     values => [ RHN::Errata->get_advisory_types ] },
		   product => {display => 'Product',
			       edit => 'text',
			       size => 30,
			       maxlength => 64,
			       required => 1 },
		   description => {display => 'Description',
				   edit => 'textarea',
				   rows => 6,
				   cols => 80,
				   maxlength => 4000,
				   required => 1 },
		   synopsis => {display => 'Synopsis',
				edit => 'text',
				size => 60,
				maxlength => 4000,
			        required => 1 },
		   topic => {display => 'Topic',
			     edit => 'textarea',
			     rows => 6,
			     cols => 80,
			     maxlength => 4000,
			     required => 1 },
		   solution => {display => 'Solution',
				edit => 'textarea',
				rows => 6,
				cols => 80,
				maxlength => 4000,
			        required => 1 },
		   refers_to => {display => 'References',
				 edit => 'textarea',
				 rows => 6,
				 cols => 40,
				 maxlength => 4000 },
		   notes => {display => 'Notes',
			     edit => 'textarea',
			     rows => 6,
			     cols => 40,
			     maxlength => 4000 },
		   keywords => {display => 'Keywords',
				edit => 'text',
				size => 40 },
		   buglist => {display => 'Bugs',
			       edit => 'special' },
		   org_id => {display => 0,
			      edit => 0 } };


sub errata_edit_cb {
  my $pxt = shift;

  my $eid = $pxt->param('eid') || 0;

  my $errata;

  if ($eid) {
    throw "user '" . $pxt->user->id . "' does not own errata '$eid'"
      unless $pxt->user->verify_errata_admin($eid);

    $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);
  }

  my $now = RHN::Date->now->short_date;

  unless ($eid) {
    $errata = RHN::ErrataTmp->create_errata;
    $errata->org_id($pxt->user->org_id);
    $errata->advisory_name($pxt->dirty_param('errata_advisory_name'));
    $errata->advisory_rel($pxt->dirty_param('errata_advisory_rel'));
    $errata->issue_date($now);
  }

  my @errors;
  my @add_bug; #data for a new bug - must be done after commit in the case of a new errata
  my @update_bugs; #data for old bugs
  my @keywords = (); #keywords

  foreach my $field (@errata_fields) {
    my $data = $errata_data->{$field};

    next unless $data->{edit};

    my $value = $pxt->dirty_param("errata_$field") || '';
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;

    if ($data->{required} && !($value)) {
      push @errors, "Required field '$field' is empty.";
      next;
    }

    if ($data->{maxlength} and (length($value) > $data->{maxlength})) {
      push @errors, sprintf(q(The %s was %d charactars long.  Maximum length is %d characters.),
			    $data->{display}, length($value), $data->{maxlength});
      next;
    }

    if ($field eq 'keywords') {
      @keywords = split /\s*,\s*/, $value;
    }
    elsif ($field eq 'buglist') {

      foreach my $bug (RHN::Utils->parameterize([ $errata->bugs_fixed ], 'id', 'summary')) { #see if old bugs changed
	my $new_id = $pxt->dirty_param('errata_buglist_' . $bug->{id} . '_id');
	my $new_summary = $pxt->dirty_param('errata_buglist_' . $bug->{id} . '_summary') || '';

	if ($new_id =~ /\D/) {
	  push @errors, "Bug ID's must be numeric";
	  next;
	}

 	unless (($bug->{id} == $new_id) && (($bug->{summary} || '') eq $new_summary)) {
	  push @update_bugs, [ $bug->{id}, $new_id, $new_summary ];
	}
      }

      if (my $bug_id = $pxt->dirty_param('errata_buglist__id') || '') { #check for a new bug

	if ($bug_id =~ /^\d+$/) {
	  my $bug_summary = $pxt->dirty_param('errata_buglist__summary') || '';
	  @add_bug = ($bug_id, $bug_summary);
	}
	else {
	  push @errors, "Bug ID's must be numeric";
	}
      }

    }
    elsif ($field eq 'advisory_name') {
      unless ($pxt->user->is('rhn_superuser')) {
	if ($value =~ /^(RH)/i) {
	  push @errors, "An errata advisory cannot begin with '<strong>$1</strong>'";
	}
      }
      $errata->advisory_name($value);
    }
    else {
      $errata->$field($value);
    }
  }

  unless (@errors) {
    $errata->advisory($errata->advisory_name . '-' . $errata->advisory_rel);
    $errata->update_date($now);
    eval {
      $errata->commit;

      if (@add_bug) {
	$errata->add_bug(@add_bug);
      }

      foreach my $bug (@update_bugs) {
	$errata->update_bug( @{$bug} );
      }

      $errata->set_keywords(@keywords);
    };
    if ($@) {
      if (ref $@ and catchable($@)) {
	my $E = $@;

	if ($E->constraint_value eq 'RHN_ERRATA_ADVISORY_UQ') {
	  $pxt->push_message(local_alert => 'An Errata with this advisory label already exists');
	  return;
	}
	elsif ($E->constraint_value eq 'RHN_ERRATA_ADVISORY_NAME_UQ') {
	  $pxt->push_message(local_alert => 'An Errata with this advisory name already exists');
	  return;
	}
	elsif ($E->constraint_value eq 'RHN_ERRATATMP_ADVISORY_UQ') {
	  $pxt->push_message(local_alert => 'An Errata with this advisory label already exists');
	  return;
	}
	elsif ($E->constraint_value eq 'RHN_ERRATATMP_ADVISORY_NAME_UQ') {
	  $pxt->push_message(local_alert => 'An Errata with this advisory name already exists');
	  return;
	}
	else {
	  throw $E;
	}
      }
      else {
	die $@;
      }
    }

  }

  foreach (@errors) {
    $pxt->push_message(local_alert => $_);
  }

  unless (@errors) {
    $pxt->redirect($pxt->uri . '?eid=' . $errata->id);
  }

  return;
}

sub errata_publish_cb {
  my $pxt = shift;

  my $eid = $pxt->param('eid') || 0;
  throw 'No eid!' unless $eid;

  throw "user '" . $pxt->user->id . "' does not own errata '$eid'"
    unless $pxt->user->verify_errata_admin($eid);

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  my @channels = ();

  my $channel_set = RHN::Set->lookup(-label => 'target_channels_list', -uid => $pxt->user->id);
  push @channels, $channel_set->contents;

  $channel_set->empty;
  $channel_set->commit;

  if (not $pxt->user->verify_channel_admin(@channels)) {
    warn sprintf("User '%d' attempted to assign unpublished errata '%d' to one or more channels (%s) without permission.",
		 $pxt->user->id, $eid, join(', ', @channels));
    $pxt->redirect('/errors/permission.pxt');
  }

  my $fail_redir = $pxt->dirty_param('fail_redirect');
  throw "Param 'fail_redir' needed but not provided." unless $fail_redir;

  my $id;
  my $dbh = RHN::DB->connect;
  eval {
    $id = RHN::ErrataEditor->publish_errata($errata, $dbh);
    RHN::ErrataEditor->assign_errata_to_channels($id, \@channels);
  };
  if ($@) {
    $dbh->rollback;
    if (ref $@ and catchable($@)) {
      my $E = $@;

      if ($E->constraint_value eq 'RHN_ERRATA_ADVISORY_UQ') {
	$pxt->push_message(local_alert => 'A published errata with this advisory already exists.');
      }
      elsif ($E->constraint_value eq 'RHN_ERRATA_ADVISORY_NAME_UQ') {
	$pxt->push_message(local_alert => 'A published errata with this advisory name already exists');
      }
      else {
	throw $E;
      }
      $pxt->redirect($fail_redir . "?eid=${eid}"); # still here?  redirect.
    }
    else {
      die $@;
    }
  }

  $dbh->commit;

  foreach my $cid (@channels) {
    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 0);
  }

  my $package_list_edited = $pxt->session->get('errata_package_list_edited') || { };
  $package_list_edited->{$eid} = 0;
  $pxt->session->set(errata_package_list_edited => $package_list_edited);

  $pxt->push_message(site_info => sprintf ('Errata <strong>%s</strong> has been successfully published to <strong>%d</strong> channel%s.', $errata->advisory_name, scalar(@channels), (scalar(@channels) == 1 ? '' : 's')));

  my $redir = $pxt->dirty_param('success_redirect');
  throw "param 'success_redirect' needed but not provided" unless $redir;

  $pxt->redirect($redir);

  return;
}

# The flow: If the errata is being published to a channel for which
# the user is an admin, and the errata has packages which are newer
# than packages in the channel, then ask the user if he wants to push
# the newer versions into that channel.  Else, just publish the errata.
sub verify_errata_packages_in_channels {
  my $pxt = shift;

  my $eid = $pxt->param('eid') || 0;
  throw 'No eid!' unless $eid;

  throw "user '" . $pxt->user->id . "' does not own errata '$eid'"
    unless $pxt->user->verify_errata_admin($eid);

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  my @channels = ();

  foreach my $param ($pxt->param()) {
    next unless $param =~ /^channel_/;
    push @channels, $pxt->dirty_param($param);
  }

  my $target_set = RHN::Set->lookup(-label => 'target_channels_list', -uid => $pxt->user->id);
  $target_set->empty;
  $target_set->add(@channels);
  $target_set->commit;

  my $action_type;
  if ($pxt->dirty_param('publish_errata')) {
    $action_type = 'publish_errata';
  }
  elsif ($pxt->dirty_param('update_channels')) {
    $action_type = 'update_channels';
  }
  else {
    throw "The action type parameter is missing.  It should have been preserved."
  }

  my @updates_needed;

  foreach my $cid (@channels) {
    die "User '" . $pxt->user->id . "' does not have permission to publish errata '$eid' to channel '$cid'"
      unless $pxt->user->verify_channel_admin($cid);

    push @updates_needed, $cid
      unless RHN::Channel->has_latest_packages($cid, $errata->packages);
  }

  if (@updates_needed) {
    my $cid = pop @updates_needed;

    my $package_set = RHN::Set->lookup(-label => 'update_package_list', -uid => $pxt->user->id);
    $package_set->empty;

    my $eid_cloned_from = $errata->cloned_from;
    my $cid_cloned_from = RHN::Channel->channel_cloned_from($cid);

    if ($eid_cloned_from and $cid_cloned_from
	and RHN::Channel->is_errata_for_channel($eid_cloned_from, $cid_cloned_from)) {
      my $ds = new RHN::DataSource::Package(-mode => 'channel_errata_full_intersection');
      my $data = $ds->execute_full(-eid => $eid_cloned_from, -cid => $cid_cloned_from);

      if (@{$data}) {
	$package_set->add(map { $_->{ID} } @{$data});
	$pxt->push_message(local_info => 'This errata is cloned from an official Red Hat errata, and the channel you are publishing this errata to is the clone of a Red Hat channel.  Packages which are associated with the original channel and errata are preselected below.');
      }
    }
    $package_set->commit;

    my $channel_set = RHN::Set->lookup(-label => 'update_channels_list', -uid => $pxt->user->id);
    $channel_set->empty;
    $channel_set->add(@updates_needed);
    $channel_set->commit;

    my $redir = $pxt->dirty_param('update_channel_redirect');

    throw "Param 'update_channel_redirect' needed but not provided"
      unless $redir;

    $pxt->redirect($redir . "?eid=${eid}&cid=${cid}&${action_type}=1");
  }
  elsif ($action_type eq 'publish_errata') {
    errata_publish_cb($pxt);
  }
  else {
    select_channels_cb($pxt);
  }

  return;
}

sub select_channels_cb {
  my $pxt = shift;

  my $eid = $pxt->param('eid') || 0;
  throw 'No eid!' unless $eid;

  throw "user '" . $pxt->user->id . "' does not own errata '$eid'"
    unless $pxt->user->verify_errata_admin($eid);

  my $errata = RHN::Errata->lookup(-id => $eid);

  my @channels = ();

  my $channel_set = RHN::Set->lookup(-label => 'target_channels_list', -uid => $pxt->user->id);
  push @channels, $channel_set->contents;

  $channel_set->empty;
  $channel_set->commit;

  if (not $pxt->user->verify_channel_admin(@channels)) {
        warn sprintf("User '%d' attempted to assign errata '%d' to one or more channels (%s) without permission.", 
		 $pxt->user->id, $eid, join(', ', @channels));
    $pxt->redirect('/errors/permission.pxt');
  }

  my @old_channels = RHN::Errata->channels($eid); #need to keep these!

  RHN::ErrataEditor->assign_errata_to_channels($eid, \@channels);

  my %all_channels = map { ($_, 1) } (@old_channels, @channels);
  my @all_affected_channels = keys %all_channels;

  foreach my $cid (@all_affected_channels) {
    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 3600);
  }

  my $package_list_edited = $pxt->session->get('errata_package_list_edited') || { };
  $package_list_edited->{$eid} = time;
  $pxt->session->set(errata_package_list_edited => $package_list_edited);

  $pxt->push_message(site_info => sprintf ('Errata <strong>%s</strong> has been successfully assigned to <strong>%d</strong> channel%s.', $errata->advisory_name, scalar(@channels), (scalar(@channels) == 1 ? '' : 's')));

  my $redir = $pxt->dirty_param('success_redirect');
  throw "param 'success_redirect' needed but not provided" unless $redir;

  $pxt->redirect($redir . "?eid=$eid");

  return;
}

sub update_errata_cache {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  die "ErrataEditor::update_errata_cache called without eid"
    unless $eid;

  foreach my $cid (RHN::Errata->channels($eid)) {
    unless ($pxt->user->verify_channel_admin($cid)) {
      $pxt->redirect("/errors/permission.pxt");
    }

    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid);
  }

  my $package_list_edited = $pxt->session->get('errata_package_list_edited');
  $package_list_edited->{$eid} = 0;
  $pxt->session->set(errata_package_list_edited => $package_list_edited);

  $pxt->redirect($pxt->uri . "?eid=$eid");
}

sub if_var {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  return unless $pxt->passthrough_param($attr{formvar});

  return $block;

}

sub unless_var {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  return if $pxt->passthrough_param($attr{formvar});

  return $block;

}

sub load_package_set {
  my $uid = shift;
  my $eid = shift;

  my $set = RHN::Set->lookup(-label => 'errata_package_list', -uid => $uid);
  $set->empty;
  $set->commit;

  my @packages_in_errata =
    RHN::ErrataEditor->packages_in_errata($eid);

  $set->add(@packages_in_errata);

  $set->commit;

  return 1;
}

sub if_errata_package_list_modified {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $eid = $pxt->param('eid');
  return unless $eid;

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  return if $errata->isa('RHN::DB::ErrataTmp'); #don't cache temp errata!

  my $package_list_edited = $pxt->session->get('errata_package_list_edited');
  my $edited = $package_list_edited->{$eid} || 0;

  if ((time - $edited) < 3600) {
    return $block;
  }

  return '';
}

sub delete_bug {
  my $pxt = shift;

  my $eid = $pxt->param('eid') || 0;
  my $bug_id = $pxt->dirty_param('bug_id') || 0;

  return unless ($eid && $bug_id);

  throw "user '" . $pxt->user->id . "' does not own errata '$eid'"
    unless $pxt->user->verify_errata_admin($eid);

  my $errata;

  $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  $errata->delete_bug($bug_id);

  $pxt->redirect($pxt->uri . sprintf('?eid=%d', $eid));
  return;
}

sub mail_notification_cb {
  my $pxt = shift;

  my $eid = $pxt->param('eid');

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);
  throw "Errata '$eid' not published." if ($errata->isa('RHN::DB::ErrataTmp'));

  RHN::ErrataEditor->update_notification_queue($eid, 0);

  $pxt->push_message(site_info => sprintf('An errata mail update has been scheduled for <strong>%s</strong>.', $errata->synopsis));

  return;
}

sub clone_specified_errata_cb {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  throw "No eid" unless $eid;

  my $set_label = 'clone_errata_list';
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  $set->empty;
  $set->add($eid);
  $set->commit;

  my $redir = $pxt->dirty_param('redir');
  throw "param redir needed" unless $redir;

  $pxt->redirect($redir . "?set_label=${set_label}");

  return;
}

sub delete_errata_cb {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);
  my $advisory = $errata->advisory;

  RHN::ErrataEditor->delete_errata($eid);

  $pxt->push_message(site_info => "Deleted errata <strong>$advisory</strong>.");
  $pxt->redirect('/network/errata/manage/list/published.pxt');
}

1;
