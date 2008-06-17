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
package RHN::API::Types;

use RHN::Session;
use RHN::Server;

use RHN::Exception qw/throw/;

sub register_default_types {
  my $class = shift;
  my $api = shift;

  $api->register_type(id => \&RHN::API::Types::validate_id);

  $api->register_type(string => \&RHN::API::Types::validate_string);
  $api->register_type(session => \&RHN::API::Types::validate_session);
  $api->register_type(integer => \&RHN::API::Types::validate_integer);
  $api->register_type(double => \&RHN::API::Types::validate_double);
  $api->register_type(boolean => \&RHN::API::Types::validate_boolean);
  $api->register_type(date => \&RHN::API::Types::validate_date);

  $api->register_type(hash => \&RHN::API::Types::validate_hash);
  $api->register_type(list => \&RHN::API::Types::validate_list);

  $api->register_type(user => \&RHN::API::Types::validate_user);
  $api->register_type(system => \&RHN::API::Types::validate_system);

  $api->register_mangler("session", "session_user", \&RHN::API::Types::session_user_mangler);
  $api->register_mangler("id", "objectify_system", \&RHN::API::Types::objectify_system_mangler);
  $api->register_mangler("string", "objectify_errata", \&RHN::API::Types::objectify_errata_mangler);
  $api->register_mangler("id", "objectify_system_group", \&RHN::API::Types::objectify_system_group_mangler);
  $api->register_mangler("id", "objectify_system_snapshot", \&RHN::API::Types::objectify_system_snapshot_mangler);
  $api->register_mangler("id", "objectify_stored_profile", \&RHN::API::Types::objectify_stored_profile_mangler);
  $api->register_mangler("id", "objectify_kickstart_profile", \&RHN::API::Types::objectify_kickstart_profile_mangler);
  $api->register_mangler("string", "objectify_activation_key", \&RHN::API::Types::objectify_activation_key_mangler);
  $api->register_mangler("string", "objectify_system_id", \&RHN::API::Types::objectify_systemid_mangler);
  $api->register_mangler("string", "objectify_login", \&RHN::API::Types::objectify_login_mangler);
  $api->register_mangler("string", "objectify_channel", \&RHN::API::Types::objectify_channel_mangler);
  $api->register_mangler("id", "objectify_package", \&RHN::API::Types::objectify_package_mangler);
}

sub validate_id {
  return validate_integer(@_);
}

sub validate_session {
  my $value = shift;

  return $value =~ /^[0-9a-f]+x[0-9a-f]+$/;
}

sub validate_integer {
  my $value = shift;

  # FIXME:  insufficient check for <i4 /> ?
  return $value =~ /^\d+$/;
}

sub validate_double {
  my $value = shift;

  # FIXME:  insufficient check for <double /> ?
  return $value =~ /^\d+\.?\d*$/;
}

sub validate_string {
  return 1;
}

sub validate_boolean {
  my $value = shift;

  throw "no value?" unless defined $value;

  return 1 if defined $value and ($value == 0 or $value == 1);

  return 0;
}

sub validate_date {
  my $value = shift;

  return $value =~ /^\d\d\d\d-\d\d-\d\d [0-2][0-9]\:[0-5][0-9]\:[0-5][0-9]$/;
}

sub validate_hash {
  my $value = shift;

  return 1 if ref($value) eq 'HASH';

  return 0;
}

sub validate_list {
  my $value = shift;

  return 1 if ref($value) eq 'ARRAY';

  return 0;
}

sub validate_user {
  my $value = shift;
}

sub validate_system {
  my $value = shift;
}

sub session_user_mangler {
  my $value = shift;

  my $session = RHN::Session->load($value);
  RHN::API::Exception->throw_named("invalid_session") unless $session->uid;

  return RHN::User->lookup(-id => $session->uid);
}

sub objectify_system_mangler {
  my $value = shift;
  my $system;
  eval {
      $system = RHN::Server->lookup(-id => $value);
  };
  if ($@) {
      my $E = $@;

      if (ref $E and $E->is_rhn_exception('server_does_not_exist')) {
          RHN::API::Exception->throw_named("no_such_system");
      }
  }

  return $system;
}

sub objectify_package_mangler {
  my $value = shift;
  my $package;

  eval {
      $package = RHN::Package->lookup(-id => $value);
  };
  if ($@) {
      RHN::API::Exception->throw_named("no_such_package");
  }

  return $package;
}

sub objectify_system_group_mangler {
  my $value = shift;

  my $group = RHN::ServerGroup->lookup($value);
  RHN::API::Exception->throw_named("no_such_system_group") unless $group;

  return $group;
}

sub objectify_system_snapshot_mangler {
  my $value = shift;

  my $snapshot = RHN::SystemSnapshot->lookup_snapshot($value);
  RHN::API::Exception->throw_named("no_such_system_snapshot") unless $snapshot;

  return $snapshot;
}

sub objectify_stored_profile_mangler {
  my $value = shift;

  my $profile = RHN::Profile->lookup($value);
  RHN::API::Exception->throw_named("no_such_stored_profile") unless $profile;

  return $profile;
}

sub objectify_kickstart_profile_mangler {
  my $value = shift;

  my $ks_profile = RHN::Kickstart->lookup(-id => $value);
  RHN::API::Exception->throw_named("no_such_kickstart_profile") unless $ks_profile;

  return $ks_profile;
}

sub objectify_activation_key_mangler {
  my $value = shift;

  my $key = RHN::Token->lookup_token(-token => $value);
  RHN::API::Exception->throw_named("no_such_activation_key") unless $key;

  return $key;
}

sub objectify_systemid_mangler {
  my $value = shift;

  my $system; 
  eval {
      $system = RHN::Server->lookup_by_cert($value);
  };
  if ($@) {
      my $E = $@;
      if (ref $E and $E->is_rhn_exception('server_does_not_exist')) {
          RHN::API::Exception->throw_named("no_such_system");
      }
      else {
          RHN::API::Exception->throw_named("problem_parsing_cert");
      }
  }

  return $system;
}

sub objectify_login_mangler {
  my $value = shift;

  my $user = RHN::User->lookup(-username => $value);
  RHN::API::Exception->throw_named("no_such_user") unless $user;

  return $user;
}

sub objectify_errata_mangler {
  my $value = shift;

  my ($type, $version) = split /[-]/, $value;
  my @errata = RHN::Errata->find_by_advisory(-type => $type, -version => $version);

  RHN::API::Exception->throw_named("no_such_errata") unless @errata;

  return RHN::Errata->lookup(-id => $errata[0][0]);
}


sub objectify_channel_mangler {
  my $value = shift;

  my $id = RHN::Channel->channel_id_by_label($value);
  my $channel = RHN::Channel->lookup(-id => $id);
  RHN::API::Exception->throw_named("no_such_channel") unless $channel;

  return $channel;
}


1;
