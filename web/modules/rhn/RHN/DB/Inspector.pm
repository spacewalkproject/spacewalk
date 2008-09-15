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

package RHN::DB::Inspector;

use RHN::DB;

use Data::Dumper;


#  returns [ org_id, org_name, user_id, first_names, last_name, login, email ]
sub find_org_by_user {
  my $class = shift;
  my %params = @_;
#  my $search_str = shift;

  my ($lower, $upper, $total_ref, $search_str) =
    map { $params{"-" . $_} } qw/lower upper total_rows search_str/;


  my $dbh = RHN::DB->connect();
  my $query;
  my $sth;
  my $where_clause;

  if ($search_str =~ /[*%]/g) {
    $search_str =~ s/\*/%/g;
#    $where_clause = "UPPER(S.name) LIKE UPPER(?)";
  }
#  else {
#    $where_clause = "S.name = ?";
#  }

  $query = <<EOQ;
SELECT  WC.org_id, WC.login, WC.id, PI.email
  FROM  web_user_personal_info PI, web_contact WC
 WHERE  (WC.login_uc LIKE UPPER(?) OR PI.email LIKE UPPER(?))
   AND  WC.id = PI.web_user_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($search_str, $search_str);

  my @ret;
  $$total_ref = 0;
  my $i = 1;
  while( my @row = $sth->fetchrow) {
    $$total_ref = $i;
    if ($i >= $lower and $i <= $upper) {
      push @ret, [ @row ];
    }
    $i++;
  }
  $sth->finish;

  return @ret;
}

#  returns [ org_id, org_name, server_id, server_name ]
#  based on search for server name
#  NOTE:  SLOW!
sub find_org_by_server_name {
  my $class = shift;
  my %params = @_;
#  my $search_str = shift;

  my ($lower, $upper, $total_ref, $search_str) =
    map { $params{"-" . $_} } qw/lower upper total_rows search_str/;


  my $dbh = RHN::DB->connect();
  my $query;
  my $sth;
  my $where_clause;

  if ($search_str =~ /[*%]/g) {
    $search_str =~ s/\*/%/g;
    $where_clause = "UPPER(S.name) LIKE UPPER(?)";
  }
  else {
    $where_clause = "S.name = ?";
  }

  $query = <<EOQ;
SELECT  O.id, O.name, S.id, S.name
  FROM  web_customer O, rhnServer S
 WHERE  $where_clause
   AND  S.org_id = O.id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($search_str);

  my @ret;
  $$total_ref = 0;
  my $i = 1;
  while( my @row = $sth->fetchrow) {
    $$total_ref = $i;
    if ($i >= $lower and $i <= $upper) {
      push @ret, [ @row ];
    }
    $i++;
  }

  $sth->finish;

  return @ret;
}

1;
