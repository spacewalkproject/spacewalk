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

# Server - Object
use strict;

package RHN::Server;

use PXT::HTML ();
use PXT::Utils ();
use RHN::Action ();

use RHN::DB::Server;
our @ISA = qw/RHN::DB::Server/;

sub lookup {
  my $class = shift;
  my $first_arg = $_[0];

  die "No argument to $class->lookup"
    unless $first_arg;

  if (substr($first_arg,0,1) eq '-') {
    return $class->SUPER::lookup(@_);
  }
  else {
    warn "deprecated use of unparameterized $class->lookup from (" . join(', ', caller) . ")\n";
    return $class->SUPER::lookup(-id => $first_arg);
  }
}

sub lookup_server_event {
  my $class = shift;
  my $sid = shift;
  my $aid = shift;

  my ($label, $struct) = RHN::DB::Server->server_event_details($sid, $aid);

  if (not defined $label) {
    return bless $struct, "RHN::ServerEvent::History";
  }
  elsif ($label eq 'errata.update') {
    return bless $struct, "RHN::ServerEvent::ErrataUpdate";
  }
  elsif ($label eq 'packages.update') {
    return bless $struct, "RHN::ServerEvent::PackageUpdate";
  }
  elsif (grep { $label eq $_ } qw/solarispkgs.install solarispkgs.patchInstall solarispkgs.patchClusterInstall/) {
    return bless $struct, "RHN::ServerEvent::PackageUpdate::Solaris";
  }
  elsif ($label eq 'packages.remove') {
    return bless $struct, "RHN::ServerEvent::PackageRemove";
  }
  elsif ($label eq 'packages.verify') {
    return bless $struct, "RHN::ServerEvent::PackageVerify";
  }
  elsif (grep { $label eq $_ } qw/solarispkgs.remove solarispkgs.patchRemove solarispkgs.patchClusterRemove/) {
    return bless $struct, "RHN::ServerEvent::PackageRemove::Solaris";
  }
  elsif ($label eq 'packages.runTransaction') {
    return bless $struct, "RHN::ServerEvent::DeltaTransaction";
  }
  elsif ($label eq 'configfiles.upload' or $label eq 'configfiles.mtime_upload') {
    return bless $struct, "RHN::ServerEvent::ConfigUpload";
  }
  elsif ($label eq 'configfiles.deploy') {
    return bless $struct, "RHN::ServerEvent::ConfigDeploy";
  }
  elsif ($label eq 'configfiles.diff') {
    return bless $struct, "RHN::ServerEvent::ConfigDiff";
  }
  elsif ($label eq 'script.run') {
    return bless $struct, "RHN::ServerEvent::RemoteCommand";
  }
  else {
    return bless $struct, "RHN::ServerEvent::SimpleAction";
  }
}

package RHN::ServerEvent;

package RHN::ServerEvent::History;
sub render {
  my $self = shift;

  my $ret;
  $ret->{server_event_summary} = $self->{SUMMARY};
  $ret->{server_event_details} = $self->{DETAILS};
  $ret->{server_event_time} = $self->{CREATED};

  return $ret;
}

package RHN::ServerEvent::SimpleAction;
sub render {
  my $self = shift;
  my $user = shift;

  my %formatted_dates = map { $_ => $self->{$_} ? $user->convert_time($self->{$_}) : "" }
    qw/EARLIEST_ACTION PICKUP_TIME CREATED COMPLETION_TIME/;

  my $ret;
  $ret->{server_event_summary} .= "$self->{ACTION_TYPE} scheduled by $self->{LOGIN}";

  $ret->{server_event_details} .= "This action will be executed after $formatted_dates{EARLIEST_ACTION}.<br /><br />";
  $ret->{server_event_details} .= "This action's status is: $self->{STATUS}.<br />";

  if ($self->{PICKUP_TIME}) {
    $ret->{server_event_details} .= qq{The client picked up this action on $formatted_dates{PICKUP_TIME}.<br />\n};

    if ($self->{COMPLETION_TIME}) {
      $ret->{server_event_details} .= qq{The client completed this action on $formatted_dates{COMPLETION_TIME}.<br />\n};

      $ret->{server_event_details} .= qq{Client execution returned "$self->{RESULT_MSG}" (code $self->{RESULT_CODE})<br />\n};
    }
    else {
      $ret->{server_event_details} .= qq{This action has not yet completed this action.<br />\n};
    }
  }
  else {
    $ret->{server_event_details} .= qq{This action has not yet been picked up.\n};
  }
  $ret->{server_event_time} = $formatted_dates{CREATED};
  return $ret;
}

