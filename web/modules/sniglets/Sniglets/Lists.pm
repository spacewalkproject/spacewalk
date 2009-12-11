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

package Sniglets::Lists;

use Params::Validate qw/validate/;

use PXT::Utils;

use Sniglets::ListView::Parser;

use Sniglets::ListView::ProbeList;
use Sniglets::ListView::UserList;
use Sniglets::ListView::PackageList;
use Sniglets::ListView::SystemList;
use Sniglets::ListView::SystemGroupList;
use Sniglets::ListView::ErrataList;
use Sniglets::ListView::FileList;
use Sniglets::ListView::ChannelList;
use Sniglets::ListView::ConfigChannelList;
use Sniglets::ListView::GeneralList;
use RHN::Access;

use PXT::HTML;
use PXT::Utils;
use Data::Dumper;
use Digest::MD5;
use RHN::Exception qw/throw/;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-listview", \&listview);

  $pxt->register_tag('rhn-pathinfo-list-mode', \&pathinfo_list_mode, -5);

  $pxt->register_tag('rhn-system-name', \&system_name, -5);
  $pxt->register_tag('rhn-time-period-selector', \&time_selector);

  $pxt->register_tag('rhn-list-legend' => \&list_legend, 200);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback("rhn:scout_list_cb", [ \&listview_cb, "Sniglets::ListView::ScoutList" ]);
  $pxt->register_callback("rhn:probe_list_cb", [ \&listview_cb, "Sniglets::ListView::ProbeList" ]);
  $pxt->register_callback("rhn:user_list_cb", [ \&listview_cb, "Sniglets::ListView::UserList" ]);
  $pxt->register_callback("rhn:package_list_cb", [ \&listview_cb, "Sniglets::ListView::PackageList" ]);
  $pxt->register_callback("rhn:system_list_cb" => [ \&listview_cb, "Sniglets::ListView::SystemList" ]);
  $pxt->register_callback("rhn:system_group_list_cb" => [ \&listview_cb, "Sniglets::ListView::SystemGroupList" ]);
  $pxt->register_callback("rhn:errata_list_cb" => [ \&listview_cb, "Sniglets::ListView::ErrataList" ]);
  $pxt->register_callback("rhn:file_list_cb", [ \&listview_cb, "Sniglets::ListView::FileList" ]);
  $pxt->register_callback("rhn:channel_list_cb", [ \&listview_cb, "Sniglets::ListView::ChannelList" ]);
  $pxt->register_callback("rhn:config-channel_list_cb", [ \&listview_cb, "Sniglets::ListView::ConfigChannelList" ]);
  $pxt->register_callback("rhn:action_list_cb", [ \&listview_cb, "Sniglets::ListView::ActionList" ]);
  $pxt->register_callback("rhn:custominfo_list_cb", [ \&listview_cb, "Sniglets::ListView::CustomInfo" ]);
  $pxt->register_callback("rhn:general_list_cb" => [ \&listview_cb, "Sniglets::ListView::GeneralList" ]);

  $pxt->register_callback("rhn:profile_list_cb" => [ \&listview_cb, "Sniglets::ListView::ProfileList" ]);

  $pxt->register_callback("rhn:empty_set" => \&empty_set, -50);
}

sub list_legend {
  my $pxt = shift;
  my %params = validate(@_, { type => 1, file => 1 });

  if ($pxt->pnotes('legend:' . $params{type})) {
    return $pxt->include(-file => $params{file});
  }

  return '';
}

my %lv_cache;
sub listview {
  my $pxt = shift;
  my %params = @_;

  my $class = $params{class};
  my $mode = $params{mode};
  my $acl_mixins = $params{acl_mixins};
  eval "use $class;";

  throw "listview ($class) called with no child block"
    unless $params{__block__};

  my $key = $mode . "|" . Digest::MD5::md5_hex($params{__block__});

  if (not exists $lv_cache{$key}) {
    my $body = qq(<rhn-listview mode="$mode">$params{__block__}</rhn-listview>);
    $lv_cache{$key} = Sniglets::ListView::Parser->parse($body);
  }

  my $list = $class->new(-listview => $lv_cache{$key},
			 -mode => $mode,
			 -alphabar_column => uc($params{alphabar_column}),
			 -filter_string => $pxt->dirty_param('filter_string') || '',
			 -filter_type => $params{filter_type} || 'text',
			 -style => $params{style},
			 -lower => $pxt->dirty_param('lower') || 1,
			 -upper => $pxt->dirty_param('upper') || $pxt->user->preferred_page_size,
			 -acl_mixins => $acl_mixins,
			);

  return $list->render($pxt);
}

