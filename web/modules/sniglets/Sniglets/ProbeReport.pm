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

package Sniglets::ProbeReport;

use Data::Dumper;
use URI::Escape;

use RHN::DataSource;
use RHN::Date;
use RHN::SCDB;
use RHN::TSDB;

use Moon::Chart;
use Moon::Dataset::Coordinate;
use Moon::Dataset::Function;
use Moon::Chart::TimeAxes;

use Sniglets::ServerActions;

use PXT::HTML;
use PXT::Handlers;


my $MAX_DISPLAY_ROWS = 100;  # Max # of event logs rows to display


###################
sub register_tags {
###################
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-probe-current-state', \&probe_current_state);
  $pxt->register_tag('rhn-probe-report-setup', \&report_setup);
  $pxt->register_tag('rhn-probe-metrics-multiple', \&probe_metrics_multiple);
  $pxt->register_tag('rhn-probe-report', \&probe_report);
  $pxt->register_tag('rhn-probe-tsdb-graph', \&tsdb_graph);
}



########################
sub register_callbacks {
########################
  my $class = shift;
  my $pxt = shift;

}



#########################
sub probe_current_state {
#########################
  my $pxt      = shift;
  my %params   = @_;
  my $block    = $params{__block__};
  my $probe_id = $pxt->param('probe_id');
  my($html, $data);


  # Collect probe data from the database (REQUIRED)
  $data = RHN::DataSource::Simple->new(
            -querybase => 'probe_queries',
            -mode      => 'probe',
          )->execute_full(-probe_id => $probe_id);

  my $probe = $data->[0];

  die("ERROR:  No probe record for probe $probe_id!") unless ($probe);

  # Collect probe state data from the database (OPTIONAL)
  $data = RHN::DataSource::Simple->new(
            -querybase => 'probe_queries',
            -mode      => 'probe_state',
          )->execute_full(-probe_id => $probe_id);

  my $pstate = $data->[0];

  unless ($pstate) {
    $pstate = {
      STATE      => 'PENDING',
      OUTPUT     => '(No probe state)',
      LAST_CHECK => '',
    };
  }

  if ($pstate->{'LAST_CHECK'}) {
    my $timestamp = new RHN::Date(-string => $pstate->{'LAST_CHECK'}, user => $pxt->user);
    my $css_class = '';

    if ($pstate->{'STATE'} eq 'CRITICAL') {
      $css_class = 'class="probe-status-critical"';
    }
    elsif ($pstate->{'STATE'} eq 'UNKNOWN') {
      $css_class = 'class="probe-status-unknown"';
    }

    # Display the probe state
    $html .= "<table class=\"details\">\n";

    $html .= "<tr>\n";
    $html .= "<th>Probe:</th>\n";
    $html .= "<td>" . $probe->{'DESCRIPTION'} . "</td>\n";
    $html .= "</tr>\n";

    $html .= "<tr>\n";
    $html .= "<th>Status:</th>\n";
    $html .= sprintf("<td $css_class>%s - %s</td>\n", $pstate->{'STATE'},
		                           $pstate->{'OUTPUT'});
    $html .= "</tr>\n";

    $html .= "<tr>\n";
    $html .= "<th>Last check:</th>\n";
    $html .= "<td>" . $timestamp->long_date_with_zone($pxt->user) . "</td>\n";
    $html .= "</tr>\n";

    $html .= "</table>\n";

  }
  else {
    $html .= "<table class=\"details\">\n";

    $html .= "<tr>\n";
    $html .= "<th>NO CURRENT STATE FOUND</th>\n";
    $html .= "</tr>\n";
    $html .= "</table>\n";

  }

  return $html;
}