package RHN::ServerEvent::ConfigUpload;
our @ISA = qw/RHN::ServerEvent::SimpleAction/;

sub render {
  my $self = shift;

  my $ret = $self->SUPER::render(@_);

  $ret->{server_event_details} .= qq{<div class="action-summary-config">Config Files:<br /><table width="100%">\n};

  for my $file (@{$self->{FILES}}) {

    my $failure_reason = $file->{FAILURE_REASON} || '';

    $ret->{server_event_details} .= <<EOR;
<tr><td class="action-summary-config">$file->{PATH}</td><td>$failure_reason</td></tr>
EOR

  }
  $ret->{server_event_details} .= qq{</table></div>\n};

  return $ret;
}

package RHN::ServerEvent::ConfigDeploy;
our @ISA = qw/RHN::ServerEvent::SimpleAction/;

sub render {
  my $self = shift;

  my $ret = $self->SUPER::render(@_);

  $ret->{server_event_details} .= qq{<div class="action-summary-config">Config Files:<br /><table width="100%">\n};

  my $sid = $self->{SERVER_ID};

  for my $rev (@{$self->{REVISIONS}}) {

    my $revision = $rev->{REVISION};
    my $failure_reason = $rev->{FAILURE_REASON} || '';

    my $url = PXT::HTML->link2(text => $rev->{PATH},
			       url => "/rhn/configuration/file/FileDetails.do?sid=$sid&amp;crid=" . $rev->{ID},
			      );

    my $file = "$url (rev. $revision)";

    $ret->{server_event_details} .= <<EOR;
<tr><td class="action-summary-config">$file</td><td>$failure_reason</td></tr>
EOR

  }
  $ret->{server_event_details} .= qq{</table></div>\n};

  return $ret;
}

package RHN::ServerEvent::ConfigDiff;
our @ISA = qw/RHN::ServerEvent::SimpleAction/;

sub render {
  my $self = shift;

  my $ret = $self->SUPER::render(@_);

  $ret->{server_event_details} .= qq{<div class="action-summary-config">Config Files:<br /><table width="100%">\n};

  for my $rev (@{$self->{REVISIONS}}) {

    my $sid = $self->{SERVER_ID};
    my $arid = $rev->{ACTION_REVISION_ID};
    my $crid = $rev->{REVISION_ID};

    my $results = '';

    if ($rev->{STATUS} and ($rev->{STATUS} eq 'Differences exist')) {
      $results = PXT::HTML->link2(text => $rev->{STATUS},
				  url => "/rhn/systems/details/configuration/ViewDiffResult.do?sid=$sid&amp;acrid=$arid",
				 );
    }
    else {
      $results = PXT::Utils->escapeHTML($rev->{STATUS} || '');
    }

    my $config_file = PXT::HTML->link2(text => $rev->{PATH},
				       url => "/rhn/configuration/file/FileDetails.do?crid=$crid&amp;sid=$sid",
				      );
    $config_file .= " (rev. $rev->{REVISION})";

    $ret->{server_event_details} .= <<EOR;
<tr><td class="action-summary-config">$config_file</td><td>$results</td></tr>
EOR
  }
  $ret->{server_event_details} .= qq{</table></div>\n};

  return $ret;
}

