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

package RHN::GPG;
use PXT::Utils;

# some GnuPG's complain about POSIX symbols.

use POSIX;
use PXT::Config;
use File::Temp qw/tempfile/;


our $default_class = undef;

sub AUTOLOAD {
  our $AUTOLOAD;
  my $function = $AUTOLOAD;

  if (not defined $default_class) {
    $default_class = PXT::Config->get('rhn_gpg_backend_module');
  }

  if ($function =~ /^(.*)::([^:]+)$/) {
    my ($class, $method) = ($1, $2);
    PXT::Utils->untaint(\$default_class);
    eval "require $default_class";
    die $@ if $@;
    my $old_class = shift;
    return $default_class->$method(@_);
  }
  else {
    die "bad func? $function";
  }
}

1;
