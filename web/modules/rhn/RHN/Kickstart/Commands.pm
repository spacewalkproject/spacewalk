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

package RHN::Kickstart::Commands;
use RHN::SimpleStruct;

our @ISA = qw/RHN::SimpleStruct/;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::Kickstart::Partitions;
use RHN::Kickstart::Raids;
use RHN::Kickstart::Logvols;
use RHN::Kickstart::Include;
use RHN::Kickstart::Volgroups;
use RHN::Kickstart::Password;

my %valid_commands = (autostep => { optional => 1,
                                    args => 0,
                                  },
                      auth => { optional => 0,
                                args => 1,
                              },
                      bootloader => { optional => 0,
                                      args => 1,
                                    },
                      cdrom => { optional => 1,
                                 args => 0,
                               },
                      clearpart => { optional => 1,
                                     args => 1,
                                   },
                      device => { optional => 1,
                                  args => 1,
                                },
                      deviceprobe => { optional => 1,
                                       args => 0,
                                     },
                      driverdisk => { optional => 1,
                                      args => 1,
                                    },
                      firewall => { optional => 1,
                                    args => 1,
                                  },
                      harddrive => { optional => 1,
                                     args => 1,
                                   },
                      install => { optional => 1,
                                   args => 0,
                                 },
                      interactive => { optional => 1,
                                       args => 0,
                                     },
                      keyboard => { optional => 0,
                                    args => 1,
                                  },
                      lang => { optional => 0,
                                args => 1,
                              },
                      langsupport => { optional => 0,
                                       args => 1,
                                     },
                      lilocheck => { optional => 1,
                                     args => 0,
                                   },
                      mouse => { optional => 0,
                                 args => 1,
                               },
                      network => { optional => 1,
                                   args => 1,
                                 },
                      nfs => { optional => 1,
                               args => 1,
                             },
                      partitions => { optional => 1,
                                      isa => 'RHN::Kickstart::Partitions',
                                      args => 1,
                                    },
                      volgroups => { optional => 1,
                                    isa => 'RHN::Kickstart::Volgroups',
                                    args => 1,
                                  },
                      logvols => { optional => 1,
                                  isa => 'RHN::Kickstart::Logvols',
                                  args => 1,
                                },
                      raids => { optional => 1,
                                 isa => 'RHN::Kickstart::Raids',
                                 args => 1,
                              },
                      include => { optional => 1,
                                 isa => 'RHN::Kickstart::Include',
                                 args => 1,
                              },
                      key => { optional => 1,
                                 args => 1,
                              },                              
                      reboot => { optional => 1,
                                  args => 0,
                                },
                      repo => { optional => 1,
                                  args => 2,
                                },                              
                      rootpw => { optional => 0,
                                  args => 1,
                                },
                      selinux => { optional => 1,
                                   args => 1,
                                 },
                      skipx => { optional => 1,
                                 args => 0,
                               },
                      text => { optional => 1,
                                args => 0,
                              },
                      timezone => { optional => 0,
                                    args => 1,
                                  },
                      upgrade => { optional => 1,
                                   args => 0,
                                 },
                      url => { optional => 1,
                               args => 1,
                             },
                      xconfig => { optional => 1,
                                   args => 1,
                                 },
                      zerombr => { optional => 1,
                                   args => 1,
                                 },
                     );

our @simple_struct_fields = keys %valid_commands;

my @output_order = qw/autostep interactive _linebr_ install upgrade
lilocheck text _linebr_ network _linebr_ cdrom harddrive nfs url
_linebr_ lang langsupport keyboard mouse _linebr_ device deviceprobe
driverdisk _linebr_ zerombr clearpart _linebr_ partitions raids include volgroups logvols
_linebr_ bootloader timezone auth rootpw selinux firewall skipx reboot
xconfig/;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  my %params = validate(@_, \%valid_commands);

  foreach my $param (keys %params) {
    $self->$param($params{$param});
  }

  return $self;
}

# override rootpw so we can encrypt it
sub rootpw {
  my $self = shift;
  my $word = shift;

  if ($word) {
    if (ref $word ne 'RHN::Kickstart::Password') {
      if (ref $word eq 'ARRAY') {
        ($word) = $word->[0];
      }
      $word = RHN::Kickstart::Password->new($word);
    }

    $self->SUPER::rootpw($word);
  }

  return $self->SUPER::rootpw();
}

sub render {
  my $self = shift;

  my @ret;

  foreach my $field (@output_order) {
    if ($field eq '_linebr_') {
      push(@ret, '');
      next;
    }

    my $value = $self->render_command($field);
    if ($value) {
      unless (grep { $field eq $_ } qw/rootpw partitions raids volgroups logvols include/) {
        $value = $field . " " . $value;
      }
    }
    elsif (defined $value) {
      $value = $field;
    }
    else {
      next;
    }

    push @ret, $value;
  }

  return join("\n", @ret) . "\n";
}

sub render_command {
  my $self = shift;
  my $field = shift;

  if ($field eq '_linebr_') {
    return '';
  }

  my $value = $self->$field();

  return undef if (not defined $value);

  if (not ref $value) {
    return $value;
  }
  elsif (ref $value eq 'ARRAY') {
    return join(" ", @{$value});
  }
  elsif ($value->can('render')) {
    return $value->render;
  }
  else {
    die "I don't know what to do with value '$value' from field '$field'";
  }
}

sub export {
  my $self = shift;

  my @ret;

  foreach my $field (@output_order) {
    next
      if ($field eq '_linebr_');

    my $value = $self->$field();

    next if (not defined $value);

    if (not ref $value) {
      if ($value) {
        push @ret, [$field, $value];
      }
      else {
        push @ret, [$field, undef];
      }
    }
    elsif (ref $value eq 'ARRAY') {
      push @ret, [$field, join(" ", @{$value})];
    }
    elsif ($value->can('export')) {
      my @rows = $value->export;
      foreach my $row ($value->export) {
        push @ret, [ $field, $row ];
      }
    }
    else {
      die "I don't know what to do with value '$value' from field '$field'";
    }
  }

  return @ret;
}

sub set {
  my $self = shift;
  my $field = shift;
  my @args = @_;

  @args = split(/\s+/, join(' ', @args));
  @args = grep { $_ !~ qr/$field/ } @args;

  $self->$field(\@args);
  
  return;
}

sub valid_commands {
  my $class = shift;

  return \%valid_commands;
}

sub output_order {
  my $class = shift;

  return @output_order;
}

1;
