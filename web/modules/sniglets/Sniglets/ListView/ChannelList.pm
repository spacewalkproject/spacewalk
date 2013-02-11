#
# Copyright (c) 2008--2013 Red Hat, Inc.
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

package Sniglets::ListView::ChannelList;

use Sniglets::ListView::List;
use RHN::DataSource::Channel;
use Data::Dumper;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:channel_list_cb";
}

sub list_of { return "channels" }

sub _register_modes {

  Sniglets::ListView::List->add_mode(-mode => "comparison_to_snapshot",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&comparison_to_snapshot_provider);

  Sniglets::ListView::List->add_mode(-mode => "user_subscribe_perms",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&subscribe_perm_provider,
			   -action_callback => \&subscribe_perm_cb);

  Sniglets::ListView::List->add_mode(-mode => "user_manage_perms",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&manage_perm_provider,
			   -action_callback => \&manage_perm_cb);


  Sniglets::ListView::List->add_mode(-mode => "channel_entitlements",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&channel_entitlements_provider);

  Sniglets::ListView::List->add_mode(-mode => "channel_tree",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&channel_tree);

  Sniglets::ListView::List->add_mode(-mode => "channel_tree_ssm_install",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&channel_tree);

  Sniglets::ListView::List->add_mode(-mode => "channel_tree_ssm_solaris_install",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&channel_tree);

  Sniglets::ListView::List->add_mode(-mode => "non_eol_all_channels_tree",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&channel_tree);

  Sniglets::ListView::List->add_mode(-mode => "eol_all_channels_tree",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&channel_tree);

  Sniglets::ListView::List->add_mode(-mode => "owned_channels_tree",
			   -datasource => RHN::DataSource::Channel->new,
			   -provider => \&channel_tree);

}

sub change_perms {
  my $role = shift;
  my $self = shift;
  my $pxt = shift;

  die "user not org_admin!" unless $pxt->user->is('org_admin');
  my $uid = $pxt->param('uid');

  my $user = RHN::User->lookup(-id => $uid);
  die "no user" unless $user;

  foreach my $cid ($pxt->param('cid')) {

    # if the numeric formvar exists, it was checked... otherwise, remove permission...
    if ($pxt->dirty_param($cid)) {
      $pxt->user->org->reset_channel_permissions(-uids => [$uid],
							 -cid => $cid,
							 -role => $role);
    }
    else {
      $pxt->user->org->remove_channel_permissions(-uids => [$uid],
						  -cid => $cid,
						  -role => $role);
    }
  }

  return 1;
}


sub comparison_to_snapshot_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;

  my %params;
  $ds->mode('system_snapshot_channel_list');
  %params = $self->lookup_params($pxt, $ds->required_params);

  my $snapshot_channels = $ds->execute_query(%params);
  $snapshot_channels = $ds->elaborate($snapshot_channels, %params);

  my $current_ds = new RHN::DataSource::Channel;

  $current_ds->mode('system_channels');
  %params = $self->lookup_params($pxt, $current_ds->required_params);

  my $current_channels = $current_ds->execute_query(%params);
  $current_channels = $current_ds->elaborate($current_channels, %params);

  # group names are unique within an org.
  my %all_channels;

  foreach my $snapshot_channel (@{$snapshot_channels}) {
    $all_channels{$snapshot_channel->{NAME}}->{ID} = $snapshot_channel->{ID};
    $all_channels{$snapshot_channel->{NAME}}->{IN_SNAPSHOT} = 1;
  }

  foreach my $current_channel (@{$current_channels}) {
    $all_channels{$current_channel->{NAME}}->{ID} = $current_channel->{ID};
    $all_channels{$current_channel->{NAME}}->{CURRENTLY_SUBSCRIBED} = 1;
  }

  my $delta = [];

  my $some_delta;
  foreach my $channel_name (sort {uc $a cmp uc $b} keys %all_channels) {

    my $channel = $all_channels{$channel_name};
    my $comparison;

    if ($channel->{IN_SNAPSHOT}) {

      if ($channel->{CURRENTLY_SUBSCRIBED}) {
	$comparison = 'Both Current and Snapshot';
      }
      else {
	$some_delta = 1;
	$comparison = 'Snapshot Profile Only';
      }
    }
    else {
      $some_delta = 1;
      $comparison = 'Current Profile Only';
    }


    push @{$delta}, { ID => $channel->{ID},
		      CHANNEL_NAME => $channel_name,
		      COMPARISON => $comparison,
		    };
  }

  $delta = [] unless $some_delta;

  my $alphabar = $self->init_alphabar($delta);
  my $on_page = $self->filter_data($delta);

  my @all_ids = map { $_->{ID} } @{$on_page};
  $self->all_ids(\@all_ids);
  $on_page = $current_ds->slice_data($on_page, $self->lower, $self->upper);


  return (data => $on_page,
	  all_ids => \@all_ids,
	  alphabar => $alphabar,
	  full_data => $delta);
}

