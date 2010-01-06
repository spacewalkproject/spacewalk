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

package RHN::DB::Server::HwDevice;

use RHN::DB;
use Carp;
use RHN::DB::TableClass;
use Data::Dumper;

# Corresponds to an entry in the rhnHwDevice table...
# basically, some hardwarea attached to a server?
#
# The information for this class comes solely from up2date...
# there should be *NO* setters for this class.

my @hw_device_fields = (qw/ID SERVER_ID CLASS BUS DETACHED/,
			qw/DEVICE DRIVER/,
			qw/VENDOR_ID DEVICE_ID SUBVENDOR_ID/,
			qw/SUBDEVICE_ID PCITYPE/);

my @normal_attribs = map { lc $_ } @hw_device_fields;

my @special_cases = (qw/DESCRIPTION/);

my $h = new RHN::DB::TableClass("rhnHwDevice", "H", "", (@hw_device_fields, @special_cases));


# create a blank hwdevice object
sub _blank_hw_device {
   my $class = shift;

   my $self = bless { }, $class;

   return $self;
}

# returns an array of hwdevice objects given a server id
sub lookup_hw_devices_by_server {
  my $class = shift;
  my $server_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $h->select_query("H.SERVER_ID = ?");
  $sth = $dbh->prepare($query);
  $sth->execute($server_id);

  my @ret;
  my $count = 0;

  while (my @columns = $sth->fetchrow) {
    if ($columns[0]) {
      $ret[$count] = $class->_blank_hw_device;
      $ret[$count]->{"__".$_."__"} = shift @columns foreach $h->method_names;
    }
    $count++;
  }

  $sth->finish;
  return @ret;
}

# build some read-only accessors
#foreach my $field ($h->method_names) {
foreach my $field (@normal_attribs) {
  my $sub = q {
    sub RHN::DB::Server::HwDevice::[[field]] {
      my $self = shift;
					      if (@_) {
						$self->{__[[field]]__} = shift;;
					      }
					      else {
						return $self->{__[[field]]__};
					      }
    }
  };

  $sub =~ s/\[\[field\]\]/$field/g;
  eval $sub;

  if ($@) {
    die $@;
  }
}

sub description {
  my $self = shift;

  my $desc;

  $_ = $self->{__description__};
  ($desc) =  m/\|+(.*)/;

  return $self->{__description__} unless $desc;

  return $desc;
}

sub vendorstring {
  my $self = shift;

  my $vstr;

  $_ = $self->{__description__};

  #($vstr) = m/"+(.*?)\|+/;
  ($vstr) = m/(.*)\|+/;

  return $vstr;
}

return 1;
