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
package RHN::Kickstart::Template;

use PXT::Config;
use RHN::Kickstart;
use RHN::Kickstart::Commands;
use RHN::Kickstart::Partitions;
use RHN::KSTree;

use Data::Dumper;

sub get_template_ks {
  my $class = shift;
  my $org_id = shift;
  my $install_type = shift || 'rhel_2.1';

  die "No org id" unless $org_id;

  my %commands = (-install => '',
		  -text => '',
		  -network => [ qw/--bootproto dhcp/ ],
		  -url => [ qw(--url http://rhn.webdev.redhat.com/kickstart/dist/<dist>/) ],
		  -auth => [ qw(--enablemd5 --enableshadow) ],
		  -bootloader => [ qw(--location mbr) ],
		  -lang => 'en_US',
		  -langsupport => [ qw(--default en_US en_US) ],
		  -keyboard => 'us',
		  -mouse => 'none',
		  -zerombr => 'yes',
		  -clearpart => [ qw/--all/ ],
		  -firewall => [ qw/--disabled/ ],
		  -rootpw => '',
		  -timezone => [ 'America/New_York' ],
		  -skipx => '',
		  -reboot => '',
		 );

  if ($install_type eq 'rhel_4') {
    $commands{-partitions} = new RHN::Kickstart::Partitions( [ qw(/boot --fstype=ext3 --size=200) ],
							     [ qw(swap --size=2000) ],
							     [ qw(pv.01 --size=1000 --grow) ],
							   );
    $commands{-volgroups} = new RHN::Kickstart::Volgroups( [ qw(myvg pv.01) ] );
    $commands{-logvols} = new RHN::Kickstart::Logvols( [ qw(/ --vgname=myvg --name=rootvol --size=1000 --grow) ] );
  }
  else {
    $commands{-partitions} = new RHN::Kickstart::Partitions( [ qw(/boot --fstype=ext3 --size=200) ],
							     [qw(swap --size=1000 --grow --maxsize=2000) ],
							     [ qw(/ --fstype=ext3 --size=700 --grow) ]
							   );
  }

  my @packages = ('@ Base');

  my $ks = new RHN::Kickstart(-name => 'New Kickstart profile',
			      -label => 'new_kickstart_profile',
			      -commands => \%commands,
			      -org_id => $org_id);

  $ks->packages(@packages);

  my $post = q!
# MOTD
echo >> /etc/motd
echo "RHN kickstart on $(date +'%Y-%m-%d')" >> /etc/motd
echo >> /etc/motd
!;

  $ks->post($post);

  my $host = PXT::Config->get('kickstart_host') || PXT::Config->get('base_domain');
  $ks->change_url_host($host);

  return $ks;
}

1;
