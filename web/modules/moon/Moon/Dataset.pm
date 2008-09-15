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

package Moon::Dataset;

use strict;

my $VERSION = '0.02';

#gaurunteed interfaces:

sub new { die "sub new should never be called in Moon::Dataset" }
sub min_x { die "sub min_x should never be called in Moon::Dataset" }
sub max_x { die "sub max_x should never be called in Moon::Dataset" }
sub value_at { die "sub value_at should never be called in Moon::Dataset" }

1;

__END__
# Below is stub documentation for your module. You better edit it!
# Nag, nag nag...

=head1 NAME

Moon::Dataset - Implementation of a Dataset parent class for use with RHN Monitoring.

=head1 SYNOPSIS

This is just a virtual parent class - see Moon::Dataset::Coordinate or Moon::Dataset::Function

=head1 DESCRIPTION

Provides a set of data - also interpolation, sampling and perhaps statistical analysis for use with the Spacewalk monitoring code.

=head2 EXPORT

No.

=head1 AUTHOR

Spacewalk Team <rhn-feedback@redhat.com>

=head1 SEE ALSO

rhn.redhat.com

L<perl>.

=cut