##################
sub report_setup {
##################
  my $pxt       = shift;
  my %params    = @_;
  my $block     = $params{__block__};
  my $probe_id  = $pxt->param('probe_id');
  my $submitted = $pxt->dirty_param('doit');
  my $html      = '';

  # Create the various widgets
  my $start_widget   = &Sniglets::ServerActions::date_pickbox($pxt,
                         preserve => 1,
                         prefix   => 'start_',
                         years    => '0,-1,-2',
                       );

  my $end_widget     = &Sniglets::ServerActions::date_pickbox($pxt,
                         preserve => 1,
                         prefix   => 'end_',
                         years    => '0,-1,-2',
                       );

  # This will be undef if there are no metrics
  my $metrics_widget = &probe_metrics_multiple($pxt);

  my $graph_checked  = $submitted ? $pxt->dirty_param('show_graph') : 1;
  my $graph_checkbox = PXT::HTML->checkbox(
                         -checked => $graph_checked,
                         -name    => 'show_graph',
                       );

  my $log_checked    = $submitted ? $pxt->dirty_param('show_events') : 1;
  my $log_checkbox   = PXT::HTML->checkbox(
                         -checked => $log_checked,
                         -name    => 'show_events',
                       );

  my $submit         = PXT::HTML->submit(
                         -name  => "doit", 
                         -value => "Generate report",
                       ) . "\n";

  my $old_min_y      = $pxt->dirty_param('min_y');
  my $min_y_widget   = PXT::HTML->text(
                         -name  => "min_y", 
                         -size  => 5,
                         -value => $old_min_y,
                       ) . "\n";

  my $old_max_y      = $pxt->dirty_param('max_y');
  my $max_y_widget   = PXT::HTML->text(
                         -name  => "max_y", 
                         -size  => 5,
                         -value => $old_max_y,
                       ) . "\n";


  # Display the probe report setup area
  $html .= "<table class=\"details\">\n";

  $html .= "<tr>\n";
  $html .= "<th>Start date:</th>\n";
  $html .= "<td>$start_widget</td>\n";

  $html .= "<td>&nbsp;&nbsp;</td>\n";

  if ($metrics_widget) {
    $html .= "<th rowspan='2'>Metrics:</th>\n";
    $html .= "<td rowspan='2'>$metrics_widget</td>\n";
  }

  $html .= "</tr>\n";

  $html .= "<tr>\n";
  $html .= "<th>End date:</th>\n";
  $html .= "<td>$end_widget</td>\n";
  $html .= "</tr>\n";


  if ($metrics_widget) {
    $html .= "<tr>\n";
    $html .= "<th>Show graph:</th>\n";
    $html .= "<td>$graph_checkbox</td>\n";

    if ($pxt->dirty_param('show_graph')) {
      $html .= "<td>&nbsp;&nbsp;</td>\n";
      $html .= "<th>Minimum Y value</th>\n";
      $html .= "<td>$min_y_widget</td>\n";
    }
    $html .= "</tr>\n";
  }

  $html .= "<tr>\n";
  $html .= "<th>Show event log:</th>\n";
  $html .= "<td>$log_checkbox</td>\n";

  if ($metrics_widget) {
    if ($pxt->dirty_param('show_graph')) {
      $html .= "<td>&nbsp;&nbsp;</td>\n";
      $html .= "<th>Maximum Y value</th>\n";
      $html .= "<td>$max_y_widget</td>\n";
    }
  }

  $html .= "</tr>\n";



  $html .= "<tr>\n";
  $html .= "<td>$submit</td>\n";
  $html .= "</tr>\n";

  $html .= "</table>\n";

  $html .= &PXT::Handlers::pxt_hidden_handler($pxt, name => "sid") . "\n";
  $html .= &PXT::Handlers::pxt_hidden_handler($pxt, name => "probe_id") . "\n";


  $html = &PXT::Handlers::pxt_form_handler($pxt, 
            __block__ => $html,
            method    => 'post',
          );


  return $html;
}



