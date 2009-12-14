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

package Sniglets::ChannelEditor;

use RHN::ChannelEditor;
use RHN::Channel;
use RHN::ErrataEditor;
use RHN::Exception;
use PXT::Utils;
use Sniglets::Channel;

use RHN::DataSource::Package;
use RHN::DataSource::Channel;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-channel-edit-form' => \&channel_edit_form);
  $pxt->register_tag('rhn-channel-select-options' => \&channel_select_options);
  $pxt->register_tag('rhn-if-package-list-modified' => \&if_package_list_modified);
  $pxt->register_tag('rhn-if-packages-deleted-from-channels' => \&if_packages_deleted_from_channels);
  $pxt->register_tag('rhn-show-all-errata-checkbox' => \&show_all_errata_checkbox);
  $pxt->register_tag('rhn-if-var' => \&if_var, -5);
  $pxt->register_tag('rhn-clone-channel-form' => \&clone_channel_form);

  $pxt->register_tag('rhn-channel-sync-prompt' => \&channel_sync_prompt);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:channel_view_cb' => \&channel_view_cb);
  $pxt->register_callback('rhn:channel_edit_cb' => \&channel_edit_cb);
  $pxt->register_callback('rhn:channel_delete_cb' => \&channel_delete_cb);
  $pxt->register_callback('rhn:update_channel_cache' => \&update_channel_cache);
  $pxt->register_callback('rhn:clone_channel_cb' => \&clone_channel_cb);
}

sub channel_view_cb {
  my $pxt = shift;

  my $cid = $pxt->param('cid') || 0;
  my $eid = $pxt->param('eid') || 0;
  my $view_channel = $pxt->param('view_channel') || 0;

  die "Missing formvar 'view_channel'."
    unless $view_channel;

  my $url = $pxt->uri . "?view_channel=${view_channel}";

  if ($cid) {
    $url .= "&cid=${cid}";
  }
  elsif ($eid) {
    $url .= "&eid=${eid}";
  }
  elsif ($pxt->dirty_param('clone_errata')) {
    my $show_all = $pxt->dirty_param('show_all_errata') || 0;

    if ($show_all) {
      $url .= "&show_all_errata=1";
    }
  }
  else { # Package manager - Need to clear the deletable package list
    my $set = RHN::Set->lookup(-label => 'deletable_package_list', -uid => $pxt->user->id);
    $set->empty;
    $set->commit;
  }

  $pxt->redirect($url);
}

sub channel_delete_cb {
  my $pxt = shift;

  my $cid = $pxt->param('cid') || 0;

  die "no channel id"
    unless $cid;

  unless ($pxt->user->verify_channel_admin($cid) and $pxt->user->is('channel_admin')) {
    $pxt->redirect("/errors/permission.pxt");
  }

  if (RHN::Channel->children($cid)) {
    $pxt->push_message(local_alert => 'A channel cannot be deleted until all child channels are deleted.');
    return;
  }
  if (RHN::Channel->distros($cid)) {
    $pxt->push_message(local_alert => 'A channel cannot be deleted until all associated kickstart distributions are deleted or dissociated.');
    return;
  }


  my @servers = RHN::Channel->servers($cid);

  my $force_unsub = $pxt->dirty_param('force_unsubscribe') || 0;

  if (@servers) {
    my $servers_link = $pxt->dirty_param('servers_link');
    throw "param 'servers_link' needed but not provided" unless $servers_link;
    unless ($force_unsub == 1) {
      $pxt->push_message(local_alert => "There are currently systems subscribed to this channel. Please confirm system channel removal by selecting the unsubscribe checkbox.");
      return;
    }
    foreach my $sid(@servers) {
      my $server = RHN::Server->lookup(-id => $sid);
      $server->unsubscribe_from_channel($cid);
    }
  }

  my $channel = RHN::Channel->lookup(-id => $cid);
  my $name = $channel->name;

  my $ds = new RHN::DataSource::Package(-mode => 'packages_only_in_channel');
  my $orphaned_packages = $ds->execute_query(-cid => $cid, -org_id => $pxt->user->org_id);

  RHN::ChannelEditor->delete_channel($cid);

  foreach my $sid (@servers) {
    RHN::Server->schedule_errata_cache_update($pxt->user->org_id, $sid, 0);
  }

  $pxt->push_message(site_info => "Channel <strong>$name</strong> has been deleted.");

  my $redirect_to;

  if (@{$orphaned_packages}) {
    $redirect_to = $pxt->dirty_param('orphaned_packages_redirect');
    throw "param 'orphaned_packages_redirect' needed but not provided" unless $redirect_to;

    $redirect_to .= '?view_channel=no_channels';
    my $set = RHN::Set->lookup(-label => 'deletable_package_list', -uid => $pxt->user->id);
    $set->empty;
    $set->add(map { $_->{ID} } @{$orphaned_packages});
    $set->commit;

    $pxt->push_message(site_info => "The packages selected below were unique to <strong>$name</strong>, and have now been orphaned.  The packages which are not selected were already orphaned.");
  }
  else {
    $redirect_to = $pxt->dirty_param('redirect_to');
    throw "param 'redirect_to' needed but not provided" unless $redirect_to;
  }
  $pxt->redirect($redirect_to);
}

