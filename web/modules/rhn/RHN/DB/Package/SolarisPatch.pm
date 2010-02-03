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

package RHN::DB::Package::SolarisPatch;

use strict;
use Carp;
use RHN::DB;
use RHN::Exception qw/throw/;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB::Package;
our @ISA = qw/RHN::DB::Package/;

my @solaris_patch_fields = qw/package_id solaris_release sunos_release readme patchinfo patch_type/;
my @solaris_patch_type_fields = qw/id name label/;

my $spt = new RHN::DB::TableClass("rhnSolarisPatch", "SP", "solaris", @solaris_patch_fields);
my $sptt = new RHN::DB::TableClass("rhnSolarisPatchType", "SPT", "solaris_pt", @solaris_patch_type_fields);

my $tc = $spt->create_join([ $sptt ],
			   { "rhnSolarisPatch" => {
						   "rhnSolarisPatch" => [ "PACKAGE_ID", "PACKAGE_ID" ],
						   "rhnSolarisPatchType" => [ "PATCH_TYPE", "ID" ],
						  }
			   }
			  );

sub _init {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $tc->select_query("SP.PACKAGE_ID = ?");

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $package_id = $columns[0];

  if ($package_id) {
    unless ($package_id == $self->id) {
      die "rhnSolarisPatch.package_id != rhnPackage.id when looking up package '"
	. $self->id . "' (" . join (',', ($package_id, @columns)) . ")";
    }

    $self->$_(shift @columns) foreach $tc->method_names;
    delete $self->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading patch '" . $self->id . ". (@columns)";
  }

  return $self;
}

foreach my $field ($tc->method_names) {
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

# The patch clusters containing this patch
sub patch_sets {
  my $self = shift;

  my $ds = new RHN::DataSource::Package (-mode => 'patchsets_for_patch');
  my $data = $ds->execute_full(-pid => $self->id);

  return @{$data};
}

1;
