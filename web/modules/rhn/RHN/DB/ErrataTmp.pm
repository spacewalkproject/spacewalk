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

# errata - DB layer
use strict;

package RHN::DB::ErrataTmp;

use Carp;
use RHN::DB;

use RHN::DB::TableClass;

use RHN::Errata;
use RHN::DB::Errata;

our @ISA = qw/RHN::DB::Errata/;

my $e = new RHN::DB::TableClass("rhnErrataTmp", "E", "", RHN::Errata->errata_fields);

sub table_class {
  return $e;
}

sub table_map {
  my $class = shift;

  my %table = (rhnErrata             => 'rhnErrataTmp',
	       rhnErrataKeyword      => 'rhnErrataKeywordTmp',
	       rhnErrataBugList      => 'rhnErrataBugListTmp',
	       rhnErrataPackage      => 'rhnErrataPackageTmp',
	       rhnErrataCloned       => 'rhnErrataClonedTmp',
	       rhnErrataFile         => 'rhnErrataFileTmp',
	       rhnErrataFilePackage  => 'rhnErrataFilePackageTmp',
	       rhnErrataFileChannel  => 'rhnErrataFileChannelTmp',
	      );

    return ($table{$_[0]} || $_);
}

1;
