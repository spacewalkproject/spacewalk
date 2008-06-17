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
package RHN::Catalog;

use RHN::DB;
use Carp qw/confess cluck/;


my %product_data;
my %product_aliases =
  ( prod_basic => "SER0129",
    prod_enterprise => "SVC0060",

    prod_wsbasic => "SVC0056",
    prod_esbasic => "SVC0057",
    prod_wsbasic_mgmt => "SVC0058",
    prod_esbasic_mgmt => "SVC0059",

    prod_prov => 'SVC0081',
    prod_prov_upgrade => 'SVC0082',

#    prod_ent5pack => "RHN035",
#    prod_ent10pack => "RHN036",
  );
my @sellable_slots = keys %product_aliases;

sub sellable_slots {
  my $class = shift;

  return @sellable_slots;
}

# handy function to a) load cache, b) verify given product alias is in it
sub prep_check {
  my $class = shift;
  my $alias = shift;

  if (not keys %product_data) {
    $class->load_products;
  }

  die "no product data for product $alias" unless exists $product_data{$alias};
}

sub product_code_by_alias {
  my $class = shift;
  my $alias = shift;

  $class->prep_check($alias);
  return $product_data{$alias}->{ITEM_CODE};
}

sub product_short_name {
  my $class = shift;
  my $alias = shift;

  $class->prep_check($alias);
  return $product_data{$alias}->{NAME};
}

sub product_price_by_alias {
  my $class = shift;
  my $alias = shift;

  $class->prep_check($alias);
  return $product_data{$alias}->{PRICE};
}

# everything is a service... for now
sub product_tax_type {
  return 'S';
}

sub valid_alias {
  my $class = shift;
  my $alias = shift;

  $class->prep_check($alias);
  return exists $product_data{$alias};
}

sub is_provisioning_upgrade_product {
  my $class = shift;
  my $item_code = shift;

  return $product_aliases{prod_prov_upgrade} eq $item_code;
}

sub lookup_product_by_alias {
  my $class = shift;
  my $alias = shift;

  $class->prep_check($alias);
  return RHN::Product->lookup(-item_code => $product_data{$alias}->{ITEM_CODE});
}

sub load_products {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT :item ALIAS, product_id, item_code, name, price FROM rh_product WHERE item_code = :item");

  for my $alias ($class->sellable_slots) {
    $sth->execute_h(item => $product_aliases{$alias});

    my $product = $sth->fetchrow_hashref;
    $sth->finish;

    confess "can't find product data for $alias/$product_aliases{$alias}" unless $product;

    $product_data{$alias} = $product;
  }
}

1;

