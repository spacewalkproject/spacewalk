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

package RHN::DB::Server::NetInterface;

use RHN::DB;
use Carp;
use RHN::DB::TableClass;
use Data::Dumper;

# Corresponds to an entry in the rhnServerNetInterface table...

my @net_interface_fields = qw/SERVER_ID NAME IP_ADDR NETMASK BROADCAST HW_ADDR MODULE/;

my $n = new RHN::DB::TableClass("rhnServerNetInterface", "N", "", @net_interface_fields);

# create a blank net info object
sub _blank_net_interface {
  my $class = shift;

  my $self = bless {}, $class;

  return $self;
}

# returns an array of net info objects given a server id
sub lookup_net_interface_by_server {
  my $class = shift;
  my $server_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $n->select_query("N.SERVER_ID = ?");
  $sth = $dbh->prepare($query);
  $sth->execute($server_id);

  my @ret;
  my $count = 0;

  while (my @columns = $sth->fetchrow) {
    if ($columns[0]) {
      $ret[$count] = $class->_blank_net_interface;
      $ret[$count]->{"__".$_."__"} = shift @columns foreach $n->method_names;
    }
    $count++;
  }

  $sth->finish;
  return @ret;
}

# build some read-only accessors
foreach my $field ($n->method_names) {
  my $sub = q {
    sub RHN::DB::Server::NetInterface::[[field]] {
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


return 1;
