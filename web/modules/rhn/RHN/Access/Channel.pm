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

package RHN::Access::Channel;

use strict;
use RHN::Exception qw/throw/;
use RHN::Channel;
use RHN::ConfigChannel;
use RHN::ConfigRevision;
use PXT::ACL;

sub register_acl_handlers {
  my $self = shift;
  my $acl = shift;

  $acl->register_handler(channel_subscribable => \&channel_subscribable);
  $acl->register_handler(channel_exists => \&channel_exists);
  $acl->register_handler(channel_accessible => \&channel_accessible);
  $acl->register_handler(base_channel => \&channel_is_base);
  $acl->register_handler(channel_licensed => \&channel_is_licensed);
  $acl->register_handler(channel_eoled => \&channel_eoled);
  $acl->register_handler(org_owns_cloned_channels => \&org_owns_cloned_channels);
  $acl->register_handler(org_channel_setting => \&org_channel_setting);
  $acl->register_handler(user_can_admin_channel => \&user_can_admin_channel);
  $acl->register_handler(channel_is_clone => \&channel_is_clone);
  $acl->register_handler(channel_has_downloads => \& channel_has_downloads);
  $acl->register_handler(channel_packaging_type => \&channel_packaging_type);
  $acl->register_handler(channel_type_capable => \&channel_type_capable);
  $acl->register_handler(configfile_is_file => \&configfile_is_file);
  $acl->register_handler(channel_is_local => \&channel_is_local);
  $acl->register_handler(channel_is_protected => \&channel_is_protected);
}

# Is the config file with crid a file or directory?
sub configfile_is_file {
    my $pxt = shift;
    my $crid = $pxt->param('crid');
    throw 'no crid param' unless $crid;
 
    my $cr = RHN::ConfigRevision->lookup(-id => $crid);

    if ($cr->filetype eq "File") {
        return 1;
    }
    else {
        return 0;
    }
}

sub channel_has_downloads {
  my $pxt = shift;

  return 1 if RHN::Channel->has_downloads($pxt->param('cid'));

  return 0;
}

sub channel_eoled {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  throw 'no cid param' unless $cid;

  my $channel = RHN::Channel->lookup(-id => $cid);
  return 0 unless $channel->is_eoled;

  return 1;
}

#really just looks to see if the 'cid' formvar is present
sub channel_exists {
  my $pxt = shift;

  my $cid = $pxt->param('cid');

  return 0 unless $cid;

  return 1;
}

sub channel_is_local {
  my $pxt = shift;

  my $ccid = $pxt->param('ccid');
  throw 'no ccid param' unless $ccid;

  my $cc = RHN::ConfigChannel->lookup(-id => $ccid);

  return 0 if $cc->confchan_type_id == 3;

  return 1;
}

sub channel_is_protected {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  throw 'no cid param' unless $cid;

  my $channel = RHN::Channel->lookup(-id => $cid);
  return $channel->is_protected;
}

sub channel_accessible {
  my $pxt = shift;

  throw 'channel_accessible_acl_test called with no $pxt->user authenticated' unless $pxt->user;

  my $cid = $pxt->param('cid');
  throw 'channel_accessible_acl_test called with no cid param' unless $cid;

  return 0 unless $pxt->user->verify_channel_access($cid);

  return 1;
}

sub channel_is_base {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  throw 'no cid param' unless $cid;

  my $channel = RHN::Channel->lookup(-id => $cid);
  return 0 if $channel->parent_channel;

  return 1;
}

sub channel_is_satellite {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  throw 'no cid param' unless $cid;

  my $channel = RHN::Channel->lookup(-id => $cid);
  return 0 unless (grep { $channel->id == $_ } RHN::Channel->rhn_satellite_channels);

  return 1;
}

sub channel_is_proxy {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  throw 'no cid param' unless $cid;

  my $channel = RHN::Channel->lookup(-id => $cid);
  return 0 unless (grep { $channel->id == $_ } RHN::Channel->rhn_proxy_channels);

  return 1;
}

sub channel_is_licensed {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  throw 'no cid param' unless $cid;

  return 0 unless (RHN::Channel->license_path($cid));

  return 1;
}

sub channel_subscribable {
  my $pxt = shift;

  return 0 unless channel_accessible($pxt);
  return 0 if channel_is_base($pxt);
  return 0 if channel_is_satellite($pxt);
  return 0 if channel_is_proxy($pxt);
  return 0 unless $pxt->user->verify_channel_subscribe($pxt->param('cid'));

  return 1;
}

sub org_owns_cloned_channels {
  my $pxt = shift;

  my @channels = RHN::Channel->cloned_channels_owned_by_org($pxt->user->org_id);

  return 0 unless (scalar @channels);

  return 1;
}

sub org_channel_setting {
  my $pxt = shift;
  my $label = shift;

  my $cid = $pxt->param('cid');
  die "No cid" unless $cid;

  return 0 unless $pxt->user->org->org_channel_setting($cid, $label);

  return 1;
}

#the current user has the given role in regards to channel in 'cid'
sub user_can_admin_channel {
  my $pxt = shift;

  my $cid = $pxt->param('cid');
  die "No cid" unless $cid;

  return 0 unless $pxt->user->verify_channel_admin($cid);

  return 1;
}

sub channel_is_clone {
  my $pxt = shift;
  my $cid = $pxt->param('cid');
  return 0 unless $cid;

  return 0 unless RHN::Channel->channel_cloned_from($cid);

  return 1;
}

# Does the packaging type of the channel match the input?  (rpm, sysv-solaris, tar)
sub channel_packaging_type {
  my $pxt = shift;
  my $type = shift;

  my $cid = $pxt->param('cid');
  return 0 unless $cid;

  return 1 if (RHN::Channel->packaging_type($cid) eq $type);

  return 0;
}

# UI bits to turn on or off based upon the package type (rpm, solaris, tar, etc)
sub channel_type_capable {
  my $pxt = shift;
  my $cap = shift;

  my $cid = $pxt->param('cid');
  return 0 unless $cid;

  return 1 if (RHN::Channel->channel_type_capable($cid, $cap));

  return 0;
}

1;
