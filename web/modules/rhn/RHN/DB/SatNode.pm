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

package RHN::DB::SatNode;

use strict;
use Carp;

our $VERSION = (split(/s+/, q$Id$, 4))[2];

# Hash of default values for instance construction
use constant INSTANCE_DEFAULTS => (
  sput_log_level => 3,
  max_concurrent_checks => 10,
  sched_log_level => 1,
  dq_log_level => 1,
);

# 
# Notes:
#   - TARGET_TYPE should always be 'NODE'.
#   - MAC_ADDRESS might be gleaned from the sat cluster's RHN server
#     hardware info.



# Generated getter/setter methods (per Chip)
{

  my @fields = qw(
    recid mac_address max_concurrent_checks sat_cluster_id ip
    sched_log_level sput_log_level dq_log_level
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



# Look up a node by node ID
############
sub lookup {
############
  my $self = shift;

  # <<INSERT CODE HERE>>

}


1;

__END__
=head1 NAME

RHN::DB::SatNode - Monitoring scout nodes ("sat nodes")

=head1 SYNOPSIS

  use RHN::DB::SatNode;
  
  <<INSERT SAMPLE CODE HERE>>

=head1 DESCRIPTION

<<INSERT LONG DESCRIPTION HERE>>

=head1 METHODS

=over 8

=item new()

<<CONSTRUCTOR DOCUMENTATION HERE>>

=item lookup()

Look up a node by node ID


=item <<METHOD()>>

<<METHOD() DOCUMENTATION HERE>>

=back

=head1 SEE ALSO

L<OTHER_MODULE>, L<ANOTHER_MODULE>

=head1 COPYRIGHT

Copyright (c) 2004-2005, Red Hat, Inc.  All rights reserved

=cut


