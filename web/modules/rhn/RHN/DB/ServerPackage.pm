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

# represents packages on servers.  we only know nvre about these things, apparently...

use strict;

package RHN::DB::ServerPackage;

use RHN::DB;
use Carp;

# given a server id, spit back the entire list of packages on a server...
sub package_list_by_server {
  my $class = shift;

}

# given a server id and package group, spit back the list of packages on a server in a package group...
sub package_list_by_group_by_server {
  my $class = shift;
  my %params = @_;

  my ($sid, $gupper, $glower) =
    map { $params{"-" . $_} } qw/sid gupper glower/;

  my $server = RHN::Server->lookup(-id => $sid);
  my $groups = $server->package_groups;

  my @pkgs;

  foreach my $upper (sort { lc $a cmp lc $b } keys %{$groups}) {
    next unless $gupper eq $upper;

    if ($glower) {
      push @pkgs, sort { lc $a cmp lc $b } @{$groups->{$gupper}->{$glower}};
    }
    else {
      push @pkgs, sort { lc $a cmp lc $b } map { @{$groups->{$gupper}->{$_}} } keys %{$groups->{$gupper}};
    }
  }

  return @pkgs;
}

# arguments:
# -org_id => $pxt->user->org_id, -lower => $lower,
# -upper => $upper, -total_rows => \$total_rows,
# -sid => $sid
sub package_list_by_server_overview {
  my $class = shift;
  my %params = @_;

  my ($org_id, $lower, $upper, $total_ref, $sid, $gupper, $glower, $like) =
    map { $params{"-" . $_} } qw/org_id lower upper total_rows sid gupper glower like/;

  $lower ||= 1;
  $upper ||= 100000;

  my $dbh = RHN::DB->connect;

  my @result;

  my $i = 1;
  $$total_ref = 0;

  if (!$gupper) {


    my $and_clause = '';
    if ($like) {
      $and_clause = 'AND SP_NAME.name LIKE ?';
    }

    my $query = <<EOQ;
  SELECT    SP_NAME.name, SP_EVR.evr.as_vre_simple() NVRE, SP.name_id || '|' || SP.evr_id
    FROM    rhnPackageEvr SP_EVR, rhnPackageName SP_NAME, rhnServerPackage SP
   WHERE    SP.server_id = ?
     AND    SP.name_id = SP_NAME.id
     AND    SP.evr_id = SP_EVR.id
     $and_clause
ORDER BY UPPER(SP_NAME.name), SP_EVR.evr DESC
EOQ

    my $sth = $dbh->prepare($query);
    $sth->execute($sid, $like ? "%$like%" : ());


    while (my @data = $sth->fetchrow) {
      $$total_ref = $i;
      if ($i >= $lower and $i <= $upper) {
	push @result, [ @data ];
      }
      $i++;
    }
    $sth->finish;
  } else {

    # hrm.  theoretically, this could be a large number of packages,
    # which means a decent sized data structure.  Could optimize here probably.
    my @temp_results = RHN::DB::ServerPackage->package_list_by_group_by_server(-sid => $sid, -gupper => $gupper, -glower => $glower);
    my @temp_results2 = sort { (lc $a->[1]) cmp (lc $b->[1]) } @temp_results;

    #warn "(hopefully xsorted) Packages in group $gupper".($glower ? " ($glower)" : "").":  ".Data::Dumper->Dump([(@temp_results2)]);
    foreach my $data (@temp_results2) {
      $$total_ref = $i;
      if ($i >= $lower and $i <= $upper) {
#	warn "total == $$total_ref, lower == $lower, upper == $upper, i == $i";
	push @result, $data;
      }
      $i++;
    }
  }

  return @result;
}

1;