############################
sub probe_metrics_multiple {
############################
  my $pxt      = shift;
  my %params   = @_;
  my $block    = $params{__block__};
  my $probe_id = $pxt->param('probe_id');
  my($html, %data);

  my @submitted_metrics = $pxt->dirty_param('metrics');
  my %checked; @checked{@submitted_metrics} = (1) x @submitted_metrics;

  # Collect probe data from the database
  my $data = RHN::DataSource::Simple->new(
               -querybase => 'probe_queries',
               -mode      => 'probe_metrics',
             )->execute_full(-probe_id => $probe_id);

  my @metrics;
  foreach my $metric (@$data) {
    push(@metrics, [
                     $metric->{'LABEL'}, 
                     $metric->{'METRIC_ID'}, 
                     $checked{$metric->{'METRIC_ID'}},
                   ]
        );
  }

  if (@metrics) {

    return PXT::HTML->select(
      -name     => 'metrics',
      -size     => 3,
      -multiple => 1,
      -options  => \@metrics,
    );

  } else {

    return undef;

  }

}



##################
sub probe_report {
##################
  my $pxt      = shift;
  my %params   = @_;
  my $org_id   = $pxt->user->org_id;
  my $probe_id = $pxt->param('probe_id');
  my $sid      = $pxt->param('sid');
  my $min_y    = $pxt->dirty_param('min_y');
  my $max_y    = $pxt->dirty_param('max_y');
  my $html;

  return $html unless ($pxt->dirty_param('doit'));

  my $show_graph  = $pxt->dirty_param('show_graph');
  my $show_events = $pxt->dirty_param('show_events');

  if ($show_events or $show_graph) {
    my $start_date = Sniglets::ServerActions->parse_date_pickbox($pxt, 
                       prefix    => 'start_', 
                       long_date => 0,
                     );
    my $end_date   = Sniglets::ServerActions->parse_date_pickbox($pxt, 
                       prefix    => 'end_',
                       long_date => 0,
                     );

    if (not $start_date or not $end_date) {

      $pxt->push_message(local_alert => 'Please pick a valid start date.') unless ($start_date);
      $pxt->push_message(local_alert => 'Please pick a valid end date.') unless ($end_date);

    } elsif ($start_date >= $end_date) {

      $pxt->push_message(local_alert => 'Please select a start date earlier than the end date.');

    } else {

      if ($show_graph) {
        my @metrics = $pxt->dirty_param('metrics');
        if (@metrics) {
          $html .= &graph_url(
                     sid      => $sid,
                     org_id   => $org_id,
                     probe_id => $probe_id,
                     start    => $start_date,
                     end      => $end_date,
                     min_y    => $min_y,
                     max_y    => $max_y,
                     metrics  => \@metrics,
                   ) . "\n";
        } else {
          $pxt->push_message(local_alert => 'Please select one or more metrics to graph.');
        }
      }

      if ($show_events) {
        $html .= &event_log(
                   pxt      => $pxt,
                   probe_id => $probe_id,
                   start    => $start_date,
                   end      => $end_date,
                 );
      }

    }


  } else {
    $html .= "You probably want to select at least one of 'Show graph' ";
    $html .= "or 'Show event log'.";
  }



  return $html;
}


###############
sub event_log {
###############
  my %params = @_;
  my $pxt    = $params{'pxt'};
  my $html   = "<h2>Event log</h2>\n";

  my $results = RHN::SCDB->new()->fetch(
    probe_id => $params{'probe_id'},
    start    => $params{'start'},
    end      => $params{'end'},
  );

  if (@$results) {

    $html .= "<table class='list' width='96%' align='center'>\n";
    $html .= "<tr>\n";
    $html .= "<th>Timestamp</th>\n";
    $html .= "<th>State</th>\n";
    $html .= "<th>Message</th>\n";
    $html .= "</tr>\n";

    for (my $i = 1; $i <= @$results; $i++) {

      my $rowstyle = ($i % 2 == 0) ? 'list-row-even' : 'list-row-odd';

      if ($i > $MAX_DISPLAY_ROWS) {
        my $left = @$results - $i + 1;
        $html .= "<tr class='$rowstyle'>\n";
        $html .= "<td nowrap='1' colspan='3'>\n";
        $html .= "(... $MAX_DISPLAY_ROWS entries displayed, ";
        $html .= "$left remaining entries not displayed)\n";
        $html .= "</td>\n";
        $html .= "</tr>\n";
        last;
      }

      my($time, $state, $escaped) = @{$results->[-$i]};
      my $msg = &uri_unescape($escaped);
      my $timestamp = new RHN::Date(-epoch => $time, user => $pxt->user);

      $html .= "<tr class='$rowstyle'>\n";
      $html .= "<td nowrap='1'>" . $timestamp->long_date_with_zone($pxt->user) . "</td>\n";
      $html .= "<td align='center'>$state</td>\n";
      $html .= "<td>$msg</td>\n";
      $html .= "</tr>\n";

    }
    $html .= "</table>\n";

  } else {

    $html .= "No events this period\n";

  }

  return $html;

}