sub listview_cb {
  my $pxt = shift;
  my $class = shift;

  eval "use $class;";

  my $list = $class->new(-mode => $pxt->dirty_param('list_mode') || '',
			 -alphabar_column => $pxt->dirty_param('alphabar_column') || '',
			 -filter_string => $pxt->dirty_param('filter_string') || '',
			 -lower => $pxt->dirty_param('lower') || 1,
			 -upper => $pxt->dirty_param('upper') || $pxt->user->preferred_page_size,
			);

  $list->callback($pxt);
}

#--- Utility Functions ---#

sub empty_set {
  my $pxt = shift;
  my $params = shift;

  my $set_label = $pxt->dirty_param('set_label') || $params->{set_label} || '';
  return unless $set_label;

  my $set = new RHN::DB::Set $set_label, $pxt->user->id;

  $set->empty;
  $set->commit;

  my @params = $pxt->param;
  my @delete_params = qw/set_label pxt_trap pxt:trap return_url/;

  my %seen;

  @seen{@delete_params} = ();
  my %keep_params;

  foreach my $param (@params) {
    unless (exists $seen{$param}) {
      next unless $pxt->passthrough_param($param);
      $keep_params{$param} = $pxt->passthrough_param($param);
    }
  }

  my $additional_vars = join('&', map { "$_=" . PXT::Utils->escapeURI($keep_params{$_}) } keys %keep_params);

  if ($additional_vars) {
    $additional_vars = "?$additional_vars";
  }

  my $url = PXT::Utils->unescapeURI($pxt->dirty_param('return_url')) || $pxt->uri;

  $pxt->redirect($url . "$additional_vars");
}

my %node_set = (system_package_list => 'removable_package_list',
		system_upgradable_package_list => 'upgrade_package_list',
		system_installable_package_list => 'install_package_list',
		system_errata_list => 'errata_list',
		target_systems_list => 'target_systems_list',
                system_groups_list => 'remove_system_from_groups',
                target_groups_for_system => 'target_groups_for_system',
		system_group_errata_list => 'systems_affected_by_errata',
		systems_subscribed_to_channel => 'remove_systems_from_channel',
		target_systems_for_channel => 'target_systems_for_channel',
		manage_package_channels => 'packages_in_channel',
		manage_packages => 'deletable_package_list',
		manage_errata_packages => 'errata_package_list',
		target_systems_for_namespace => 'target_systems',
		target_systems_for_package => 'target_systems',
		clonable_errata_list => 'clone_errata_list',
		remove_channel_packages => 'packages_to_remove',
		add_channel_packages => 'packages_to_add',
                remove_errata_packages => 'packages_to_remove',
                add_errata_packages => 'packages_to_add',
		clone_channel_errata => 'errata_clone_actions',
		selected_configfiles => 'selected_configfiles',
		selected_configfiles_ssm => 'selected_configfiles_ssm',
		selected_configfilenames => 'selected_configfilenames',
		selected_namespaces => 'selected_namespaces',
		packages_for_system_sync => 'packages_for_system_sync',
	       );

sub navi_empty_set {
  my $class = shift;
  my $node = shift;
  my $pxt = shift;

  my $set_label = $node_set{$node->node_id};
  empty_set($pxt, { set_label => $set_label });

  return;
}

