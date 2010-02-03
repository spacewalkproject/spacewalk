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

package RHN::AppInstall::ActionHandler::ActionRunner;

use strict;

use RHN::AppInstall::ActionHandler;

our @ISA = qw/RHN::AppInstall::ActionHandler/;

use RHN::ConfigChannel;

use RHN::Exception;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use File::Spec;

my %valid_fields = ( );

sub valid_fields {
  my $class = shift;
  return ($class->SUPER::valid_fields(), %valid_fields);
}

sub register_actions {
  my $self = shift;

  $self->add_action("set-system-entitlement" => \&set_system_entitlement);
  $self->add_action("subscribe-system-to-software-channel-with-package" =>
		    \&subscribe_system_to_software_channel_with_package);
  $self->add_action("create-config-channel" => \&create_config_channel);
  $self->add_action("subscribe-system-to-config-channel" =>
		    \&subscribe_system_to_config_channel);
  $self->add_action("generate-config-file" => \&generate_config_file);
  $self->add_action("method-call" => \&method_call);

  return;
}

sub set_system_entitlement {
  my $session = shift;
  my $entitlement = shift;

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions();

  unless ( $session->get_server->has_entitlement($entitlement)) {
    eval {
      $session->get_server->entitle_server($entitlement);
    };
    if ($@) {
      $transaction->nested_rollback();

      my $E = $@;
      if (ref $E and catchable($E) and $E->is_rhn_exception('servergroup_max_members')) {
	return "You do not have enough '$entitlement' entitlements to continue";
      }

      throw $E;
    }
  }

  $transaction->nested_commit();

  return 0;
}

sub subscribe_system_to_software_channel_with_package {
  my $session = shift;
  my $package_name = shift;

  my $ds = new RHN::DataSource::Simple(-querybase => "Package_queries",
				       -mode => "latest_package_in_channel_tree");
  my @packages = @{$ds->execute_query(-user_id => $session->user->id,
				      -cid => $session->get_server->base_channel_id,
				      -package_name => $package_name )};

  if (not @packages) {
    return "Package '$package_name' not found for server '" . $session->get_server->id . "'\n";
  }

  my %by_channel = map { ($_->{CHANNEL_ID}, $_->{PACKAGE_ID}) } @packages;
  my @server_channels = $session->get_server->server_channels();

  # If the system is already subscribed to a channel with the package,
  # then we don't need to do anything.
  unless (grep { $by_channel{$_->{ID}} } @server_channels) {
    # For now just pick the first channel - the case where a package
    # is in more than one channel should be rare enough to ignore for
    # now.
    my ($target) = keys %by_channel;
    my $channel = RHN::Channel->lookup(-id => $target);

    eval {
      $session->get_server->subscribe_to_channel($target);
    };
    if ($@) {
      my $E = $@;
      if (ref $E and catchable($E) and $E->is_rhn_exception('channel_family_no_subscriptions')) {
	return "Not enough subscriptions for required channel '" . $channel->name . "'\n";
      }

      throw $E;
    }
  }

  return 0;
}

sub create_config_channel {
  my $session = shift;
  my %params = validate(@_, { org_id => 1,
			      type => { type => SCALAR,
					default => 'normal' },
			      name => 1,
			      label => 1,
			      description => 1 });

  my $existing_channel;

  eval {
    $existing_channel = RHN::ConfigChannel->lookup(-org_id => $params{org_id},
						   -label => $params{label},
						  );
  };
  if ($@) {
    throw $@ unless ($@ =~ /No config_channel/);
  }

  return 0 if ($existing_channel);

  my $config_channel = RHN::ConfigChannel->create_config_channel();
  $config_channel->$_($params{$_}) foreach (qw/org_id name label description/);

  eval {
    $config_channel->set_type($params{type});
  };
  if ($@) {
    my $E = $@;
    if (ref $E and catchable($E) and $E->is_rhn_exception('invalid_configchannel_type')) {
      return "Invalid config channel type '$params{type}'\n";
    }

    throw $E;
  }

  $config_channel->commit;

  return 0;
}

sub subscribe_system_to_config_channel {
  my $session = shift;
  my %params = validate(@_, { channel_label => 1,
			      order => { default => 'first' },
			    });

  my $target_channel = RHN::ConfigChannel->lookup(-org_id => $session->get_user->org_id,
						  -label => $params{channel_label},
						 );

  my @channels = map { $_->{ID} }
    grep { $_->{TYPE} eq 'normal' and $_->{ID} != $target_channel->id }
      $session->get_server->config_channels();

  if ($params{order} eq 'first') {
    unshift @channels, $target_channel->id;
  }
  elsif ($params{order} eq 'last') {
    push @channels, $target_channel->id;
  }
  else {
    throw "(appinstall:parameter_error) Parameter 'order' must be 'first' or 'last'";
  }

  $session->get_server->set_normal_config_channels(-server_ids => [ $session->get_server->id ],
						   -config_channel_ids => \@channels);

  return 0;
}

sub generate_config_file {
  my $session = shift;
  my %params = validate(@_, { target_config_channel => 1,
			      path => 1,
			      template => 1,
			      binary => { default => 0 },
			      username => { default => 'root' },
			      groupname => { default => 'root' },
			      mode => { default => '770' },
			      new_only => { default => 0 },
			      selinux_ctx => { default => '' },
			    });

  my $template_file = File::Spec->catfile($session->get_app_instance->get_app_dir(), $params{template});
  my $contents;

  $contents = RHN::Utils->read_file($template_file);
  $session->perform_substitutions(\$contents);

  my $cc = RHN::ConfigChannel->lookup(-org_id => $session->user->org_id, label => $params{target_config_channel});
  my $exists = $cc->find_file_existence($params{path});

  if ($params{new_only} and $exists) {
    return;
  }

  my $cfid = $cc->vivify_file_existence($params{path});

  my $new_revision = new RHN::ConfigRevision;
  $new_revision->config_file_id($cfid);
  $new_revision->path($params{path});

  if ($params{binary}) {
    $new_revision->is_binary(1);
  }
  else {
    $new_revision->is_binary(0);
  }

  $new_revision->delim_start(PXT::Config->get('config_delim_start'));
  $new_revision->delim_end(PXT::Config->get('config_delim_end'));
  $new_revision->username($params{username});
  $new_revision->groupname($params{groupname});
  $new_revision->filemode($params{mode});
  $new_revision->contents($contents);
  $new_revision->selinux_ctx($params{selinux_ctx});

  eval {
    $new_revision->commit;
  };
  if ($@) {
    my $E = $@;

    if ($E->is_rhn_exception('not_enough_quota')) {
      throw "(appinstall:not_enough_quota) Storing the needed configuration files would exceed your configuration quota.";
    }

    throw $E;
  }

  return 0;
}

sub method_call {
  my $session = shift;
  my %params = @_;

  throw "(appinstall:parameter_error) The 'class' parameter is required for method calls."
    unless $params{class};
  throw "(appinstall:parameter_error) The 'method' parameter is required for method calls."
    unless $params{method};

  my $class = delete $params{class};
  my $method = delete $params{method};

  eval "require $class";
  if ($@) {
    throw "(class_not_found) Could not require '$class': $@";
  }

  return $class->$method(%params, -session => $session);
}

1;
