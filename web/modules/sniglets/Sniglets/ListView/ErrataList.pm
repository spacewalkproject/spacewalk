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

package Sniglets::ListView::ErrataList;

use Sniglets::ListView::List;
use RHN::DataSource::Errata;
use RHN::DataSource::Simple;
use RHN::Server;
use RHN::Channel;
use RHN::ChannelEditor;
use RHN::SearchTypes;
use PXT::Utils;
use RHN::Exception qw/throw/;

use RHN::Form::Widget::Select;

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:errata_list_cb";
}

sub list_of { return "errata" }

sub _register_modes {

  Sniglets::ListView::List->add_mode(-mode => "errata_search_results",
			   -datasource => new RHN::DataSource::Simple(-querybase => "errata_search_elaborators"),
			   -provider => \&errata_search_results_provider);


  Sniglets::ListView::List->add_mode(-mode => "relevant_errata",
			   -datasource => RHN::DataSource::Errata->new);

  Sniglets::ListView::List->add_mode(-mode => "all_errata",
			   -datasource => RHN::DataSource::Errata->new);

  Sniglets::ListView::List->add_mode(-mode => "relevant_to_system_set",
			   -datasource => RHN::DataSource::Errata->new);

  Sniglets::ListView::List->add_mode(-mode => "relevant_to_system",
			   -datasource => RHN::DataSource::Errata->new,
			   -provider => \&relevant_to_system_provider);

  Sniglets::ListView::List->add_mode(-mode => "unscheduled_relevant_to_system",
			   -datasource => RHN::DataSource::Errata->new,
			   -action_callback => \&apply_unscheduled_errata);

  Sniglets::ListView::List->add_mode(-mode => "relevant_to_channel",
			   -datasource => RHN::DataSource::Errata->new);

  Sniglets::ListView::List->add_mode(-mode => "relevant_to_group",
			   -datasource => RHN::DataSource::Errata->new);

  Sniglets::ListView::List->add_mode(-mode => "in_set",
			   -datasource => RHN::DataSource::Errata->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "unpublished_in_set",
			   -datasource => RHN::DataSource::Errata->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "in_set_relevant_to_system_set",
			   -datasource => RHN::DataSource::Errata->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "published_owned_errata",
			   -datasource => RHN::DataSource::Errata->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "unpublished_owned_errata",
			   -datasource => RHN::DataSource::Errata->new,
			   -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "clonable_errata_list",
  		           -datasource => RHN::DataSource::Errata->new,
                           -provider => \&clonable_errata_list_provider);

  Sniglets::ListView::List->add_mode(-mode => "relevant_to_progenitor",
  		           -datasource => RHN::DataSource::Errata->new,
                           -action_callback => \&default_callback);

  Sniglets::ListView::List->add_mode(-mode => "owned_by_org_potential_for_channel",
  		           -datasource => RHN::DataSource::Errata->new);

  Sniglets::ListView::List->add_mode(-mode => "potential_for_cloned_channel",
  		           -datasource => RHN::DataSource::Errata->new,
                           -provider => \&potential_for_cloned_channel_provider,
                           -action_callback => \&potential_for_cloned_channel_cb);
}


