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

package Sniglets::ListView::CustomInfo;

use Sniglets::ListView::List;
use RHN::Exception qw/throw/;
use RHN::Token;
use RHN::DataSource::CustomInfo;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:custominfo_list_cb";
}

sub _register_modes {
  Sniglets::ListView::List->add_mode(-mode => "custom_info_keys",
			   -datasource => RHN::DataSource::CustomInfo->new,
			   -provider => \&custom_info_keys_provider);


  Sniglets::ListView::List->add_mode(-mode => "custom_info_keys_sans_value_for_system",
			   -datasource => RHN::DataSource::CustomInfo->new,
			   -provider => \&custom_info_keys_provider);

}

sub custom_info_keys_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  foreach my $key (@{$ret{data}}) {

    if (defined $key->{DESCRIPTION}) {
      $key->{DESCRIPTION} = '<pre>' . $key->{DESCRIPTION} . '</pre>';
    }
  }

  return (%ret);
}



1;
