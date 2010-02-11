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

package RHN::AppInstall::Process::Step::Requirements;

use strict;

use RHN::AppInstall::Process::Step;
our @ISA = qw/RHN::AppInstall::Process::Step/;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (requirements => { type => ARRAYREF,
				      default => [],
				    },
		   );

sub valid_fields {
  my $class = shift;
  return ($class->SUPER::valid_fields(), %valid_fields);
}

sub push_requirement {
  my $self = shift;
  my @requirements = @_;

  foreach my $requirement (@requirements) {
    throw "(set_error) $requirement is not an RHN::AppInstall::ACL"
      unless (ref $requirement and $requirement->isa('RHN::AppInstall::ACL'));
  }

  push @{$self->{requirements}}, @requirements;

  return;
}

sub pop_requirement {
  my $self  = shift;

  return if (not @{$self->{requirements}});
  return pop @{$self->{requirements}};
}

1;