sub errata_search_results_provider {
  my $self = shift;
  my $pxt = shift;

  my $search = RHN::SearchTypes->find_type('errata');
  my $mode = $pxt->dirty_param('view_mode') || '';

  die "No mode specified for errata_search_results"
    unless $mode;

  my $ds = $self->datasource;
  $ds->mode($mode);

  my %ret = $self->default_provider($pxt);

  my $quicksearch = $pxt->dirty_param('quicksearch') || 0;
  if (scalar @{$ret{all_ids}} == 1 and $quicksearch) {
    my $eid = $ret{all_ids}->[0];
    $pxt->push_message(site_info => "Your search returned one result, displayed below.");
    $pxt->redirect("/network/errata/details/Details.do?eid=$eid");
  }

  if (defined $self->listview()) { # don't run this in callback - no listview
    foreach my $col (@{$self->listview->columns}) {
      if ($col->label eq 'matching_field') {
	$col->name($search->label_to_column_name($mode));
      }
    }
  }

  my $string = quotemeta($pxt->dirty_param('search_string') || '');
  foreach my $row (@{$ret{data}}) {
    my $field = $row->{MATCHING_FIELD} || '&#160;';

    # ugly hack.  the datasource layer can't really help us much here.
    # need to recompute relevant rows by hand.
    if ($mode eq 'errata_search_by_package_name') {
      my @packages = RHN::Errata->matching_packages_in_errata($row->{ID}, $string);
      $field = join("<br />", @packages) || '&#160;';
    }

    $field =~ s/($string)/<strong>$1<\/strong>/gi;
    $row->{MATCHING_FIELD} = $field;
  }

  return %ret;
}

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  if (exists $row->{ADVISORY_TYPE}) {
    $row->{ADVISORY_ICON} = PXT::HTML->img(-src => '/img/wrh-' . lc ((split /[\s]/, $row->{ADVISORY_TYPE})[0]) . '.gif',
				      -alt => $row->{ADVISORY_TYPE},
				      -title => $row->{ADVISORY_TYPE});
  }

  if (exists $row->{ADVISORY_LAST_UPDATED}) {
    my $date = new RHN::Date(string => $row->{ADVISORY_LAST_UPDATED},
			     user => $pxt->user);
    $row->{ADVISORY_LAST_UPDATED} = $date->short_date();
  }

  return $row;
}

sub default_callback {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;
  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  if ($label eq 'confirm_errata_application') {
    return apply_errata_cb($pxt);
  }
  elsif ($label eq 'clone_errata') {
    return clone_errata_from_set($pxt);
  }
  elsif ($label eq 'remove_errata') {
    return remove_errata_from_channel($pxt);
  }
  elsif ($label eq 'add_errata') {
    return add_errata_to_channel($pxt);
  }

  return 1;
}

sub apply_unscheduled_errata {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;
  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  if ($label eq 'apply_unscheduled_errata') {
    my $sid = $pxt->param('sid');
    throw "no server id" unless $sid;

    my $system = RHN::Server->lookup(-id => $sid);

    my $earliest_date = RHN::Date->now->long_date;
    my $count = RHN::Scheduler->schedule_all_errata_updates_for_system(-org_id => $pxt->user->org_id,
								       -user_id => $pxt->user->id,
								       -earliest => $earliest_date,
								       -server_id => $sid);

    $pxt->push_message(site_info => sprintf('Scheduled <b>%d</b> errata update%s for <strong>%s</strong>.',
					    $count,
					    $count == 1 ? '' : 's',
					    PXT::Utils->escapeHTML($system->name)));

  }

  return 1;
}

sub relevant_to_system_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    my $stat = $row->{__data__}->[0];
    if ($stat) {
      if ($stat->{STATUS} eq 'Queued') {
	$stat->{STATUS} = 'Pending';
      }
      $row->{STATUS} = PXT::HTML->link('/rhn/schedule/ActionDetails.do?aid=' . $stat->{ACTION_ID}, $stat->{STATUS});
    }
    else {
      $row->{STATUS} = 'None';
    }
  }

  return %ret;
}

sub clonable_errata_list_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;
  my %params;

  my $mode = $pxt->param('view_channel') || '';

  if ($mode =~ /channel_(\d+)/) {
    $ds->mode('clonable_errata_for_channel');
    my $view_channel = $1;

    $params{-channel_id} = $view_channel;
  }

  %params = ($self->lookup_params($pxt, $ds->required_params), %params);

  my $data = $ds->execute_query(%params);

  my $alphabar = $self->init_alphabar($data);
  $data = $self->filter_data($data);

  unless ($pxt->dirty_param('show_all_errata')) {
    $data = [ grep { not $_->{ALREADY_CLONED} } @{$data} ];
  }

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  foreach my $row (@{$data}) {
    $row->{RELATED_CHANNELS} =
      join "<br />\n",
	map { PXT::HTML->link('/rhn/channels/manage/Manage.do?cid=' . $_->{CHANNEL_ID},
			      $_->{CHANNEL_NAME}) } @{$row->{__data__} };
    $row->{CLONED} = $row->{ALREADY_CLONED} ? 'Yes' : 'No';
  }

  return (data => $data,
	  alphabar => $alphabar,
	  all_ids => $all_ids);
}

