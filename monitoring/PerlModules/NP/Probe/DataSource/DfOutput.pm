package NOCpulse::Probe::DataSource::DfEntry;

# Information from df for a single filesystem
use strict;

use Data::Dumper;

use Class::MethodMaker
  get_set =>
  [qw(
      device
      blocks
      used
      available
      percent_used
      mountpoint
     )],
  static_hash =>
  [qw(
      for_device
      for_mountpoint
     )],
  new => 'new',
  ;

# Divides used and available values by 1024.
sub convert_to_megabytes {
    my $self = shift;
    $self->used(int($self->used / 1024));
    $self->available(int($self->available / 1024));
}

1;

sub to_string {
    return Dumper(shift);
}



package NOCpulse::Probe::DataSource::DfOutput;

# Container for df entries

use strict;

use Class::MethodMaker
  hash =>
  [qw(
      for_device
      for_mountpoint
     )],
  new_with_init => 'new',
  ;

use constant DF_FIELD_COUNT => 6;

# Parses df output. Puts instances for each device into the for_device 
# hash table, and for each mountpoint into the for_mountpoint hash
# table.  Returns this class name.
sub init {
    my ($self, $df_string) = @_;

    $df_string or return;

    # Output looks like this:
    # /dev/md0               2063440    294008   1664616  15% /
    # Or, on Irix:
    # /dev/md0      ext2     2063440    294008   1664616  15% /
    # Long device names can cause wrapping:
    # canyon:/u1/oracle/product
    #                     249292492 130330640 118961852    53%    /ora_product

    # Returns a list of all matches, so each df row is split into multiple
    # list entries.
    my @fields = $df_string =~ /^(\S+)\s+(?:\D\S*\s+|)(\d+)\s+(\d+)\s+(\d+)\s+(\d+)%?\s+(\S+)$/mg;

    for (my $i = 0; $i < @fields; $i += DF_FIELD_COUNT) {

        my $subfield = $i;
        my $df = NOCpulse::Probe::DataSource::DfEntry->new();
        $df->device($fields[$subfield++]);
        $df->blocks($fields[$subfield++]);
        $df->used($fields[$subfield++]);
        $df->available($fields[$subfield++]);
        $df->percent_used($fields[$subfield++]);
        $df->mountpoint($fields[$subfield++]);

        # Stash it away.
        $self->for_device($df->device, $df);
        $self->for_mountpoint($df->mountpoint, $df);
    }

    return $self;
}

__END__