package RHN::ServerEvent::ErrataUpdate;
our @ISA = qw/RHN::ServerEvent::SimpleAction/;

sub render {
  my $self = shift;

  my $ret = $self->SUPER::render(@_);

  $ret->{server_event_details} .= qq{<div class="action-summary-errata">Errata Affected:<br /><ul>\n};

  for my $errata (@{$self->{ERRATA}}) {
    $ret->{server_event_details} .= qq{  <li class="action-summary-errata-advisory">$errata->{ADVISORY} ($errata->{SYNOPSIS})</li>\n};
  }
  $ret->{server_event_details} .= qq{</ul></div>\n};

  return $ret;
}


package RHN::ServerEvent::PackageAction;
our @ISA = qw/RHN::ServerEvent::SimpleAction/;

sub dependency_errors {
  my $self = shift;
  my $ret = shift;

  # package dependency errors... we are clamping at 20 for this view, beyond that go to list view
  if ($self->{STATUS} eq 'Failed' and $self->{NUM_SHOWN_PKG_DEPENDENCY_ERRORS}) {

    $ret->{server_event_details} .= qq{<div class="action-summary-package">Dependency errors encountered:<br /><ul>\n};

    foreach my $dependency (@{$self->{PACKAGE_RMV_DEPENDENCY_ERRORS}}) {
      $ret->{server_event_details} .= qq{  <li class="action-summary-package-nvre">$dependency->{DEPENDENCY_ERROR}</li>\n};
    }

    $ret->{server_event_details} .= qq{</ul></div>\n};

    if ($self->{NUM_SHOWN_PKG_DEPENDENCY_ERRORS} < $self->{TOTAL_PKG_DEPENDENCY_ERRORS}) {
      $ret->{server_event_details} .= qq{<div class="action-summary-package">};
      $ret->{server_event_details} .= PXT::HTML->link('/network/systems/details/history/dependency_failures.pxt?sid=' . $self->{SERVER_ID} . 
						      '&amp;hid=' . $self->{ACTION_ID}, "View all $self->{TOTAL_PKG_DEPENDENCY_ERRORS} dependency errors");
      $ret->{server_event_details} .= qq{</div>};
    }
  }
}

package RHN::ServerEvent::PackageRemove;
our @ISA = qw/RHN::ServerEvent::PackageAction/;

sub render {
  my $self = shift;

  #PXT::Debug->log(7, "package removal event:  " . Data::Dumper->Dump([($self)]));

  my $ret = $self->SUPER::render(@_);

  my $package_name = 'Packages'; 
  $package_name = 'Patches' if $self->{NAME} =~ /Patch/;
  $package_name = 'Patch Cluster' if $self->{NAME} =~ /Patch Cluster/;

  $ret->{server_event_details} .= qq{<div class="action-summary-package">$package_name to be removed:<br /><ul>\n};

  for my $pkg (@{$self->{PACKAGES}}) {
    $ret->{server_event_details} .= qq{  <li class="action-summary-package-nvre">$pkg->{NVRE}</li>\n};
  }
  $ret->{server_event_details} .= qq{</ul></div>\n};


  $self->dependency_errors($ret);

  return $ret;
}

package RHN::ServerEvent::PackageVerify;
our @ISA = qw/RHN::ServerEvent::PackageAction/;

sub render {
  my $self = shift;

  my $ret = $self->SUPER::render(@_);

  $ret->{server_event_details} .= qq{<div class="action-summary-package">Packages to be verified:<br /><ul>\n};

  for my $pkg (@{$self->{PACKAGES}}) {
    $ret->{server_event_details} .= qq{  <li class="action-summary-package-nvre">$pkg->{NVRE}</li>\n};
  }
  $ret->{server_event_details} .= qq{</ul></div>\n};

  if ($self->{STATUS} eq 'Completed') {
    $ret->{server_event_details} .=
      "View " . PXT::HTML->link2(-url => "verify_results.pxt",
				 -params => { sid => $self->{SERVER_ID}, hid => $self->{ACTION_ID} },
				 -text => "verify results");
    $ret->{server_event_details} .= " for these packages.";
  }
  else {
    $ret->{server_event_details} .= "(results not yet available)";
  }

  return $ret;
}

