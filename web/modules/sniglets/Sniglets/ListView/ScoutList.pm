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

package Sniglets::ListView::ScoutList;

use PXT::HTML;

use RHN::Exception qw/throw/;
use RHN::Token;
use RHN::DataSource::Scout;
use RHN::SatCluster;
use RHN::Set;

use Sniglets::ListView::List;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:scout_list_cb";
}

sub list_of { return "scouts" }

sub _register_modes {
  Sniglets::ListView::List->add_mode(-mode => "scouts_for_org",
				     -datasource => new RHN::DataSource::Simple(-querybase => "scout_queries"),
				     -action_callback => \&push_config_cb);
				     
  Sniglets::ListView::List->add_mode(-mode => "scouts_all",
				     -datasource => new RHN::DataSource::Simple(-querybase => "scout_queries"),
				     -action_callback => \&push_config_cb);				     
}

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  my $status = $row->{CONFIG_STATUS};

  if (defined $row->{DATE_EXECUTED}) {
    if ($row->{PUSH_NEEDED}) {
      $status = 'needed';
    }
  }

  # convert the dates to the proper format for display
  if (exists $row->{DATE_SUBMITTED}) {
      $row->{DATE_SUBMITTED} = $pxt->user->convert_time($row->{DATE_SUBMITTED}, "%F %r %Z");
  }
  if (exists $row->{DATE_EXECUTED}) {
    if (defined $row->{DATE_EXECUTED}) {
      $row->{DATE_EXECUTED} = $pxt->user->convert_time($row->{DATE_EXECUTED}, "%F %r %Z");
    }
    elsif (uc($status) eq "PENDING") {
      $row->{DATE_EXECUTED} = "(Request Pending)";
    }
    elsif (uc($status) eq "EXPIRED") {
      $row->{DATE_EXECUTED} = "(Request Expired)";
    }
  }

  if (not defined $status) {
    $status = "needed";
    $row->{DATE_EXECUTED} = "(PUSH Needed)";
    $row->{DATE_SUBMITTED} = "(PUSH Needed)";
  }
  $row->{CONFIG_STATUS_ICON} = PXT::HTML->img(-src => $self->get_config_status_icon($status),
                                              -alt => ucfirst(lc($status)),
                                              -title => ucfirst(lc($status)));
  return $row;
}

sub get_config_status_icon {
  my $self = shift;
  my $status = shift;

  my %status_icon_map = ( OK => "/img/configureScoutOK.gif",
			  PENDING   => "/img/configureScoutPending.gif",
			  WARNING   => "/img/configureScoutWarning.gif",
			  EXPIRED   => "/img/configureScoutError.gif",
			  ERROR     => "/img/configureScoutError.gif",
                          NEEDED    => "/img/configureScout.gif"
	       	         );

  my $icon = $status_icon_map{uc($status)};

  die "unknown value for config_push_state: $status" unless defined $icon;
  return $icon;

}


sub push_config_cb {
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

  if (exists $action{label} and $action{label} eq 'push_config') {

    my $uid = $pxt->user->id;
    my $org_id = $pxt->user->org_id;
    my $set_label = $pxt->dirty_param('set_label');
    my $scout_set = RHN::Set->lookup(-label => $set_label, -uid => $uid);


    my @scout_ids = $scout_set->contents;
    $scout_set->empty;
    $scout_set->commit;

    foreach my $sat_cluster_id (@scout_ids) {
      RHN::SatCluster->push_config($org_id, $sat_cluster_id, $uid);
    }
    $pxt->push_message(site_info => '<strong>Config Push Initiated</strong>');


  }


}



1;
