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

package RHN::AppInstall::ActionHandler::ActionScheduler;

use strict;

use RHN::AppInstall::ActionHandler;

our @ISA = qw/RHN::AppInstall::ActionHandler/;

use RHN::Scheduler;

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

  $self->add_action("install-packages" => \&install_packages);
  $self->add_action("remove-packages" => \&remove_packages);
  $self->add_action("deploy-configs" => \&deploy_configs);
  $self->add_action("run-script" => \&run_script);
  $self->add_action("restart-services" => \&restart_services);
  $self->add_action("start-services" => \&start_services);
  $self->add_action("stop-services" => \&stop_services);

  return;
}

sub install_packages {
  my $session = shift;
  my %params = validate(@_, { earliest => { default => time() },
			      prerequisite => 0,
			      action_name => 0,
			      rpm => 1,
                              force => 0,
			    });

  my $scheduled_time = RHN::Date->new(-epoch => $params{earliest})->long_date();

  my %packages;

  if (ref $params{rpm} eq 'ARRAY') {
    %packages = map { ($_, undef) } @{$params{rpm}};
  }
  else {
    %packages = ($params{rpm}, undef);
  }

  my $ds = new RHN::DataSource::Package(-mode => 'system_all_available_packages');
  my %ids_by_name = map { ($_->{NAME}, $_->{REAL_ID}) } @{$ds->execute_query(-sid => $session->get_server->id)};
  my $ds_new_pckg = new RHN::DataSource::Package(-mode => 'system_newest_available_package');

  foreach my $name (keys %packages) {
    if (not exists $ids_by_name{$name}) {
      my %id_by_pckg_name = map { ($name, $_->{REAL_ID}) } @{$ds_new_pckg->execute_query(-sid => $session->get_server->id, -name => $name)};
      if ($session->get_server->version_of_package_installed($name) and not $params{'force'}) {
        delete $packages{$name};
      } elsif ($id_by_pckg_name{$name} and $params{'force'}) {
	$packages{$name} = $id_by_pckg_name{$name};
      }
      else {
	throw "(appinstall:package_not_found) The '$name' package was not available to system '"
	  . $session->get_server->id . "'";
      }
    }
    else {
      $packages{$name} = $ids_by_name{$name};
    }
  }

  my %package_install_params;

  if (values %packages > 1) {
    $package_install_params{-package_ids} = [ values %packages ];
  }
  elsif (values %packages == 1) {
    ($package_install_params{-package_id}) = values %packages;
  }
  else {
    return;
  }

  my $install_aid = RHN::Scheduler->schedule_package_install(-org_id => $session->user->org_id,
							     -user_id => $session->user->id,
							     -earliest => $scheduled_time,
							     -server_id => $session->get_server->id,
							     -action_name => $params{action_name},
							     -prerequisite => $params{prerequisite},
							     %package_install_params,
							    );

  return $install_aid;
}

sub remove_packages {
  my $session = shift;
  my %params = validate(@_, { earliest => { default => time() },
			      prerequisite => 0,
			      action_name => 0,
			      rpm => 1,
			    });

  my $scheduled_time = RHN::Date->new(-epoch => $params{earliest})->long_date();

  my %packages;

  if (ref $params{rpm} eq 'ARRAY') {
    %packages = map { ($_, undef) } @{$params{rpm}};
  }
  else {
    %packages = ($params{rpm}, undef);
  }

  my $ds = new RHN::DataSource::Package(-mode => 'system_canonical_package_list');
  my %ids_by_name = map { ($_->{NAME}, $_->{ID}) } @{$ds->execute_query(-sid => $session->get_server->id,
								        -org_id => $session->get_user->org_id)};

  foreach my $name (keys %packages) {
    if (not exists $ids_by_name{$name}) {
      delete $packages{$name};
    }
    else {
      $packages{$name} = $ids_by_name{$name};
    }
  }

  my %package_remove_params;

 if (values %packages) {
    $package_remove_params{-package_id_combos} = [ values %packages ];
  }
  else {
    return;
  }

  my $remove_aid = RHN::Scheduler->schedule_package_remove(-org_id => $session->user->org_id,
							   -user_id => $session->user->id,
							   -earliest => $scheduled_time,
							   -server_id => $session->get_server->id,
							   -action_name => $params{action_name},
							   -prerequisite => $params{prerequisite},
							   %package_remove_params,
							  );

  return $remove_aid;
}

