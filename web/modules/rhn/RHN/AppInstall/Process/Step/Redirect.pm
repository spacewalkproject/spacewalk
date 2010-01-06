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

package RHN::AppInstall::Process::Step::Redirect;

use strict;

use RHN::AppInstall::Process::Step;
our @ISA = qw/RHN::AppInstall::Process::Step/;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

# redirects can have either a single argument, or multiple named arguments

my %valid_fields = (url => 1,
		    save_session => 0,
		   );

sub valid_fields {
  my $class = shift;

  return ($class->SUPER::valid_fields(), %valid_fields);
}

sub get_url {
  my $self = shift;

  return $self->{url};
}

sub set_save_session {
  my $self = shift;
  my $save_session = shift;

  $self->{save_session} = $save_session;

  return;
}

#alternate getter
sub save_session {
  my $self = shift;

  return $self->{save_session};
}

1;
