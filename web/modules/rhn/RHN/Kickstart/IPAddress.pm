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

package RHN::Kickstart::IPAddress;

# An IP Address.  stored as an int for easier troubleshooting and databasing.

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use overload # I, for one, welcome our new operator overloaders
  "<=>" => \&_op_cmp,
  "cmp" => \&_op_cmp,
  "==" => \&_op_eq,
  "<" => \&_op_lt,
  ">" => \&_op_gt,
  "<=" => \&_op_lte,
  ">=" => \&_op_gte,
  '""' => \&as_string;

# New takes an array of four values (0-255), or an int
sub new {
  my $class = shift;
  my @attr = @_;

  my $ip;

  if (scalar @attr == 4) {
    $ip = _encode(@attr);
  }
  elsif (scalar @attr == 1) {
    die "No ip address" unless (defined $attr[0]);

    if ($attr[0] =~ /\./) {
      $ip = _encode(split(/\./, $attr[0]));
    }
    else {
      $ip = $attr[0];
    }
  }
  else {
    die "No ip address";
  }

  my $self = bless \$ip, $class;

  return $self;
}

# Input the array version, return the int version.
sub _encode {
  my @ip = @_;

  return unpack("N", pack("C4", @ip));
}

# Input the int version, return the array version.
sub _decode {
  my $value = shift;

  return unpack("C4", pack("N", $value));
}

# return the int version
sub export {
  my $self = shift;

  return $$self;
}

# return the array version
sub value {
  my $self = shift;

  return _decode($$self);
}

# dotted quad
sub as_string {
  my $self = shift;

  return join(".", $self->value);
}

sub _op_eq {
  my ($ip1, $ip2) = validate_pos(@_, { isa => "RHN::Kickstart::IPAddress" }, { isa => "RHN::Kickstart::IPAddress" }, 0);

  return ($ip1->export == $ip2->export);
}

sub _op_lt {
  my ($ip1, $ip2) = validate_pos(@_, { isa => "RHN::Kickstart::IPAddress" }, { isa => "RHN::Kickstart::IPAddress" }, 0);

  return ($ip1->export < $ip2->export);
}

sub _op_lte {
  my ($ip1, $ip2) = validate_pos(@_, { isa => "RHN::Kickstart::IPAddress" }, { isa => "RHN::Kickstart::IPAddress" }, 0);

  return ($ip1 < $ip2 or $ip1 == $ip2);
}

sub _op_gt {
  my ($ip1, $ip2) = validate_pos(@_, { isa => "RHN::Kickstart::IPAddress" }, { isa => "RHN::Kickstart::IPAddress" }, 0);

  return ($ip1->export > $ip2->export);
}

sub _op_gte {
  my ($ip1, $ip2) = validate_pos(@_, { isa => "RHN::Kickstart::IPAddress" }, { isa => "RHN::Kickstart::IPAddress" }, 0);

  return ($ip1 > $ip2 or $ip1 == $ip2);
}

sub _op_cmp {
  my ($ip1, $ip2) = validate_pos(@_, { isa => "RHN::Kickstart::IPAddress" }, { isa => "RHN::Kickstart::IPAddress" }, 0);

  return (  ($ip1->export == $ip2->export) ? 0
          : ($ip1->export > $ip2->export) ? 1
          : -1
         );
}

1;
