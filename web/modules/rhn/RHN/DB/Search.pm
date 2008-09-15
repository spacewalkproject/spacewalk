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

package RHN::DB::Search;
use RHN::DB;
use RHN::Set;
use RHN::DataSource::Simple;
use Data::Dumper;

sub query_into_set {
  my $class = shift;
  my $set = shift;
  my $query_body = shift;
  my $query_params = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query_body);

  $sth->execute_h(%$query_params);

  my @ids;

  while (my ($id) = $sth->fetchrow) {
    push @ids, $id;
  }

  $set->add(@ids);
  $set->commit;

  return $set;
}

sub errata_search {
  my $class = shift;
  my $user = shift;
  my $search_mode = shift;
  my $search_string = shift;

  my $user_id = $user->id;

  my $search = RHN::SearchTypes->find_type('errata');
  my $set_name = $search->set_name;
  my $set = RHN::Set->lookup(-label => $set_name, -uid => $user_id);
  $set->empty;
  $set->commit;

  my $ds = new RHN::DataSource::Simple(-querybase => "errata_search_setbuilder", -mode => $search_mode);
  my %query_params = (org_id => $user->org->id,
		      search_string => $search_string);

  $class->query_into_set($set, $ds->get_query_body("query"), \%query_params);
}

sub package_search {
  my $class = shift;
  my $user = shift;
  my $search_mode = shift;
  my $search_string = shift;
  my $search_arches = shift;
  my $smart_search = shift;

  my $user_id = $user->id;

  my $search = RHN::SearchTypes->find_type('package');
  my $set_name = $search->set_name;
  my $set = RHN::Set->lookup(-label => $set_name, -uid => $user_id);
  $set->empty;
  $set->commit;

  my %query_params = (org_id => $user->org->id,
		      search_string => $search_string);
  if ($smart_search) {
    # UGLY HACK.  since you can't name the inline queries of a mode, we
    # do this.  TODO: make robin fix inconsistencies in datasource

    if ($user->org->server_count > 0) {
      $search_mode .= "_smart";
    }
    else {
      # UGLY HACK. 
      $search_mode .= "_clabel";
      $query_params{channel_label} = 'redhat-linux-i386-8.0';
    }
  }

  my $ds = new RHN::DataSource::Simple(-querybase => "package_search_setbuilder", -mode => $search_mode);

  my $query_body = $ds->get_query_body("query");

  if (not $smart_search) {
    my @arch_pholders = map { "C$_" } 0 .. $#$search_arches;
    $query_body = sprintf $query_body, join(", ", map { ":$_" } @arch_pholders);
    @query_params{@arch_pholders} = @$search_arches;
  }

  $class->query_into_set($set, $query_body, \%query_params);
}

sub system_search {
  my $class = shift;
  my $user = shift;
  my $search_string = shift;
  my $prev_set_name = shift; #currently either 'all' or 'system_list'
  my $search_type = shift;
  my $invert = shift;

  my $user_id = $user->id;

  my $set_name = 'system_search';
  my $set = RHN::Set->lookup(-label => $set_name, -uid => $user_id);
  $set->empty;
  $set->commit;

  my $ds = new RHN::DataSource::Simple(-querybase => "system_search_setbuilder", -mode => $search_type);

  my %query_params = (user_id => $user->id);
  my $query_body;
  # numeric searches

  if (grep { $search_type eq $_ } qw/search_cpu_mhz_lt search_cpu_mhz_gt search_ram_lt search_ram_gt/) { 
    $query_params{search_value} = $search_string;
    $query_body = $ds->get_query_body("query");
  }
  else {
    $query_params{search_string} = $search_string;
    $query_body = $ds->get_query_body("query");
  }

  if ($invert) {
    $query_body = <<"        EOQ";
        SELECT  USP.server_id
          FROM  rhnUserServerPerms USP
         WHERE  USP.user_id = :user_id
        MINUS
        (
        $query_body
        )
        EOQ
  }

  if ($prev_set_name eq 'system_list') {
    $query_params{previous_set_label} = $prev_set_name;
    $query_body .= " INTERSECT SELECT element FROM rhnSet WHERE label = :previous_set_label AND user_id = :user_id";
  }

  $class->query_into_set($set, $query_body, \%query_params);
}

1;
