#
# Copyright (c) 2008--2009 Red Hat, Inc.
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

package Sniglets::ListView::FileList;

use Sniglets::ListView::List;
use RHN::DataSource::General;
use RHN::DataSource::Simple;
use PXT::HTML;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:file_list_cb";
}

sub list_of { return "files" }

sub _register_modes {


  Sniglets::ListView::List->add_mode(-mode => "diff_action_info",
				     -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "diff_action_differences",
				     -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "config_action_failures",
				     -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "config_action_non_failures",
				     -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "package_files",
			   -datasource => RHN::DataSource::General->new);

  Sniglets::ListView::List->add_mode(-mode => "selected_files",
				     -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));
  Sniglets::ListView::List->add_mode(-mode => "latest_files_in_namespace",
				     -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));
  Sniglets::ListView::List->add_mode(-mode => "files_in_sandbox",
				     -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));
  Sniglets::ListView::List->add_mode(-mode => "files_in_override",
				     -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "configfile_revisions",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "configfiles_for_system",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"),
			   -provider => \&configfiles_for_system_provider);

  Sniglets::ListView::List->add_mode(-mode => "configfiles_for_system_diff",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"),
			   -provider => \&configfiles_for_system_provider);

  Sniglets::ListView::List->add_mode(-mode => "configfiles_for_ssm",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"),
			   -provider => \&configfiles_for_ssm);

  Sniglets::ListView::List->add_mode(-mode => "configfiles_for_ssm_diff",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"),
			   -provider => \&configfiles_for_ssm);

  Sniglets::ListView::List->add_mode(-mode => "configfiles_for_snapshot",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "configfiles_for_user",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "selected_configfiles",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "selected_configfilenames",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"));

  Sniglets::ListView::List->add_mode(-mode => "configfilenames_for_import",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"),
			   -provider => \&configfilenames_for_import_provider);

  Sniglets::ListView::List->add_mode(-mode => "org_configfile_size_totals",
			   -datasource => new RHN::DataSource::Simple(-querybase => "config_queries"),
			  );
}

my %type_icon = ('Directory' => '/img/folder-config-sm.png',
                 'File' => '/img/file-config-sm.png');

sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  if ($self->datasource->mode eq 'package_files') {
    $row->{NAME} = '<tt>' . $row->{NAME} . '</tt>';

    if ($row->{CHECKSUM}) {
      $row->{CHECKSUM} = '<tt>' . uc($row->{CHECKSUM_TYPE}) . ': ' . $row->{CHECKSUM} . '</tt>';
      $row->{FILE_SIZE} = '<tt>' . PXT::Utils->commafy($row->{FILE_SIZE}) . " bytes</tt>";
    }
    elsif ($row->{LINKTO}) {
      $row->{FILE_SIZE} = '&#160;';
      $row->{CHECKSUM} = "<tt>(Symlink)</tt>";
    }
    else {
      $row->{FILE_SIZE} = '&#160;';
      $row->{CHECKSUM} = "<tt>(Directory)</tt>";
    }
  }

  if ($self->datasource->mode eq 'latest_files_in_namespace' or
      $self->datasource->mode eq 'selected_files' or
      $self->datasource->mode eq 'configfiles_for_ssm' or
      $self->datasource->mode eq 'configfiles_for_system' or
      $self->datasource->mode eq 'files_in_override') {
      my $type = $row->{FILETYPE};
      # If type is a directory, we need to add a trailing "/" to the filename
      if (defined $type and $type eq 'Directory') {
          $row->{PATH} .= "/";
      }
      if (defined $type) {
	# Show corresponding image before the path
	$row->{PATH} = "<img src=\"" . $type_icon{$type} ."\" alt=\"" . $type . "\" />&#160;" . $row->{PATH};
      }
  }

  return $row;
}