sub subscribe_perm_provider {
  my $self = shift;
  my $pxt = shift;

  my $uid = $pxt->param('uid');
  my $user = RHN::User->lookup(-id => $uid);
  die "no user" unless $user;

  my %ret = $self->default_provider($pxt, (-u_id => $uid));

  foreach my $row (@{$ret{data}}) {
    if ($user->is('channel_admin')) {
      $row->{PERM_CHECKBOX} = PXT::HTML->img(-src => '/img/rhn-listicon-ok.gif',
					     -title => 'Channel admin status');
    }
    elsif ($row->{GLOBALLY_SUBSCRIBABLE}) {
      $row->{PERM_CHECKBOX} = PXT::HTML->img(-src => '/img/rhn-listicon-ok.gif',
					     -title => 'Globally subscribable channel');
    }
    else {
      $row->{PERM_CHECKBOX} = PXT::HTML->checkbox(-name => $row->{ID},
						  -checked => $row->{HAS_PERM});
      $row->{PERM_CHECKBOX} .= PXT::HTML->hidden(-name => "cid", -value => $row->{ID});
    }
  }

  return (%ret);
}

sub subscribe_perm_cb {
  return change_perms('subscribe', @_);
}

sub manage_perm_provider {
  my $self = shift;
  my $pxt = shift;

  my $uid = $pxt->param('uid');
  my $user = RHN::User->lookup(-id => $uid);

  die "no user" unless $user;

  my %ret = $self->default_provider($pxt, (-u_id => $uid));

  foreach my $row (@{$ret{data}}) {
    if ($user->is('channel_admin')) {
      $row->{PERM_CHECKBOX} = PXT::HTML->img(-src => '/img/rhn-listicon-ok.gif',
					     -title => 'Channel admin status');
    }
    else {
      $row->{PERM_CHECKBOX} = PXT::HTML->checkbox(-name => $row->{ID},
						  -checked => $row->{HAS_PERM});
      $row->{PERM_CHECKBOX} .= PXT::HTML->hidden(-name => "cid", -value => $row->{ID});
    }
  }

  return (%ret);
}

sub manage_perm_cb {
  return change_perms('manage', @_);
}

sub channel_entitlements_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $row (@{$ret{data}}) {
    my $avail;

    if (not defined $row->{MAX_MEMBERS}) {
      $avail = "(unlimited)";
    }
    else {
      $avail = $row->{MAX_MEMBERS} - $row->{CURRENT_MEMBERS};
    }

    $row->{AVAILABLE_SUBSCRIPTIONS} = $avail;
    $row->{MORE_INFO} = 'More Info';
  }

  return (%ret);
}

sub channel_tree {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;

  my %params = $self->lookup_params($pxt, $ds->required_params);
  my $data = $ds->execute_query(%params);

  my $alphabar = $self->init_alphabar($data);
  my @data = @{$self->filter_data($data)};

  my $package_list_edited = $pxt->session->get('package_list_edited');
  my @rows;

  my %seen_parents;
  foreach my $i (0 .. $#data) {
    my $channel = $data[$i];

    my $edited = $package_list_edited->{$channel->{ID}} || 0;

    $channel->{PACKAGE_LIST_MODIFIED} = ((time - $edited) < 600) ? 'Update Cache' : '';

    # if these two are the same, then it is a base channel, so we say we've seen it.
    if ($channel->{PARENT_OR_SELF_LABEL} eq $channel->{CHANNEL_LABEL}) {
      $seen_parents{$channel->{CHANNEL_LABEL}} = 1;
    }

    # uh oh, we have not seen your parent.  that is bad.
    if (exists $channel->{SHOW_ALL_RESULTS}) {
      if (not exists $seen_parents{$channel->{PARENT_OR_SELF_LABEL}}) {
        push @rows, { ID => '-1', NAME => "(no access to parent channel)",
		      CURRENT_MEMBERS => '', PACKAGE_LIST_MODIFIED => 0, PACKAGE_COUNT => '',
		      DEPTH => 1, NOLINK => 1};
      }
      push @rows, $channel;
    } else {
      if (exists $seen_parents{$channel->{PARENT_OR_SELF_LABEL}}) {
        push @rows, $channel;
      }
    }
  }

  $data = \@rows; # don't use @rows anymore, use $data instead.

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $self->lower(1);
  $self->upper(scalar @{$data});

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  return (data => $data,
	  all_ids => $all_ids);
}

# only increment when you go from one base channel to the next...
sub incr_row_counter {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  PXT::Debug->log(7, "row:  " . Data::Dumper->Dump([($row)]));

  if (not exists $row->{DEPTH} or ($row->{DEPTH} and $row->{DEPTH} eq 1)) {
    $self->SUPER::incr_row_counter($self, $row, $pxt);
  }
}

sub render_url {
  my $self = shift;
  my $pxt = shift;
  my $url = shift;
  my $row = shift;
  my $url_column = shift;

  if ($self->datasource->mode eq 'owned_channels_tree') {
    $url = ''
      unless (defined($row->{ORG_ID})
	      and $row->{ORG_ID} == $pxt->user->org_id
	      and $pxt->user->verify_channel_admin($row->{ID}));
  }
  else {
    if ($row->{$url_column} eq '0') {
      return '0';
    }
  }

  $url = ''
    if $row->{NOLINK};

  $url =~ s{\{column:(.*?)\}}{PXT::Utils->escapeURI($row->{uc "$1"})}ge;

  my $ret;
  if ($url) {
    $ret = sprintf("<a href=\"%s\">%s</a>", $url, $row->{$url_column});
  }
  else {
    $ret = $row->{$url_column};
  }

  my $depth = $row->{DEPTH} || 1;
  if ($url_column eq 'NAME' && $depth > 1) {
    $ret = '<img src="/img/branch.gif" alt="branch" />&#160;' . $ret;
  }

  return $ret;
}

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  $row->{SYSTEM_COUNT} ||= 0;

  return $row;
}

1;
