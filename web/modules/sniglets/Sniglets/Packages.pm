#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

package Sniglets::Packages;

use Carp;

use PXT::HTML;
use RHN::Package;
use RHN::Form;
use Sniglets::ListView::PackageList;

use RHN::Exception qw/throw/;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-unknown-package-nvre' => \&unknown_package_nvre);

  $pxt->register_tag('rhn-upload-answerfile-form' => \&upload_answerfile_form);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:upload-answerfile-cb' => \&upload_answerfile_cb);
}

sub unknown_package_nvre {
  my $pxt = shift;
  my %params = @_;

  my $id_combo = $pxt->dirty_param('id_combo');
  die "no id_combo" unless $id_combo;

  my ($name_id, $evr_id) = split /[|]/, $id_combo;
  return RHN::Package->lookup_nvre($name_id, $evr_id);
}

sub upload_answerfile_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_upload_answerfile_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

sub build_upload_answerfile_form {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $cid = $pxt->param('cid');
  my $id_combo = $pxt->dirty_param('id_combo');
  my $set_label = $pxt->dirty_param('set_label');
  my $mode = $pxt->dirty_param('mode');

  my $form = new RHN::Form::ParsedForm(name => "Answer File",
                                       label => 'answerfile_form',
                                       action => $attr{action},
                                       enctype => 'multipart/form-data',
                                      );

  $form->add_widget( new RHN::Form::Widget::TextArea(name => 'Answer File',
                                                     label => 'answerfile_contents',
                                                     rows => 24,
                                                     cols => 80,
                                                     default => '') );

  if ($mode eq 'ssm_package_install_answer_files') {
    $form->add_widget(hidden => { name => 'sscd_confirm_package_installations', value => 1 });
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:upload-answerfile-cb') );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'sid', value => $sid) ) if $sid;
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'cid', value => $cid) ) if $cid;
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'set_label', value => $set_label) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'id_combo', value => $id_combo) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'mode', value => $mode) );
  $form->add_widget( new RHN::Form::Widget::Submit(name => "Upload File") );

  return $form;
}

sub upload_answerfile_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  my $id_combo = $pxt->dirty_param('id_combo');
  my $set_label = $pxt->dirty_param('set_label');
  my $mode = $pxt->dirty_param('mode');

  my $contents = $pxt->dirty_param('answerfile_contents') || '';

  my $package_answer_files = $pxt->session->get('package_answer_files') || { };
  $package_answer_files->{$id_combo} = $contents;
  $pxt->session->set('package_answer_files' => $package_answer_files);

  Sniglets::ListView::PackageList->default_callback($pxt, label => $mode);

  if ($mode eq 'ssm_package_install_remote_command'
      or $mode eq 'ssm_package_install_answer_files') {
    $pxt->redirect("/network/systems/ssm/packages/index.pxt?sid=$sid");
  }
  else {
    $pxt->redirect("/rhn/systems/details/packages/Packages.do?sid=$sid");
  }

  return;
}

1;
