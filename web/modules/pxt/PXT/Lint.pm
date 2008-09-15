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
package PXT::Lint;

use Data::Dumper;

my %calls;
sub swaddle_package {
  my $class = shift;
  my $package = shift;

  my $chash = eval "\\%${package}::";

  for my $func (grep { *{$chash->{$_}}{CODE} } keys %$chash) {
    my ($package, $name, $cref) = map { *{$chash->{$func}}{$_} } qw/PACKAGE NAME CODE/;

    # prevent warning of subroutine redefinition
    local $^W = 0;
    $calls{"${package}::${name}"} = 0;
    $chash->{$func} = sub { $calls{"${package}::${name}"}++; goto &$cref };
  }

  warn "Swaddled package: $package";
}

sub dump_empty_calls {
  my $class = shift;

  for my $func (sort grep { $calls{$_} == 0 } keys %calls) {
    warn "$func: $calls{$func}";
  }
}

1;
