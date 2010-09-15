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

use strict;

package Sniglets::ListView::FileList;

use Sniglets::ListView::List;
use RHN::DataSource::General;
use RHN::DataSource::Simple;
use PXT::HTML;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:file_list_cb";
}

sub list_of { return "files" }

sub _register_modes {

  Sniglets::ListView::List->add_mode(-mode => "package_files",
			   -datasource => RHN::DataSource::General->new);


  Sniglets::ListView::List->add_mode(-mode => "configfiles_for_snapshot",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));
}

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  if ($self->datasource->mode eq 'package_files') {
    $row->{NAME} = '<tt>' . $row->{NAME} . '</tt>';

    if ($row->{CHECKSUM}) {
      $row->{CHECKSUM} = '<tt>' . uc($row->{CHECKSUM_TYPE}) . ': ' . $row->{CHECKSUM} . '</tt>';
      $row->{FILE_SIZE} = '<tt>' . PXT::Utils->commafy($row->{FILE_SIZE}) . " bytes</tt>";
    }
    elsif ($row->{LINKTO}) {
      $row->{FILE_SIZE} = '&#160;';
      $row->{CHECKSUM} = "<tt>(Symlink)</tt>";
    }
    else {
      $row->{FILE_SIZE} = '&#160;';
      $row->{CHECKSUM} = "<tt>(Directory)</tt>";
    }
  }
  return $row;
}

# Overrides the List.pm implementation.  We don't want the alphabar to 
# appear when displaying files.
sub render_alphabar {
    return '';
}

1;
