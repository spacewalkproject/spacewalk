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

package Sniglets::Mailer;

use Carp;
use Data::Dumper;

use RHN::Mail;
use RHN::Postal;
use PXT::HTML;

use PXT::Utils;

use RHN::SessionSwap;
use RHN::Feedback;
use RHN::Exception qw/throw/;
use RHN::DataSource::General;
use RHN::TemplateString;

use Text::Wrap qw/wrap/;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-userid-mac' => \&userid_mac, 20);
  $pxt->register_tag('rhn-your-email' => \&your_email, 20);

  $pxt->register_tag('mailer-feedback-respond' => \&mailer_feedback_respond);
  $pxt->register_tag('mailer-feedback-tree' => \&mailer_feedback_tree, 20); #run after feedback respond tag

  $pxt->register_tag('faq-faq-list' => \&mailer_faq_list);
  $pxt->register_tag('faq-faq-edit' => \&mailer_faq_edit);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:mail_customer_support_cb' => \&mail_customer_support_cb);
  $pxt->register_callback('mailer:feedback_respond_cb' => \&mailer_feedback_respond_cb);

  $pxt->register_callback('faq:faq_update_cb' => \&mailer_faq_update_cb);
}



sub your_email {
  my $pxt = shift;

  return 'no email address' unless $pxt->user;

  return $pxt->user->email ? PXT::Utils->escapeHTML($pxt->user->email) : 'no email address';
}

sub userid_mac {
  my $pxt = shift;

  my $mac = RHN::SessionSwap->encode_data(time, $pxt->user->id);

  return PXT::HTML->hidden(-name => 'user_id_mac', -value => $mac);
}

sub mail_customer_support_cb {
  my $pxt = shift;

  my $paid_user_status = '';
  my $users_address;
  my $paying_customer;
  my $user = $pxt->user;

  if (not $user) {
    my ($then, $user_id) = RHN::SessionSwap->extract_data($pxt->dirty_param('user_id_mac'));

    # if the mac is less than four hours old, we use it
    $user = RHN::User->lookup(-id => $user_id)
      if time() - $then < 4 * 60 * 60;
  }
  else {
    $paying_customer = $user->org->is_paying_customer();
    $paid_user_status = $paying_customer ? " - Subscription User" : " - Demo User";

    # logged in users get an automatic response if they're paid or have verified email addys.
    if ($paying_customer) {
      my $mailable_address = $user->find_mailable_address;
      $users_address = $mailable_address ? $mailable_address->address : undef;
  }
    else {
      # only let verified BEL's get autoresponse mail...
      ($users_address) = $user->email_addresses_by_types('verified');
      $users_address = $users_address->address if $users_address;
    }
  }

  my $email_addr_form = $pxt->dirty_param('email_addr');
  die "no email addr!" unless $email_addr_form;

  my $email_addr = '';
  my $email_subj = '';

  my $autoresponse_file;

  if ($email_addr_form eq 'support') {
    $email_subj = "RHN Website Support Request from " . $user->email;
    $email_addr = PXT::Config->get('support_email');
  }
  elsif ($email_addr_form eq 'feedback') {
    $email_subj = "RHN Website Feedback from " . $user->email;
    $email_addr = PXT::Config->get('customer_service_email');
    $autoresponse_file = 'rhn-feedback-autoresponse.xml';
  }
  elsif ($email_addr_form eq 'customerservice') {
    $email_subj = "RHN Website Customer Service Request from " . $user->email;
    $email_addr = PXT::Config->get('customer_service_email');
    $autoresponse_file = 'cs-autoresponse.xml';
  }

  my $subject = $pxt->dirty_param('subject');

  unless ($subject) {
    $pxt->push_message(local_alert => 'A subject is required.');
    return;
  }

  my $message = substr($pxt->dirty_param('message'), 0, 3999);

  unless ($message) {
    $pxt->push_message(local_alert => 'You must enter a message body.');
    return;
  }

  # only shove stuff into the tool if they're paid users asking for technical support.
  if ($email_addr_form eq 'support') {
    if ($user and $user->org->is_paying_customer()) {
      my $msg = RHN::Feedback->create;

      $msg->user_id($user->id);
      $msg->re_id(undef);
      $msg->subject($subject);
      $msg->message($message);
      $msg->set_status('new');
      $msg->set_type('new');

      $msg->commit;
    }
    else {
      # could get here if they leave their browser to sit for too long...
      $pxt->push_message(site_notice => "Your session has expired.  If you still need tech support from RHN, please log in first.");

      return;
    }
  }

  my $body = sprintf(<<EOQ, $user->first_names, $user->last_name, $user->email, $subject, $user->login, $user->id, ($user->org->oracle_customer_number || 'None'), $message);
From: %s %s <%s>
Subject: %s

User Login: %s
User ID: %d
Customer Number: %s

%s
EOQ

  # send the email to whatever list it should go to...
  RHN::Mail->send(to => $email_addr,
  		  from => $user->email,
  		  subject => "[Support Inquiry$paid_user_status] $subject",
  		  body => $body,
  		  headers => {"X-RHN-Info" => "support_inquiry"}
  		 );

  # make sure we get a copy of customer service emails sent...
  if ($email_addr_form eq 'customerservice') {
    RHN::Mail->send(to => PXT::Config->get("feedback_bcc_address"),
		    from => $user->email,
		    subject => "[Customer Service Inquiry$paid_user_status] $subject",
		    body => $body,
		    headers => {"X-RHN-Info" => "customer_service_inquiry"}
		   );
  }

  # when possible, send a fake autoresponse to the user,
  # since we send mail to thoses lists as dev-null@rhn.redhat.com
  if ($autoresponse_file and $users_address) {

    my $response = new RHN::Postal;

    $response->template($autoresponse_file);
    $response->set_tag("login", $user->login());
    $response->set_tag("email-address", $users_address);
    $response->set_header("X-RHN-Info", "autoresponse");
    $response->to($users_address);

    $response->wrap_body();
    $response->render();

    $response->send();
  }

  $pxt->redirect("/help/email_sent_$email_addr_form.pxt");
}