sub channel_edit_cb {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  $cid = '' if $cid =~ /\D/;

  my $new_channel = $cid ? 0 : 1;

  my $parent_id = $pxt->dirty_param('channel_parent');
  die "illegal parent id" unless $pxt->user->verify_channel_access($parent_id);

  my $channel;

  if ($pxt->dirty_param('delete')) {
    my $delete_redirect = $pxt->dirty_param('delete_redirect');
    throw "param 'delete_redirect' needed but not provided" unless $delete_redirect;
    $pxt->redirect("$delete_redirect?cid=$cid");
  }

  if ($cid) {

    unless ($pxt->user->verify_channel_admin($cid)) {
      $pxt->redirect("/errors/permission.pxt");
    }

    $channel = RHN::Channel->lookup(-id => $cid);
  } else {
    die "Must be a channel admin to create a channel"
      unless $pxt->user->is('channel_admin');
  }

  my $channel_label = $pxt->dirty_param('new_channel_label') || (ref $channel ? $channel->label : '');
  my $channel_name = $pxt->dirty_param('channel_name') || '';
  my $channel_summary = $pxt->dirty_param('channel_summary') || '';

  my $clone_from = $pxt->dirty_param('clone_from') || '';
  die "attempt to clone illegal channel" unless $pxt->user->verify_channel_access($clone_from);

  my $from_channel;

  if ($clone_from) {
    $from_channel = RHN::Channel->lookup(-id => $clone_from);
  }

  my $clone_type = $pxt->dirty_param('clone_type') || '';

  my $errors = 0;

  unless ($pxt->user->is('rhn_superuser')) {
    if ($channel_name =~ /^(rhn|red\s*hat)/i) {
      $pxt->push_message(local_alert => "Channel name cannot begin with '<strong>$1</strong>'");
      $errors++;
    }

    if ($channel_label =~ /^(rhn|red\s*hat)/i) {
      $pxt->push_message(local_alert => "Channel label cannot begin with '<strong>$1</strong>'");
      $errors++;
    }
  }
  # bugzilla: 161517 - allow _ and / in channel labels
  # bugzilla: 459827 - disallow names longer than 64 characters
  unless ($channel_name =~ /^[a-z][\w\d\s\-\.\'\(\)\/\_]*$/i and length($channel_name) >= 6 and length($channel_name) <= 256) {
    $pxt->push_message(local_alert => "Invalid channel name '" .
    PXT::Utils->escapeHTML($channel_name) . "' - must be at least 6 characters long and no longer than 256 characters, begin with a letter, and contain only letters, digits, spaces, '-', ' / ', '_' and '.'");
    $errors++;
  }

  # bugzilla: 161517 - allow _ in channel labels
  unless ($channel_label =~ /^[a-z\d][a-z\d\-\.\_]*$/ and length($channel_label) >= 6) {
    $pxt->push_message(local_alert => "Invalid channel label '$channel_label' - must be at least 6 characters long, begin with a letter or digit, and contain only lowercase letters, digits, '-', '_', and '.'");
    $errors++;
  }

  my $gpg_fp = $pxt->dirty_param('channel_gpg_key_fp');
  if ($gpg_fp ne '' and not $gpg_fp =~ m(^(\s*[0-9A-F]{4}\s*){10}$)) {
    $pxt->push_message(local_alert => "Invalid GPG fingerprint, must be of form 'CA20 8686 2BD6 9DFC 65F6 ECC4 2191 80CD DB42 A60E'");
    $errors++;
  }

  my $gpg_id = $pxt->dirty_param('channel_gpg_key_id');
  if ($gpg_id ne '' and not $gpg_id =~ m(^[0-9A-F]{8}$)) {
    $pxt->push_message(local_alert => "Invalid GPG key ID, must be of form 'DB42A60E'");
    $errors++;
  }

  my $gpg_url = $pxt->dirty_param('channel_gpg_key_url');
  if ($gpg_url ne '' and not $gpg_url =~ m(^(https?|file)://.*?$)) {
    $pxt->push_message(local_alert => "GPG Key URL invalid - please enter a valid URL");
    $errors++;
  }

  unless ($channel_summary) {
    $pxt->push_message(local_alert => "Invalid channel summary '$channel_summary' - cannot be empty.");
    $errors++;
  }

  if ($clone_from) {
    throw "Attempt to clone unauthorized channel '$clone_from' by user '". $pxt->user->id . "'."
      unless $pxt->user->verify_channel_access($clone_from);

    if ($parent_id and not $from_channel->parent_channel) {
      $pxt->push_message(local_alert => "You cannot clone a base channel as the child of another channel.");
      $errors++;
    }
    elsif (not $parent_id and $from_channel->parent_channel) {
      $pxt->push_message(local_alert => "The clone of a child channel must have a parent channel.");
      $errors++;
    }
  }
  
  #bugzilla  175845 - restrict child channels arches
  if($new_channel and $parent_id){
	  my $parent_channel = RHN::Channel->lookup(-id => $parent_id);
	  my $archmap = RHN::ChannelEditor->channel_base_arch_map;
	  	
	  my $parent_arch = $archmap->{$parent_channel->channel_arch_id}->{NAME};
	  my $child_arch = $archmap->{$pxt->dirty_param("channel_arch")}->{NAME};
	  
	  if(verify_arch_compat($parent_arch, $child_arch) == 0){
	  	$pxt->push_message(local_alert => "The child channel arch $child_arch is not compatible with a parent channel arch of $parent_arch");
	  	$errors++;
	  }
   }

  return if $errors;

  my $transaction = RHN::DB->connect; #do channel creation in one transaction...
  $transaction->nest_transactions;


  # cannonize how we store gpg fingerprints in the db
  if ($gpg_fp ne '') {
    $gpg_fp =~ s{\s}{}g;
    my @segments;
    while ($gpg_fp =~ m/([0-9A-Z]{4})/g) {
      push @segments, $1;
    }
    $gpg_fp = sprintf("%s %s %s %s %s  %s %s %s %s %s", @segments);
  }

  eval {
    if ($cid) {

      # fingerprint is "special"
      $channel->gpg_key_fp($gpg_fp);

      $channel->$_($pxt->dirty_param("channel_$_")) foreach qw/name summary description gpg_key_url gpg_key_id/;

      Sniglets::Channel::update_global_subscription_pref($pxt);
      $channel->commit;
    } else {
      $channel = RHN::Channel->create_channel;

      # fingerprint is "special"
      $channel->gpg_key_fp($gpg_fp);

      $channel->$_($pxt->dirty_param("channel_$_")) foreach qw/name summary description gpg_key_url gpg_key_id/;
      $channel->label($pxt->dirty_param('new_channel_label'));
      my $caid = $pxt->dirty_param("channel_arch");
      $channel->channel_arch_id($caid);
      $channel->org_id($pxt->user->org_id);
      $channel->parent_channel($parent_id or undef);

      if($from_channel){
          $channel->product_name_id($from_channel->product_name_id);
      }

      $channel->basedir('/dev/null');

      $channel->commit();

      if ($clone_from) {
	if ($clone_type eq 'current') {
	  RHN::ChannelEditor->clone_channel_packages($clone_from, $channel->id);
	  my ($data, $special_handling) = RHN::ChannelEditor->clone_all_errata(-from_cid => $clone_from, -to_cid => $channel->id, -org_id => $pxt->user->org_id);
	}
	elsif ($clone_type eq 'original') {
	  RHN::ChannelEditor->clone_original_channel_packages($clone_from, $channel->id);
	}
	elsif ($clone_type eq 'select_errata') {
	  RHN::ChannelEditor->clone_original_channel_packages($clone_from, $channel->id);
	}

	$channel->set_cloned_from($clone_from);
      }

      #adopt the channel into the user's org's channelfamily
      my @cf_ids = RHN::Org->get_channel_family($pxt->user->org_id);

      $channel->adopt_into_family(\@cf_ids);

      $cid = $channel->id;
      RHN::Channel->refresh_newest_package_cache($cid, 'web.channel_created');
      #load packes from cloned channel, if any
    }

  };
  if ($@) {
    $transaction->nested_rollback;
    if (ref $@ and catchable($@)) {
      my $E = $@;

      if ($E->constraint_value eq '"RHNCHANNEL"."LABEL"') {
	$pxt->push_message(local_alert => 'Channel label must be non-empty');
	return;
      }
      elsif ($E->constraint_value eq 'RHN_CHANNEL_LABEL_UQ') {
	$pxt->push_message(local_alert => 'That channel label already exists in our database.  Please choose another.');
	return;
      }
      elsif ($E->constraint_value eq '"RHNCHANNEL"."SUMMARY"') {
	$pxt->push_message(local_alert => 'Channel summary must not be empty');
	return;
      }
      elsif ($E->constraint_value eq 'RHN_CHANNEL_NAME_UQ') {
	$pxt->push_message(local_alert => 'That channel name already exists in our database.  Please choose another.');
	return;
      }
      else {
	throw $E;
      }
    } else {
      die $@;
    }
  }

  $transaction->nested_commit;

  # use the new java page
  my $url = '/rhn/channels/manage/Edit.do';

  #If we just cloned a channel, 'flow' the user into the errata cloning page for that channel....
  if ($clone_type eq 'select_errata') {
    $pxt->push_message(site_info => sprintf('<strong>%s</strong> has been cloned as <strong>%s</strong>.  You may now wish to clone the errata associated with <strong>%s</strong>', $from_channel->name, $channel->name, $from_channel->name));
    $url = '/network/software/channels/manage/errata/clone.pxt';
  }
  elsif ($clone_type) {
    $pxt->push_message(site_info => sprintf('<strong>%s</strong> has been cloned as <strong>%s</strong>.', $from_channel->name, $channel->name));
  }
  elsif ($new_channel) {
    $pxt->push_message(site_info => sprintf('Channel <strong>%s</strong> created.', $channel->name));
  }
  else {
    $pxt->push_message(site_info => sprintf('Channel <strong>%s</strong> updated.', $channel->name));
  }

  $url .= "?cid=$cid";
  $pxt->redirect($url);
}

sub clone_channel_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_clone_channel_details_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

sub build_clone_channel_details_form {
  my $pxt = shift;
  my %attr = @_;

  my @channel_list = RHN::ChannelEditor->channels_visible_to_org_with_parent($pxt->user->org_id);

  my $ds = new RHN::DataSource::Channel(-mode => 'user_subscribe_perms');
  my $subscribable = $ds->execute_query(-u_id => $pxt->user->id, -org_id => $pxt->user->org_id);
  my %perm_map = map { ($_->{ID}, 1) }
    grep { $_->{HAS_PERM} } @{$subscribable};
  @channel_list = grep { $perm_map{$_->{ID}} } @channel_list;

  my $clone_id = $pxt->dirty_param('clone_from') || 0;
  die "illegal clone id" unless $pxt->user->verify_channel_access($clone_id);

  my $form = new RHN::Form::ParsedForm(name => 'Clone Channel Details',
				       label => 'clone_channel_details',
				       action => $attr{action},
				      );

  my $channel_selectbox = new RHN::Form::Widget::Select(name => 'Clone From',
							label => 'clone_from');

  my @my_channels = grep {$_->{CHANNEL_ORG_ID} and $_->{CHANNEL_ORG_ID} == $pxt->user->org_id} @channel_list;
##  my @other_channels = grep { not ($_->{CHANNEL_ORG_ID} and $_->{CHANNEL_ORG_ID} == $pxt->user->org_id) } @channel_list;
  ##bugzilla
  my @other_channels = grep { not ($_->{CHANNEL_ORG_ID}) } @channel_list;

  my @options = ( { NAME => 'My Channels', ID => 'my_channels', DEPTH => 1, OPTGROUP => 1 },
		 @my_channels,
		  { NAME => 'Other Channels', ID => 'other_channels', DEPTH => 1, OPTGROUP => 1 },
		 @other_channels);

  foreach my $opt (@options) {
    $channel_selectbox->add_option( {value => $opt->{ID},
				     label => ( $opt->{DEPTH} == 1
						? $opt->{NAME}
						: '&#160;&#160;' . $opt->{NAME}),
				     optgroup => $opt->{OPTGROUP} ? 1 : 0
				    } );
  }

  if ($clone_id) {
    $channel_selectbox->value($clone_id);
  }

  my $type_radiogroup = new RHN::Form::Widget::RadiobuttonGroup(name => 'Clone',
								label => 'clone_type');

  $type_radiogroup->add_option( {value => 'current',
				 label => 'Current state of the channel (all errata)'} );
  $type_radiogroup->add_option( {value => 'original',
				 label => 'Original state of the channel (no errata)'} );
  $type_radiogroup->add_option( {value => 'select_errata',
				 label => 'Select errata'} );

  my $clone_type = $pxt->dirty_param('clone_type') || 'current';

  $type_radiogroup->value($clone_type);

  $form->add_widget($channel_selectbox);
  $form->add_widget($type_radiogroup);
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:clone_channel_cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Create Channel') );

  return $form;
}

sub clone_channel_cb {
  my $pxt = shift;

  my $clone_from = $pxt->dirty_param('clone_from');
  my $clone_type = $pxt->dirty_param('clone_type');

  throw "Attempt to clone unauthorized channel '$clone_from' by user '". $pxt->user->id . "'."
    unless $pxt->user->verify_channel_access($clone_from);

  throw "Invalid clone type: $clone_type" unless grep { $clone_type eq $_ } qw/current original select_errata/;

  $pxt->redirect(sprintf('edit.pxt?clone_from=%d&clone_type=%s', $clone_from, $clone_type));
}

sub update_channel_cache {
  my $pxt = shift;
  my $channel = $pxt->param('cid');

  my $package_list_edited = $pxt->session->get('package_list_edited');

  my @channels = ($channel);

  unless (defined $channel) {
    @channels = keys %{$package_list_edited};
  }

  foreach my $cid (@channels) {

    unless ($pxt->user->verify_channel_admin($cid)) {
      warn "User '",$pxt->user->id,"' attempted to update errata cache for channel '$cid'\n";
      $pxt->redirect("/errors/permission.pxt");
    }

    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 0);

    $package_list_edited->{$cid} = 0;
  }

  $pxt->session->set(package_list_edited => $package_list_edited);

  my $uri = $pxt->uri;

  $uri .= "?cid=$channel"
    if ($channel);

  $pxt->redirect($uri);
}

sub channel_edit_form {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  # only allow cloning of channels
  $pxt->redirect("/errors/permission.pxt") unless $pxt->dirty_param('clone_from');

  my %subs;
  my %editable;
  my $archmap = RHN::ChannelEditor->channel_base_arch_map;

  $subs{cid} = '';
  $subs{channel_parent} = $pxt->dirty_param('channel_parent') || "(none)";
  $subs{channel_name} = $pxt->dirty_param('channel_name') || '';
  $subs{channel_label} = $pxt->dirty_param('new_channel_label') || '';
  $subs{channel_arch} = $pxt->dirty_param('channel_arch') || 0;
  $subs{channel_package_summary} = "n/a";
  $subs{channel_summary} = $pxt->dirty_param('channel_summary') || '';
  $subs{channel_description} = $pxt->dirty_param('channel_description') || '';
  $subs{channel_gpg_key_url} = $pxt->dirty_param('channel_gpg_key_url') || '';
  $subs{channel_gpg_key_id} = $pxt->dirty_param('channel_gpg_key_id') || '';
  $subs{channel_gpg_key_fp} = $pxt->dirty_param('channel_gpg_key_fp') || '';

  %editable = map { $_ => 1 } qw/channel_name channel_summary
				 channel_description channel_label channel_arch channel_parent
				 channel_gpg_key_url channel_gpg_key_fp
				 channel_gpg_key_id/;

  if (my $clone_from_cid = $pxt->dirty_param('clone_from')) {
    my $clone_from_channel = RHN::Channel->lookup(-id => $clone_from_cid);
    $subs{clone_from_string} = $clone_from_channel->name;

    my $clone_type = $pxt->dirty_param('clone_type') || '';
    $subs{clone_type_string} = $clone_type eq 'current'
	? 'Current state of the channel'
	  : ($clone_type eq 'original')
	    ? 'Original channel with no updates'
	      : 'Select errata';

    if ($clone_from_channel->parent_channel) {
	$subs{channel_parent} = RHN::ChannelEditor->likely_parent($pxt->user->org_id, $clone_from_channel->id);
    }
    else {
	$subs{channel_parent} = 'None';
	delete $editable{channel_parent};
    }

    my $name_prefix = 'Clone of ';
    my $label_prefix = 'clone-';
    my $number = 1;

    while (RHN::ChannelEditor->label_exists($label_prefix . $clone_from_channel->label)) {
	$number++;
	$name_prefix = "Clone ${number} of ";
	$label_prefix = "clone-${number}-";
    }

    $subs{channel_arch} ||= $clone_from_channel->channel_arch_id;
    $subs{channel_name} ||= $name_prefix . $clone_from_channel->name;
    $subs{channel_summary} ||= $clone_from_channel->summary;
    $subs{channel_label} ||= $label_prefix . $clone_from_channel->label;
    $subs{channel_gpg_key_url} ||= $clone_from_channel->gpg_key_url || '';
    $subs{channel_gpg_key_id} ||= $clone_from_channel->gpg_key_id || '';
    $subs{channel_gpg_key_fp} ||= $clone_from_channel->gpg_key_fp || '';
  }

  $subs{channel_arch} ||= RHN::ChannelEditor->default_arch_id;

  PXT::Utils->escapeHTML_multi(\%subs);

  my @arch_order = sort { $archmap->{$a}->{NAME} cmp $archmap->{$b}->{NAME} } keys %$archmap;

  if (exists $editable{channel_arch}) {
    $subs{channel_arch} =
      PXT::HTML->select(-name => 'channel_arch',
			-options => [ map { [ $archmap->{$_}->{NAME}, $_, $_ == $subs{channel_arch} ] } @arch_order ]);
  }
  else {
    $subs{channel_arch} = $archmap->{$subs{channel_arch}}->{NAME};
  }

  if (exists $editable{channel_parent}) {
    my @channel_list = grep { $_->{DEPTH} == 1 } RHN::ChannelEditor->channels_visible_to_org($pxt->user->org_id);

    if ($subs{channel_parent} eq '(none)') {
      $subs{channel_parent} = 0;
    }

    my $parent_id = int(0 + ($subs{channel_parent} || 0));

    foreach my $chan (@channel_list) {
      if ($chan->{ID} == $parent_id) {
	$chan->{SELECTED} = 1;
      }
    }

    $subs{channel_parent} = PXT::HTML->select(-name => 'channel_parent',
					      -options => [ [ "None", "", 1 ],
							    map { [ $_->{NAME}, $_->{ID}, $_->{SELECTED} ] }
							    sort { $a->{NAME} cmp $b->{NAME} }
							    @channel_list ]);
  }

  if ($editable{channel_label}) {
    $subs{channel_label} = PXT::HTML->text(-name => 'new_channel_label', -value => $subs{channel_label}, -size => 32, -maxlength => 128);
    $subs{channel_label} .= '<br />Ex: custom-channel';
  }
  if ($editable{channel_name}) {
    $subs{channel_name} = PXT::HTML->text(-name => 'channel_name', -value => $subs{channel_name}, -size => 48, -maxlength => 256);
  }
  if ($editable{channel_summary}) {
    $subs{channel_summary} = PXT::HTML->text(-name => 'channel_summary', -value => $subs{channel_summary}, -size => 40, -maxlength => 500);
  }
  if ($editable{channel_gpg_key_url}) {
    $subs{channel_gpg_key_url} = PXT::HTML->text(-name => 'channel_gpg_key_url', -value => $subs{channel_gpg_key_url}, -size => 40, -maxlength => 256);
  }
  if ($editable{channel_gpg_key_id}) {
    $subs{channel_gpg_key_id} = PXT::HTML->text(-name => 'channel_gpg_key_id', -value => $subs{channel_gpg_key_id}, -size => 8, -maxlength => 8);
  }
  if ($editable{channel_gpg_key_fp}) {
    $subs{channel_gpg_key_fp} = PXT::HTML->text(-name => 'channel_gpg_key_fp', -value => $subs{channel_gpg_key_fp}, -size => 60, -maxlength => 50);
  }
  if ($editable{channel_description}) {
    $subs{channel_description} = PXT::HTML->textarea(-name => 'channel_description', -value => $subs{channel_description}, -rows => 6, -cols => 40, -wrap => 'VIRTUAL');
  }

  $block = PXT::Utils->perform_substitutions($block, \%subs);

  return $block;
}

#output a list of channels to select packages from, including 'no channels', and 'any channel'
sub channel_select_options {
  my $pxt = shift;
  my %params = @_;

  my $html;

  my $cid = $pxt->param('cid');
  my $eid = $pxt->param('eid') || 0;

  my $selected = $pxt->param('view_channel') || '';

  my @channel_list;

  my $mode = $params{mode} || 'channel_manager';

  my $ds = new RHN::DataSource::Channel(-mode => 'user_subscribe_perms');
  my $subscribable = $ds->execute_query(-u_id => $pxt->user->id, -org_id => $pxt->user->org_id);
  my %perm_map = map { ('channel_' . $_->{ID}, 1) }
    grep { $_->{HAS_PERM} } @{$subscribable};

  if ($mode eq 'channel_manager' or
      $mode eq 'channel_patchset_manager' or $mode eq 'channel_patch_manager') {
    throw "param cid needed but not provided"
      unless $cid;

    if ($mode eq 'channel_manager') {
      $selected ||= 'channel_' . $cid;
      @channel_list = ([ 'All managed packages', 'any_channel' ], [ 'Packages in no channels', 'no_channels' ]);
    }
    elsif ($mode eq 'channel_patch_manager') {
      $selected ||= 'channel_' . $cid;
      @channel_list = ([ 'All managed patches', 'any_channel' ], [ 'Patches in no channels', 'no_channels' ]);
    }
    elsif ($mode eq 'channel_patchset_manager') {
      $selected ||= 'channel_' . $cid;
      @channel_list = ([ 'All managed patchsets', 'any_channel' ], [ 'Patchsets in no channels', 'no_channels' ]);
    }

    if (PXT::Config->get('satellite')) {
      my @org_channels = RHN::Channel->compat_channels_owned_by_org($pxt->user->org_id, $cid);
      my @rh_channels = RHN::Channel->compat_channels_owned_by_org('NULL', $cid);

      @org_channels = grep { $perm_map{$_->[1]} } @org_channels;
      @rh_channels = grep { $perm_map{$_->[1]} } @rh_channels;

      push @channel_list, ([ 'My Channels', 'my_channels', 'optgroup' ],
			   @org_channels,
			   [ 'Red Hat Channels', 'redhat_channels', 'optgroup' ],
			   @rh_channels);
    }
    else {
      my @org_channels = RHN::Channel->compat_channels_owned_by_org($pxt->user->org_id, $cid);
      @org_channels = grep { $perm_map{$_->[1]} } @org_channels;
      push @channel_list, @org_channels;
    }
  }
  elsif ($mode eq 'compare_channels') {
      my @org_channels = RHN::Channel->channels_owned_by_org($pxt->user->org_id);
      my @rh_channels = RHN::Channel->channels_owned_by_org('NULL');

      @org_channels = grep { $perm_map{$_->[1]} } @org_channels;
      @rh_channels = grep { $perm_map{$_->[1]} } @rh_channels;

      push @channel_list, ([ 'My Channels', 'my_channels', 'optgroup' ],
                           @org_channels,
                           [ 'Red Hat Channels', 'redhat_channels', 'optgroup' ],
                           @rh_channels);
  }
  elsif ($mode eq 'errata_manager') {
    @channel_list = ([ 'All managed packages', 'any_channel' ]);

    my @org_channels = RHN::Channel->channels_owned_by_org($pxt->user->org_id);
    @org_channels = grep {     $perm_map{$_->[1]}
			   and $_->[1] =~ /channel_(\d+)/
			   and RHN::Channel->channel_type_capable($1, 'errata') } @org_channels;

    push @channel_list, @org_channels;
  }
  elsif ($mode eq 'package_manager') {
    @channel_list = ([ 'All managed packages', 'any_channel' ], [ 'Packages in no channels', 'no_channels' ]);

    my @org_channels = RHN::Channel->channels_owned_by_org($pxt->user->org_id);
    @org_channels = grep { $perm_map{$_->[1]} } @org_channels;
    push @channel_list, @org_channels;
  }
  elsif ($mode eq 'errata_cloning') {
    @channel_list = ([ 'Any managed channel', 'any_channel' ]);

    my @cloned_channels = RHN::Channel->cloned_channels_owned_by_org($pxt->user->org_id);
    @cloned_channels = grep {     $perm_map{$_->[1]}
 		              and $_->[1] =~ /channel_(\d+)/
		              and RHN::Channel->channel_type_capable($1, 'errata') } @cloned_channels;
    push @channel_list, @cloned_channels;
  }

  my @render;

  foreach my $channel (@channel_list) {
    my $x = { };
    @{$x}{qw/name value optgroup/} = @{$channel}[0 .. 2]; #slice. allows $x->{name}, etc

    push @render, $x;
  }

  my @options;

  foreach my $channel (@render) {
    my $is_selected = $channel->{value} eq $selected ? '1' : undef;
    push @options, [ $channel->{name}, $channel->{value}, $is_selected, $channel->{optgroup} ? 1 : 0 ];
  }

  return PXT::HTML->select(-name => 'view_channel',
			   -options => \@options);
}

sub if_package_list_modified {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $cid = $pxt->param('cid');

  return unless $cid;

  my $package_list_edited = $pxt->session->get('package_list_edited');
  my $edited = $package_list_edited->{$cid} || 0;

  if ((time - $edited) < 3600) {
    return $block;
  }

  return '';
}

sub if_packages_deleted_from_channels {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $package_list_edited = $pxt->session->get('package_list_edited');

  my @channels = keys %{$package_list_edited};

  foreach my $cid (@channels) {
    my $edited = $package_list_edited->{$cid} || 0;

    if ((time - $edited) < 3600) {
      return $block;
    }
  }

  return '';
}

sub if_var {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  return unless $pxt->passthrough_param($attr{formvar});

  return $block;
}

sub show_all_errata_checkbox {
  my $pxt = shift;
  my %attr = @_;

  return PXT::HTML->checkbox(-name => 'show_all_errata',
			     -value => 1,
			     -checked => $pxt->dirty_param('show_all_errata') ? 1 : 0);
}

sub channel_sync_prompt {
  my $pxt = shift;
  my %params = @_;

  my $target = RHN::Channel->lookup(-id => $pxt->param('cid'));
  my $source = $pxt->param('view_channel');
  my $source_id = (split /_/, $source, 2)[-1];
  $source = RHN::Channel->lookup(-id => $source_id);

  my %s = (target_channel => sprintf("<strong>%s</strong>", $target->label),
	   source_channel => sprintf("<strong>%s</strong>", $source->label));

  #only clear if sync_type is not set, otherwise we clear the set on pagination
  if (!$pxt->dirty_param("sync_type")) {
	# Clear the packages for merge set to remove any old selections:
	my $set = RHN::Set->lookup(-label => 'packages_for_merge', -uid => $pxt->user->id);
	$set->empty;
	$set->commit;
  }

  return PXT::Utils->perform_substitutions($params{__block__}, \%s);
}

sub verify_arch_compat {
	my $parent_arch = shift;
	my $child_arch = shift;
	
	my $ia32 = 'IA-32';
	my $ia64 = "IA-64";
	my $sparc = "Sparc";
	my $alpha = "Alpha";
	my $s390 = "s390";
	my $s390x = "s390x";
	my $iSeries = "iSeries";
	my $pSeries = "pSeries";
	my $x86_64 = "x86_64";
	my $ppc = "PPC";
	my $sparc_solaris = "Sparc Solaris";
	my $i386_solaris = "i386 Solaris";
	
	my %compat_table = (
	        $ia32 => {$ia32 => '1'},
	        $ia64 => {$ia64 => '1', $ia32 => '1'},
	        $sparc => {$sparc => '1',  $sparc_solaris => '1',  $i386_solaris => '1'},
	        $alpha => {$alpha => '1'},
	        $s390 => {$s390 => '1'},
	        $s390x => {$s390 => '1',  $s390x => '1'},
	        $iSeries => {$iSeries => '1', $pSeries => '1'},
	        $pSeries => {$iSeries => '1', $pSeries => '1'},
	        $x86_64 => {$x86_64 => '1', $ia32 => '1'},
	        $ppc => {$ppc => '1'},
	        $sparc_solaris => {$sparc => '1',  $sparc_solaris => '1',  $i386_solaris => '1'},
	        $i386_solaris => {$sparc => '1',  $sparc_solaris => '1',  $i386_solaris => '1'}
	    );
	return $compat_table{$parent_arch}->{$child_arch};
}

1;