sub potential_for_cloned_channel_provider {
  my $self = shift;
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  throw "user '" . $pxt->user->id . "' does not have permission to modify channel '$cid'"
    unless $pxt->user->verify_channel_admin($cid);

  my $cloned_from = RHN::Channel->channel_cloned_from($cid);

  throw "Channel '$cid' is not a clone!" unless $cloned_from;

  my $data = RHN::ChannelEditor->errata_migration_provider(-from_cid => $cloned_from, -to_cid => $cid, -org_id => $pxt->user->org_id);

  my $alphabar = $self->init_alphabar($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $self->datasource->slice_data($data, $self->lower, $self->upper);

  my $set_label = 'errata_clone_actions';
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my %actions = $set->output_hash;
  foreach my $row (@{$data}) {
    my @options;

    my $action_formvar = 'errata_' . $row->{ID} . '_action';
    my $selected_action = $pxt->dirty_param($action_formvar);
    my $default_action;

    if (defined $row->{OWNED_ERRATA}) {
      my @owned = @{$row->{OWNED_ERRATA}};
      my @ranked = sort compare_owned_errata @owned;

      $default_action ||= 'merge_' . $ranked[0]->{ID};

      $row->{OWNED_ERRATA_LIST} = join("<br/>\n", map { PXT::HTML->link('/network/errata/manage/edit.pxt?eid=' . $_->{ID},$_->{ADVISORY_NAME}) . ' (' .
						        ($_->{PUBLISHED} ? '+pub' : '-pub') . ', ' .
						        ($_->{LOCALLY_MODIFIED} ? '+mod' : '-mod') . ')' } @owned);
      push(@options, map { { label => 'Merge w/' . $_->{ADVISORY_NAME},
			     value => 'merge_' . $_->{ID} } } @owned);

    }
    else {
      $row->{OWNED_ERRATA_LIST} = '(none)';
    }

    my ($adv, $adv_name) = RHN::DB::ErrataEditor::find_next_advisory($row->{ADVISORY}, $row->{ADVISORY_NAME});

    push(@options, ( { label => "Clone as ${adv_name}",
		       value => 'clone_new' },
		     { label => 'Do Nothing',
		       value => 'noop' } ) );

    $default_action ||= 'clone_new';

    my $select_widget = new RHN::Form::Widget::Select(name => 'errata_' . $row->{ID} . '_action',
						      options => \@options,
						      default => $default_action);

    if (defined $actions{$row->{ID}} and not $selected_action) {
      my $val = $actions{$row->{ID}};
      if ($val > 0) {
	$selected_action = 'merge_' . $val;
      }
      elsif ($val == 0) {
	$selected_action = 'clone_new';
      }
      elsif ($val == -1) {
	$selected_action = 'noop';
      }
    }

    my $on_page_widget = new RHN::Form::Widget::Hidden(name => 'errata_on_page',
						       value => $row->{ID});

    if ($selected_action) {
      $select_widget->value($selected_action);
    }

    my ($sel_option) = grep { $_->{value} eq $select_widget->value } $select_widget->options;
    $row->{ACTION} = $sel_option->{label};

    $row->{SELECT_ACTION} = $select_widget->render . "\n" . $on_page_widget->render;
  }

  my $all_errata_html = "\n";

  foreach my $id (@{$all_ids}) {
    my $all_errata_widget = new RHN::Form::Widget::Hidden(name => 'all_errata',
							  value => $id);
    $all_errata_html .= $all_errata_widget->render;
  }

  if ($data->[0]) {
    $data->[0]->{SELECT_ACTION} .= $all_errata_html;
  }

  return (data => $data,
	  all_ids => $all_ids,
	  alphabar => $alphabar);
}

sub potential_for_cloned_channel_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;
  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  my $set_label = 'errata_clone_actions';
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my %set_as_hash = $set->output_hash;
  my @all_errata = $pxt->dirty_param('all_errata');
  my %on_page = map { ($_, 1) } ($pxt->dirty_param('errata_on_page'));
  foreach my $eid (@all_errata) {
    my $action = $pxt->dirty_param("errata_${eid}_action") || '';

    if ($action =~ /merge/) {
      $action =~ s/merge_//;
    }
    elsif ($action eq 'clone_new') {
      $action = 0;
    }
    elsif ($action eq 'noop') {
      $action = -1;
    }
    else {
      undef $action; 
    }
 
    if ($on_page{$eid}) {
      if (defined $set_as_hash{$eid}) {
        $set->remove( [$eid, $set_as_hash{$eid}] );
      }
      else {
        $set->remove($eid);  
      }
    } 

    if (defined $action) {
      $set->add( [$eid, $action] );
    }
     elsif (not exists $set_as_hash{$eid}) { 	 
       $set->add($eid); 	 
     }
  }

  $set->commit;

  if ($label eq 'confirm_errata_application') {
    %set_as_hash = $set->output_hash;
    my $cid = $pxt->param('cid');

    my ($merge_count, $publish_count, $clone_count) = (0,0,0);

    my $transaction = RHN::DB->connect;
    $transaction->nest_transactions;

    my $cloned_from = RHN::Channel->channel_cloned_from($cid);

    foreach my $eid (keys %set_as_hash) {
      my $target_eid = $set_as_hash{$eid};

      if (not defined $target_eid) { # not specified, need to find the correct default...
	my $owned = RHN::ErrataEditor->find_clones_of_errata(-eid => $eid, -org_id => $pxt->user->org_id);
	my @ranked = sort compare_owned_errata @{$owned};

	if (@ranked) {
	  $target_eid = $ranked[0]->{ID};
	}
	else {
	  $target_eid = 0;
	}
     }

      next if $target_eid == -1; # noop

      if ($target_eid) { # merge with existing errata
	my $target_errata = RHN::ErrataTmp->lookup_managed_errata(-id => $target_eid);

	if ($target_errata->isa('RHN::ErrataTmp')) {
	  $target_eid = RHN::ErrataEditor->publish_errata($target_errata);
	  $publish_count++;
	}
	else {
	  $merge_count++;
	}
	undef $target_errata; #don't use this anymore, it might not exist.

	RHN::ChannelEditor->add_cloned_errata_to_channel(-eids => [ $target_eid ], -to_cid => $cid, -from_cid => $cloned_from);
      }
      else { # create new errata
	$clone_count++;
	RHN::ChannelEditor->clone_errata_into_channel(-to_cid => $cid, -eid => $eid, -org_id => $pxt->user->org_id, -include_packages => 1, -from_cid => $cloned_from);
      }
    }

    my $channel = RHN::Channel->lookup(-id => $cid);
    my @messages;
    if ($clone_count) {
      push @messages, sprintf('<strong>%d</strong> errata cloned into <strong>%s</strong>.', $clone_count, $channel->name);
    }

    if ($merge_count) {
      push @messages, sprintf('<strong>%d</strong> errata assigned to <strong>%s</strong>.', $merge_count, $channel->name);
    }

    if ($publish_count) {
      push @messages, sprintf('<strong>%d</strong> errata published to <strong>%s</strong>.', $publish_count, $channel->name);
    }

    RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 0);
    RHN::Channel->refresh_newest_package_cache($cid, 'web.channel_manager');

    $transaction->nested_commit;

    $pxt->push_message(site_info => $_) foreach (@messages);
    $pxt->redirect("/rhn/channels/manage/errata/Errata.do?cid=${cid}");
  }

  return 1;
}

