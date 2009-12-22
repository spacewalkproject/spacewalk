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

use RHN::Exception;
use RHN::ConfigChannel;
use RHN::ConfigRevision;
use RHN::DataSource::ConfigChannel;

use Sniglets::Forms;
use Sniglets::Forms::Style;
use Sniglets::ActivationKeys;
use RHN::Form::ParsedForm;
use RHN::Form::Widget::File;
use RHN::Form::Widget::RadiobuttonGroup;

use Params::Validate qw/validate/;

use File::Spec;

# constant representing the 16kb limit for editable config files
use constant max_edit_size => 16384;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  # use -150 for priority since we need to set a {foo} that is consumed by a the navi tag
}

sub configfile_copy_files_cb {
  my $pxt = shift;
  my $mode = $pxt->dirty_param('copy_mode') || '';

  my $sid = $pxt->param('sid');

  my $transaction = RHN::DB->connect;
  $transaction->nest_transactions;

  my (@dest_chan, @redir_params);
  my $success_target_string;
  if ($mode eq 'system_local_override') {
    my $ccid = RHN::ConfigChannel->vivify_server_config_channel($sid, 'local_override');
    push @dest_chan, RHN::ConfigChannel->lookup(-id => $ccid);
    @redir_params = (sid => $sid, ccid => RHN::ConfigChannel->vivify_server_config_channel($sid, 'server_import'));

    my $server = RHN::Server->lookup(-id => $sid);
    $success_target_string = sprintf "the local config channel for <strong>%s</strong>", $server->name;
  }
  elsif ($mode eq 'normal_channel') {
    my $set = RHN::Set->lookup(-label => $pxt->dirty_param('set_label'), -uid => $pxt->user->id);
    @redir_params = (sid => $sid);
    push @redir_params, ccid => $pxt->param('ccid')
      if $pxt->param('ccid');

    for my $ccid ($set->contents) {
      push @dest_chan, RHN::ConfigChannel->lookup(-id => $ccid);
    }

    $success_target_string = sprintf "%d global config channel%s", scalar @dest_chan, scalar @dest_chan > 1 ? 's' : '';
  }
  else {
    die "Unknown configfile_copy_files_cb mode $mode";
  }

  my $source_set_label = $pxt->dirty_param('source_set');
  my $set = RHN::Set->lookup(-label => $source_set_label, -uid => $pxt->user->id);

  my $file_count = 0;
  for my $crid ($set->contents) {
    my $cr = RHN::ConfigRevision->lookup(-id => $crid);

    # don't copy metadata-only stuff... can happen from sandbox
    next unless ($cr->contents() or (uc $cr->filetype eq "DIRECTORY"));

    $file_count++;

    for my $dest_chan (@dest_chan) {
      my $cfid = $dest_chan->vivify_file_existence($cr->path);

      my $new_revision = $cr->copy_revision;
      $new_revision->revision(undef);
      $new_revision->config_file_id($cfid);
      eval {
        $new_revision->commit;
      };

      # check to see if we are over quota, if so let user know
      if ($@) {
        my $E = $@;
                                                                                                                        
        $transaction->nested_rollback;
                                                                                                                        
        die $E unless (ref $E and $E->isa('RHN::Exception'));
                                                                                                                        
        if ($E->is_rhn_exception('not_enough_quota')) {
          $pxt->push_message(local_alert => 'Insufficient available quota for the specified action!');
        }
        else {
          throw $E;
        }
                                                                                                                        
        return;
      }
    }
  }

  if ($file_count != (scalar $set->contents())) {
    $pxt->push_message(site_info => "Some of the requested files were meta-data only, and could not be copied.");
  }

  $set->empty;
  $set->commit;

  $transaction->nested_commit;

  if ($file_count) {
    $pxt->push_message(site_info =>
		       sprintf('<strong>%s</strong> file%s copied to %s.',
			       $file_count, $file_count == 1 ? '' : 's', $success_target_string));
  }

  $pxt->redirect($pxt->dirty_param('success_redirect'), @redir_params);
}



1;