###############
sub graph_url {
###############
  my %p = @_;
  my $metrics = delete($p{'metrics'});
  my $html = "<h2>Time series</h2>\n";

  my @params;
  foreach my $key (keys %p) {
    push(@params, "$key=$p{$key}");
  }

  foreach my $metric (@$metrics) {
    my $params = join('&amp;', @params, "metric=$metric");
    my $src    = "graph.pxt?$params";
    $html     .=  PXT::HTML->img(-src => $src);
  }

  return '<div style="text-align: center">' . $html . '</div>';
}


# Generate a time series graph
################
sub tsdb_graph {
################
  my $pxt       = shift;
  my $org_id    = $pxt->user->org_id;
  my $probe_id  = $pxt->param('probe_id');
  my $metric_id = $pxt->dirty_param('metric');
  my $min_y     = $pxt->dirty_param('min_y');
  my $max_y     = $pxt->dirty_param('max_y');

  # Fetch the dataset from the TSDB
  my $tsdata = RHN::TSDB->new()->fetch(
    org_id   => $org_id,
    probe_id => $probe_id,
    metric   => $metric_id,
    start    => $pxt->dirty_param('start') - 600,
    end      => $pxt->dirty_param('end') + 600,
  );

  # Fetch metric labels and units
  my $data = RHN::DataSource::Simple->new(
               -querybase => 'probe_queries',
               -mode      => 'probe_metric',
             )->execute_full(
               -probe_id  => $probe_id,
               -metric_id => $metric_id,
             );


  my $metric = $data->[0];
  die ("ERROR:  No metric '$metric_id' for probe $probe_id") unless ($metric);

  my $sd = Moon::Dataset::Coordinate->new(
             -coords => $tsdata, 
             -label  => $metric->{'LABEL'},
            );

  my $no_data_image;

  if (@$tsdata) {
    $max_y = $sd->max_y unless (length($max_y));
    $min_y = $sd->min_y unless (length($min_y));
  } else {
    # No data, show prefab image w/ informative text
    $no_data_image = '/var/www/html/img/rhn-no-ts-data.png';
  }

  if (abs($max_y - $min_y) < 0.02 * $max_y) {
    $max_y = 2 * $max_y;
    $min_y = 0;
  }


  my $chart = new Moon::Chart(800, 250);

  $chart->add_dataset($sd->label, $sd);

  $chart->graph_stencil_min(0.05, 0.2);

  $chart->graph_stencil_max(0.97, 0.95);

  my $axes = new Moon::Chart::TimeAxes(undef, undef, undef, $pxt->user);

  $axes->set_bounds(
    [$pxt->dirty_param('start'), $min_y ], 
    [$pxt->dirty_param('end')  , $max_y * 1.01]
  );

  $chart->set_axes($axes);
  
  my $imgfile;
  if ($no_data_image) {
    $imgfile = $no_data_image;
  }
  else {
    $imgfile = "/tmp/mychart.$$.png";
    $chart->render_to_file($imgfile);
  }

  # Send that puppy
  $pxt->manual_content(1);
  $pxt->no_cache(1);
  $pxt->content_type('image/png');
  $pxt->header_out('Content-length' => -s $imgfile);
  $pxt->send_http_header;

  open(FILE, $imgfile) or die "Couldn't open $imgfile: $!";
  $pxt->send_fd(*FILE);
  close(FILE);

  unlink($imgfile) if not $no_data_image;


}


1;