sub compare_owned_errata { #sorting sub
  if (($a->{PUBLISHED} and not $a->{LOCALLY_MODIFIED})
      and
      (not $b->{PUBLISHED} or $b->{LOCALLY_MODIFIED})) {
    return -1;
  }
  elsif ($a->{PUBLISHED} and not $b->{PUBLISHED}) {
    return -1;
  }
  else {
    return ($a->{ADVISORY_NAME} cmp $b->{ADVISORY_NAME});
  }
}

sub apply_errata_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');

  my $errata_set = RHN::Set->lookup(-label => $pxt->dirty_param('set_label'), -uid => $pxt->user->id);

  my $earliest_date = RHN::Date->now->long_date;
  my @action_ids = RHN::Scheduler->schedule_errata_updates_for_system(-org_id => $pxt->user->org_id,
								      -user_id => $pxt->user->id,
								      -earliest => $earliest_date,
								      -errata_set => $errata_set,
								      -server_id => $sid);

  my $system = RHN::Server->lookup(-id => $sid);

  my $errata_count = scalar $errata_set->contents;
  $pxt->push_message(site_info => sprintf('<strong>%d</strong> errata update%s been scheduled for <a href="/rhn/systems/details/Overview.do?sid=%d"><strong>%s</strong></a>.',
					  $errata_count,
					  $errata_count == 1 ? ' has' : 's have',
					  $sid,
					  PXT::Utils->escapeHTML($system->name) ));

  $errata_set->empty;
  $errata_set->commit;

  return 1;
}

