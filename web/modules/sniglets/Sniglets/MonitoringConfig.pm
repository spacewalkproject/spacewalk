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

package Sniglets::MonitoringConfig;

use Data::Dumper;

use RHN::MonitoringConfigMacro;
use RHN::SatInstall;
use RHN::ProxyInstall;

use Sniglets::Forms;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-editable-monitoring-macros", \&editable_macros);
  $pxt->register_tag("rhn-squelch-notifications", \&squelch_notifications);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:monitoring-config-edit-cb' => \&update_cb);
}


sub squelch_notifications {
  my $pxt = shift;

  my $am_squelched = RHN::MonitoringConfigMacro->are_notifications_squelched();

  return PXT::HTML->checkbox(-name => 'squelch',
			     -value => 1,
			     -checked => ($am_squelched ? 1 : 0));
}

#####################
sub editable_macros {
#####################
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $html;

  my $macros = RHN::MonitoringConfigMacro->load_editable_macros();

  foreach my $macro (@$macros) {
    my $row = $block;
    $row =~ s/{macro_name}/$macro->name()/eg;
    $row =~ s/{macro_definition}/$macro->definition()/eg;
    $row =~ s/{macro_description}/$macro->description()/eg;
    $html .= $row;
  }

  return $html;
}

###############
sub update_cb {
###############
  my $pxt = shift;

  # Fetch current values to compare against submitted values
  my $macros = RHN::MonitoringConfigMacro->load_editable_macros();

  foreach my $macro (@$macros) {
    my $mname    = $macro->name();
    my $olddef   = $macro->definition();
    my $newdef   = $pxt->dirty_param($mname);

    if ($olddef ne $newdef) {
      $macro->definition($newdef);
      $macro->update($pxt->user->login) or die "Couldn't update macro: $!";
    }
  }

  if (PXT::Config->get('is_monitoring_scout')) {
    RHN::SatInstall->restart_satellite(-delay => 0,
				       -service => 'MonitoringScout');
  }

  RHN::SatInstall->restart_satellite(-delay => 5,
				     -service => 'Monitoring');

  $pxt->push_message(site_info => 'Configuration updated, Monitoring services restarted.');

  my $proxy_config_aid = RHN::ProxyInstall->push_monitoring_config_changes($pxt->user);

  if ($proxy_config_aid) {
    $pxt->push_message(site_info => <<EOQ);
A Monitoring Proxy configuration update has been
<strong><a href="/rhn/schedule/ActionDetails.do?aid=$proxy_config_aid">scheduled</a></strong>.
EOQ
  }

  return;
}



1;