sub mailer_faq_edit {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $faq;
  if (defined $pxt->dirty_param('type')) {
    my $fid = $pxt->dirty_param('type');
    my $ds = new RHN::DataSource::General(-mode => 'faq_lookup');
    $faq = $ds->execute_one(-faq_id => $fid);
  }

  my $editable = 0;

  my $buttons;

  if ($faq) {
    $buttons .= PXT::HTML->hidden(-name => "id", -value => $pxt->dirty_param('type'));
    $buttons .= PXT::HTML->submit(-name => "update", -value => "Submit");
    $buttons .= PXT::HTML->submit(-name => "delete", -value => "Delete");

    if ($faq->{PRIVATE} or $pxt->user->is('org_admin')) {
      $editable = 1;
    }
  }
  else {
    $buttons .= PXT::HTML->submit(-name => "update", -value => "Create");

    $editable = 1;
  }

  my %subst;

  if ($editable) {
    $subst{input_buttons} = $buttons;
    $subst{question} = PXT::HTML->text(-name => 'question', -value => PXT::Utils->escapeHTML($faq->{SUBJECT} || ''), -size => 80, -maxlength => 200);
    $subst{answer} = PXT::HTML->textarea(-name => 'answer', -value => PXT::Utils->escapeHTML($faq->{DETAILS} || ''), -rows => 20, -cols => 80);

    my $ds = new RHN::DataSource::General(-mode => 'faq_classes');
    my $faq_classes = $ds->execute_query();
    $faq->{CLASS_LABEL} ||= '';
    $subst{class} = PXT::HTML->select(-name => 'class', -size => 1, -options =>
				      [ map { [ $_->{NAME}, $_->{LABEL}, $faq->{CLASS_LABEL} eq $_->{LABEL} ? 1 : 0 ] } @{$faq_classes} ]);
  }
  else {
    $subst{input_buttons} = '&#160;';
    $subst{question} = PXT::Utils->escapeHTML($faq->{SUBJECT} || '');
    $subst{answer} = wrap("", "", PXT::Utils->escapeHTML($faq->{DETAILS} || ''));
    $subst{class} = $faq->{CLASS_LABEL} || '';
  }

  if ($pxt->user->is('rhn_superuser')) {
    $subst{private} = PXT::HTML->checkbox(-name => 'private', -value => 1, -checked => $faq->{PRIVATE} || '');
  }
  else {
    $faq->{PRIVATE} = 1 unless (exists $faq->{PRIVATE});
    $subst{private} = $faq->{PRIVATE} ? 'Yes' : 'No';
    if ($subst{private} eq 'Yes') {
      $subst{private} .= '&#160;&#160;' . PXT::HTML->checkbox(-name => 'request_publication', -value => 1, -checked => 0);
      $subst{private} .= 'Request publication of this FAQ';
    }
  }

  $subst{id} = $pxt->dirty_param('type') || '';

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub mailer_faq_list {
  my $pxt = shift;
  my %params = @_;

  my $block = '';
  my $ret = '';

  my $path = $pxt->path_info;
  $path =~ s|/(\w+)\.pxt$|$1|;

  my $class = $params{class} || $path || '/';

  my $faqs;
  if ($class eq 'top_ten' or $class eq '/') {
    my $ds = new RHN::DataSource::General(-mode => 'all_faqs');
    $faqs = $ds->execute_full(-private => 0);
    my $last = ($#$faqs >= 9) ? 9 : $#$faqs;
    $faqs = [ @$faqs[0 .. $last] ];
    if ($last == 0) {
      @{$faqs} = [ ];
    }
  }
  elsif ($class eq 'all_faqs') {
    my $ds = new RHN::DataSource::General(-mode => 'all_faqs');
    $faqs = $ds->execute_full(-private => 0);
  }
  else {
    my $ds = new RHN::DataSource::General(-mode => 'faqs_in_class');
    $faqs = $ds->execute_full(-private => 0, -class => $class);
  }

  foreach my $faq (@{$faqs}) {
    my %subst;

    $block = $params{__block__};
    $subst{id} = $faq->{ID};
    $subst{subject} = PXT::Utils->escapeHTML($faq->{SUBJECT});
    $subst{date} = $faq->{MODIFIED};
    $subst{usage_count} = $faq->{USAGE_COUNT};
    $subst{class} = $faq->{CLASS};

    # substitution of new lines with break tags in details

    my $details = PXT::HTML->htmlify_text($faq->{DETAILS});
    $details =~ s/\A\<br \/\>//;  # kill leading break tag, if any

    my $hostname = RHN::TemplateString->get_string(-label => 'hostname');

    if ($hostname) {
      $details =~ s/rhn\.redhat\.com/$hostname/g;
    }

    $subst{details} = $details;

    $ret .= PXT::Utils->perform_substitutions($block, \%subst);
  }

  return $ret;
}

sub mailer_feedback_tree {
  my $pxt = shift;
  my %params = @_;

  ### Get our initial node

  my $id = $pxt->param('fid');
  my ($re_id, $subject) = RHN::Feedback->lookup(-id => $id);

  ### Walk the tree and find id/subject pairs

  my $block = '';
  my @data;
  my $exit = 0;

  while(! $exit) {

    ($id, $subject) = RHN::Feedback->lookup(-id => $re_id);

    $exit++
      unless $id;

    unshift @data, [$re_id, $subject];

    $re_id = $id;

  }

  ### Render our data structure

  $block = _paint_feedback_tree(\@data)
    if (@data);

  return $block;

}

sub _paint_feedback_tree {
  my $data = shift;

  my $block = '';

  my ($id, $subject) = @{ shift @{ $data }}
    if @{ $data };

  return '' unless $id;

  $block .= "<ul>";
  $block .= "<li><a href=\"/internal/feedback/feedback_details.pxt?fid=$id\">";
  $block .= "$subject</a></li>";
  $block .=  _paint_feedback_tree($data);
  $block .= "</ul>";

  return $block;

}

sub mailer_feedback_respond {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $fb;
  my $fid = $pxt->param('fid') || '';

  eval {
    $fb = RHN::Feedback->lookup(-id => $fid);
  };

  if ($@) {
    $pxt->push_message(local_alert => "Could not find a feedback with id '$fid'.");
    $pxt->redirect('index.pxt');
  }

  my $u = RHN::User->lookup(-id => $fb->user_id);

  $block =~ s/\{sender_$_\}/PXT::Utils->escapeHTML($u->$_() || '')/eig
    foreach qw/first_names last_name login id/;

  my $message = wrap("", "", $fb->message);

  my $to_label = $u->login;
  $to_label = $u->first_names . " " . $u->last_name if $u->first_names ne 'Valued';
  my $to = sprintf("%s <%s>", $to_label, $u->email);

  my $reply = $pxt->dirty_param('response') || sprintf("%s writes:\n\n%s\n", $to, wrap("> ", "> ", $fb->message));

  if ($pxt->dirty_param('insert_from_faq')) {
    my $faq_id = $pxt->dirty_param('type');
    my $ds = new RHN::DataSource::General(-mode => 'faq_lookup');
    my $faq = $ds->execute_one(-faq_id => $faq_id);

    RHN::Feedback->faq_increment_usage($faq_id);
    $faq->{DETAILS} =~ s/ < .*? > //exigs;
    $reply = wrap('', '', $faq->{DETAILS}) . "\n\n$reply";
  }

  $block =~ s/ \{ date \} / $fb->modified /eigx;
  $block =~ s/\{$_\}/$fb->$_() || ''/eig
    foreach qw/id subject/;

  $block =~ s/ \{ sender_email \} / PXT::Utils->escapeHTML($u->email || '') /xgie;
  $block =~ s/ \{ message \} / PXT::Utils->escapeHTML($message) /xgie;

  $block =~ s/ \{ change_subject \} / PXT::HTML->text(-name => "subject", -value => $fb->subject, -size => 80, -maxsize => 200) /xgie;

  $block =~ s/\{reply_area\}/PXT::HTML->textarea(-name => "response", -value => PXT::Utils->escapeHTML($reply), -rows => 20, -cols => 80)/eig;

  my $buttons;

  if($params{mode} and $params{mode} eq 'details') {
    $buttons .= PXT::HTML->submit(-name => "update", -value => "Update") . "&#160; &#160;";
    $buttons .= PXT::HTML->submit(-name => "discard", -value => "Discard") . "&#160; &#160;";
    $buttons .= PXT::HTML->submit(-name =>"reply", -value => "Update and Reply");
  }
  else {
    $buttons .= PXT::HTML->submit(-name => "send_reply", -value => "Send Reply");
    $buttons .= PXT::HTML->submit(-name => "send_to_faq", -value => "Use as FAQ");
    $buttons .= PXT::HTML->submit(-name => "cancel_reply", -value => "Cancel Reply");
  }
  $block =~ s/\{buttons\}/$buttons/ig;

  my $type_dropdown = PXT::HTML->radio_group(-name => "type", -size => 1, -separator => "&#160; &#160; \n",
					     -buttons => [ map { [ $_->[1], $_->[1], $_->[0] == $fb->type] }
							   RHN::Feedback->feedback_types ]);

  my ($status_label) = map { $_->[0] == $fb->status ? $_->[2] : () } RHN::Feedback->feedback_statuses;
  my ($type_label) = map { $_->[0] == $fb->type ? $_->[2] : () } RHN::Feedback->feedback_types;

  my $faqs_ds = new RHN::DataSource::General(-mode => 'faqs_by_class');
  my $faqs_by_class = $faqs_ds->execute_full();

  my @faqs;
  foreach my $class (@{$faqs_by_class}) {
    push @faqs, [ $class->{CLASS_NAME}, '', 0, 1 ];

    push @faqs, map { [ $_->{FAQ_ID} . ": " . $_->{SUBJECT}, $_->{FAQ_ID}, 0 ] } @{$class->{__data__}};
  }

  my $auto_response = PXT::HTML->select(-name => "type", -size => 1, -options => [ @faqs ] );

  $block =~ s/\{type_dropdown\}/$type_dropdown/ig;
  $block =~ s/\{status_label\}/$status_label/ig;
  $block =~ s/\{type_label\}/$type_label/ig;
  $block =~ s/\{auto_response\}/$auto_response/ig;

  my $forward_control;
  $forward_control .= PXT::HTML->radio_button(-name => 'forward_to',
					      -value => 'customerservice@redhat.com');
  $forward_control .= 'customerservice@redhat.com<br/>';

  $forward_control .= PXT::HTML->radio_button(-name => 'forward_to',
					      -value => 'other' );

  $forward_control .= PXT::HTML->text(-name => 'forward_special',
				      -value => '',
				      -size => 30, -maxlength => 80);

  $block =~ s/\{forward_control\}/$forward_control/ig;

  my $escalate_control;
  $escalate_control = PXT::HTML->radio_button(-name => 'escalate_to',
					      -value => 'issue_tracker',
					      -checked => ($fb->get_status eq 'escalated') ? 1 : 0);

  $escalate_control .= 'Issue Tracker ID:';
  $escalate_control .= PXT::HTML->text(-name => 'escalation_id',
				       -value => $fb->escalation_id || '',
				       -maxlength => 32,
				       -size => 8);
  $escalate_control .= PXT::HTML->submit(-name => 'escalate_button',
					 -value => 'Escalate');

  $block =~ s/\{escalate_control\}/$escalate_control/g;

  return $block;
}

sub mailer_faq_update_cb {
  my $pxt = shift;

  my $question = $pxt->dirty_param('question') || '';
  my $answer = $pxt->dirty_param('answer') || '';

  unless ($question && $answer) {
    $pxt->push_message(local_alert => 'A FAQ must have both a question and an answer.');
    my $id = $pxt->dirty_param('id') || '';
    my $url = $pxt->uri;

    if ($id) {
      $url .= "?type=$id";
    }
    $pxt->redirect($url);
  }

  my $id = $pxt->dirty_param('id');
  my $private;
  my $faq;

  if ($id) {
    my $ds = new RHN::DataSource::General(-mode => 'faq_lookup');
    $faq = $ds->execute_one(-faq_id => $id);

    $private = $faq->{PRIVATE};
  }
  else {
    $private = 1;
  }

  if ($pxt->user->is('rhn_superuser')) {
    $private = $pxt->dirty_param('private') ? 1 : 0;
    if (not $private and $faq->{PRIVATE}) { # the FAQ is being published
      send_faq_publication_notice($pxt, $id);
    }
  }

  my $class = $pxt->dirty_param('class') || 'general';

  if ($pxt->dirty_param('delete')) {
    $pxt->push_message(site_info => "FAQ <strong>" . PXT::Utils->escapeHTML($question) . "</strong> deleted.");
    RHN::Feedback->faq_delete($pxt->dirty_param('id'));
  }
  elsif (not defined $pxt->dirty_param('id')) {
    $pxt->push_message(site_info => "FAQ <strong>" . PXT::Utils->escapeHTML($question) . "</strong> created.");
    $id = RHN::Feedback->faq_insert(-question => $question,
				    -answer => $answer,
				    -private => $private,
				    -class => $class);
  }
  else {
    $pxt->push_message(site_info => "FAQ <strong>" . PXT::Utils->escapeHTML($question) . "</strong> updated.");
    RHN::Feedback->faq_update(-id => $pxt->dirty_param('id'),
			      -question => $question,
			      -answer => $answer,
			      -private => $private,
			      -class => $class);
  }

  if ($pxt->dirty_param('request_publication')) {
    send_faq_publication_request($pxt, $id);
  }

  $pxt->redirect($pxt->uri . "?type=$id");
}

sub mailer_feedback_respond_cb {
  my $pxt = shift;

  my $fb = RHN::Feedback->lookup(-id => $pxt->param('fid'));

  my ($upper, $lower) = map { $pxt->session->get($_) } qw/feedback_upper feedback_lower/;
  my $vars = '';
  if ($upper) {
    $vars = "?upper=$upper&lower=$lower";
  }

  if ($pxt->dirty_param('cancel_reply')) {
    $pxt->push_message(site_info => 'Reply cancelled.');
    $pxt->redirect("/internal/feedback/index.pxt$vars");
  }

  if ($pxt->dirty_param('escalate_button')) {
    my $escalate_to = $pxt->dirty_param('escalate_to') || '';
    my $escalation_id = $pxt->dirty_param('escalation_id');

    unless ($escalate_to and $escalation_id) {
      $pxt->push_message(site_info => "An escalation target and escalation ID is required when escalating feedback.");
      return;
    }

    $fb->escalation_id($escalation_id);
    $fb->set_status('escalated');
    $fb->commit;

    $pxt->push_message(site_info => "Feedback <strong>" . $fb->id . "</strong> escalated to issue tracker #<strong>$escalation_id</strong>.");
    $pxt->redirect("/internal/feedback/index.pxt$vars");
  }

  my $forward_to;
  if ($pxt->dirty_param('forward_button')) {
    $forward_to = $pxt->dirty_param('forward_to') || '';
    if ($forward_to eq 'other') {
      $forward_to = $pxt->dirty_param('forward_special');
    }
  }

  if ($forward_to) {
    my $from = RHN::User->lookup(-id => $fb->user_id);
    my $bounce = "rhn-bounce+" . $from->id . "-" . $from->org->id . '@' . PXT::Config->get("bounce_to_host");

    my $comment = $pxt->dirty_param('forward_comment') || '';
    my $login = $pxt->user->login;

    my $body = "[ This message has been forwarded from '$login' using the RHN support tool ]";
    if ($comment) {
      $body .= "\n\n[ Comment from support ]\n$comment\n[ End comment ]";
    }

    $body .= "\n\n";

    RHN::Mail->send(to => $forward_to,
		    from => $from->email,
		    subject => "[Support Forward] " . $fb->subject,
		    headers => { "Reply-To" => $from->email,
				 "Errors-To" => $bounce },
		    body => $body . $fb->message);

    $fb->set_type('support');
    $fb->set_status('discard');
    $fb->commit;

    $pxt->push_message(site_info => "Feedback forwarded to <strong>$forward_to</strong>.");

    $pxt->redirect("/internal/feedback/index.pxt$vars");
  }

  if ($pxt->dirty_param('reply') or $pxt->dirty_param('update') or $pxt->dirty_param('discard')) {
    if ($pxt->dirty_param('discard')) {
      $pxt->push_message(site_info => 'Feedback discarded.');
      $fb->set_status('discard');
    }

    $fb->set_type($pxt->dirty_param('type'));
    $fb->commit;

    if ($pxt->dirty_param('reply')) {
      $pxt->redirect('/internal/feedback/feedback_reply.pxt?fid=' . $pxt->param('fid'));
    }
    else {
      $pxt->redirect("/internal/feedback/index.pxt$vars");
    }
  }

  if ($pxt->dirty_param('send_reply')) {
    my $message = $pxt->dirty_param('response');
    my $length = length $message;

    if ($length > 4000) {
      $pxt->push_message(local_alert => "Sorry, your reply is <strong>${length}</strong> characters long.  The maximum length is <strong>4000</strong> characters.  Please edit your message and try again.");
      return;
    }

    my $reply = RHN::Feedback->create;
    $reply->re_id($fb->id);
    $reply->user_id($pxt->user->id);
    $reply->subject("Re: " . $fb->subject);
    $reply->message($message);
    $reply->set_status('reply');
    $reply->set_type('new');
    $reply->commit;

    my $to = RHN::User->lookup(-id => $fb->user_id);

    my $to_label = $to->login;
    $to_label = $to->first_names . " " . $to->last_name if $to->first_names ne 'Valued';

    my $from = "rhn-feedback+" . $to->id . "-" . $reply->id . '@' . PXT::Config->get("feedback_from_host");
    my $bounce = "rhn-bounce+" . $to->id . "-" . $to->org->id . '@' . PXT::Config->get("bounce_to_host");

    RHN::Mail->send(to => sprintf("%s <%s>", $to_label, $to->email),
		    from => $from,
		    subject => $reply->subject,
		    headers => { "Reply-To" => $from,
				 "Errors-To" => $bounce },
		    body => $reply->message);

    RHN::Mail->send(to => PXT::Config->get("feedback_bcc_address"),
		    from => $from,
		    subject => "[Support Response] " . $reply->subject,
		    headers => { "Reply-To" => PXT::Config->get("feedback_bcc_address"),
				 "Errors-To" => $bounce },
		    body => $reply->message);

    $fb->set_status('answered');
    $pxt->push_message(site_info => "Reply sent to <strong>" . $to->email . "</strong>.");
  }
  elsif ($pxt->dirty_param('send_to_faq')) {
    my $fid = RHN::Feedback->faq_insert(-question => $pxt->dirty_param('subject'),
					-answer => $pxt->dirty_param('response'),
					-private => 1);

    $pxt->push_message(site_info => "New FAQ entry created.");

    if ($pxt->dirty_param('request_publication')) {
      send_faq_publication_request($pxt, $fid);
    }
  }
  $fb->commit;

  $pxt->redirect("/internal/feedback/index.pxt$vars")
    unless $pxt->dirty_param('insert_from_faq');
}

sub send_faq_publication_request {
  my $pxt = shift;
  my $fid = shift;

  my $letter = new RHN::Postal;
  $letter->template('internal/faq_publication_request.xml');
  $letter->set_tag('user_login' => $pxt->user->login);
  my $url = $pxt->derelative_url("/internal/feedback/faq_edit.pxt?type=${fid}");
  $letter->set_tag('faq_link' => $url);
  $letter->render;
  my $mail = PXT::Config->get('faq_publication_email');
  $letter->to($mail);
  $letter->wrap_body;
  $letter->send;

  $pxt->push_message(site_info => "A message was sent to <strong>${mail}</strong> requesting that this FAQ be published.");
  return;
}

sub send_faq_publication_notice {
  my $pxt = shift;
  my $fid = shift;

  my $letter = new RHN::Postal;
  $letter->template('internal/faq_publication_notice.xml');
  $letter->set_tag('user_login' => $pxt->user->login);
  my $url = $pxt->derelative_url("/internal/feedback/faq_edit.pxt?type=${fid}");
  $letter->set_tag('faq_link' => $url);
  $letter->render;
  my $mail = PXT::Config->get('faq_publication_email');
  $letter->to($mail);
  $letter->wrap_body;
  $letter->send;

  return;
}

1;
