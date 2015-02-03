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

package RHN::Kickstart::Password;

use PXT::Utils;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

# a simple class to represent the password, and output it as a md5 hash

sub new {
  my $class = shift;
  my @vals = @_;

  my $word = @vals ? encrypt_password(@vals) : '';

  my $self = bless \$word, $class;

  return $self;
}

sub encrypt_password {
  my @vals = @_;
  my $word;

  foreach my $val (@vals) {
    next if ($val =~ /--iscrypted/);
    $word = $val;
  }

  if (not $word =~ /\$1\$/) {
    my $salt = '$1$' . PXT::Utils->generate_salt(8);
    $word = crypt($word, $salt);
  }

  return $word;
}

sub password {
  my $self = shift;
  my @vals = @_;

  if (@vals) {
    $$self = encrypt_password(@vals);
  }

  return $$self;
}

sub render {
  my $self = shift;

  my $word = $self->password;
  my $opt = '--iscrypted ';

  return "rootpw ${opt}${word}";
}

sub export {
  my $self = shift;

  return $$self;
}

1;

