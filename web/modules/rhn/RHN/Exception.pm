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

package RHN::Exception;

use Exporter;
use Data::Dumper;

use strict;

our @ISA = qw/Exporter/;
our @EXPORT = qw/throw rethrow catchable/;

use overload '""' => \&as_string;

sub new {
  my $class = shift;

  my $self = bless { }, $class;

  # dash params?
  if ($_[0] and $_[0] =~ /^-/) {
    %$self = @_;
  }
  else {
    $self->{-text} = shift;
    $self->{-severity}="unhandled" unless $self->{-severity} = shift;
  }

  $self->{-trace} = obj_stack_trace();

  return $self;
}

sub as_string {
  my $self = shift;

  my $trace = $self->stack_trace || '';

  if ($self->{-query}) {
    return sprintf("RHN::Exception: %s\n%s\nOffending Query: %s\n", $self->fault_text || "(none)", $trace, $self->{-query});
  }
  else {
    return sprintf("RHN::Exception: %s\n%s", $self->fault_text || "(none)", $trace);
  }
}

sub value {
  return $_[0]->{-value};
}

sub catchable {
  my $E = shift;

  if ($E and ref $E and $E->isa('RHN::Exception')) {
    return 1;
  }

  return;
}

sub is_rhn_exception {
  my $self = shift;
  my $label = shift;

  return $self->{-text} =~ /\(([^.]+\.)?$label\)/;
}

sub fault_text {
  my $self = shift;

  return $self->{-text};
}

sub constraint_value {
  my $self = shift;

  if ($self->{-oracle_error}) {
    if ($self->{-oracle_error}->[1] =~ /^.*?\(.*?\.(.*?)\)/) {
      return $1;
    }
    else {
      return "";
    }
  }
  else {
    return "";
  }
}

sub throw {
  if ($_[0] and ref $_[0] and $_[0]->isa("RHN::Exception")) {
    die $_[0];
  }

  my $self = new RHN::Exception(@_);

  die $self;
}

sub rethrow {
  my $self = shift;
  die $self;
}

sub stack_trace {
  my $self = shift;

  my $ret;
  $ret .= "  @{$_}[0, 1, 2, 3]\n" foreach @{$self->{-trace}};

  return $ret;
}

sub obj_stack_trace {
  my $i = 2;

  my @ret;
  while ($i < 99) {
    my @s = caller($i++);
    push @ret, [ @s ] if $s[0];
  }

  return [ @ret ];
}

package RHN::Exception::DB;
our @ISA = qw/RHN::Exception/;

sub throw {
  my $class = shift;

  my $exception = $class->new(@_);
  $exception->SUPER::throw;
}

1;
