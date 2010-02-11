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

package Sniglets::ListView::ProbeList;

use PXT::Utils;
use Sniglets::ListView::List;
use RHN::DataSource::Probe;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:probe_list_cb";
}

sub list_of { return "probes" }

sub _register_modes {
  Sniglets::ListView::List->add_mode(-mode => "system_probes",
				     -datasource => new RHN::DataSource::Simple(-querybase => "probe_queries"));
  Sniglets::ListView::List->add_mode(-mode => "system_groups_probes",
                                     -datasource => RHN::DataSource::Probe->new,
                                     -provider => \&system_groups_probes_provider);
  Sniglets::ListView::List->add_mode(-mode => "ok_system_probes",
				     -datasource => new RHN::DataSource::Simple(-querybase => "probe_queries"));
  Sniglets::ListView::List->add_mode(-mode => "warning_system_probes",
				     -datasource => new RHN::DataSource::Simple(-querybase => "probe_queries"));
  Sniglets::ListView::List->add_mode(-mode => "critical_system_probes",
				     -datasource => new RHN::DataSource::Simple(-querybase => "probe_queries"));
  Sniglets::ListView::List->add_mode(-mode => "unknown_system_probes",
				     -datasource => new RHN::DataSource::Simple(-querybase => "probe_queries"));
  Sniglets::ListView::List->add_mode(-mode => "pending_system_probes",
				     -datasource => new RHN::DataSource::Simple(-querybase => "probe_queries"));
  Sniglets::ListView::List->add_mode(-mode => "all_system_probes",
				     -datasource => new RHN::DataSource::Simple(-querybase => "probe_queries"));
  Sniglets::ListView::List->add_mode(-mode => "probes_for_contact_method",
                                     -datasource => RHN::DataSource::Probe->new,
                                     -provider => \&probes_for_method_provider);
}


sub probes_for_method_provider {
  my $self = shift;
  my $pxt = shift;
  my $cmid = $pxt->param('cmid');
  my %ret = $self->default_provider($pxt, (-method_id => $cmid));

  return (%ret);
}


sub system_groups_probes_provider {
  my $self = shift;
  my $pxt = shift;
  my $sgid = $pxt->param('sgid');
  my %ret = $self->default_provider($pxt, (-group_id => $sgid));

  return (%ret);
}


sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  # convert the date to the proper format for display
  if (exists $row->{LAST_CHECK}) {
    $row->{LAST_CHECK} = $pxt->user->convert_time($row->{LAST_CHECK}, "%F %r %Z");
  }

  # Fill in the details for the state icon row.
  if (exists $row->{PROBE_STATE}) {
      if (not defined $row->{PROBE_STATE}) {
	  $row->{PROBE_STATE} = 'PENDING';
      }
      $row->{PROBE_STATE_ICON} = PXT::HTML->img(-src => $self->get_probe_state_icon($row->{PROBE_STATE}),
					     -alt => ucfirst(lc($row->{PROBE_STATE})),
					     -title => ucfirst(lc($row->{PROBE_STATE})));
  }
  return $row;
}

sub get_probe_state_icon {
  my $self = shift;
  my $state = shift;

  # map the probe state to an icon
  my %state_icon_map = ( OK => "/img/rhn-mon-ok.gif",
                         WARNING => "/img/rhn-mon-warning.gif",
                         CRITICAL => "/img/rhn-mon-down.gif",
                         UNKNOWN => "/img/rhn-mon-unknown.gif",
                         PENDING => "/img/rhn-mon-pending.gif");

  my $icon = $state_icon_map{uc($state)};

  die "unknown value for probe_state: $state" unless defined $icon;
  return $icon;
}

sub render_url {
  my $self = shift;
  my $pxt = shift;
  my $url = shift;
  my $row = shift;
  my $url_column = shift;

  my $ret = $self->SUPER::render_url($pxt, $url, $row, $url_column);

  if (($self->datasource->mode eq 'probes_for_contact_method')
      and (not $pxt->user->verify_system_access($row->{SYSTEM_ID}))
     ) {
    $ret = $row->{$url_column};
  }

  return $ret;
}

1;
