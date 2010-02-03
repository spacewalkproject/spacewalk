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

package RHN::AppInstall::RequirementHandler;

use strict;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = ( requirement_registry => { type => HASHREF,
					       optional => 1 },
		   );

sub valid_fields {
  return %valid_fields;
}

sub new {
  my $class = shift;
  my %fields = $class->valid_fields();
  my %attr = validate(@_, \%fields);

  my $self = bless { map { ( $_, undef ) } keys(%fields),
		   }, $class;

  foreach (keys %attr) {
    my $func = "set_${_}";
    throw "Invalid function: $func"
      unless $self->can($func);

    $self->$func($attr{$_});
  }

  $self->_init();
  return $self;
}

sub _init {
  my $self = shift;

  $self->register_requirements();

  return;
}

sub register_requirements {
  my $self = shift;

  $self->add_requirement("system_entitled" => 'The system must be ${param} entitled');
  $self->add_requirement("system_entitlement_possible" => 'There must be at least one ${param} entitlement available');
  $self->add_requirement("package_available" => 'The ${param} package must be available');
  $self->add_requirement("client_capable" => 'The system must support the ${param} capability');

  return;
}

sub add_requirement {
  my $self = shift;
  my $requirement_name = shift;
  my $message = shift;

  if (exists $self->{requirement_registry}->{$requirement_name}) {
    throw "(requirement_exists) An requirement with the name '$requirement_name' already exists";
  }

  $self->{requirement_registry}->{$requirement_name} = $message;

  return;
}

sub check_requirement {
  my $self = shift;
  my $requirement = shift;
  my $session = shift;

  if (not exists $self->{requirement_registry}->{$requirement->get_name()}) {
    throw "(unknown_requirement) Could not find an requirement named '" . $requirement->get_name() . "' in $self";
  }

  if ($session->eval_acl($requirement->to_string)) {
    return 0;
  }

  my $arg = $requirement->get_argument();

  my $msg = $self->{requirement_registry}->{$requirement->get_name()};
  $msg =~ s/\$\{param\}/make_param_pretty($arg)/eg;

  return $msg;
}

my %param_subs = (
		  sw_mgr_entitled => 'Update',
		  enterprise_entitled => 'Management',
		  provisioning_entitled => 'Provisioning',
		  monitoring_entitled => 'Monitoring',
		  nonlinux_entitled => 'Non-Linux',
		 );

sub make_param_pretty {
  my $param = shift;

  return $param_subs{$param} || $param;
}

1;
