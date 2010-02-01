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

package RHN::DB::Product;
use RHN::DB;
use RHN::DB::TableClass;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my @product_fields =
  (qw/PRODUCT_ID ITEM_CODE NAME CATEGORY SHORT_DESCRIPTION PRICE WEIGHT/,
   qw/PRODUCT_SIZE COLOR NOTICE COOL IMG MAX_REGISTRATIONS SHIP_IND LIST_IND/,
   qw/SERVICE_IND SHIP_INCLUDED_IND SUPPORTABLE_DAYS EXPORT_RESTR_IND/,
   qw/FREQUENT_ORDER_IND CREATED MODIFIED/);

my $p = new RHN::DB::TableClass("RH_PRODUCT", "RP", "", @product_fields);

sub _blank_product {
   my $class = shift;

   my $self = bless { }, $class;

   return $self;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {item_code => 1});
  my $item_code = $params{item_code};

  my $dbh = RHN::DB->connect;
  my $sqlstmt;

  $sqlstmt = $p->select_query("RP.ITEM_CODE = ?");

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute($item_code);
  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;

  if ($columns[0]) {
    $ret = $class->_blank_product();

    foreach ($p->method_names) {
      $ret->{"__".$_."__"} = shift @columns;
    }
  }
  else {
    local $" = ", ";
    RHN::Exception::throw '(product_does_not_exist)';
  }

  return $ret;
}

foreach my $field ($p->method_names) {
  my $sub = q {
       sub [[field]] {
         my $self = shift;
         return $self->{__[[field]]__};
       }
     };

  $sub =~ s/\[\[field\]\]/$field/g;
  eval $sub;

  if ($@) {
    die $@;
  }
}


sub product_line {
  my $class = shift;
  my $label = shift;

  die 'No label!' unless $label;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;
  $query = <<EOQ;
SELECT PL.name
  FROM rhnProductLine PL,
       rhnProduct
 WHERE label = :product_label
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(product_label => $label);
  my ($name) = $sth->fetchrow;
  $sth->finish;

  return $name;
}

sub products_by_line {
  my $class = shift;
  my $line_label = shift;
  my $order = shift;

  die "no line label" unless $line_label;

  my $order_by_str = '';

  if ($order and (lc $order eq 'desc')) {
    $order_by_str = 'DESC';
  }

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;
  $query = <<EOQ;
SELECT DISTINCT P.id, P.label, P.name,
       (SELECT MIN (rhn_channel.channel_priority(PC.channel_id))
       FROM rhnProductChannel PC
       WHERE P.id = PC.product_id) as priority
  FROM rhnProduct P,
       rhnProductLine PL
 WHERE PL.label = :product_line_label
   AND PL.id = P.product_line_id
ORDER BY priority ASC, UPPER(P.name) $order_by_str
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(product_line_label => $line_label);

  my @ret;
  while(my $row = $sth->fetchrow_hashref) {
    push @ret, $row;
  }

  return @ret;
}

1;
