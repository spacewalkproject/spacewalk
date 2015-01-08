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

package RHN::TSDB;

use strict;
use Carp;
use LWP::UserAgent;
use NOCpulse::Config;

our $VERSION = (split(/s+/, q$Id$, 4))[2];

use vars qw($URL);

BEGIN {

  $URL = NOCpulse::Config->new->get('ts_db', 'url');

}

# Hash of default values for instance construction
use constant INSTANCE_DEFAULTS => (
  url => $URL,
);



#
# Note:  'fetch' could possibly be a class method, as there is little
#         config data.
#
# For TSDB queries, the OID is <org_id>-<probe_id>-<metric>


# Generated getter/setter methods (per Chip)
{

  my @fields = qw(
    url
    ua
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

  # Create a reusable UserAgent object
  $self->ua(LWP::UserAgent->new());

  return $self;
}



# Fetch TSDB data
###########
sub fetch {
###########
  my $self = shift;
  my %args = @_;
  my @results;

  # Required:  org_id, probe_id, metric, start, end
  my @missing;
  foreach my $required (qw(org_id probe_id metric start end)) {
    push(@missing, $required) unless (exists($args{$required}));
  }
  confess "Missing required parameters: @missing" if (@missing);

  my $req = HTTP::Request->new('POST' => $self->url);

  my $oid = join('-', $args{'org_id'}, $args{'probe_id'}, $args{'metric'});

  my $content = sprintf('fn=fetch&oid=%s&start=%s&end=%s',
                $oid, $args{'start'}, $args{'end'});

  $req->content($content);

  my $response = $self->ua->request($req);

  if ($response->is_success) {
    foreach my $line (split(/\n/, $response->content)) {
      next if ( $line =~ /^BEGIN/ );
      last if ( $line =~ /^END/ );

      # time, value
      my($time, $value) = split(/\s+/, $line, 2);

      # Make sure null values are numeric to avoid warnings
      $time ||= 0; $value ||= 0;

      push(@results, [$time, $value]);

    }

  } else {

    $! = $response->status_line;
    return undef;

  }

  return \@results;


}




1;

__END__
=head1 NAME

RHN::TSDB - Time Series Database (TSDB) access

=head1 SYNOPSIS

  use RHN::TSDB;

  my $tsdb = RHN::TSDB->new(url => $TSDB_url);

  my $results = $tsdb->fetch(
    org_id   => $org_id,
    probe_id => $probe_id,
    metric   => $metric,
    start    => $start_time,
    end      => $end_time,
  );

  foreach my $record (@$results) {
    my($time, $value) = @$record;
    # ...
  }

=head1 DESCRIPTION

RHN::TSDB provides read-only access to the monitoring
Time Series Database (TSDB).

=head1 METHODS

=over 8

=item new()

The constructor takes a single optional argument ('url'), the base
URL of the TSDB web interface.

=item fetch()

Fetches TSDB data.  Required parameters include the organization ID
('org_id'), the probe ID ('probe_id'), the metric name ('metric'),
and a time range in Unix epoch format ('start' .. 'end').   Returns
a list of lists, each element of which is a [time, value] pair.


=back

=head1 SEE ALSO

L<RHN::SCDB>

=head1 COPYRIGHT

Copyright (c) 2004-2005, Red Hat, Inc.  All rights reserved

=cut


