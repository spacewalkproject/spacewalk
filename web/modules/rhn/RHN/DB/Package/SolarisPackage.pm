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

package RHN::DB::Package::SolarisPackage;

use strict;
use Carp;
use RHN::DB;
use RHN::DB::TableClass ();

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB::Package;
our @ISA = qw/RHN::DB::Package/;

my @solaris_package_fields = qw/package_id pkginfo pkgmap intonly category/;

my $spt = new RHN::DB::TableClass("rhnSolarisPackage", "SP", "solaris", @solaris_package_fields);

sub _init {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $spt->select_query("SP.PACKAGE_ID = ?");

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $package_id = $columns[0];

  if ($package_id) {
    unless ($package_id == $self->id) {
      die "rhnSolarisPackage.package_id != rhnPackage.id when looking up package '"
	. $self->id . "' (" . join (',', ($package_id, @columns)) . ")";
    }

    $self->$_(shift @columns) foreach $spt->method_names;
    delete $self->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading package '" . $self->id . ". (@columns)";
  }

  return $self;
}

foreach my $field ($spt->method_names) {
  my $sub = q {
    sub [[field]] {
      my $self = shift;
      if (@_ and "[[field]]" ne "id") {
        $self->{":modified:"}->{[[field]]} = 1;
        $self->{__[[field]]__} = shift;
      }
      return $self->{__[[field]]__};
    }
  };

  $sub =~ s/\[\[field\]\]/$field/g;

  eval $sub;

  croak $@ if($@);
}

1;
