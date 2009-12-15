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

package RHN::TokenGen::Local;

use strict;
use RHN::DB::Downloads;

use URI::URL;
use PXT::Utils;
use PXT::Config;

our @ISA = qw/RHN::DB::Downloads/;

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

sub new {
  my $class = shift;
  my %params = validate(@_, { expires => 1, user_id => 1, path => 1, file_id => 0 });

  my $self = bless \%params, $class;
  $self->{path_trail} = $self->{path};
  return $self;
}

sub token_signature {
  my $self = shift;

  return RHN::SessionSwap->rhn_hmac_data($self->{expires}, $self->{user_id}, $self->{file_id} || 0, $self->{path_trail});
}

sub url_form {
  my $self = shift;
  my $base_url = shift;

  return join("/", $base_url, $self->{expires}, $self->token_signature, $self->{user_id}, $self->{file_id}, $self->{path});
}


sub generate_url {
  my $class = shift; # == 'RHN::TokenGen::Local'
  my $user_id = shift;
  my $file_id = shift;
  my $path = shift;
  my $base_url = shift;
  my $location = shift;
  my $expires = shift;
  my $ssl_available = shift;

  my $obj = RHN::TokenGen::Local->new(-expires => $expires, -user_id => $user_id, -path => $path, -file_id => $file_id );

  my $uri = new URI::URL($obj->url_form($base_url));
  $uri->scheme('http');
  $uri->scheme("https") if $ssl_available and PXT::Config->get('download_ssl_enable');

  if ($location eq 'local') {
    $uri->host(PXT::Config->get('download_local_domain') || PXT::Config->get('base_domain'));
  }
  elsif ($location eq 'tpa') {
    $uri->host('download.rhn.redhat.com');
  }
  else {
    die "unknown download location '$location'";
  }

  return $uri;
}

1;
