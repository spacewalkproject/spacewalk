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

package RHN::DB::Server::StorageDevice;

use RHN::DB;
use Carp;
use RHN::DB::TableClass;

# Corresponds to an entry in the rhnHwDevice table...
# basically, some hardwarea attached to a server?
#
# The information for this class comes solely from up2date...
# there should be *NO* setters for this class.

my @storage_device_fields = (qw/ID SERVER_ID CLASS BUS DETACHED DEVICE DRIVER/,
			     qw/DESCRIPTION PHYSICAL LOGICAL PCITYPE/);

my $s = new RHN::DB::TableClass("rhnStorageDevice", "S", "", @storage_device_fields);


# create a blank hwdevice object
sub _blank_storage_device {
   my $class = shift;

   my $self = bless { }, $class;

   return $self;
}


# returns an array of storage device objects given a server id
sub lookup_storage_devices_by_server {
  my $class = shift;
  my $server_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $s->select_query("S.SERVER_ID = ?");
  $sth = $dbh->prepare($query);
  $sth->execute($server_id);

  my @ret;
  my $count = 0;

  while (my @columns = $sth->fetchrow) {
    if ($columns[0]) {
      $ret[$count] = $class->_blank_storage_device;
      $ret[$count]->{"__".$_."__"} = shift @columns foreach $s->method_names;
    }
    $count++;
  }

  $sth->finish;
  return @ret;
}

# build some read-only accessors  
foreach my $field ($s->method_names) {
  my $sub = q {
    sub RHN::DB::Server::StorageDevice::[[field]] {
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