sub clone_errata_from_set {
  my $pxt = shift;

  throw "user '" . $pxt->user->id . "' is not a channel admin." unless $pxt->user->is('channel_admin');

  my $errata_set = RHN::Set->lookup(-label => $pxt->dirty_param('set_label'), -uid => $pxt->user->id);
  my @ids = $errata_set->contents;

  my $count = scalar @ids;

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions;

  foreach my $errata_id (@ids) {
    eval {
      RHN::ErrataEditor->clone_into_org($errata_id, $pxt->user->org_id);
    };
    if ($@) {
      my $E = $@;
      $transaction->nested_rollback;
      die $E;
    }
  }

  $transaction->nested_commit;

  $errata_set->empty;
  $errata_set->commit;

  $pxt->push_message(site_info => sprintf('Successfully cloned <strong>%d</strong> errata.', $count));

  return 1;
}

sub remove_errata_from_channel {
  my $pxt = shift;
  my $cid = $pxt->param('cid');

  throw "user '" . $pxt->user->id . "' does not have permission to modify channel '$cid'" unless $pxt->user->verify_channel_admin($cid);

  my $channel = RHN::Channel->lookup(-id => $cid);

  my $errata_set = RHN::Set->lookup(-label => $pxt->dirty_param('set_label'), -uid => $pxt->user->id);
  my @eids = $errata_set->contents;

  my $count = scalar @eids;

  RHN::ChannelEditor->remove_errata_from_channel(-cid => $cid, -eids => \@eids, -include_packages => 1);

  $errata_set->empty;
  $errata_set->commit;

  RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 0);
  RHN::Channel->refresh_newest_package_cache($cid, 'web.channel_manager');

  $pxt->push_message(site_info => sprintf('Removed <strong>%d</strong> errata from <strong>%s</strong>.', $count, $channel->name));

  return 1;
}

sub add_errata_to_channel {
  my $pxt = shift;
  my $cid = $pxt->param('cid');

  throw "user '" . $pxt->user->id . "' does not have permission to modify channel '$cid'" unless $pxt->user->verify_channel_admin($cid);

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions;

  my $channel = RHN::Channel->lookup(-id => $cid);

  my $errata_set = RHN::Set->lookup(-label => $pxt->dirty_param('set_label'), -uid => $pxt->user->id);
  my @eids = $errata_set->contents;

  my $count = scalar @eids;

  RHN::ChannelEditor->add_errata_to_channel(-cid => $cid, -eids => \@eids, -include_packages => 1);

  $errata_set->empty;
  $errata_set->commit;

  RHN::ChannelEditor->schedule_errata_cache_update($pxt->user->org_id, $cid, 0);
  RHN::Channel->refresh_newest_package_cache($cid, 'web.channel_manager');

  $transaction->nested_commit;

  $pxt->push_message(site_info => sprintf('Added <strong>%d</strong> errata to <strong>%s</strong>.', $count, $channel->name));

  return 1;
}

sub render_checkbox {
  my $self = shift;
  my %params = validate(@_, { row => 1, checked => 1, blank => 0, pxt => 0 });

  my $row = $params{row};
  my $stat = exists $row->{__data__} ? $row->{__data__}->[0] : undef;

  if ($self->datasource->mode eq 'relevant_to_system' and defined $stat and $stat->{STATUS} eq 'Pending') {
    my $checkbox = PXT::HTML->link('/rhn/schedule/ActionDetails.do?aid=' . $stat->{ACTION_ID}, PXT::HTML->img(-src => '/img/icon_pending.gif', -alt => 'Update Scheduled', -title => 'Update Scheduled', -border => 0));

    my $checkbox_template = $self->style->checkbox();
    $checkbox_template =~ s/\{checkbox\}/$checkbox/;
    return $checkbox_template;
  }
  else {
    return $self->SUPER::render_checkbox(%params);
  }

}

sub clean_set {
  my $self = shift;
  my $set = shift;
  my $user = shift;
  my $formvars = shift;

  if($self->datasource->mode() eq 'relevant_to_system') {
    $set->remove_scheduled_errata_for_system($formvars->{sid});
  }

  return;
}

1;
