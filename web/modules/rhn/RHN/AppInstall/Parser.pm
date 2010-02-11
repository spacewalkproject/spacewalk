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
# This package is the parser for RHN::AppInstall.  It will parse an
# xml file or an xml string.  It will return an AppInstall::Instance
# object.

package RHN::AppInstall::Parser;

use strict;
use XML::LibXML;
use Digest::MD5 qw/md5_hex/;
use RHN::Exception qw/throw/;

use RHN::AppInstall::Instance;
use RHN::AppInstall::ACL;
use RHN::AppInstall::Process::Install;
use RHN::AppInstall::Process::InstallProgress;
use RHN::AppInstall::Process::Configure;
use RHN::AppInstall::Process::Remove;
use RHN::AppInstall::Process::Step::Activity;
use RHN::AppInstall::Process::Step::Activity::Action;
use RHN::AppInstall::Process::Step::Requirements;
use RHN::AppInstall::Process::Step::CollectData;
use RHN::AppInstall::Process::Step::ScheduleActions;
use RHN::AppInstall::Process::Step::ScheduleActions::Action;
use RHN::AppInstall::Process::Step::Action::Arg;
use RHN::AppInstall::Process::Step::ActionStatus;
use RHN::AppInstall::Process::Step::Redirect;
use RHN::AppInstall::Process::Step::ActionStatus::Action;

use RHN::Form::Parser;

my $root_node_name = 'application';

sub parse_file {
  my $class = shift;
  my $file = shift;

  my $parser = new XML::LibXML;
  $parser->keep_blanks(0);
  $parser->expand_xinclude(1);
  my $doc = $parser->parse_file($file);
  my $root = $doc->getDocumentElement;

  return parse_tree($root);
}

sub parse_string {
  my $class = shift;
  my $data = shift;

  my $parser = new XML::LibXML;
  $parser->keep_blanks(0);
  $parser->expand_xinclude(1);
  my $doc = $parser->parse_string($data);
  my $root = $doc->getDocumentElement;

  return parse_tree($root);
}

sub parse_tree {
  my $root = shift;
  my $actual_root_node_name = $root->nodeName;

  throw "(parse_error) root element is '$actual_root_node_name', but should be '$root_node_name'"
    unless $actual_root_node_name eq $root_node_name;

  my $app = new RHN::AppInstall::Instance();

  foreach my $xml_node (grep { $_->isa("XML::LibXML::Element") } $root->childNodes) {
    my $node_name = $xml_node->nodeName;

    if (grep { $node_name eq $_ } qw/name label version/) {
      my $text = parse_simple_element($xml_node);
      my $func = "set_$node_name";

      throw "(unknown_setter) Could not call $func on $app"
	unless $app->can($func);

      $app->$func($text);
    }
    elsif ($node_name eq 'prerequisites') {
      $app->set_prerequisites(parse_prerequisites($xml_node));
    }
    elsif ($node_name eq 'terms-and-conditions') {
      $app->set_ts_and_cs(parse_ts_and_cs($xml_node));
    }
    elsif ($node_name eq 'install') {
      $app->set_install_process(parse_install_section($xml_node));
    }
    elsif ($node_name eq 'install-progress') {
      $app->set_install_progress_process(parse_install_progress_section($xml_node));
    }
    elsif ($node_name eq 'configure') {
      $app->set_configure_process(parse_configure_section($xml_node));
    }
    elsif ($node_name eq 'remove') {
      $app->set_remove_process(parse_remove_section($xml_node));
    }
    else {
      throw "(invalid_node) " . $xml_node->toString;
    }
  }

  foreach my $attr ($root->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'acl-mixins') {
      $app->set_acl_mixins(split(/,\s*/, $attr->getValue));
    }
    else {
      throw "(invalid_attribute) '$attr_name' is an invalid attribute for root element: " . $root->toString;
    }
  }

  foreach my $req_attr (qw/name label version/) {
    my $func = "get_$req_attr";
    throw "(missing_node) the '$req_attr' node is missing: " . $root->toString
      unless ($app->$func());
  }

  my $md5 = md5_hex($root->toString);
  $app->set_md5($md5);

  return $app;
}

sub parse_prerequisites {
  my $xml_node = shift;

  my @prerequisites;

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    my $node_name = $child_node->nodeName;

    push @prerequisites, parse_acl_element($child_node);
  }

  return @prerequisites;
}

sub parse_ts_and_cs {
  my $xml_node = shift;

  my $ts_and_cs;

  my $url = $xml_node->getAttribute('url');
  if ($url) {
    $ts_and_cs = $url;
  }
  else {
    $ts_and_cs = parse_simple_element($xml_node);
  }

  throw "(parse_error) Could not parse terms and conditions: " . $xml_node->toString
    unless $ts_and_cs;

  return $ts_and_cs;
}