package RHN::ServerEvent::PackageRemove::Solaris;
our @ISA = qw/RHN::ServerEvent::PackageRemove/;

sub render {
  my $self = shift;
  my $ret = $self->SUPER::render(@_);
  use Data::Dumper;
  warn Dumper($self);
  my $package_name = 'Packages'; 
  $package_name = 'Patches' if $self->{NAME} =~ /Patch/;
  $package_name = 'Patch Cluster' if $self->{NAME} =~ /Patch Cluster/;

  $ret->{server_event_details} .= qq{<div class="action-summary-package">$package_name Scheduled:<br /><ul>\n};

  for my $pkg (@{$self->{PACKAGES}}) {
    my $html = '  <li class="action-summary-package-nvre">%s';

    if (defined $pkg->{RESULTS}) {
      $html .= <<EOQ;
    - <a target="_new" href="/network/systems/details/history/package_event_results.pxt?sid=%d&amp;hid=%d&amp;id_combo=%s">results</a>
    <br/>
    <span style="color: #555;padding-left: 5%%">return code:</span> %d
EOQ
    }

    $html .= "\n  </li>";

    $ret->{server_event_details} .= sprintf($html, $pkg->{NVRE}, $self->{SERVER_ID}, $self->{ACTION_ID}, $pkg->{ID_COMBO}, $pkg->{RESULTS}->{RESULT_CODE});
  }
  $ret->{server_event_details} .= qq{</ul></div>\n};

  $self->dependency_errors($ret);

  return $ret;
}

package RHN::ServerEvent::PackageUpdate;
our @ISA = qw/RHN::ServerEvent::PackageAction/;

sub render {
  my $self = shift;

  my $ret = $self->SUPER::render(@_);

  $ret->{server_event_details} .= qq{<div class="action-summary-package">Packages Scheduled:<br /><ul>\n};

  for my $pkg (@{$self->{PACKAGES}}) {
    $ret->{server_event_details} .= qq{  <li class="action-summary-package-nvre">$pkg->{NVRE}</li>\n};
  }
  $ret->{server_event_details} .= qq{</ul></div>\n};

  $self->dependency_errors($ret);

  return $ret;
}

package RHN::ServerEvent::PackageUpdate::Solaris;
our @ISA = qw/RHN::ServerEvent::PackageAction/;

sub render {
  my $self = shift;
  my $ret = $self->SUPER::render(@_);

  my $package_name = 'Packages'; 
  $package_name = 'Patches' if $self->{NAME} =~ /Patch/;
  $package_name = 'Patch Cluster' if $self->{NAME} =~ /Patch Cluster/;

  $ret->{server_event_details} .= qq{<div class="action-summary-package">$package_name Scheduled:<br /><ul>\n};

  for my $pkg (@{$self->{PACKAGES}}) {
    my $html = '  <li class="action-summary-package-nvre">%s';

    if (defined $pkg->{RESULTS}) {
      $html .= <<EOQ;
    - <a target="_new" href="/network/systems/details/history/package_event_results.pxt?sid=%d&amp;hid=%d&amp;id_combo=%s">results</a>
    <br/>
    <span style="color: #555;padding-left: 5%%">return code:</span> %d
EOQ
    }

    $html .= "\n  </li>";

    $ret->{server_event_details} .= sprintf($html, $pkg->{NVRE}, $self->{SERVER_ID}, $self->{ACTION_ID}, $pkg->{ID_COMBO}, $pkg->{RESULTS}->{RESULT_CODE});
  }
  $ret->{server_event_details} .= qq{</ul></div>\n};

  $self->dependency_errors($ret);

  return $ret;
}

