#
# Copyright (c) 2008--2013 Red Hat, Inc.
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

package Sniglets::ListView::ConfigChannelList;

use Sniglets::ListView::List;
use RHN::DataSource::ConfigChannel;
use RHN::Exception qw/throw/;

use PXT::HTML;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:config-channel_list_cb";
}

sub list_of { return "namespaces" }

sub _register_modes {

  Sniglets::ListView::List->add_mode(-mode => "namespaces_visible_to_org",
			   -datasource => RHN::DataSource::ConfigChannel->new,
			   -provider => \&namespaces_visible_to_org_provider,
			   -action_callback => \&namespaces_visible_to_org_cb);

  Sniglets::ListView::List->add_mode(-mode => "namespaces_for_system",
			   -datasource => RHN::DataSource::ConfigChannel->new);

  Sniglets::ListView::List->add_mode(-mode => "rank_namespaces_for_system",
			   -datasource => RHN::DataSource::ConfigChannel->new);

  Sniglets::ListView::List->add_mode(-mode => "namespaces_for_snapshot",
			   -datasource => RHN::DataSource::ConfigChannel->new);

  Sniglets::ListView::List->add_mode(-mode => "available_namespaces_for_system",
			   -datasource => RHN::DataSource::ConfigChannel->new);

  Sniglets::ListView::List->add_mode(-mode => "namespaces_with_filename",
			   -datasource => RHN::DataSource::ConfigChannel->new);
}


sub namespaces_visible_to_org_provider {
  my $self = shift;
  my $pxt = shift;

  my %ret = $self->default_provider($pxt);

  my $cr;
  if (my $crid = $pxt->param('crid')) {
    $cr = RHN::ConfigRevision->lookup(-id => $crid);
  }

  foreach my $row (@{$ret{data}}) {
    $row->{FILE_COUNT} ||= 0;
    $row->{SYSTEM_COUNT} ||= 0;

    if ($cr) {
      my $alt_cr = $cr->find_alternate_in_namespace($row->{ID});

      if ($alt_cr) {
	$row->{CURRENT_FILE_VERSION} = ($alt_cr->{ID} == $cr->id) ? '(this file)'

	  : PXT::HTML->link('/rhn/configuration/file/FileDetails.do?crid=' . $alt_cr->{ID}, 'revision ' . $alt_cr->{REVISION});
      }
      else {
	$row->{CURRENT_FILE_VERSION} = '(none)';
      }

    }
  }

  return %ret;
}

sub is_row_selectable {
  my $self = shift;
  my $pxt = shift;
  my $row = shift;

  my $mode = $self->datasource->mode();

  if (    $mode eq 'namespaces_visible_to_org'
      and $row->{CURRENT_FILE_VERSION}
      and $row->{CURRENT_FILE_VERSION} eq '(this file)') {
    return 0;
  }

  return 1;
}

sub clean_set {
  my $self = shift;
  my $set = shift;
  my $user = shift;
  my $formvars = shift;

  my $mode = $self->datasource->mode();


  if ($mode eq 'namespaces_visible_to_org') {
    my $crid = $formvars->{crid};

    if ($crid) {
      my $cr = RHN::ConfigRevision->lookup(-id => $crid);

      throw "no revision for crid $crid" unless $cr;

      my $ccid = $cr->config_channel_id;

      my @contents = $set->contents;
      @contents = grep { $_ != $ccid } @contents;

      $set->empty;
      $set->add(@contents);
      $set->commit;
    }
  }

  return;
}

sub namespaces_visible_to_org_cb {
  my $self = shift;
  my $pxt = shift;

  my %action = @_;

  my $label = '';

  if (exists $action{label}) {
    $label = $action{label};
  }

  if ($label eq 'copy_configfile') {
    my $set_label = $pxt->dirty_param('set_label');
    my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

    my $cr = RHN::ConfigRevision->lookup(-id => $pxt->param('crid'));

    my $count = scalar $set->contents;

    foreach my $ccid ($set->contents) {
      my $cc = RHN::ConfigChannel->lookup(-id => $ccid);
      my $cfid = $cc->vivify_file_existence($cr->path);

      my $new_revision = $cr->copy_revision;
      $new_revision->revision(undef);
      $new_revision->config_file_id($cfid);
      $new_revision->commit;
    }

    $set->empty;
    $set->commit;

    if ($count) {
      $pxt->push_message(site_info => sprintf('<strong>%s</strong> copied to <strong>%d</strong> config channel%s.', $cr->path, $count, $count == 1 ? '' : 's'));
    }
  }
  elsif ($label eq 'copy_sandbox_configfile') {
    Sniglets::ConfigManagement::configfile_copy_files_cb($pxt);
  }
  elsif ($label eq 'copy_override_configfile') {
    Sniglets::ConfigManagement::configfile_copy_files_cb($pxt);
  }

  return 1;
}

1;
