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

package RHN::ContactMethod;

use RHN::DB::ContactMethod;
use RHN::DB;

our @ISA = qw/RHN::DB::ContactMethod/;


1;

__END__
=head1 NAME

RHN::ContactMethod - Wrapper class for RHN::DB::ContactMethod

=head1 DESCRIPTION

Wrapper class for RHN::DB::ContactMethod.  This wrapper decorates
RHN::DB::ContactMethod with methods that provide a more intuitive
API to some of the underlying data.

=head1 SEE ALSO

L<RHN::DB::ContactMethod>

=head1 COPYRIGHT

Copyright (c) 2004-2005, Red Hat, Inc.  All rights reserved

=cut