package RHN::ServerEvent::DeltaTransaction;
our @ISA = qw/RHN::ServerEvent::PackageAction/;

my %operation_label_map = (delete => "Remove", insert => "Install", "replace" => "Replace");
sub render {
  my $self = shift;

  my $ret = $self->SUPER::render(@_);

  $ret->{server_event_details} .= qq{<div class="action-summary-package">Changes Scheduled:<br /><ul>\n};

  # pre-process the list, coalescing same-name with REPLACE instead of
  # abutted install/delete.  note this relies on the REMOVE action
  # being in front of the INSTALL action, which is ensures from the
  # order of entries in PACKAGES (see Server.pm)

  my @packages;
  for my $pkg (@{$self->{PACKAGES}}) {
    if ($packages[-1] and $packages[-1]->{NAME} eq $pkg->{NAME}) {
      $packages[-1]->{OTHER_NVRE} = $pkg->{NVRE};
      $packages[-1]->{OPERATION} = 'replace';
    }
    else {
      push @packages, $pkg;
    }
  }

  for my $pkg (@packages) {
    my $op = $operation_label_map{$pkg->{OPERATION}};
    if ($pkg->{OPERATION} eq 'replace') {
      $ret->{server_event_details} .= qq{  <li class="action-summary-package-nvre">$op $pkg->{NVRE} with $pkg->{OTHER_NVRE}</li>\n};
    }
    else {
      $ret->{server_event_details} .= qq{  <li class="action-summary-package-nvre">$op $pkg->{NVRE}</li>\n};
    }
  }
  $ret->{server_event_details} .= qq{</ul></div>\n};


  $self->dependency_errors($ret);

  return $ret;
}

package RHN::ServerEvent::RemoteCommand;
our @ISA = qw/RHN::ServerEvent::SimpleAction/;

sub render {
  my $self = shift;
  my $ret = $self->SUPER::render(@_);

  my $action = RHN::Action->lookup(-id => $self->{ACTION_ID});
  my $run_as = $action->script_username . ":" . $action->script_groupname;

  my $output = $action->script_server_results($self->{SERVER_ID});

  $output->{OUTPUT} ||= ''; #prevent warnings from operating on undef

  # sigh.  there has to be an easier way to filter out ansi control codes...
  $output->{OUTPUT} =~ s{\x1B\[(\d+[ABCDG]|[suK]|2J|(\d+;)*\d+m|=\d+[hl])}{}gism;

  $ret->{server_event_details} .=
    sprintf(<<EOQ, $run_as, $action->script_timeout || 0, PXT::HTML->htmlify_text($action->script_script));
<br/><br/>
Run as: <strong>%s</strong><br/>
Timeout: <strong>%d</strong> seconds<br/><br/>
<div style="padding-left: 1em"><code>%s</code></div><br/>
EOQ

  if ($output) {
    my $template =<<EOQ;
<br/>
<strong>Start Date:</strong> %s<br/>
<strong>End Date:</strong> %s<br/>
<strong>Return Code:</strong> %d<br/>
<strong>Raw Output:</strong> %s<br />
<strong>Filtered Output:</strong><br/><br/>
<div style="padding-left: 1em"><code>%s</code></div><br/>
EOQ

    my $raw_output_url = "/network/systems/details/history/raw_script_output.txt";

    $ret->{server_event_details} .=
      sprintf($template,
	      $output->{START_DATE} || '(unknown)',
	      $output->{STOP_DATE} || '(unknown)',
	      $output->{RETURN_CODE} || '0',
	      PXT::HTML->link2(-url => $raw_output_url, -params => {sid => $self->{SERVER_ID}, hid => $action->id},
			       -text => 'view/download raw script output'),
	      PXT::HTML->htmlify_text($output->{OUTPUT}),
	     );
  }

  return $ret;
}

1;