sub configfiles_for_system_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;
  my %params = $self->lookup_params($pxt, $ds->required_params);
  my $data = $ds->execute_query(%params);

  $data = resolve_ordered_paths($data);
  $data = $self->filter_data($data);
  my $alphabar = $self->init_alphabar($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  my $sid = $pxt->param('sid');

  foreach my $row (@$data) {
    Sniglets::ListView::List::escape_row($row);

    $row->{OVERRIDES} = '&#160;';

    if ($row->{__data__}) {

      my @overrides;

      if ($sid) {
          my $rev_link = sprintf("/rhn/configuration/file/FileDetails.do?sid=%d&amp;crid=", $sid);
          my $chan_link = sprintf("/rhn/configuration/ChannelFiles.do?ccid=");
          @overrides = map { PXT::HTML->link($rev_link . $_->{CRID}, "Revision " . $_->{REVISION})
                             . " from " .
                             PXT::HTML->link($chan_link . $_->{CONFIG_CHANNEL_ID}, $_->{CONFIG_CHANNEL})
                           } @{$row->{__data__}};
      }
      else {
          my $cf_url = '/rhn/configuration/file/FileDetails.do?crid=';
          my $ns_url = '/rhn/configuration/ChannelOverview.do?ccid=';
          @overrides = map { PXT::HTML->link($cf_url . $_->{CRID}, "Revision " . $_->{REVISION})
                             . " from " .
                             PXT::HTML->link($ns_url . $_->{CONFIG_CHANNEL_ID}, $_->{CONFIG_CHANNEL})
                           } @{$row->{__data__}};
      }

      $row->{OVERRIDES} = join("<br />\n", @overrides);
    }
  }

  return (data => $data,
	  all_ids => $all_ids,
	  alphabar => $alphabar);
}

sub configfiles_for_ssm {
  my $self = shift;
  my $pxt = shift;

  my $ds = $self->datasource;
  my %params = $self->lookup_params($pxt, $ds->required_params);
  my $data = $ds->execute_query(%params);

  $data = resolve_ordered_paths($data);
  $data = $self->filter_data($data);
  my $alphabar = $self->init_alphabar($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params);

  return (data => $data,
	  all_ids => $all_ids,
	  alphabar => $alphabar);
}


sub configfilenames_for_import_provider {
  my $self = shift;
  my $pxt = shift;

  my $ds = new RHN::DataSource::Simple(-querybase => "config_queries", -mode => 'configfiles_for_system');
  my %params = $self->lookup_params($pxt, $ds->required_params);
  my $sys_data = $ds->execute_query(%params);
  $sys_data = resolve_ordered_paths($sys_data);

  my $data = [ map { { ID => $_->{CONFIG_FILE_NAME_ID},
		       PATH => $_->{PATH},
		     } } @{$sys_data} ];

  $ds = new RHN::DataSource::Simple(-querybase => "config_queries", -mode => 'selected_configfilenames');
  my $selected_files = $ds->execute_query(-user_id => $pxt->user->id, -set_label => 'selected_configfilenames');

  my %exists = map { ($_->{ID}, 1) } @{$data};

  foreach my $row (@{$selected_files}) {
    unless ($exists{$row->{ID}}) {
      $exists{$row->{ID}} = 1;
      push @{$data}, $row;
    }
  }

  $data = [ sort { $a->{PATH} cmp $b->{PATH} } @{$data} ];

  $data = $self->filter_data($data);
  my $alphabar = $self->init_alphabar($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);

  return (data => $data,
	  all_ids => $all_ids,
	  alphabar => $alphabar);
}

# given a set of file data, find the latest occurence of each path.
sub resolve_ordered_paths {
  my $data = shift;

  my %seen;

  $data = [ sort { $a->{PATH} cmp $b->{PATH} }
	    grep { not $seen{$_->{PATH}}++ } @{$data} ];

  return $data;
}

# Overrides the List.pm implementation.  We don't want the alphabar to 
# appear when displaying files.
sub render_alphabar {
    return '';
}

1;
