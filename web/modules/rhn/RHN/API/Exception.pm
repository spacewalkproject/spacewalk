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
package RHN::API::Exception;

use RHN::API::ExceptionBox;

our @ISA = qw/RHN::Exception/;

our $global_exception_box;

sub exception_box {
  my $class = shift;

  $global_exception_box ||= new RHN::API::ExceptionBox;

  return $global_exception_box;
}

sub throw_named {
  my $class = shift;
  my $string = shift;
  my @extra = @_;

  my $box = $class->exception_box;

  my $exception = $class->new;

  # so, er have a named exception.  huzzah!  look it up.  if it fails,
  # mark it slightly different than arbitrary unhandled exception.

  my $exc = $box->lookup_by_label($string);
  if ($exc) {
    $exception->{fault_code} = $exc->{code};
    $exception->{fault_label} = $exc->{label};
    $exception->{fault_text} = "Named exception: (" . $exc->{label} . ")";
    if ($exc->{description}) {
      $exception->{fault_text} .= "\n\n" . $exc->{description};
    }
  }
  else {
    $exc = $box->lookup_by_label('unhandled_named_exception');
    $exception->{fault_code} = $exc->{code};
    $exception->{fault_label} = $exc->{label};
    $exception->{fault_text} = "Unhandled exception '$string' (" . ($exc->{label} || '') . ")";
  }

  if (@extra) {
    $exception->{fault_text} .= "\n" . join("\n", @extra);
  }

  $exception->SUPER::throw;
}

sub is_rhn_exception {
  my $self = shift;
  my $label = shift;

  return ($self->{fault_label} eq $label) ? 1 : 0;
}

sub fault_code {
  return (shift)->{fault_code};
}

sub fault_text {
  return (shift)->{fault_text};
}

# can it serialize into an xmlrpc fault?  why, yes, yes we can.
sub serialize_xmlrpc_fault {
  return 1;
}

1;
