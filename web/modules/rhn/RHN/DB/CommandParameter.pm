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

package RHN::DB::CommandParameter;

use strict;
use Carp;
use RHN::DataSource::Simple;


our $VERSION = (split(/s+/, q$Id$, 4))[2];

# Hash of default values for instance construction
use constant INSTANCE_DEFAULTS => (
);




# Generated getter/setter methods (per Chip)
{

  my @fields = qw(
    command_id param_name param_type data_type_name description mandatory
    default_value min_value max_value field_order field_widget_name
    field_visible_length field_maximum_length field_visible
    default_value_visible
  );

  my $tmpl = q|
    sub [[field]] {
      my $self = shift;
      if (@_) {
        $self->{__[[field]]__} = shift;
      }
      return $self->{__[[field]]__};
    };
  |;

  foreach my $field (@fields) {

    (my $sub = $tmpl) =~ s/\[\[field\]\]/$field/g;

    eval $sub;

    croak $@ if($@);
  }

}


#########
sub new {
#########
  my $class = shift;
  my %args  = @_;
  my $self  = {};
  bless($self, $class);

  foreach my $arg (keys %args) {
    $self->$arg($args{$arg});
  }

  # Set defaults for values that weren't supplied to the constructor
  my %defaults = (INSTANCE_DEFAULTS);
  foreach my $field (keys %defaults) {
    $self->$field($defaults{$field}) unless(defined($self->$field()));
  }

  return $self;
}



1;

__END__
=head1 NAME

RHN::DB::CommandParameter - Monitoring command parameters

=head1 SYNOPSIS

  use RHN::DB::CommandParameter;
  
=head1 DESCRIPTION

RHN::DB::CommandParamter provides access to monitoring command
parameters (RHN_COMMAND_PARAMETER table).

=head1 SEE ALSO

L<RHN::DB::Command>

=head1 COPYRIGHT

Copyright (c) 2004-2005, Red Hat, Inc.  All rights reserved

=cut


