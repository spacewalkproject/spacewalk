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

package Sniglets::Actions;

use Carp;
use Data::Dumper;

use RHN::User;
use RHN::Action;
use PXT::Utils;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-action-details', \&action_details);
  $pxt->register_tag('rhn-action-name', \&action_name, 2);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

}

sub action_name {
  my $pxt = shift;

  my $aid = $pxt->param('aid');

  die "no action id!" unless $aid;

  my $action_name = $pxt->pnotes('action_name');

  return $action_name if $action_name;

  my $action = RHN::Action->lookup(-id => $aid);
  # this should change once we add in support for named actions...
  $action_name = $action->name;
  $action_name = $action->action_type_name unless $action_name;

  $pxt->pnotes(action_name => $action_name);

  return $action_name;
}

sub action_details {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__} || "";

  my $action_id = $pxt->param('aid');
  croak "No action id!" unless $action_id;

  my $action = RHN::Action->lookup(-id => $action_id);
  croak "Failed to load action!" unless $action;

  my $notes = '';

  if ($action->name) {
    $pxt->pnotes(action_name => $action->name);
  }
  else {
    $pxt->pnotes(action_name => $action->action_type_name);
  }

  my %subst;

  $subst{action_type} = $action->action_type_name;
  $subst{action_scheduler} = $action->action_scheduler_login;
  $subst{action_earliest_action} = $pxt->user->convert_time($action->earliest_action);
  $subst{action_in_progress_count} = $action->action_in_progress_count;
  $subst{action_successful_count} = $action->action_successful_count;
  $subst{action_failed_count} = $action->action_failed_count;
  $subst{action_total_count} = $action->action_total_count;

  PXT::Utils->escapeHTML_multi(\%subst);

  if ($subst{action_failed_count} > 0) {
    $notes .= sprintf('<strong><a href="/rhn/schedule/FailedSystems.do?aid=%d">%d system%s</a></strong> failed to complete this action.<br/><br/>', $action_id, $subst{action_failed_count}, $subst{action_failed_count} == 1 ? '' : 's');
  }

  if ($subst{action_successful_count} > 0) {
    $notes .= sprintf('<strong><a href="/rhn/schedule/CompletedSystems.do?aid=%d">%d system%s</a></strong> successfully completed this action.<br/><br/>', $action_id, $subst{action_successful_count}, $subst{action_successful_count} == 1 ? '' : 's');
  }

  # hack to show errata info straight on this page,
  # assumes that only 1 errata per scheduled action
  if ($action->action_type_label eq 'errata.update') {
    my @errata = $action->associated_errata;
    my $errata = RHN::Errata->lookup(-id => $errata[0]);

    if ($errata) {
      $notes .= sprintf('<strong><a href="/network/errata/details/Details.do?eid=%d">%s</a></strong><br/><br/>', $errata->id, $errata->advisory);
      $notes .= "<strong>" . $errata->synopsis . "</strong><br/><br/>";
      $notes .= $errata->advisory_type . "<br/><br/>";
      $notes .= PXT::HTML->htmlify_text($errata->topic || '') . "<br/>";
      $notes .= PXT::HTML->htmlify_text($errata->description || '') . "<br/>";
    }
  }

  if ($action->action_type_label eq 'script.run') {
    $notes .= sprintf(<<EOQ, $action->script_username, PXT::HTML->htmlify_text($action->script_script));
Run as: <strong>%s</strong><br/><br/>
<div style="padding-left: 1em"><code>%s</code></div><br/>
EOQ
  }

  $subst{action_notes} = $notes || '(none)'; # don't escapeHTML notes

  return PXT::Utils->perform_substitutions($block, \%subst);
}

1;