sub parse_install_section {
  my $xml_node = shift;

  my $install_process = new RHN::AppInstall::Process::Install();

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    $install_process->push_step(parse_step($child_node));
  }

  foreach my $attr ($xml_node->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'acl') {
      $install_process->set_acl($attr->getValue);
    }
  }

  return $install_process;
}

sub parse_configure_section {
  my $xml_node = shift;

  my $configure_process = new RHN::AppInstall::Process::Configure();

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    $configure_process->push_step(parse_step($child_node));
  }

  foreach my $attr ($xml_node->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'acl') {
      $configure_process->set_acl($attr->getValue);
    }
  }

  return $configure_process;
}

sub parse_install_progress_section {
  my $xml_node = shift;

  my $install_progress_process = new RHN::AppInstall::Process::InstallProgress();

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    $install_progress_process->push_step(parse_step($child_node));
  }

  foreach my $attr ($xml_node->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'acl') {
      $install_progress_process->set_acl($attr->getValue);
    }
  }

  return $install_progress_process;
}

sub parse_remove_section {
  my $xml_node = shift;

  my $remove_process = new RHN::AppInstall::Process::Remove();

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    $remove_process->push_step(parse_step($child_node));
  }

  foreach my $attr ($xml_node->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'acl') {
      $remove_process->set_acl($attr->getValue);
    }
  }

  return $remove_process;
}

sub parse_step {
  my $xml_node = shift;
  my $node_name = $xml_node->nodeName;

  my $step;

  if ($node_name eq 'activity') {
    $step = parse_activity($xml_node);
  }
  elsif ($node_name eq 'requirements') {
    $step = parse_requirements_step($xml_node);
  }
  elsif ($node_name eq 'collect-data') {
    $step = parse_collect_data_step($xml_node);
  }
  elsif ($node_name eq 'schedule-actions') {
    $step = parse_schedule_actions_step($xml_node);
  }
  elsif ($node_name eq 'action-status') {
    $step = parse_action_status_step($xml_node);
  }
  elsif ($node_name eq 'redirect') {
    $step = parse_redirect_step($xml_node);
  }
  else {
    throw "(invalid_node) " . $xml_node->toString;
  }

  my $acl = $xml_node->getAttribute('acl');
  $step->set_acl($acl) if $acl;

  return $step;
}

sub parse_action_status_step {
  my $xml_node = shift;
  my $description = $xml_node->getAttribute('description');
  throw "(parse_error) A description is required for 'action-status' steps: " . $xml_node->toString()
    unless $description;

  my $step = new RHN::AppInstall::Process::Step::ActionStatus (-description => $description);

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    my $node_name = $child_node->nodeName();

    if ($node_name eq 'header') {
      $step->set_header(parse_simple_element($child_node));
    }
    elsif($node_name eq 'footer') {
      $step->set_footer(parse_simple_element($child_node));
    }
    elsif($node_name eq 'inprogress') {
      $step->set_inprogress_msg(parse_simple_element($child_node));
    }
    elsif($node_name eq 'complete') {
      $step->set_complete_msg(parse_simple_element($child_node));
    }
    elsif($node_name eq 'failed') {
      $step->set_failed_msg(parse_simple_element($child_node));
    }
    elsif ($node_name eq 'target-action') {
      $step->set_action(parse_target_action($child_node));
    }
    else {
      throw "(invalid_node) " . $child_node->toString;
    }
  }

  return $step;
}

sub parse_redirect_step {
  my $xml_node = shift;
  my $description = $xml_node->getAttribute('description') || "Redirect";

  my $url = parse_simple_element($xml_node);
  throw "(parse_error) No url found in redirect step: " . $xml_node->toString()
    unless $url;

  my $step = new RHN::AppInstall::Process::Step::Redirect(-url => $url,
							  -description => $description);

  foreach my $attr ($xml_node->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'acl') {
      $step->set_acl($attr->getValue);
    }
    elsif ($attr_name eq 'save-session') {
      $step->set_save_session($attr->getValue);
    }
    elsif ($attr_name eq 'description') {
      # noop
    }
    else {
      throw "(parse_error) unknown attr '$attr' for redirect: " . $xml_node->toString();
    }
  }

  return $step;
}

sub parse_target_action {
  my $xml_node = shift;
  my $node_name = $xml_node->nodeName;

  my $action = new RHN::AppInstall::Process::Step::ActionStatus::Action ();

  foreach my $attr ($xml_node->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'name') {
      $action->set_name($attr->getValue);
    }
  }

  return $action;
}

