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

package RHN::AppInstall::Instance;

use strict;

use RHN::DB::AppInstall::Instance;
our @ISA = qw/RHN::DB::AppInstall::Instance/;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

# Lookup the requested process by name.
# One of: qw/install install_in_progress config remove/
sub lookup_process {
  my $self = shift;
  my $process = shift;

  my $lookup_call = "get_${process}_process";

  if ($self->can($lookup_call)) {
    return $self->$lookup_call();
  }

  return;
}

1;
