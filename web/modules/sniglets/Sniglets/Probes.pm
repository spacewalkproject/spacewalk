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

package Sniglets::Probes;

use Data::Dumper;

use RHN::Command;
use RHN::CommandParameter;
use RHN::ContactGroup;
use RHN::DataSource;
use RHN::Exception;
use RHN::Probe;
use RHN::ProbeParam;
use RHN::Server;

use RHN::Form::Widget::Checkbox;
use RHN::Form::Widget::Hidden;
use RHN::Form::Widget::Literal;
use RHN::Form::Widget::Password;
use RHN::Form::Widget::Select;
use RHN::Form::Widget::Submit;
use RHN::Form::Widget::Text;

use PXT::Utils;
use PXT::HTML;

use Sniglets::Forms;
use Sniglets::Navi::Style;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-probe-state-summary", \&probe_state_summary);
}


sub probe_state_summary {
  my $pxt = shift;
  my %params = @_;

  # my $ds = new RHN::DataSource::Simple(-querybase => 'probe_queries', -mode => 'probe_state_summary');
  my $ds = new RHN::DataSource::Simple(-querybase => 'probe_queries', -mode => 'probe_state_count_by_state_and_user');

  my $probe_state_summary = { total => 0 };
  

  my @states = qw/ok warning critical unknown pending/;

  # process the data looking for states that we recognize and rolling up the total
  # number of probes configured.
  foreach my $state (@states) {
    my $data = $ds->execute_query(-user_id => $pxt->user->id, -state => uc($state));
    foreach my $row (@{$data}) {
      $probe_state_summary->{$state} = $row->{STATE_COUNT};
      $probe_state_summary->{total} += $row->{STATE_COUNT};
    }
  }

  my @probe_state_display = ( 
			      { label => 'critical',
				name  => 'Critical',
                                icon  => '/img/rhn-mon-down.gif',
				value => ($probe_state_summary->{critical} || 0),
				mode  => 'critical' },
			      { label => 'warning',
				name  => 'Warning',
                                icon  => '/img/rhn-mon-warning.gif',
				value => ($probe_state_summary->{warning} || 0),
				mode  => 'warning' },
			      { label => 'unknown',
				name  => 'Unknown',
                                icon  => '/img/rhn-mon-unknown.gif',
				value => ($probe_state_summary->{unknown} || 0),
				mode  => 'unknown' },
			      { label => 'pending',
				name  => 'Pending',
                                icon  => '/img/rhn-mon-pending.gif',
				value => ($probe_state_summary->{pending} || 0),
				mode  => 'pending' },
                              { label => 'ok',
				name  => 'OK',
                                icon  => '/img/rhn-mon-ok.gif',
				value => ($probe_state_summary->{ok} || 0),
				mode  => 'ok' },
			      { label => 'all',
				name  => 'All',
				value => $probe_state_summary->{total},
				mode  => 'all' },
			    );

  if (($probe_state_summary->{total} == 0) and (not defined $params{no_probes_message})) {
    return;
  }

  my $navbar = Sniglets::Navi::Style->new('contentnav');

  my $level = 0;
  my $html .= $navbar->pre_nav;
  $html .= $navbar->pre_level($level);
  my $selected_mode = $params{"selected_mode"};

  foreach my $attrib (@probe_state_display) {
    my $active = ((defined $selected_mode) and ($selected_mode =~ /^$attrib->{mode}/));
    my $link_style = $active ? $navbar->link_style_active($level) : $navbar->link_style($level);
    my $mode_url = $params{"link_url"};
    $mode_url =~ s/\{mode\}/$attrib->{mode}/eg;

    my $link_content;
    if (defined $attrib->{icon}) {
      $link_content .= "<span class=\"toolbar\">";
      $link_content .= PXT::HTML->img( -src => $attrib->{icon} ); 
      #leave out alt and title since the text is right next to it.
      #, -alt => $attrib->{name}, -title => $attrib->{name} );
      $link_content .= "</span>";
    }
    $link_content .= $attrib->{name} . " (" . $attrib->{value} . ")";

    $html .= $navbar->pre_item($pxt, $active, $level);

    $html .= PXT::HTML->link($mode_url, $link_content, $link_style);

    $html .= $navbar->post_item;

  }

  if ($probe_state_summary->{total} == 0) {
    my $msg = $params{no_probes_message};

    $html .= <<EOQ;
<li class="graydata"><strong>$msg</strong></li>
EOQ
  }

  $html .= $navbar->post_level;
  $html .= $navbar->post_nav($pxt);

  return $html;
}


1;
