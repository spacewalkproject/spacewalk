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

package Sniglets::ServerNotes;

use Carp;
use RHN::Server;
use RHN::ServerNotes;
use RHN::Exception;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-server-note-edit-form' => \&server_note_edit_form);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:server_note_cb' => \&server_note_cb);
}

sub server_note_edit_form {
  my $pxt = shift;
  my %params = @_;

  my $work_block = $params{__block__};

  my $sid = $pxt->param('sid') || '';  #server_id
  my $nid = $pxt->param('nid') || '';  #note_id
  my $n;

  if ($nid) {
    $n = RHN::ServerNotes->lookup(-id => $nid);
    my $server = RHN::Server->lookup(-id => $n->server_id);
    $pxt->user->verify_system_access($server->id)
	or $pxt->redirect('/errors/permission.pxt');
  }

  my $note_field = defined ($n) ? $n->note : $pxt->dirty_param('note') || '';
  my $subject_field = defined ($n) ? $n->subject : $pxt->dirty_param('subject') || '';

  $work_block =~ s/\{note\}/PXT::Utils->escapeHTML($note_field || '')/eg;
  $work_block =~ s/\{subject\}/PXT::Utils->escapeHTML($subject_field)/eg;

  return $work_block;
}

# validate server note and insert into db
sub server_note_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  my $nid = $pxt->param('nid');
  my $delete = $pxt->dirty_param('delete');
  my $server = RHN::Server->lookup(-id => $sid);
  my $note;
  my $subject = $pxt->dirty_param('subject') || '';
  my $text = $pxt->dirty_param('note') || '';

  my $len = length $text;

  if ($len > 4000) {
    $pxt->push_message(local_alert => "The text entered was $len characters long.  A note cannot exceed 4000 characters.");
    return;
  }

  $len = length $subject;

  if ($len > 80) {
    $pxt->push_message(local_alert => "The subject entered was $len characters long.  It must be at most 80 characters long.");
    return;
  }

  # insert or update, depending on whether $nid is defined
  if ($server) {
    if ($nid) {
      $note = RHN::ServerNotes->lookup(-id => $nid);
      my $server = RHN::Server->lookup(-id => $note->server_id);
      $pxt->user->verify_system_access($server->id)
	or $pxt->redirect('/errors/permission.pxt');
    }
    else {
      $note = RHN::ServerNotes->create;
    }
    $note->server_id($sid);
    $note->creator($pxt->user->id());
    $note->subject($subject);
    $note->note($text);

    # hack alert
    if (defined $delete) {
      $note->{__delete__} = 1;
    }
    eval {
      $note->commit;
    };

    if ($@ and catchable($@)) {
      my $E = $@;

      if ($E->constraint_value eq '"RHNSERVERNOTES"."SUBJECT"') {
	$pxt->push_message(local_alert => 'You must choose a subject for your note.');
	return;
      }
      else {
	throw $E;
      }
    }
    elsif ($@) {
      die $@;
    }
  }

  my $redir = $pxt->dirty_param('redirect_success');
  throw "param 'redirect_success' needed but not provided." unless $redir;

  if ($delete) {
    $pxt->push_message(site_info => "System note deleted.");
  }
  elsif ($nid) {
    $pxt->push_message(site_info => "System note updated.");
  }
  else {
    $pxt->push_message(site_info => "System note created.");
  }

  $pxt->redirect($redir);
}

1;