sub deploy_configs {
  my $session = shift;
  my %params = validate(@_, { earliest => { default => time() },
			      prerequisite => 0,
			      action_name => 0,
			      configfile => 1,
			    });

  my @configfile_names;
  my @revision_ids;

  if (ref $params{configfile} eq 'ARRAY') {
    @configfile_names = @{$params{configfile}};
  }
  else {
    @configfile_names = ($params{configfile});
  }

  my %system_files_by_path = map { ($_->{PATH}, $_) } $session->get_server->get_resolved_files();

  foreach my $path (@configfile_names) {
    if (not exists $system_files_by_path{$path}) {
      throw "(appinstall:configfile_not_found) The '$path' config file was not available to system '"
	. $session->get_server->id . "'";
    }
    else {
      push @revision_ids, $system_files_by_path{$path}->{ID};
    }
  }

  my $scheduled_time = RHN::Date->new(-epoch => $params{earliest})->long_date();

  my ($deploy_aid) = RHN::Scheduler->schedule_config_action(-org_id => $session->user->org_id,
							    -user_id => $session->user->id,
							    -earliest => $scheduled_time,
							    -server_id => $session->get_server->id,
							    -action_type => 'configfiles.deploy',
							    -action_name =>
							      $params{action_name} || 'Configuration deploy',
							    -revision_ids => \@revision_ids,
							    -prerequisite => $params{prerequisite},
							   );

  return $deploy_aid;
}

sub run_script {
  my $session = shift;
  my %params = validate(@_, { earliest => { default => time() },
			      prerequisite => 0,
			      action_name => 0,
			      script => 1,
			      username => { default => 'root' },
			      groupname => { default => 'root' },
			      timeout => { default => 600 },
			    });

  my $scheduled_time = RHN::Date->new(-epoch => $params{earliest})->long_date();
  my $script_aid = RHN::Scheduler->schedule_remote_command(-org_id => $session->user->org_id,
							   -user_id => $session->user->id,
							   -server_id => $session->get_server->id,
							   -earliest => $scheduled_time,
							   -action_name => $params{action_name},
							   -script => $params{script},
							   -username => $params{username},
							   -group => $params{groupname},
							   -timeout => $params{timeout},
							   -prerequisite => $params{prerequisite},
							  );

  return $script_aid;
}

sub restart_services {
  my $session = shift;
  my %params = validate(@_, { earliest => { default => time() },
			      prerequisite => 0,
			      action_name => 0,
			      service => 1,
			    });

  return do_services_command($session, %params, -service_command => 'restart');
}

sub start_services {
  my $session = shift;
  my %params = validate(@_, { earliest => { default => time() },
			      prerequisite => 0,
			      action_name => 0,
			      service => 1,
			    });

  return do_services_command($session, %params, -service_command => 'start');
}

sub stop_services {
  my $session = shift;
  my %params = validate(@_, { earliest => { default => time() },
			      prerequisite => 0,
			      action_name => 0,
			      service => 1,
			    });

  return do_services_command($session, %params, -service_command => 'stop');
}

sub do_services_command {
  my $session = shift;
  my %params = validate(@_, { earliest => { default => time() },
			      prerequisite => 0,
			      action_name => 0,
			      service => 1,
			      service_command => 1,
			    });

  my @services;

  if (ref $params{service} eq 'ARRAY') {
    @services = @{$params{service}};
  }
  else {
    @services = ($params{service});
  }

  my $script =<<EOQ;
#!/bin/sh

EOQ

  my $command = $params{service_command};

  # This is the way we do it until we have services management
  $script .= join("\n", map { "/sbin/service $_ $command" } @services);

  delete $params{service};
  delete $params{service_command};
  my $script_aid = run_script($session, %params, -script => $script);

  return $script_aid;

}

1;