sub parse_schedule_actions_step {
  my $xml_node = shift;
  my $description = $xml_node->getAttribute('description');
  throw "(parse_error) A description is required for 'schedule-actions' steps: " . $xml_node->toString()
    unless $description;

  my $step = new RHN::AppInstall::Process::Step::ScheduleActions (-description => $description);

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    $step->push_action(parse_action($child_node,
				    'RHN::AppInstall::Process::Step::ScheduleActions::Action'));
  }

  return $step;
}

sub parse_action {
  my $xml_node = shift;
  my $class = shift;
  my $node_name = $xml_node->nodeName;

  my $action = new $class (-name => $node_name);
  my @args;

  my @child_elements = grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes;
  my @child_text_nodes = grep { $_->isa("XML::LibXML::Text") } $xml_node->childNodes;

  if (@child_elements > 0) {
    @args = parse_action_arguments($xml_node);
  }

  if (@child_text_nodes == 1) {
    my $arg = new RHN::AppInstall::Process::Step::Action::Arg
      (-value => parse_simple_element($xml_node));
    $action->push_argument($arg);
  }

  foreach my $attr ($xml_node->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'acl') {
      $action->set_acl($attr->getValue);
    }
    else {
      push @args, new RHN::AppInstall::Process::Step::Action::Arg (-name => $attr_name,
								   -value => $attr->getValue);
    }
  }

  if (@args) {
    $action->set_arguments(@args);
  }

  return $action;
}

sub parse_collect_data_step {
  my $xml_node = shift;
  my $description = $xml_node->getAttribute('description');
  throw "(parse_error) A description is required for 'collect-data' steps: " . $xml_node->toString()
    unless $description;

  my $step = new RHN::AppInstall::Process::Step::CollectData (-description => $description);

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    my $node_name = $child_node->nodeName();

    if ($node_name eq 'header') {
      $step->set_header(parse_simple_element($child_node));
    }
    elsif($node_name eq 'footer') {
      $step->set_footer(parse_simple_element($child_node));
    }
    elsif ($node_name eq 'rhn-form') {
      $step->set_form(parse_form($child_node));
    }
    else {
      throw "(invalid_node) " . $child_node->toString;
    }
  }

  foreach my $attr ($xml_node->attributes) {
    my $attr_name = $attr->getName;

    if ($attr_name eq 'no-cancel') {
      $step->set_no_cancel($attr->getValue);
    }
  }

  return $step;
}

sub parse_form {
  my $xml_node = shift;

  return RHN::Form::Parser->parse_string($xml_node->toString);
}

sub parse_activity {
  my $xml_node = shift;
  my $description = $xml_node->getAttribute('description');
  throw "(parse_error) A description is required for 'activity' steps: " . $xml_node->toString()
    unless $description;

  my $step = new RHN::AppInstall::Process::Step::Activity (-description => $description);

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    $step->push_action(parse_action($child_node,
				    'RHN::AppInstall::Process::Step::Activity::Action'));
  }

  return $step;
}

sub parse_action_arguments {
  my $xml_node = shift;

  my @args;

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    my $node_name = $child_node->nodeName();
    my $node_value = parse_simple_element($child_node);
    my $acl = $child_node->getAttribute('acl');

    my $arg = new RHN::AppInstall::Process::Step::Action::Arg (-name => $node_name,
							       -value => $node_value,
							       -acl => $acl,
							      );
    push @args, $arg;
  }

  return @args;
}

sub parse_requirements_step {
  my $xml_node = shift;

  my $description = $xml_node->getAttribute('description') || 'Check requirements';
  my $step = new RHN::AppInstall::Process::Step::Requirements (-description => $description);

  foreach my $child_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    $step->push_requirement(parse_acl_element($child_node));
  }

  return $step;
}

# parse something that looks like <acl>sometext</acl>
sub parse_acl_element {
  my $xml_node = shift;
  my $acl_name = $xml_node->nodeName;

  $acl_name =~ tr/-/_/;
  my $acl = new RHN::AppInstall::ACL(-name => $acl_name);

  foreach my $attr ($xml_node->attributes) {
    if ($attr eq 'failed-message') {
      $acl->set_failed_message($xml_node->getAttribute($attr));
    }
    else {
      throw "(parse_error) unknown attr '$attr' for acl: " . $xml_node->toString();
    }
  }

  my $arg = parse_simple_element($xml_node);
  $acl->set_argument($arg) if $arg;

  return $acl;
}

sub parse_simple_element {
  my $xml_node = shift;

  my @child_nodes = $xml_node->childNodes;

  my $ret;

  foreach my $node (@child_nodes) {
    my $data;

    if ($node->isa("XML::LibXML::Text")) {
      $data = $node->getData;
    }
    else {
      $data = $node->toString;
    }

    $data =~ s/^\s*(.*)\s*$/$1/s; # strip leading and trailing whitespace.

    $ret .= $data;
  }

  return $ret;
}

1;
