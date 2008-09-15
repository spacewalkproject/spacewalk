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

package RHN::Utils;

use strict;

use Date::Parse;
use PXT::Utils;
use RHN::Access;

use RHN::Exception;

use Socket;

# similar to PXT::Utils, but for RHN specific stuff...

#takes an ref to an array of arrayrefs, and a list of parameters -
#traverses the array, and assigns elements of each array to named
#parameters in a hashref... - example -

# my @channels = ( [1, 'Red Hat Linux 7.0'], [2, 'Red Hat Linux 7.1'], [3, 'Red Hat Linux 7.3'] );
# my @p_channels = parameterize(\@channels, 'id', 'name');

# foreach my $chan (@p_channels) {
#   $html =~ s/\{channel_name\}/$chan->{name}/ge;
#   $html =~ s/\{channel_id\}/$chan->{id}/ge;
# }

sub parameterize {
  my $class = shift;
  my $data = shift;
  my @params = @_;

  my @return;

  foreach my $datum (@{$data}) {

    my $x = { };
    @{$x}{@params} = @{$datum}[0 .. $#params]; #slice. allows $x->{name}, etc

    push @return, $x;
  }

  return @return;
}

sub sets_differ {
  my ($first, $second) = @_;

  my %elements;

  foreach my $elem (@{$first}, @{$second}) {
    next unless defined $elem;
    $elements{$elem}++;
  }

  foreach my $elem (keys %elements) {
    return 1 unless ($elements{$elem} == 2);
  }

  return 0;
}

sub read_file {
  my $class = shift;
  my $filename = shift;

  unless (-e $filename) {
    throw "(file_not_found) Could not find '$filename'";
  }

  unless (-r $filename) {
    throw "(file_not_readable) Could not read '$filename'";
  }

  open(FH, $filename) or throw "(file_open_error) Could not open '$filename': $!";

  my @lines = <FH>;

  close(FH);

  return join('', @lines);
}

sub find_ip_address {
  my $hostname = shift;

  return unless $hostname;

  my $host = gethostbyname($hostname);
  my $ip_addr = inet_ntoa($host);

  return unless $ip_addr;

  return $ip_addr;
}

1;