my %pinfo_modes = (
          system => {'/visible_to_user.pxt' => {mode => 'visible_to_user', name => 'Systems'},
		     '/out_of_date.pxt' => {mode => 'out_of_date', name => 'Out of Date Systems'},
		     '/unentitled.pxt' => {mode => 'unentitled', name => 'Unentitled Systems'},
		     '/ungrouped.pxt' => {mode => 'ungrouped', name => 'Ungrouped Systems'},
		     '/inactive.pxt' => {mode => 'inactive', name => 'Inactive Systems'},
		     '/proxy.pxt' => {mode => 'proxy_servers', name => 'Proxy Servers'},
		     '/in_channel_family.pxt' => {mode => 'systems_in_channel_family', name => 'Subscribed Systems'},
		     '/potentially_in_channel_family.pxt' => {mode => 'systems_potentially_in_channel_family', name => 'Subscribable Systems'},
		    },
          errata => {'/relevant.pxt' => {mode => 'relevant_errata', name => 'Errata Relevant to Your Systems'},
		     '/all.pxt' => {mode => 'all_errata', name => 'All Errata'},
		    },
   manage_errata => {'/published.pxt' => {mode => 'published_owned_errata', name => 'Published Errata',
					  label => 'published' },
		     '/unpublished.pxt' => {mode => 'unpublished_owned_errata', name => 'Unpublished Errata',
					    label => 'unpublished' },
		    },
	  probes => {'/all.pxt' => {mode => 'all_system_probes', name => 'Probes'},
		     '/ok.pxt' => {mode => 'ok_system_probes', name => 'OK Probes'},
		     '/warning.pxt' => {mode => 'warning_system_probes', name => 'Warning Probes'},
		     '/critical.pxt' => {mode => 'critical_system_probes', name => 'Critical Probes'},
		     '/unknown.pxt' => {mode => 'unknown_system_probes', name => 'Unknown Probes'},
		     '/pending.pxt' => {mode => 'pending_system_probes', name => 'Pending Probes'},
		    },
		  );

sub pathinfo_list_mode {
  my $pxt = shift;
  my %attr = @_;

  my $html = $attr{__block__} || '';
  throw "No block in pathinfo_list_mode"
    unless $html;

  my $type = $attr{type} || '';
  throw "Invalid pathinfo list type '$type'."
    unless (exists $pinfo_modes{$type});

  my $pinfo = $pxt->path_info || '';
  $pinfo =~ s/\.pxt.*$/.pxt/;
  $pxt->redirect('/errors/404.pxt')
    unless (exists $pinfo_modes{$type}->{$pinfo});

  $html =~ s/\{pinfo_list_name\}/$pinfo_modes{$type}->{$pinfo}->{name}/ge;
  $html =~ s/\{pinfo_list_label\}/$pinfo_modes{$type}->{$pinfo}->{label} || ''/ge;
  $html =~ s/\{pinfo_list_mode\}/$pinfo_modes{$type}->{$pinfo}->{mode}/ge;

  return $html;
}

sub system_name {
  my $pxt = shift;
  my %params = @_;

  my $sid = $params{sid} || $pxt->param('sid');
  die "no server id" unless $sid;

  $pxt->user->verify_system_access($sid)
    or $pxt->redirect('/errors/permission.pxt');

  my $server = RHN::Server->lookup(-id => $sid);
  die "no valid server" unless $server;

  my %subst;

  $subst{system_name} = PXT::Utils->escapeHTML($server->name);
  return PXT::Utils->perform_substitutions($params{__block__}, \%subst);
}

my @sort_columns = ( { value => 'FB.created',
		       label => 'Date', },
		     { value => 'BASIC_SLOTS',
		       label => 'Update Slots', },
		     { value => 'ENTERPRISE_SLOTS',
		       label => 'Management Slots', },
		     );

my @sort_orders = ( { value => 'DESC',
		      label => 'Descending', },
		    { value => 'ASCENDING',
		      label => 'Ascending', },
		    );

my $time_slots = [
		  { label => '5 Minutes',
		    value => 5 },
		  { label => 'Hour',
		    value => 60 },
		  { label => 'Day',
		    value => 1440 },
		  { label => 'Week',
		    value => 10080 },
		  { label => 'Month',
		    value => 40320 },
		 ];


sub time_selector {
  my $pxt = shift;
  my %params = @_;

  my $formvar = $params{formvar};
  throw "No formvar specified." unless $formvar;

  my $current = $pxt->dirty_param($formvar) || $params{default};
  throw "No default value." unless $current;

  my $ret = PXT::HTML->form_start(-method => 'POST');

  $ret .= PXT::HTML->select(-name => $formvar,
			    -options => [ map { [ $_->{label}, $_->{value}, $_->{value} == $current ] }
					  @{$time_slots} ] );

  $ret .= PXT::HTML->submit(-name => 'Submit',
			    -value => 'Submit');

  $ret .= PXT::HTML->form_end;
  return $ret;
}

1;
