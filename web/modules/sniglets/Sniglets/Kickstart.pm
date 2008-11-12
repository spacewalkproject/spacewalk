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
package Sniglets::Kickstart;

use PXT::Utils;
use File::Spec;
use File::stat;
use Digest::MD5;
use HTTP::Date;

use RHN::KSTree;
use RHN::Kickstart;
use RHN::Kickstart::Commands;
use RHN::Kickstart::Partitions;
use RHN::Kickstart::Volgroups;
use RHN::Kickstart::Logvols;
use RHN::Kickstart::Include;
use RHN::Kickstart::Raids;
use RHN::Kickstart::Template;
use RHN::Kickstart::IPRange;
use RHN::Scheduler;
use RHN::TinyURL;
use RHN::Profile;
use Sniglets::ServerActions;
use Sniglets::ActivationKeys;
use RHN::Kickstart::Session;
use RHN::SessionSwap;
use RHN::Set;
use RHN::Package;
use RHN::FileList;

use RHN::Form::Widget::Spacer;
use RHN::Form::Widget::Multiple;

use RHN::DataSource::Package;
use RHN::DataSource::General;

use RHN::DB;

use RHN::Exception;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-kickstart-handler' => \&kickstart_handler);
  $pxt->register_tag('rhn-kickstart-edit-form' => \&kickstart_edit_form);
  $pxt->register_tag('rhn-kickstart-create-form' => \&kickstart_create_form);
  $pxt->register_tag('rhn-kickstart-create-options-form' => \&kickstart_create_options_form);
  $pxt->register_tag('rhn-kickstart-command-edit-form' => \&kickstart_command_edit_form);
  $pxt->register_tag('rhn-kickstart-script-edit-form' => \&kickstart_script_edit_form);
  $pxt->register_tag('rhn-kickstart-details' => \&kickstart_details);
  $pxt->register_tag('rhn-kickstart-package-select-form' => \&kickstart_package_select_form);
  $pxt->register_tag('rhn-kickstart-ip-ranges-form' => \&kickstart_ip_ranges_form);
  $pxt->register_tag('rhn-kickstart-options-form' => \&kickstart_options_form);
  $pxt->register_tag('rhn-kickstart-schedule-form' => \&kickstart_schedule_form);
  $pxt->register_tag('rhn-kickstart-session-details' => \&session_details);
  $pxt->register_tag('rhn-ip-kickstart-url' => \&ip_kickstart_url);
  $pxt->register_tag('rhn-kstree-edit-form' => \&kstree_edit_form);

  $pxt->register_tag('rhn-kickstart-tinyurl' => \&tiny_url_handler);
  $pxt->register_tag('rhn-kickstart-file-preserv' => \&edit_file_preservation);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:kickstart-details-cb' => \&kickstart_details_cb);
  $pxt->register_callback('rhn:kickstart-create-cb' => \&kickstart_create_cb);
  $pxt->register_callback('rhn:kickstart-create-options-cb' => \&kickstart_create_options_cb);
  $pxt->register_callback('rhn:kickstart-post-cb' => \&kickstart_post_cb);
  $pxt->register_callback('rhn:kickstart-interpreter-post-cb' => \&kickstart_interpreter_post_cb);
  $pxt->register_callback('rhn:kickstart-interpreter-pre-cb' => \&kickstart_interpreter_pre_cb);
  $pxt->register_callback('rhn:kickstart-nochroot-post-cb' => \&kickstart_nochroot_post_cb);
  $pxt->register_callback('rhn:kickstart-pre-cb' => \&kickstart_pre_cb);
  $pxt->register_callback('rhn:kickstart-commands-cb' => \&kickstart_commands_cb);
  $pxt->register_callback('rhn:kickstart-delete-cb' => \&kickstart_delete_cb);
  $pxt->register_callback('rhn:kickstart-add-packages-cb' => \&kickstart_add_packages_cb);
  $pxt->register_callback('rhn:kickstart-ip-ranges-cb' => \&kickstart_ip_ranges_cb);
  $pxt->register_callback('rhn:kickstart-delete-range-cb' => \&kickstart_delete_range_cb);

  $pxt->register_callback('rhn:schedule-kickstart-cb' => \&schedule_kickstart_cb);
  $pxt->register_callback('rhn:cancel-kickstart-cb' => \&cancel_kickstart_cb);

  $pxt->register_callback('rhn:kstree-edit-cb' => \&kstree_edit_cb);
  $pxt->register_callback('rhn:kstree-delete-cb' => \&kstree_delete_cb);
  $pxt->register_callback('rhn:edit_file_preserv_cb' => \&edit_file_preserv_cb);
  $pxt->register_callback('rhn:delete_file_list_cb' => \&delete_file_preserv);
}

sub kickstart_handler {
  my $pxt = shift;

  my $path_info = File::Spec->canonpath($pxt->path_info);
  $path_info =~ s(^/)();

  my ($subsys, $path) = split m(/), $path_info, 2;

  if ($subsys eq 'dist') {
    return dist_handler($pxt, $path);
  }
  elsif ($subsys eq 'ks') {
    return kickstart_cfg_handler($pxt, $path);
  }
  else {
    die "argh, no idea how to handle subsys $subsys"
  }
}

sub dist_handler {
  my $pxt = shift;
  my $req_path = shift;
 
  # we accept two URL forms, for cases when there is a pre-determined
  # session available:
  #             /dist/tree/path/to/file.rpm
  # /dist/session/HEX/tree/path/to/file.rpm

  my ($tree_label, $path) = split m(/), $req_path, 2;
  my ($session, $session_id);
  my $new_state;

  # is the tree_label 'session'?  if so, we actually picked up part of
  # the session id tuple; keep trying to split it out
  if ($tree_label eq 'session') {
    ($session_id, $tree_label, $path) = split m(/), $path, 3;
    ($session_id) = RHN::SessionSwap->extract_data($session_id);
  }

  my $tree = RHN::KSTree->lookup(-label => $tree_label);

  if (not $tree) {
    return manual_404($pxt);
  }

  my $disk_path;
  my $kickstart_mount = PXT::Config->get('kickstart_mount_point');
  if (index($tree->base_path, $kickstart_mount) == 0) {
      warn("Trimming ...");
      $kickstart_mount = "";
  }

  
   if ($path =~ /\.rpm$/) {
    # is it a request for an RPM?  If so, try to serve from our magic repo
    my $filename = (split m(/), $path)[-1];
    my $channel = RHN::Channel->lookup(-id => $tree->channel_id);
    my $package_id = $channel->package_by_filename_in_tree($filename);

    if ($package_id) {
      # found the package in our channel repo?  good, serve it...
      my $package = RHN::Package->lookup(-id => $package_id);

      $disk_path = File::Spec->catfile(PXT::Config->get('mount_point'), $package->path);
    }
    $new_state = 'in_progress';
  }
  else {
    # check for dir pings, virt manager or install, bz #345721
    my $dp = File::Spec->catfile($kickstart_mount, $tree->base_path, $path);
    if (-d $dp) {
      $pxt->header_out('Content-Length' => '0');
      $pxt->send_http_header;
      return;
    }
  }

  if (not $disk_path) {
    # either it was not an rpm, or we didn't have it in our repo.  try
    # to find it in the kickstart mount place.

    # is it in the tree?  if not, serve a 404
    if ($tree->has_file($path)) {
      $disk_path = File::Spec->catfile($kickstart_mount, $tree->base_path, $path);
      $new_state = 'started';
    }
    else {
      # We used to return a 404 here but relaxed some of these rules
      # during the cobbler-koan integration.
      $disk_path = File::Spec->catfile($tree->base_path, $path); 
    }
  }

  # finally; we actually will serve a file, so let's mark the status,
  # if we have a session
  if ($session_id) {
    $session = RHN::Kickstart::Session->lookup(-id => $session_id);
    $session->update_state($new_state);
    $session->package_fetch_count($session->package_fetch_count + 1)
      if $new_state eq 'in_progress';
    $session->last_file_request($path);
    $session->commit;
  }

  # At this point, we need to determine whether this is a request for the 
  # actual file, or merely a "ping" from the proxy requesting checksum 
  # information.  If it's a ping request, it will have a HEAD method instead of
  # a GET.

  # XXX: two consecutive .'s in the filename?  404.  ugly, we need to
  # check better.

  if ($disk_path =~ /\.\./ or not -e $disk_path) {
    warn "Missing file while serving kickstart: $disk_path";
    return manual_404($pxt);
  }

  if ($pxt->method eq 'HEAD') 
  {
      return manual_serve_checksum($pxt, $disk_path);
  }
  elsif (my $range = $pxt->header_in('Range')) {
      return manual_serve_byte_range($pxt, $disk_path, $range);
  }
  else {
      return manual_serve($pxt, $disk_path);
  }
}

sub manual_404 {
  my $pxt = shift;

  $pxt->status(404);

  return $pxt->include("/errors/404.pxt");
}

# In the event of a HEAD request for a file, we just compute the
# checksum and place it in the outgoing HTTP headers for the proxy's
# consumption.
sub manual_serve_checksum {
    my $pxt = shift;
    my $disk_path = shift;

    $pxt->manual_content(1);
    $pxt->content_type('application/octet-stream');

    # Obtain the checksum for the file in question and stick it in the 
    # outgoing HTTP headers under "X-RHN-Checksum".

    open(FILE, "$disk_path") or die "open $disk_path: $!";
    binmode(FILE);
    my $checksum = Digest::MD5->new->addfile(*FILE)->hexdigest;
    close FILE;

    # Create some headers.

    $pxt->header_out('Content-Length' => '0');
    $pxt->header_out('X-RHN-Checksum' => $checksum);

    $pxt->send_http_header;

    return;
}

sub manual_serve_byte_range {
    my $pxt = shift;
    my $disk_path = shift;
    my $range = shift;

    $range =~ /bytes=([0-9]*)(?:-([0-9]*))?/;
    my $start = $1;
    my $end = $2 || -1;
    die "Could not understand range header: '$range'" unless $start;

    my $size = $end - $start + 1;
    my $total_size = -s $disk_path;

    if ($size <= 0) {
	return manual_serve($pxt, $disk_path);
    }

    $pxt->manual_content(1);
    $pxt->content_type('application/octet-stream');
    $pxt->status(206); # AKA - PARTIAL_CONTENT

    # Obtain the last modified date of the file and convert it to the preferred
    # HTTP date format.
    my $file_info = stat($disk_path) or die "stat $disk_path: $!";
    my $http_fmt_date = time2str($file_info->mtime);

    # Create some headers.  We need to include the last-modified header so that
    # the package will be cached by squid if the response goes back through an
    # RHN proxy.

    $pxt->header_out('last-modified'  => $http_fmt_date);
    $pxt->header_out('Content-Length' => $size);
    $pxt->header_out('Content-Range' => "bytes $start-$end/$total_size");
    $pxt->header_out('Accept-Ranges' => 'bytes');

    $pxt->send_http_header();

    my $chunk;

    open(FILE, "$disk_path") or die "open $disk_path: $!";
    seek(FILE, $start, 0);
    read(FILE, $chunk, $size);
    $pxt->print($chunk);
    close(FILE);

    return;
}

sub manual_serve {
    my $pxt = shift;
    my $disk_path = shift;

    $pxt->manual_content(1);
    $pxt->content_type('application/octet-stream');

    # Obtain the last modified date of the file and convert it to the preferred
    # HTTP date format.

    my $file_info = stat($disk_path) or die "stat $disk_path: $!";
    my $http_fmt_date = time2str($file_info->mtime);

    # Create some headers.  We need to include the last-modified header so that
    # the package will be cached by squid if the response goes back through an
    # RHN proxy.

    $pxt->header_out('last-modified'  => $http_fmt_date);
    $pxt->header_out('Content-Length' => -s $disk_path);

    $pxt->send_http_header;

    $pxt->sendfile($disk_path);

    return;
}

sub kickstart_cfg_handler {
  my $pxt = shift;
  my $path = shift;

  my $options = ks_path_parser($pxt, $path);

  unless ($options->{-ks}) {
    warn "No kickstart found for path '" . $options->{-path} . "\n";
    return manual_404($pxt);
  }

  my $data;

  if ($options->{-debug}) {
    my %debug_options = map { $_, (($_ eq '-ks' or $_ eq '-ip_range_ks' or $_ eq '-system_ip_ks') and $options->{$_})
				  ? $options->{$_}->id : $options->{$_}
			    } keys %{$options};
    foreach my $opt (sort keys %debug_options) {
      $data .= sprintf("# %s = %s\n", $opt, $debug_options{$opt});
    }
    $data .= "\n\n";
    warn "---ks debug options = '" . Data::Dumper->Dump([(%debug_options)]) . "'\n";
  }

  my $ks = $options->{-ks};
  my $host = PXT::Config->get('kickstart_host') || PXT::Config->get('base_domain');

  my $rhn_proxy_auth = $pxt->header_in('X-RHN-Proxy-Auth');

  if ($rhn_proxy_auth and not $options->{-external_dist}) { # We went through one or more proxies
    my ($first_proxy) = split(/,\s*/, $rhn_proxy_auth);
    my ($proxy_hostname) = reverse split(/:/, $first_proxy);

    $host = $proxy_hostname;
  }

  $ks->change_url_host($host);
  prepare_kickstart_profile(-ks => $ks, -options => $options, -ks_host => $host, -pxt => $pxt);

  $data .= $ks->render;

  $pxt->content_type('text/plain');
  $pxt->manual_content(1);
  $pxt->header_out("Pragma" => "no-cache");
  $pxt->header_out("Cache-Control" => "no-cache");
  $pxt->header_out('Content-length' => length($data));
  $pxt->send_http_header;

  $pxt->print($data);
}

sub ks_path_parser {
  my $pxt = shift;
  my $path = shift;

  my %raw_tags = split(m|/|, $path);
  my %params;

  if ($raw_tags{debug}) {
    $params{-debug} = 1;
  }

  my $mode = '';
  my @valid_modes = qw/session label system_ip ip_range org_default/;

# first part might be a mode name to explicitly set the mode
  if (defined $raw_tags{mode} and grep { $raw_tags{mode} eq $_ } @valid_modes) {
    $mode = $raw_tags{mode};
  }

# check for a hashed org_id
  if (defined $raw_tags{org}) {
    ($params{-org_id}) = RHN::SessionSwap->extract_data($raw_tags{org});
  }

  my $session; # The ks session - probably the one we'll use if it exists.

# ...or session_id
  if (defined $raw_tags{session} or defined $raw_tags{view_session}) {
    my ($session_id) = RHN::SessionSwap->extract_data($raw_tags{session} || $raw_tags{view_session});
    $params{-view_only} = 1 if $raw_tags{view_session};

    $session = RHN::Kickstart::Session->lookup(-id => $session_id);

    if (not $session->kickstart_id
	and $session->kickstart_mode
	and grep { $session->kickstart_mode eq $_ } qw/system_ip ip_range/) {
      $mode ||= $session->kickstart_mode;
    }
    if ($session->kstree_id) {
      my $kstree = RHN::KSTree->lookup(-id => $session->kstree_id);
      $params{-dist} ||= $kstree->label;
    }

    $params{-org_id} = $session->org_id;
    $session->update_state('configuration_accessed');
    $session->commit unless $params{-view_only};

    if ($session->kickstart_id) {
      $mode ||= 'session';
    }
    $params{-session} = $session;
  }

# Use the only org id if in satellite context
  if (not exists $params{-org_id} and PXT::Config->get('satellite')) {
    $params{-org_id} = RHN::Org->satellite_org->id;
  }

  if (not exists $params{-org_id} and $pxt->user) {
    $params{-org_id} = $pxt->user->org_id;
  }

# We cannot proceed without an org id
  return \%params unless exists $params{-org_id};

# extract the label
  if ($raw_tags{label} or $raw_tags{view_label}) {
    $params{-label} = $raw_tags{label} || $raw_tags{view_label};
    $mode ||= 'label';

    $params{-view_only} = 1 if $raw_tags{view_label};
  }

  my $kstree;
# Now verify the dist label
  if ($raw_tags{dist}) {
    $kstree = RHN::KSTree->lookup(-label => $raw_tags{dist});
    $params{-dist} = $raw_tags{dist} if $kstree;
    $params{-external_dist} = 1 if ($kstree and $kstree->org_id);
  }

# For various proxies - 'X-Forwarded-For' can sometimes be 'unknown',
# but is usually the ip of the originating box if the req passed through a proxy.
  my $forwarded_ip = $pxt->header_in('X-Forwarded-For') || '';
  $forwarded_ip =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/;
  $forwarded_ip = $1 || 'unknown';

# Check the IP from the incoming request
  $params{-ip} = $forwarded_ip eq 'unknown' ? $pxt->connection->remote_ip : $forwarded_ip;

# look for an ip-based ks, unless we've already picked a non-ip mode
  if ($params{-ip}  and not grep { $mode eq $_ } qw/session label org_default/) {
    $params{-system_ip_ks} = RHN::Kickstart->lookup_ks_by_system_ip(-org_id => $params{-org_id},
								    -ip => $params{-ip});

    $params{-ip_range_ks} = RHN::Kickstart->lookup_ks_by_ip_in_range(-org_id => $params{-org_id},
								     -ip => $params{-ip});
# system_ip takes precedence over ip_range
    if ($params{-system_ip_ks}) {
      $mode ||= 'system_ip';
    }

    if ($params{-ip_range_ks}) {
      $mode ||= 'ip_range';
    }
  }

# fall back to org default
  $mode ||= 'org_default';

# ok, data gathering done, let's find our ks

  if ($mode eq 'session') {
    if ($session->kickstart_id) {
      $params{-ks} = RHN::Kickstart->lookup(-id => $session->kickstart_id);
    }
  }
  elsif ($mode eq 'label') {
    if ($params{-label}) {
      $params{-ks} = RHN::Kickstart->lookup(-org_id => $params{-org_id},
					    -label => $params{-label});
    }
  }
  elsif ($mode eq 'system_ip') {
    $params{-ks} = $params{-system_ip_ks};
  }
  elsif ($mode eq 'ip_range') {
    $params{-ks} = $params{-ip_range_ks} || RHN::Kickstart->lookup_org_default(-org_id => $params{-org_id});
  }
  elsif ($mode eq 'org_default') {
    $params{-ks} = RHN::Kickstart->lookup_org_default(-org_id => $params{-org_id});
    if (not $params{-ks}) {
      $params{-ks} = RHN::Kickstart::Template->get_template_ks($params{-org_id});
      $params{-ks}->commit;
    }
  }
  else {
    die "Not a valid mode: '$mode'\n";
  }

  $params{-mode} = $mode;
  $params{-path} = $path;

  if ($session and $params{-ks}) {
    $session->kickstart_id($params{-ks}->id);
    $session->commit unless $params{-view_only};
  }
  elsif ($session and not $params{-ks}) { # could not find a ks for this session
    $session->update_state('failed');
    $session->commit;
  }
  elsif ($params{-ks} and not $params{-view_only}) { # create a new session
    $session = new RHN::Kickstart::Session (-org_id => $params{-org_id}, -kickstart_id => $params{-ks}->id,
					    -kickstart_mode => $mode, -kstree_id => $params{-ks}->default_kstree_id,
					    -server_profile_id => $params{-ks}->default_server_profile_id);

    $session->commit;

    foreach my $regtoken ($params{-ks}->get_regtokens) {
      $regtoken->create_new_key;
      $regtoken->activation_key_ks_session_id($session->id);

      $regtoken->commit;
    }

    $params{-session} = $session;
  }

  return \%params;
}

sub prepare_kickstart_profile {
  my %params = validate(@_, { ks => 1, options => 1, ks_host => 1, pxt => 1 });

  my $ks = $params{ks};
  my $options = $params{options};
  my $session = $params{options}->{-session};
  my $pxt = $params{pxt};
  my $ks_host = $params{ks_host};

  my $uid;
  my @tokens;
  my $kstree;

  if ($session) {
    @tokens = $session->activation_keys;
    $uid = $session->scheduler;
    $kstree = $session->kstree;

    $ks->change_dist($options->{-dist} || $kstree->label, $session->id);

    if ($session->system_rhn_host) {
      $ks_host = $session->system_rhn_host;
    }

  }
  else {
    @tokens = $ks->get_regtokens;
    $uid = RHN::Org->random_org_admin($ks->org_id);
    $kstree = $ks->default_tree;

    $ks->change_dist($kstree->label);
  }

  if ($kstree->is_rhn_tree) {
    my $ty_exp = RHN::Date->now();
    $ty_exp->add(hours => 4);

    $ks->tinify_url($ty_exp->long_date);
  }

  $ks->nochroot_post_helper('set_resolv_conf',1);
  $ks->nochroot_post_helper('copy_preserved_files', 1);
  $ks->post_helper('start_log', 1);

  # oddly enough, we do %post helpers in reverse, except for logging.
  $ks->post_helper('add_comment', 1, { comment => '--End RHN command section--' });
  $ks->post_helper('copy_out', 1);

  if (@tokens) {
    $ks->post_helper('rhn_check', 1);
    if ($session and $session->current_server) {
      my $system_name = $session->current_server->name();

      # handle escaping...
      $system_name =~ s{\"}{\\"}g;
      $ks->post_helper('rhnreg_ks_with_profile_name', 1,
		       { key => join(",", map { $_->activation_key_token } @tokens), profile_name => $system_name});
    }
    else {
      $ks->post_helper('rhnreg_ks', 1, { key => join(",", map { $_->activation_key_token } @tokens) });
    }
  }

  if ($ks->default_cfg_management_flag eq 'Y') {
    $ks->post_helper('enable_cfg_management', 1);
  }
  else {
    $ks->post_helper('enable_cfg_management', 0);
  }

  if ($ks->default_remote_command_flag eq 'Y') {
    $ks->post_helper('enable_remote_command', 1);
  }
  else {
    $ks->post_helper('enable_remote_command', 0);
  }

  my @update_package_names = qw/pyOpenSSL rhnlib libxml2-python/;
  my (@update_packages, @freshen_packages);

  if ($ks->installer_generation eq 'rhel_3' or
      $ks->installer_generation eq 'rhel_4') {
    if ($kstree) {
      @update_packages =
	RHN::Package->latest_packages_in_channel_tree(-uid => $uid,
						      -packages => \@update_package_names,
						      -base_cid => $kstree->channel_id);
      @freshen_packages =
	RHN::Package->latest_packages_in_channel_tree(-uid => $uid,
						      -packages => [ qw/up2date up2date-gnome/ ],
						      -base_cid => $kstree->channel_id);
    }

    $ks->post_helper('rhn_register_conf_www', 0);
    $ks->post_helper('up2date_conf_www', 0);

    if ($ks_host ne 'xmlrpc.rhn.redhat.com') {
      $ks->post_helper('up2date_conf_xmlrpc', 1, { kickstart_host => $ks_host });
    }

    $ks->post_helper('import_rhn_gpg_key_rhel2_1', 0);
    $ks->post_helper('import_rhn_gpg_key_rhel3', 1);

    if (@freshen_packages) {
      $ks->post_helper('freshen_rhn_packages', 1);
    }
    if (@update_packages) {
      $ks->post_helper('update_rhn_packages', 1, { package_names => \@update_package_names } );
    }

    if (@freshen_packages) { #has to be this way because the order matters
      $ks->post_helper('get_rhn_packages', 1, { packages => [ @freshen_packages ],
						style => 'download_rhn_packages' } );
    }
    if (@update_packages) {
      $ks->post_helper('get_rhn_packages', 1, { packages => [ @update_packages ],
						style => 'download_optional_rhn_packages' } );
    }

    if (@update_packages or @freshen_packages) {
      $ks->post_helper('make_rhn_packages_dir', 1);
    }

    $ks->post_helper('add_ssl_keys', 1, { key_data => [ $ks->ssl_key_data ] });
    $ks->post_helper('add_gpg_keys', 1, { dist => 'rhel3', key_data => [ $ks->gpg_key_data ] });
  }
  elsif ($ks->installer_generation eq 'rhel_2.1') {
    if ($kstree) {
      @update_packages =
	RHN::Package->latest_packages_in_channel_tree(-uid => $uid,
						      -packages => \@update_package_names,
						      -base_cid => $kstree->channel_id);
      @freshen_packages =
	RHN::Package->latest_packages_in_channel_tree(-uid => $uid,
						      -packages => [ qw/rhn_register up2date rhn_register-gnome up2date-gnome/ ],
						      -base_cid => $kstree->channel_id);
    }

    $ks->post_helper('rhn_register_conf_www', 0);
    $ks->post_helper('up2date_conf_www', 0);

    if ($ks_host ne 'xmlrpc.rhn.redhat.com') {
      $ks->post_helper('rhn_register_conf_xmlrpc', 1, { kickstart_host => $ks_host });
      $ks->post_helper('up2date_conf_xmlrpc', 1, { kickstart_host => $ks_host });
    }

    $ks->post_helper('import_rhn_gpg_key_rhel3', 0);
    $ks->post_helper('import_rhn_gpg_key_rhel2_1', 1);

    if (@freshen_packages) {
      $ks->post_helper('freshen_rhn_packages', 1);
    }
    if (@update_packages) {
      $ks->post_helper('update_rhn_packages', 1, { package_names => \@update_package_names } );
    }

    if (@freshen_packages) { #has to be this way because the order matters
      $ks->post_helper('get_rhn_packages', 1, { packages => [ @freshen_packages ],
                				style => 'download_rhn_packages' } );
    }
    if (@update_packages) {
      $ks->post_helper('get_rhn_packages', 1, { packages => [ @update_packages ],
						style => 'download_optional_rhn_packages' } );
    }

    if (@update_packages or @freshen_packages) {
      $ks->post_helper('make_rhn_packages_dir', 1);
    }

    $ks->post_helper('add_ssl_keys', 1, { key_data => [ $ks->ssl_key_data ] });
    $ks->post_helper('add_gpg_keys', 1, { dist => 'rhel2_1', key_data => [ $ks->gpg_key_data ] });
    $ks->packages->add('@ Network Support', 'openssh-server');
    $ks->package_options([]);
  }

  $ks->post_helper('add_comment', 1, { comment => '--Begin RHN command section--' });
  $ks->post_helper('end_log', 1);

  if ($ks->commands->url and $kstree->base_path =~ /^(http|ftp)/) {
    $ks->commands->url('--url ' . $kstree->base_path);
  }

  return;
}

sub kickstart_details {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks = RHN::Kickstart->lookup(-id => $ksid);

  my %subst;
  if ($ks) {
    $subst{"kickstart_${_}"} = $ks->$_ foreach qw/id org_id name label pre post comments active/;

    my $ss_oid = RHN::SessionSwap->encode_data($pxt->user->org_id);
    my $label = $ks->label;
    $subst{"kickstart_link"} = PXT::HTML->link("/kickstart/ks/org/${ss_oid}/view_label/${label}", '(view kickstart)', '', '_new');
  }
  else {
    $subst{"kickstart_${_}"} = '' foreach qw/id org_id pre post comments/;
    $subst{kickstart_name} = 'New Kickstart';
    $subst{kickstart_label} = 'new_kickstart';
    $subst{kickstart_active} = 'N';
  }

  my $block = $attr{__block__};
  return PXT::Utils->perform_substitutions($block, \%subst); 
}

sub kickstart_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kickstart_edit_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style('standard');
  my $html = $rform->render($style);

  return $html;
}

sub kickstart_create_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kickstart_create_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style('standard');
  my $html = $rform->render($style);

  return $html;
}

sub kickstart_create_options_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kickstart_create_options_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style('standard');
  my $html = $rform->render($style);

  return $html;
}

sub kickstart_command_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kickstart_command_edit_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style('kickstart');
  my $html = $rform->render($style);

  return $html;
}

sub kickstart_script_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $script = $attr{script};

  my $form;

# pre and post are different to allow for potential 'helper' actions - like adding an rhnreg_ks line
  if ($script eq 'pre') {
    $form = build_kickstart_pre_edit_form($pxt, %attr);
  }
  elsif ($script eq 'post') {
    $form = build_kickstart_post_edit_form($pxt, %attr);
  }
  elsif ($script eq 'nochroot_post') {
    $form = build_kickstart_nochroot_post_edit_form($pxt, %attr);
  }
  elsif ($script eq 'interpreter_post') {
    $form = build_kickstart_interpreter_post_edit_form($pxt, %attr);
  }
  elsif ($script eq 'interpreter_pre') {
    $form = build_kickstart_interpreter_pre_edit_form($pxt, %attr);
  }
  else {
    die "Invalid script: '$script'";
  }

  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style();
  my $html = $rform->render($style);

  return $html;
}

sub kickstart_package_select_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kickstart_package_select_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style();
  my $html = $rform->render($style);

  return $html;
}

sub build_kickstart_package_select_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  $ks = RHN::Kickstart->lookup(-id => $ksid);

  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Packages',
				       label => 'kickstart_packages',
				       action => $attr{action},
				      );

  $form->add_widget( new RHN::Form::Widget::Text(name => 'Packages',
						 label => 'packages',
						 default => '',
						 ) );

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ks->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-add-packages-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Add Packages') );

  return $form;
}

sub build_kickstart_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  if ($ksid) {
    $ks = RHN::Kickstart->lookup(-id => $ksid);

    if (PXT::Config->get('satellite')) {
      my $ds = new RHN::DataSource::Simple(-querybase => "General_queries", -mode => 'crypto_keys_for_org');
      my $data = $ds->execute_full(-org_id => $pxt->user->org_id);

      $data = [ grep { $_->{LABEL} eq 'SSL' } @{$data} ];

      if (scalar @{$data} == 0) {
	$pxt->push_message(local_alert => <<EOQ);
You have no <a href="/network/keys/key_list.pxt">SSL keys</a> defined.
You should import the proper SSL key for your satellite and associate
it with your kickstart profiles, under 'Post'.
EOQ
      }
    }
  }
  else {
    $ks = new RHN::Kickstart(-name => 'New Kickstart Profile', -label => 'ks_profile', -org_id => $pxt->user->org_id);
  }

  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Profile',
				       label => 'kickstart_profile',
				       action => $attr{action},
				      );

  $form->add_widget( new RHN::Form::Widget::Literal(name => 'ID', label => 'id', default => $ks->id ? $ks->id : '(None)') );
  $form->add_widget( new RHN::Form::Widget::Literal(name => 'Org ID', label => 'org_id', default => $ks->org_id) );
  $form->add_widget( new RHN::Form::Widget::Text(name => 'Name',
						 label => 'name',
						 default => $ks->name,
						 requires => { response => 1 }) );
  $form->add_widget( new RHN::Form::Widget::Text(name => 'Label',
						 label => 'label',
						 default => $ks->id ? $ks->label : '',
						 requires => { response => 1 }) );

  my $trees = RHN::KSTree->kstrees_for_user($pxt->user->id);
  my $default_kstree = RHN::KSTree->lookup(-id => $ks->default_kstree_id);

  $trees = [ grep { $default_kstree->compatible_tree($_->{ID}) } @{$trees} ];

  if (not PXT::Config->get('satellite')) {
    $trees = [ grep { $_->{ORG_ID} } @{$trees} ];
  }

  if (@{$trees}) {
    $form->add_widget(select => { name => 'Distribution', label => 'default_kstree_id', size => 1,
				  default => $ks->default_kstree_id, options =>
				  [ map { { label => $_->{CHANNEL_NAME} . ' (' . $_->{LABEL} . ')',
					      value => $_->{ID} } } @{$trees}
				  ] } );
  }
  else {
    $pxt->push_message(site_info => 'You must create a distribution tree before creating a kickstart profile.');
    $pxt->redirect('/network/systems/provisioning/trees/trees.pxt');
  }

  my $ss_oid = RHN::SessionSwap->encode_data($pxt->user->org_id);
  my %url_params;

  if (not PXT::Config->get('satellite')) {
    $url_params{-org_id} = $pxt->user->org_id;
  }

  my $ks_url_scheme = PXT::Config->get('ssl_available') ? 'https' : 'http';
  my $view_link = PXT::HTML->link($ks->get_url(-mode => 'view_label', -scheme => $ks_url_scheme,
					       %url_params),
				  'view kickstart', '', '_new');
  $form->add_widget( literal => { name => 'View', value => $view_link } );
  $form->add_widget( literal => { name => 'URL', value => $ks->get_url(-mode => 'label', %url_params) } );

  $form->add_widget( new RHN::Form::Widget::Checkbox(name => 'Active', label => 'active', default => 1, checked => $ks->active eq 'Y' ? 1 : 0) );

    $form->add_widget( new RHN::Form::Widget::Select(name => 'Org Default', label => 'is_org_default', size => 1,
                                                     value => $ks->is_org_default, options =>
                                                       [ { label => 'Yes', value => 'Y' },
                                                         { label => 'No', value => 'N' } ]) );

  $form->add_widget( new RHN::Form::Widget::TextArea(name => 'Comments', label => 'comments', rows => 6, cols => 80, default => $ks->comments) );
  my @lists = file_preservation_lists($pxt->user->org_id);

  if (@lists) {
    $form->add_widget(new RHN::Form::Widget::Select(
                        name =>'File Preservation Lists',
                        multiple => 1,
                        size => 6,
                        label => 'file_list', 
                        default => $ks->file_list(),
                        options => [
                          map { { value => $_->{ID}, label => $_->{LABEL} }  } @lists 
                        ]
                      ));
  }
  else {
    $form->add_widget(literal => { name => 'File Preservation Lists',
				   value => '<strong>(none available)</strong>',
				 } );
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ks->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-details-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => $ks->id ? 'Update Kickstart' : 'Create Kickstart') );
  return $form;
}

sub build_kickstart_create_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid'); # if ksid exists, we are cloning
  my $ks;

  my $form = new RHN::Form::ParsedForm(name => 'Create Kickstart Profile',
				       label => 'create_kickstart_profile',
				       action => $attr{action},
				      );

  if ($ksid) {
    $ks = RHN::Kickstart->lookup(-id => $ksid);
    $form->add_widget( literal => {name => 'Clone of',
				   value => $ks->name,
				  } );
  }

  $form->add_widget( text => {name => 'Name',
			      label => 'name',
			      requires => { response => 1 },
			     } );
  $form->add_widget( text => {name => 'Label',
			      label => 'label',
			      requires => { response => 1 },
			     } );

  my $trees = RHN::KSTree->kstrees_for_user($pxt->user->id);

  if ($ks) {
    my $default_kstree = RHN::KSTree->lookup(-id => $ks->default_kstree_id);
    $trees = [ grep { $default_kstree->compatible_tree($_->{ID}) } @{$trees} ];
  }

  if (not PXT::Config->get('satellite')) {
    $trees = [ grep { $_->{ORG_ID} } @{$trees} ];
  }

  if (@{$trees}) {
    $form->add_widget(select => { name => 'Distribution', label => 'default_kstree_id', size => 1,
				  default => $ks ? $ks->default_kstree_id : -1,
				  options =>
				  [ map { { label => $_->{CHANNEL_NAME} . ' (' . $_->{LABEL} . ')',
					      value => $_->{ID} } } @{$trees} ] } );
  }
  else {
    $pxt->push_message(site_info => 'You must create a distribution tree before creating a kickstart profile.');
    $pxt->redirect('/network/systems/provisioning/trees/trees.pxt');
  }


  $form->add_widget( checkbox => {name => 'Active',
				  label => 'active',
				  default => 1,
				  checked => 1,
				 } );

  if ($ksid) {
    $form->add_widget(hidden => {name => 'ksid', value => $ksid} );
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-create-cb') );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'redir', value => $ksid ? 'clone.pxt' : 'create.pxt') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => $ksid ? 'Clone Kickstart' : 'Select Kickstart Options') );

  return $form;
}

sub build_kickstart_create_options_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  if ($ksid) {
    $ks = RHN::Kickstart->lookup(-id => $ksid);
  }
  else {
    my $default_kstree_id = $pxt->dirty_param('default_kstree_id');
    my ($install_type, $dist);

    if ($default_kstree_id) {
      die "illegal kickstart tree id" unless $pxt->user->verify_kickstartabletree_access($default_kstree_id);

      my $kstree = RHN::KSTree->lookup(-id => $default_kstree_id);
      $install_type = $kstree->install_type_label();
      $dist = $kstree->label();
    }

    $ks = RHN::Kickstart::Template->get_template_ks($pxt->user->org_id, $install_type);

    if ($dist) {
      $ks->change_dist($dist);
    }

    # would rather have this in the template but need extra query and 11th hour request

    foreach my $meth (qw/name label active/) {
      $ks->$meth($pxt->dirty_param($meth));
    }

    $ks->default_kstree_id($default_kstree_id);

    if ($ks->get_channel_arch eq 'channel-ia64') {
      my $iaparts;

      if ($install_type eq 'rhel_4') {
	$iaparts = new RHN::Kickstart::Partitions ( [ qw(/boot/efi --fstype=vfat --size=100) ], 
						    [ qw(swap --size=1000 --grow --maxsize=2000) ], 
						    [ qw(pv.01 --fstype=ext3 --size=700 --grow) ] );
      }
      else {
	$iaparts = new RHN::Kickstart::Partitions ( [ qw(/boot/efi --fstype=vfat --size=100) ], 
						    [ qw(swap --size=1000 --grow --maxsize=2000) ], 
						    [ qw(/ --fstype=ext3 --size=700 --grow) ] );
      }

      $ks->commands->partitions( $iaparts );
    }
  }

  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Profile',
				       label => 'kickstart_profile',
				       action => $attr{action},
				      );

  $form->add_widget(literal => { name => 'Name',
				 value => $ks->name,
				} );

  $form->add_widget(literal => { name => 'Distribution',
				 value => $ks->default_tree ? $ks->default_tree->name : '(none)',
			       } );

  if ($ks->get_channel_arch ne 'channel-ia64') {
    $form->add_widget(select => { name => 'Bootloader',
				  label => 'bootloader',
				  size => 1,
				  default => 'grub',
				  value => $ks->get_bootloader,
				  options => [ { label => 'LILO', value => 'lilo' },
					       { label => 'GRUB', value => 'grub' },
					     ],
				  requires => { response => 1 },
				} );
  }
  else {
    $form->add_widget(select => { name => 'Bootloader',
				  label => 'bootloader',
				  size => 1,
				  default => 'elilo',
				  value => 'elilo',
				  options => [ { label => 'ELILO', value => 'elilo' } ],
				  requires => { response => 1 },
				} );
  }

  my @bl_extras = grep { not /Lilo/ } @{$ks->commands->bootloader()};
  my %bl_extras;

  my $cur;
  foreach my $extra (@bl_extras) {
    if ($extra =~ /^--/) {
      if ($cur) {
	$bl_extras{$cur} = '';
	$cur = '';
      }

      my ($key, $value) = split(/=/, $extra);
      if (defined $value) {
	$bl_extras{$key} = $value;
      }
      else {
	$cur = $key;
      }
    }
    elsif ($cur) {
      $bl_extras{$cur} = $extra;
      $cur = '';
    }
  }

  if ($cur) {
    $bl_extras{$cur} = '';
  }

  foreach my $key (keys %bl_extras) {
    if ($key) {
      $form->add_widget(hidden => { name => 'bootloader' . $key,
				    value => $bl_extras{$key},
				  } );
    }
  }

  my @tz_widgets;
  push @tz_widgets,
    new RHN::Form::Widget::Select(name => 'Timezone',
				  label => 'timezone',
				  size => 1,
				  default => $ks->get_timezone,
				  options => [ map { { label => $_, value => $_ } } sort {$a cmp $b } RHN::Kickstart::timezones() ],
				  requires => { response => 1 },
				 );

  push @tz_widgets,
    new RHN::Form::Widget::Literal(label => 'utc_message',
				   value => '&#160;Hardware Clock uses UTC');

  push @tz_widgets,
    new RHN::Form::Widget::Checkbox(name => 'UTC',
				    label => 'timezone_utc',
				    value => 1,
				    checked => $ks->is_timezone_utc ? 1 : 0);

  $form->add_widget(multiple => { name => "Timezone",
				  label => "timezone_data",
				  widgets => \@tz_widgets,
				} );

  my ($static_value, $dhcp_value, $radio_default) = ('', '', '');
  if (not $ks->static_device) {
    $dhcp_value = 'eth0';
    $radio_default = 'dhcp';
  }
  elsif ($ks->static_device =~ /^dhcp:(\S+)$/) {
    $dhcp_value = $1;
    $radio_default = 'dhcp';
  }
  elsif ($ks->static_device =~ /^static:(\S+)$/) {
    $static_value = $1;
    $radio_default = 'static';
  }
  else {
    $static_value = $ks->static_device;
    $radio_default = 'static';
  }

  my $static_ip_iface_widget = new RHN::Form::Widget::Text(name => "static_ip_iface",
							   label => "static_ip_iface",
							   value => $static_value,
							   size => 6);
  my $dhcp_ip_iface_widget = new RHN::Form::Widget::Text(name => "dhcp_ip_iface",
							 label => "dhcp_ip_iface",
							 value => $dhcp_value,
							 size => 6);

  $form->add_widget(radio_group =>
		    { name => "Kickstart Network Configuration",
		      label => "ks_ip_type",
		      default => $radio_default,
		      options => [ { value => "dhcp", label => "Use DHCP from interface: " . $dhcp_ip_iface_widget->render },
				   { value => "static", label => "Use static IP from interface: " . $static_ip_iface_widget->render }]});

  $form->add_widget(text => {name => "Extra Kernel Parameters",
			     label => 'kernel_params',
			     size => 32,
			     maxlength => 64,
			     default => $ks->kernel_params});

  my $password_required;

  if ($ksid) {
    $form->add_widget(literal => { name => 'Encrypted Root Password',
				   value => $ks->commands->rootpw->export } );
  }
  else {
    $password_required = { response => 1 };
  }


  $form->add_widget(password => { name => ($ksid ? 'New ' : '') . 'Root Password',
				  label => 'root_password_1',
				  default => $pxt->dirty_param('root_password_1') || '',
				  size => 48,
				  maxlength => 256,
				  requires => $password_required,
				} );

  $form->add_widget(password => { name => 'Verify Root Password',
				  label => 'root_password_2',
				  default => $pxt->dirty_param('root_password_2') || '',
				  size => 48,
				  maxlength => 256,
				  requires => $password_required,
				} );

  my $kstree = $ks->default_tree;
  if ($kstree and $kstree->is_selinux_capable()) {
    my $default_selinux;

    if ($ks->commands) {
      $default_selinux = $ks->commands->render_command('selinux');
    }
    $default_selinux ||= '--permissive';

    $form->add_widget(radio_group => { name => 'SELinux',
				       label => 'selinux',
				       default => $default_selinux,
				       options => [ { value => '--enforcing',
						      label => 'Enforcing - SELinux security policy is enforced.' },
						    { value => '--permissive',
						      label => 'Permissive - SELinux prints warnings instead of enforcing.' },
						    { value => '--disabled',
						      label => 'Disabled - SELinux is fully disabled.' },
						  ],
				       } );
  }

  $form->add_widget(radio_group => { name => 'Zero MBR',
				     label => 'zerombr',
				     default => ($ks->commands and $ks->commands->zerombr) ? 'yes' : 'no',
				     options => [ { value => 'yes', label => 'Yes' },
						  { value => 'no', label => 'No' } ] } );

  my $clearpart = $ks->commands ? $ks->commands->render_command('clearpart') : '';
  $form->add_widget(text => { name => 'Clear Partitions',
			      label => 'clearpart',
			      default => (defined $clearpart) ? $clearpart : '',
			      size => 48,
			      maxlength => 1024 } );

  my $parts = $ks->commands ? $ks->commands->partitions : '';
  my $raids = $ks->commands ? $ks->commands->raids : '';
  my $volgroups = $ks->commands ? $ks->commands->volgroups : '';
  my $logvols = $ks->commands ? $ks->commands->logvols : '';
  my $include = $ks->commands ? $ks->commands->include : '';

  my $part_texts = join("\n\n", grep { $_ } map { $_ ? $_->render : '' } 
		($parts, $raids, $volgroups, $logvols, $include));
  $form->add_widget(textarea => { name => 'Partition Details',
				  label => 'partitions',
				  default => $part_texts || '',
				  rows => 6,
				  cols => 80,
				} );

  $form->add_widget( hidden => {name => 'ksid', value => $ks->id} );
  $form->add_widget( hidden => {name => 'name', value => $ks->name} );
  $form->add_widget( hidden => {name => 'label', value => $ks->label} );
  $form->add_widget( hidden => {name => 'active', value => $ks->active} );
  $form->add_widget( hidden => {name => 'default_kstree_id', value => $ks->default_kstree_id} );
  $form->add_widget( hidden => {name => 'success_redir', value => ($ksid ? 'select_options.pxt' : 'details.pxt') } );
  $form->add_widget( hidden => {name => 'pxt:trap', value => 'rhn:kickstart-create-options-cb'} );
  $form->add_widget( submit => {name => $ksid ? 'Update Kickstart' : 'Create Kickstart'} );

  return $form;
}

sub ip_kickstart_url {
  my $pxt = shift;

  my %url_params;

  if (not PXT::Config->get('satellite')) {
    $url_params{-org_id} = $pxt->user->org_id;
  }

  return RHN::Kickstart->get_ip_url(%url_params);
}

sub kickstart_details_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  my $ks;

  my $default_kstree_id = $pxt->dirty_param('default_kstree_id');
  my ($install_type, $dist);

  if ($default_kstree_id) {
    die "illegal kickstart tree id" unless $pxt->user->verify_kickstartabletree_access($default_kstree_id);

    my $kstree = RHN::KSTree->lookup(-id => $default_kstree_id);
    $install_type = $kstree->install_type_label();
    $dist = $kstree->label();
  }

  if ($ksid) {
    $ks = RHN::Kickstart->lookup(-id => $ksid);
  }
  else {
    $ks = RHN::Kickstart::Template->get_template_ks($pxt->user->org_id, $install_type);

    if ($dist) {
      $ks->change_dist($dist);
    }
  }

  $ks->$_($pxt->dirty_param($_)) foreach qw/name label comments pre post is_org_default/;
  if ($pxt->dirty_param('active')) {
    $ks->active('Y');
  }
  else {
    $ks->active('N');
  }

  my @lists = $pxt->dirty_param('file_list');
  $ks->file_list(\@lists);

  unless ($ks->name and $ks->label) {
    $pxt->push_message( local_alert => 'A kickstart profile must have both a name and label.' );
    return;
  }

  unless ($ks->label =~ /^[a-zA-Z\d\_\-\.]*$/ and length($ks->label) >= 6) {
    $pxt->push_message(local_alert => "Invalid profile label '" . $ks->label . "' - must be at least 6 characters long, and contain only letters, digits, '_', and '-'");
    return;
  }

  $ks->default_kstree_id($default_kstree_id);

  if ($ks->get_channel_arch eq 'channel-ia64') {
    $ks->set_bootloader(-bootloader => 'elilo');
  }

  eval {
    $ks->commit;
  };
  if ($@) {
    my $E = $@;
    my $str = ref $E;

    if ((ref $E and $E->isa('RHN::Exception')) and $E->is_rhn_exception('RHN.RHN_KS_OID_LABEL_UQ')) {
      $pxt->push_message( local_alert => 'A kickstart profile with that label already exists.' );
      return;
    }
    elsif ((ref $E and $E->isa('RHN::Exception')) and $E->is_rhn_exception('RHN.RHN_KS_OID_NAME_UQ')) {
      $pxt->push_message( local_alert => 'A kickstart profile with that name already exists.' );
      return;
    }
    else {
      die $E;
    }
  }

  my $redir = $pxt->dirty_param('redir');
  if ($redir) {
    $pxt->redirect($redir . '?ksid=' . $ks->id);
  }

  $pxt->push_message( site_info => sprintf('Kickstart profile <strong>%s</strong> %s.', $ks->name, $ksid ? 'updated' : 'created') );
  my $url = $pxt->uri . '?ksid=' . $ks->id;

  $pxt->redirect($url);
}

sub kickstart_create_cb {
  my $pxt = shift;

  my $name = $pxt->dirty_param('name');
  my $label = $pxt->dirty_param('label');
  my $default_kstree_id = $pxt->dirty_param('default_kstree_id');
  my $active = $pxt->dirty_param('active');
  my $ksid = $pxt->param('ksid');

  my $url_args = join('&', map { $_ . '=' . PXT::Utils->escapeURI($pxt->dirty_param($_)) } qw/name label active default_kstree_id/);

  if ($ksid) {
    $url_args .= "&ksid=${ksid}";
  }

  my $url = $pxt->dirty_param('redir') . "?${url_args}";

  unless ($name and $label) {
    $pxt->push_message(local_alert => 'A kickstart profile must have both a name and label.');
    $pxt->redirect($url);
  }

  unless ($default_kstree_id) {
    $pxt->push_message(local_alert => 'You must select a distribution.');
    $pxt->redirect($url);
  }

  unless ($label =~ /^[a-zA-Z\d\_\-\.]*$/ and length($label) >= 6) {
    $pxt->push_message(local_alert => "Invalid profile label '" . PXT::Utils->escapeHTML($label) . "' - must be at least 6 characters long, and contain only letters, digits, '.', '-', and '-'");
    $pxt->redirect($url);
  }

  my $current_ks = RHN::Kickstart->lookup(-org_id => $pxt->user->org_id, -label => $label);

  if ($current_ks) {
    $pxt->push_message(local_alert => 'A kickstart profile with that label already exists.');
    $pxt->redirect($url);
  }

  $current_ks = RHN::Kickstart->lookup(-org_id => $pxt->user->org_id, -name => $name);

  if ($current_ks) {
    $pxt->push_message(local_alert => 'A kickstart profile with that name already exists.');
    $pxt->redirect($url);
  }

  if ($ksid) { # we are creating a clone...
    my $ks = RHN::Kickstart->lookup(-id => $ksid);

    my $old_name = $ks->name;
    my @saved_crypto_keys = map { $_->{ID} } $ks->crypto_keys;

    my $new_ks = $ks->clone;

    $new_ks->$_($pxt->dirty_param($_)) foreach qw/name label active/;
    $new_ks->ip_ranges([]);
    $new_ks->file_list([]);
    $new_ks->is_org_default('N');
    $new_ks->default_kstree_id($pxt->dirty_param('default_kstree_id'));
    $new_ks->commit;

    $new_ks = RHN::Kickstart->lookup(-org_id => $new_ks->org_id, -label => $new_ks->label);
    $new_ks->crypto_keys(@saved_crypto_keys);

    $pxt->push_message( site_info => sprintf('Kickstart profile <strong>%s</strong> cloned from <strong>%s</strong>.',
					     $new_ks->name, $old_name) );
    $pxt->redirect('/rhn/kickstart/KickstartDetailsEdit.do?ksid=' . $new_ks->id);
  }

  return;
}

sub kickstart_create_options_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  my $ks;

  if ($ksid) {
    $ks = RHN::Kickstart->lookup(-id => $ksid);
  }
  else {
    my $kstid = $pxt->dirty_param('default_kstree_id');
    my ($install_type, $dist);

    if ($kstid) {
      my $kstree = RHN::KSTree->lookup(-id => $kstid);
      $install_type = $kstree->install_type_label();
      $dist = $kstree->label();
    }

    $ks = RHN::Kickstart::Template->get_template_ks($pxt->user->org_id, $install_type);

    if ($dist) {
      $ks->change_dist($dist);
    }
  }

  $ks->$_($pxt->dirty_param($_)) foreach qw/name label/;

  if ($pxt->dirty_param('active')) {
    $ks->active('Y');
  }
  else {
    $ks->active('N');
  }

  my $ip_choice = $pxt->dirty_param('ks_ip_type') || 'dhcp';
  if ($ip_choice eq 'static') {
    $ks->static_device("static:" . ($pxt->dirty_param('static_ip_iface') || 'auto'));
  }
  else {
    $ks->static_device("dhcp:" . ($pxt->dirty_param('dhcp_ip_iface') || 'eth0'));
  }

  unless ($ks->name and $ks->label) {
    $pxt->push_message( local_alert => 'A kickstart profile must have both a name and label.' );
    return;
  }

  unless ($ks->label =~ /^[a-zA-Z\d\_\-\.]*$/ and length($ks->label) >= 6) {
    $pxt->push_message(local_alert => "Invalid profile label '" . $ks->label . "' - must be at least 6 characters long, and contain only letters, digits, '-', and '-'");
    return;
  }

  my $rootpw_1 = $pxt->dirty_param('root_password_1') || '';
  my $rootpw_2 = $pxt->dirty_param('root_password_2') || '';

  if ($ksid and not $rootpw_1) {
    $rootpw_1 = $rootpw_2 = $ks->commands->rootpw->export;
  }

  unless ($rootpw_1 and $rootpw_2) {
    $pxt->push_message(local_alert => "This kickstart profile must have a root password.");
    return;
  }

  unless ($rootpw_1 eq $rootpw_2) {
    $pxt->push_message(local_alert => "Root passwords did not match.");
    return;
  }

  $ks->commands->rootpw($rootpw_1);

  my %bl_options;
  $bl_options{-bootloader} = $pxt->dirty_param('bootloader');
  foreach my $key (qw/append driveorder location password md5pass upgrade/) {
    my $value = $pxt->dirty_param("bootloader--$key");
    if (defined $value) {
      $bl_options{"-" . $key} = $value;
    }
  }

  $ks->set_bootloader(%bl_options);

  my $hw_utc = $pxt->dirty_param('timezone_utc');

  $ks->set_timezone(-zone => $pxt->dirty_param('timezone'), -hardware_utc => $hw_utc);

  eval {
    $ks->set_partition_info(-parts => $pxt->dirty_param('partitions'));
  };
  if ($@) {
    my $E = $@;

    if ((ref $E and $E->isa('RHN::Exception')) and $E->is_rhn_exception('ks_multi_add_label_already_exists')) {
      $E =~ /'(.*)'/;
      my $label = $1;

      if ($label) {
	$pxt->push_message( local_alert => "Only one $label partition allowed" );
	return;
      }
      else {
	throw $E;
      }
    }

    throw $E;
  }

  $ks->set_zerombr($pxt->dirty_param('zerombr'));

  if (length($pxt->dirty_param('kernel_params')) > 64) {
    $pxt->push_message('Kernel parameters cannot be longer than 64 characters.');
    return;
  }

  my $server_profile_id = $pxt->dirty_param('default_server_profile_id');
  if ($server_profile_id) {

    unless ($pxt->user->verify_system_profile_access($server_profile_id)) {
      die sprintf("User '%d' attempted to assign server profile '%d' to kickstart "
		  . "profile '%d' without permission.", $pxt->user->id, $server_profile_id, $ks->id);
    }
  }

  $ks->$_($pxt->dirty_param($_)) foreach qw/default_kstree_id default_server_profile_id kernel_params/;

  my $clearpartvalue = $pxt->dirty_param('clearpart') || undef;
  $ks->commands->clearpart($clearpartvalue);

  my $selinux = $pxt->dirty_param('selinux') || undef;
  $ks->commands->selinux($selinux);

  eval {
    $ks->commit;
  };
  if ($@) {
    my $E = $@;

    if ((ref $E and $E->isa('RHN::Exception')) and $E->is_rhn_exception('RHN.RHN_KS_OID_LABEL_UQ')) {
      $pxt->push_message( local_alert => 'A kickstart profile with that label already exists.' );
      return;
    }
    if ((ref $E and $E->isa('RHN::Exception')) and $E->is_rhn_exception('RHN.RHN_KS_OID_NAME_UQ')) {
      $pxt->push_message( local_alert => 'A kickstart profile with that name already exists.' );
      return;
    }
    else {
      die $E;
    }
  }

  $pxt->push_message( site_info => sprintf('Kickstart profile <strong>%s</strong> %s.', $ks->name, $ksid ? 'updated' : 'created') );

  if (not $ksid and PXT::Config->get('satellite')) {
    my $ds = new RHN::DataSource::Simple(-querybase => "General_queries", -mode => 'crypto_keys_for_org');
    my $data = $ds->execute_full(-org_id => $pxt->user->org_id);

    $data = [ grep { $_->{LABEL} eq 'SSL' } @{$data} ];

    if (scalar @{$data} > 0) {
      $ks->crypto_keys(map { $_->{ID} } @{$data});
      $ks->commit;

      foreach my $row (@{$data}) {
	my $ckid = $data->[0]->{ID};
	my $ckname = $data->[0]->{DESCRIPTION};

	$pxt->push_message(site_info => <<EOQ);
Automatically added the SSL key <strong><a href="/network/keys/edit.pxt?ckid=$ckid">$ckname</a></strong>.
EOQ
      }
    }
  }

  my $url = $pxt->dirty_param('success_redir') || $pxt->uri;
  $url .= '?ksid=' . $ks->id;

  $pxt->redirect($url);
}

sub kickstart_post_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  die "No ksid" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);

  $ks->post($pxt->dirty_param('post') || '');

  my $server_profile_id = $pxt->dirty_param('default_server_profile_id');
  if ($server_profile_id) {

    unless ($pxt->user->verify_system_profile_access($server_profile_id)) {
      die sprintf("User '%d' attempted to assign server profile '%d' to kickstart "
		  . "profile '%d' without permission.", $pxt->user->id, $server_profile_id, $ks->id);
    }
  }

  $ks->default_server_profile_id($server_profile_id);
  $ks->default_cfg_management_flag($pxt->dirty_param('default_cfg_management_flag') ? 'Y' : 'N');
  $ks->default_remote_command_flag($pxt->dirty_param('default_remote_command_flag') ? 'Y' : 'N');
  $ks->commit;

  my @regtoken_ids = $pxt->param('tid');
  $ks->set_regtokens(@regtoken_ids);

  $pxt->push_message( site_info => sprintf('Kickstart profile <strong>%s</strong> updated.', $ks->name) );
  my $url = $pxt->uri . '?ksid=' . $ks->id;

  $pxt->redirect($url);
}

sub kickstart_nochroot_post_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  die "No ksid" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);
  $ks->nochroot_post($pxt->dirty_param('nochroot_post') || '');
  $ks->commit;

  $pxt->push_message( site_info => sprintf('Kickstart profile <strong>%s</strong> updated.', $ks->name) );
  my $url = $pxt->uri . '?ksid=' . $ks->id;

  $pxt->redirect($url);
}

sub kickstart_interpreter_post_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  die "No ksid" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);

  my $post_script = $pxt->dirty_param('interpreter_post_script') || '';
  my $post_val = $pxt->dirty_param('interpreter_post_val') || '';

  #remove leading spaces
  $post_script =~ s/^ *//;
  $post_val =~ s/^ *//;

  $ks->interpreter_post_script($post_script);
  $ks->interpreter_post_val($post_val);

  # if user supplied post interpreter info, make sure both the script/inter are provisioned
  if ($ks->interpreter_post_script || $ks->interpreter_post_val) {
    unless ($ks->interpreter_post_script && $ks->interpreter_post_val) {
      $pxt->push_message( local_alert => 
		'You must supply both the interpreter and post script when choosing this optional configuration' );
	  return;
    }
  }

  $ks->commit_int_script('post');

  $pxt->push_message( site_info => sprintf('Kickstart profile <strong>%s</strong> updated.', $ks->name) );
  my $url = $pxt->uri . '?ksid=' . $ks->id;

  $pxt->redirect($url);
}

sub kickstart_interpreter_pre_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  die "No ksid" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);

  my $pre_script = $pxt->dirty_param('interpreter_pre_script') || '';
  my $pre_val = $pxt->dirty_param('interpreter_pre_val') || '';

  #remove leading spaces
  $pre_script =~ s/^ *//;
  $pre_val =~ s/^ *//;

  $ks->interpreter_pre_script($pre_script);
  $ks->interpreter_pre_val($pre_val);

  # if user supplied pre interpreter info, make sure both the script/inter are provisioned
  if ($ks->interpreter_pre_script || $ks->interpreter_pre_val) {
    unless ($ks->interpreter_pre_script && $ks->interpreter_pre_val) {
      $pxt->push_message( local_alert => 
		'You must supply both the interpreter and pre script when choosing this optional configuration' );
      return;
    }
  }

  $ks->commit_int_script('pre');

  $pxt->push_message( site_info => sprintf('Kickstart profile <strong>%s</strong> updated.', $ks->name) );
  my $url = $pxt->uri . '?ksid=' . $ks->id;

  $pxt->redirect($url);
}

sub kickstart_pre_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  die "No ksid" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);

  my $pre_script = $pxt->dirty_param('pre') || '';

  $ks->pre($pre_script);
  $ks->commit;

  $pxt->push_message( site_info => sprintf('Kickstart profile <strong>%s</strong> updated.', $ks->name) );
  my $url = $pxt->uri . '?ksid=' . $ks->id;

  $pxt->redirect($url);
}

sub build_kickstart_command_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  die "No kickstart id" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);
  my $kstree = $ks->default_tree;

  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Profile',
				       label => 'kickstart_profile',
				       action => $attr{action},
				      );

  my $valid_commands = RHN::Kickstart::Commands->valid_commands;

  my $spacer_index = 0;

  foreach my $command (RHN::Kickstart::Commands->output_order) {
    next if ($command eq '_linebr_');
    next if ($command eq 'selinux' and $kstree and not $kstree->is_selinux_capable());

    $spacer_index++;

    my $value = $ks->commands ? $ks->commands->render_command($command) : '';

    $form->add_widget( new RHN::Form::Widget::Checkbox(name => $command,
						       value => $command,
						       label => $command,
						       checked => defined $value ? 1 : 0,
						       requires => $valid_commands->{$command}->{optional} ? undef : { response => 1 }) );

    if ($command eq 'rootpw') {
      $form->add_widget( new RHN::Form::Widget::Text(name => '', label => $command . '_options', default => $ks->commands ? $ks->commands->rootpw->export : '', size => 64, maxlength => 256) );
    }
    elsif (grep { $command eq $_ } qw/partitions raids volgroups logvols include/) {
# multiple entries allowed
      my $line_index = 0;
      $form->add_widget( new RHN::Form::Widget::Spacer(name => '', label => 'spacer_' . $spacer_index++) );
      my $prefix = $ks->commands->$command->prefix;
      $prefix =~ s/\%include/include/;

      if ($ks->commands) {

	foreach my $line ($ks->commands->$command->export()) {
	  $form->add_widget( new RHN::Form::Widget::Spacer(name => $command, label => 'spacer_' . $spacer_index) );
	  $form->add_widget( new RHN::Form::Widget::Text(name => '', label => "${prefix}_" . $line_index, default => $line, size => 64, maxlength => 1024) );
	  $spacer_index++;
	  $line_index++;
	}
      }
      $form->add_widget( new RHN::Form::Widget::Spacer(name => "new ${prefix}", label => 'spacer_' . $spacer_index) );
      $form->add_widget( new RHN::Form::Widget::Text(name => '', label => "${prefix}_${line_index}", default => '', size => 64, maxlength => 1024) );
      $form->add_widget( new RHN::Form::Widget::Hidden(name => "last_${prefix}", value => $line_index) );
    }
    elsif ( $valid_commands->{$command}->{args} ) {
      $form->add_widget( new RHN::Form::Widget::Text(name => '', label => $command . '_options', default => $value, size => 64, maxlength => 1024) );
    }
    else {
      $form->add_widget( new RHN::Form::Widget::Spacer(name => '', label => 'spacer_' . $spacer_index) );
    }
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ksid) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-commands-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Update Kickstart') );

  return $form;
}

sub kickstart_commands_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');

  die "No kickstart id" unless $ksid;
  my $ks = RHN::Kickstart->lookup(-id => $ksid);

  my $form = build_kickstart_command_edit_form($pxt);
  my $response = $form->prepare_response;

  my $errors = Sniglets::Forms::load_params($pxt, $response);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $valid_commands = RHN::Kickstart::Commands->valid_commands;
  my %commands;

  foreach my $command (keys %{$valid_commands}) {
    my $checked = $pxt->dirty_param($command);
    my $options = $pxt->dirty_param($command . '_options');

    next unless $checked;

    if ($options) {
      my @options = split(/\s+/, $options);
      $commands{$command} = \@options;
    }
    else {
      $commands{$command} = '';
    }
  }

  my %classmap = (partition => 'RHN::Kickstart::Partitions',
		  raid => 'RHN::Kickstart::Raids',
		  logvol => 'RHN::Kickstart::Logvols',
		  volgroup => 'RHN::Kickstart::Volgroups',
		  include => 'RHN::Kickstart::Include',
		 );

# handle partitions, raids, volgroups, and logvols
  foreach my $type (keys %classmap) {
    my $last = $pxt->dirty_param("last_${type}") || 0;;
    my $group = eval "new $classmap{$type}";

    foreach my $id ( (0 .. $last) ) {
      my $line = $pxt->dirty_param("${type}_${id}");

      next unless $line;
      $group->add( [ split(/\s+/, $line) ] );
    }

    if (exists $commands{"${type}s"}) {
      $commands{"${type}s"} = $group;
    }
    elsif (exists $commands{$type}) {
      $commands{$type} = $group;
    }

  }

  $ks->commands(\%commands);

  eval {
    $ks->commit;
  };
  if ($@) {
    my $E = $@;

    die $E;
  }

  $pxt->push_message( site_info => sprintf('Commands for Kickstart profile <strong>%s</strong> updated.', $ks->name) );

  my $url = $pxt->uri . '?ksid=' . $ks->id;
  $pxt->redirect($url);
}

sub build_kickstart_pre_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  $ks = RHN::Kickstart->lookup(-id => $ksid);
  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Pre Section',
				       label => 'kickstart_pre',
				       action => $attr{action},
				      );

  $form->add_widget( new RHN::Form::Widget::TextArea(name => 'Pre', label => 'pre', rows => 24, cols => 80, default => $ks->pre || '') );

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ks->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-pre-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Update Pre') );

  return $form;
}

sub build_kickstart_post_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  $ks = RHN::Kickstart->lookup(-id => $ksid);
  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Post Section',
				       label => 'kickstart_post',
				       action => $attr{action},
				      );

  $form->add_widget( new RHN::Form::Widget::TextArea(name => 'Post', label => 'post', rows => 24, cols => 80, default => $ks->post || '') );

  my @current_key_ids = map { $_->id } $ks->get_regtokens;
  my $select_keys_widget = multiple_activation_keys_widget($pxt, @current_key_ids);
  $form->add_widget($select_keys_widget);

  my @profiles = RHN::Profile->compatible_with_channel(-cid => $ks->default_tree->channel_id, -org_id => $pxt->user->org_id);

  my $select_profile_widget;

  if (@profiles) {
    unshift @profiles, { ID => 0, NAME => '(none)' };
    $select_profile_widget = new RHN::Form::Widget::Select(name => 'Package Sync', label => 'default_server_profile_id',
							   options => [ map { { value => $_->{ID},
										label => $_->{NAME} } } @profiles
								      ],
							   default => $ks->default_server_profile_id || 0 );
  }
  else {
    $select_profile_widget = new RHN::Form::Widget::Literal(name => 'Package Sync', value => '<strong>No Compatible Profiles</strong>');
  }

  $form->add_widget($select_profile_widget);

  $form->add_widget(checkbox => { name => 'Enable Configuration Management',
				  value => '1',
				  label => 'default_cfg_management_flag',
				  checked => ($ks->default_cfg_management_flag eq 'Y') ? 1 : 0 } );
  $form->add_widget(checkbox => { name => 'Enable Remote Commands',
				  value => '1',
				  label => 'default_remote_command_flag',
				  checked => ($ks->default_remote_command_flag eq 'Y') ? 1 : 0 } );

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ks->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-post-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Update Post') );

  return $form;
}

# Helper function, not a sniglet.
sub multiple_activation_keys_widget {
  my $pxt = shift;
  my @current_keys = @_;

  my @available_keys = RHN::Token->org_activation_keys($pxt->user->org_id);
  my $widget;

  if (@available_keys) {
    $widget = new RHN::Form::Widget::Multiple(name => 'Activation Keys');

    my $select_widget = new RHN::Form::Widget::Select(
      name => 'Keys',
      label => 'tid',
      options => [
		  map { { value => $_->{ID}, label => $_->{NOTE} } }
		  grep { not $_->{DISABLED} } @available_keys
		 ],
      default => \@current_keys,
      multiple => 1,
      size => 6,
      );

    my $help_link =
      Sniglets::HTML::render_help_link(-user => $pxt->user,
				       -href => 's1-sm-systems.html#S3-SM-SYSTEM-KEYS-MULTIPLE',
				       -block => 'help');

    my $help_widget = new RHN::Form::Widget::Literal(
      name => 'Note',
      value => <<EOQ,
<p class="local-alert">Note: Selection of incompatible activation keys may prevent the 
system from registering properly after kickstart.  For more 
information, consult our $help_link.</p>
EOQ
						    );

    $widget->widgets([$select_widget, $help_widget]);
    $widget->joiner("<br/>\n");
  }
  else {
    $widget = new RHN::Form::Widget::Literal(
				  name => 'Key',
				  value => <<EOQ,
<strong>No <a href="/rhn/activationkeys/List.do">Activation Keys</a> defined</strong>
EOQ
					    );
  }

  return $widget;
}

sub build_kickstart_nochroot_post_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  $ks = RHN::Kickstart->lookup(-id => $ksid);
  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Post Section',
				       label => 'kickstart_post',
				       action => $attr{action},
				      );

  $form->add_widget( new RHN::Form::Widget::TextArea(name => '--nochroot<br/>Post', label => 'nochroot_post', rows => 24, cols => 80, default => $ks->nochroot_post || '') );

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ks->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-nochroot-post-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Update Post') );

  return $form;
}

sub build_kickstart_interpreter_post_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  $ks = RHN::Kickstart->lookup(-id => $ksid);
  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Interpreter Post Section',
				       label => 'kickstart_interpreter_post',
				       action => $attr{action},
				      );

  $form->add_widget( new RHN::Form::Widget::Text(name => "Interpreter",
                               label => "interpreter_post_val",
                               value => $ks->interpreter_post_val,
                               size => 80));

  $form->add_widget( new RHN::Form::Widget::TextArea(name => '--interpreter<br/> Post', label => 'interpreter_post_script', rows => 24, cols => 80, default => $ks->interpreter_post_script || '') );


  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ks->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-interpreter-post-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Update Post') );

  return $form;
}

sub build_kickstart_interpreter_pre_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  $ks = RHN::Kickstart->lookup(-id => $ksid);
  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Post Section',
				       label => 'kickstart_post',
				       action => $attr{action},
				      );

  $form->add_widget( new RHN::Form::Widget::Text(name => "Interpreter",
                               label => "interpreter_pre_val",
                               value => $ks->interpreter_pre_val,
                               size => 80));

  $form->add_widget( new RHN::Form::Widget::TextArea(name => '--interpreter<br/> Pre', label => 'interpreter_pre_script', rows => 24, cols => 80, default => $ks->interpreter_pre_script || '') );

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ks->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-interpreter-pre-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Update Pre') );

  return $form;
}

sub kickstart_delete_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  die "No kickstart id" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);
  my $name = $ks->name;
  undef $ks;

  RHN::Kickstart->delete_kickstart($ksid);

  $pxt->push_message(site_info => sprintf('Kickstart <strong>%s</strong> deleted.', $name) );

  my $redir = $pxt->dirty_param('success_redirect');
  throw "param 'success_redirect' needed but not provided." unless $redir;
  $pxt->redirect($redir);
}

sub kickstart_add_packages_cb {
  my $pxt = shift;
  my $ksid = $pxt->param('ksid');
  die "No kickstart id" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);
  my $packages = $pxt->dirty_param('packages');

  $packages =~ s/^\s*(.*)\s*$/$1/;
  my @packages = split(/,\s*/, $packages);

  s/@(\S+)/@ $1/ foreach @packages;

  my $count = $ks->packages->add(@packages) || 0;
  $ks->commit;

  $pxt->push_message( site_info => sprintf('Added <strong>%d</strong> new packages to Kickstart profile <strong>%s</strong>.', $count, $ks->name) );

  my $url = $pxt->uri . '?ksid=' . $ks->id;
  $pxt->redirect($url);
}

sub kickstart_ip_ranges_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kickstart_ip_ranges_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style();
  my $html = $rform->render($style);

  return $html;
}

sub kickstart_ip_ranges_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  die "No kickstart id" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);
  my @ranges;
  my $count = $pxt->dirty_param('ranges_on_page');

  foreach my $range ( 1 .. $count ) {
    my @ips = grep { defined $_ && $_ =~ /^\d+$/ } $pxt->dirty_param("ip_range_$range");

    next unless (scalar @ips); # skip empty
    if ((scalar @ips) % 8) {
      $pxt->push_message(local_alert => "Not enough values for IP address.");
      return;
    }

    foreach my $part (@ips) {
      if ($part < 0 or $part > 255) {
	$pxt->push_message(local_alert => "IP address out of range.");
	return;
      }
    }

    my $min = new RHN::Kickstart::IPAddress( @ips[0 .. 3] );
    my $max = new RHN::Kickstart::IPAddress( @ips[4 .. 7] );

    if ($min > $max) {
      $pxt->push_message(local_alert => "Invalid range - minimum must be less than maximum.");
      return;
    }

    my $range = new RHN::Kickstart::IPRange(-min => $min,
					    -max => $max,
					    -org_id => $pxt->user->org_id,
					    -ksid => $ks->id);

    my @conflicts = RHN::Kickstart::IPRange->test_org_conflicts($pxt->user->org_id, $range);

    if (@conflicts) {
      my %kickstarts = map { ($_->ksid, RHN::Kickstart->lookup(-id => $_->ksid) ) } @conflicts;

      my @urls = map { PXT::HTML->link("/rhn/kickstart/KickstartIpRangeEdit.do?ksid=$_", $kickstarts{$_}->name) } keys %kickstarts;

      my $ranges_string = join(", ", @urls);

      $pxt->push_message(local_alert => sprintf('The range <strong>%s</strong> conflicts with %s from: %s',
						$range->as_string,
						(scalar @conflicts == 1) ? 'a range' : 'ranges',
						$ranges_string) );

      return;
    }

    push @ranges, $range;
  }

  my %unique_ranges = map { ( $_->min->export . '|' . $_->max->export, $_ ) } @ranges;
  @ranges = sort { $a->min->export <=> $b->min->export } values %unique_ranges;

  $ks->ip_ranges(\@ranges);
  $ks->commit;

  $pxt->push_message( site_info => sprintf('Updated IP addresses for Kickstart profile <strong>%s</strong>.', $ks->name) );

  my $url = $pxt->uri . '?ksid=' . $ks->id;
  $pxt->redirect($url);
}

sub build_kickstart_ip_ranges_form {
  my $pxt = shift;
  my %attr = @_;

  my $ksid = $pxt->param('ksid');
  my $ks;

  $ks = RHN::Kickstart->lookup(-id => $ksid);

  my $form = new RHN::Form::ParsedForm(name => 'Kickstart IP Address Ranges',
				       label => 'kickstart_ip_ranges',
				       action => $attr{action},
				      );

  my @ip_ranges = @{$ks->ip_ranges};

  foreach my $range_id ( 1 .. (scalar @ip_ranges + 1) ) {
    my @widgets;

    my $range = $ip_ranges[$range_id - 1];
    my @parts = defined $range ? $range->split_ips : ('' x 8);

    foreach my $id ((0 .. 3)) {
      push @widgets, new RHN::Form::Widget::Text(name => "ip_range_${range_id}", label => "ip_range_${range_id}", value => $parts[$id], size => 3, maxlength => 3);
    }
    push @widgets, new RHN::Form::Widget::Literal(label => "gap", default => '-');
    foreach my $id ((4 .. 7)) {
      push @widgets, new RHN::Form::Widget::Text(name => "ip_range_${range_id}", label => "ip_range_${range_id}", value => $parts[$id], size => 3, maxlength => 3);
    }

    if (defined $range) {
      push @widgets,  new RHN::Form::Widget::Literal(label => 'delete', default => PXT::HTML->link(sprintf('/rhn/kickstart/KickstartIpRangeEdit.do?pxt:trap=%s&amp;ksid=%d&amp;min=%s&amp;max=%s', 'rhn:kickstart-delete-range-cb', $ks->id, $range->min->export, $range->max->export), 'delete'));
    }
    $form->add_widget( new RHN::Form::Widget::Multiple(name => "IP Address Range", label => "ip_range_${range_id}", joiner => '.', widgets => \@widgets) );
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ranges_on_page', value => (scalar @ip_ranges + 1)) );

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'ksid', value => $ks->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kickstart-ip-ranges-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Update IP ranges') );

  return $form;
}

sub kickstart_delete_range_cb {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  my $min = $pxt->dirty_param('min');
  my $max = $pxt->dirty_param('max');

  die "need both a min and a max ($min, $max)" unless (defined $min and defined $max);

  RHN::Kickstart->remove_ip_range($ksid, $min, $max);

  $pxt->push_message(site_info => 'IP Address range deleted');
  my $url = $pxt->uri;

  $pxt->redirect($url . '?ksid=' . $ksid);
}


sub kickstart_options_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kickstart_options_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style();
  my $html = $rform->render($style);

  return $html;
}

my %kickstart_types = (
		       label => 'Select kickstart profile <strong>manually</strong>.',
		       ip_range => 'Kickstart by <strong>IP Address</strong>.',
		      );

sub build_kickstart_options_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Kickstart Options',
				       label => 'kickstart_options',
				       action => $attr{action},
				      );

  my $sid = $pxt->param('sid');
  my $server;
  my $default_ks_tree;

  my @trees = @{RHN::KSTree->kstrees_for_user($pxt->user->id)};

  if (not PXT::Config->get('satellite')) {
    @trees = grep { $_->{ORG_ID} } @trees;
  }

  if ($sid) {
    $server = RHN::Server->lookup(-id => $sid);
    my $base_channel_id = $server->base_channel_id;

    if ($base_channel_id) {
      $default_ks_tree = RHN::KSTree->best_kstree_for_server($pxt->user, $server);

      #if itanium only allow ia64 ks profiles. really need a new compat table in schema
      if ( $default_ks_tree and $default_ks_tree->channel_arch_label() eq 'channel-ia64' ) {
        @trees = grep { $_->{CHANNEL_ARCH_LABEL} eq 'channel-ia64' } @trees;
      }
      else {
        @trees = grep { $_->{CHANNEL_ARCH_LABEL} ne 'channel-ia64' } @trees;
      }
    }
    else {
      $pxt->push_message(local_alert => 'This server cannot be kickstarted because it does not have a base channel.');
    }
  }

  my @tree_options;

  push @tree_options, map { { value => $_->{ID}, label => $_->{CHANNEL_NAME} . ' - (' . $_->{LABEL} . ')' } } @trees;

  if ($sid) {
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'System Name', value => $server->name) );
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'Current Base Channel', value => $server->base_channel_name) );
  }

  if (@tree_options) {
    $form->add_widget( new RHN::Form::Widget::Select(name => 'Kickstart Distribution', label => 'kstid',
						     default => ($pxt->param('kstid')
								 or ($default_ks_tree ? $default_ks_tree->id : 0)),
						     options => \@tree_options) );

    my @kickstart_type_options;

    foreach my $type (sort { $b cmp $a } keys %kickstart_types) {
      my $opt = { value => $type, label => $kickstart_types{$type} };

      if ($type eq 'ip_range' and not (RHN::Kickstart->org_ks_ip_ranges($pxt->user->org_id))) {
	$opt->{label} .= ' (No '
	  . PXT::HTML->link('/rhn/kickstart/KickstartIpRanges.do', 'ip ranges')
	    . ' defined)';
	$opt->{disabled} = 1;
      }

      push @kickstart_type_options, $opt;
    }

    $form->add_widget(
		      new RHN::Form::Widget::RadiobuttonGroup(name => 'Kickstart type', label => 'kickstart_type',
							      default => $pxt->dirty_param('kickstart_type') || 'label',
							      options => \@kickstart_type_options) );

    if ($sid) {
      $form->add_widget( new RHN::Form::Widget::Hidden(name => 'sid', value => $sid) );
    }

    $form->add_widget( new RHN::Form::Widget::Submit(name => 'Continue') );
  }
  else {
    my $message = 'No available kickstart distributions.';

    if ($pxt->user->is('config_admin')) {
      $message .= <<EOQ
<br/>
<a href="/rhn/kickstart/TreeCreate.do">Create one</a>, then create a kickstart profile to continue.
EOQ
    }
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'Kickstart Distribution',
						      value => $message ));
  }

  return $form;
}

sub kickstart_schedule_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kickstart_schedule_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style();
  my $html = $rform->render($style);

  return $html;
}

sub build_kickstart_schedule_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Schedule Kickstart',
				       label => 'schedule_kickstart',
				       action => $attr{action},
				      );

  my $server;
  my $plural = '';

  my $redir_options = $pxt->session->get('kickstart_options') || { };
  $pxt->session->unset('kickstart_options');

  my $sid = $pxt->param('sid');
  my $ksid = $redir_options->{ksid} || $pxt->param('ksid');
  my $kstid = $redir_options->{kstid} || $pxt->param('kstid');
  my $kickstart_type = $redir_options->{kickstart_type} || $pxt->dirty_param('kickstart_type');

  my $tids = $redir_options->{tids} || [ $pxt->param('tid') ];
  my $prid = $redir_options->{prid};
  my $package_profile = $redir_options->{package_profile};
  my $sync_sid = $redir_options->{sync_sid};
  my $activation_type = $redir_options->{activation_type};
  my $deploy_configs = $redir_options->{deploy_configs};


  my $kstree = RHN::KSTree->lookup(-id => $kstid);

  if ($sid) {
    $server = RHN::Server->lookup(-id => $sid);
  }
  else {
    $plural = 's';
  }

  my $profile_widget;

  my @kickstarts = grep { $_->{ACTIVE} eq 'Y'
		      and $kstree->compatible_tree($_->{KSTREE_ID}) } RHN::Kickstart->kickstarts_for_org($pxt->user->org_id);

  unless (@kickstarts) {
    my $message = 'You have no compatible active kickstart profiles.';
    if ($pxt->user->is('config_admin')) {
      $message .= <<EOQ
<br/>
Select a different distribution, or
<a href="/rhn/kickstart/CreateProfileWizard.do">create a new kickstart profile</a>
to continue.
EOQ
    }
    else {
      $message .= 'Select a different distribution, or have an administrator create a kickstart profile to continue.';
    }

    $form->add_widget(literal => {name => 'Kickstart Profile',
				  value => $message});
    return $form;
  }

  if ($kickstart_type eq 'label') {
    my ($org_default) = grep { $_->{IS_ORG_DEFAULT} eq 'Y' } @kickstarts;

    my @ks_options = map { { value => $_->{ID}, label => $_->{NAME} . ($_->{IS_ORG_DEFAULT} eq 'Y' ? ' (org default)' : '') } } @kickstarts;

    $profile_widget = new RHN::Form::Widget::Select(name => 'Kickstart Profile', label => 'ksid',
						    default => $ksid ? $ksid : $org_default ? $org_default->{ID} : '',
						    options => \@ks_options);
  }
  else {
    $profile_widget = new RHN::Form::Widget::Literal(name => 'Kickstart profile', value => $kickstart_types{$kickstart_type});
  }

  if ($sid) {
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'System Name', value => $server->name) );
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'Current Base Channel', value => $server->base_channel_name) );
  }

  $form->add_widget( new RHN::Form::Widget::Literal(name => 'Kickstart Distribution', value => $kstree->name) );
  $form->add_widget($profile_widget);

  add_proxy_widget_to_ks_form($form, $pxt, $server);

  $form->add_widget(text => {name => "Extra Kernel Parameters",
			     label => 'kernel_params',
			     size => 32,
			     maxlength => 64,
			     default => ''});

  my $select_keys_widget = multiple_activation_keys_widget($pxt, @{$tids});

  $form->add_widget( radio_group => {name => "RHN System Profile$plural", label => 'activation_type',
    default => $activation_type || 'system_key',
    options => [ { value => 'system_key', label => "Use existing RHN profile$plural" },
		 { value => 'activation_key', label => 'Use Activation Keys: ' . $select_keys_widget->render },
	       ] } );

  my @profiles = RHN::Profile->compatible_with_channel(-cid => $kstree->channel_id, -org_id => $pxt->user->org_id);

  my $select_profile_widget;

  if (@profiles) {
    $select_profile_widget = new RHN::Form::Widget::Select(name => 'Profile', label => 'prid',
							   options => [
								       map { { value => $_->{ID}, label => $_->{NAME} } } @profiles
								      ],
							   default => $prid );
  }
  else {
    $select_profile_widget = new RHN::Form::Widget::Literal(name => 'Profile', value => '<strong>No Compatible Profiles</strong>');
  }

  my @compatible_servers = RHN::Server->systems_subscribed_to_channel(-org_id => $pxt->user->org_id,
								      -user_id => $pxt->user->id,
								      -cid => $kstree->channel_id);

  if ($server) {
    @compatible_servers = grep { $_->{ID} != $server->id } @compatible_servers;
  }

  my $select_server_profile_widget;

  if (@compatible_servers) {
    $select_server_profile_widget =
      new RHN::Form::Widget::Select(name => 'System', label => 'sync_sid', options => [
				    map { { value => $_->{ID}, label => sprintf('%s (%d)', $_->{NAME}, $_->{ID}) } }
										  @compatible_servers ],
				   default => $sync_sid );
  }
  else {
    $select_server_profile_widget =
      new RHN::Form::Widget::Literal(name => 'System', value => '<strong>No Compatible Systems</strong>');
  }

  my @package_profile_options;

  if ($server) {
    if (($server->base_channel_id || 0) == $kstree->channel_id) {
      push @package_profile_options, { value => 'system_profile', label => 'Current package profile' };
    }
  }

  push @package_profile_options,
    ( { value => 'stored_profile', label => 'With Package Profile: ' . $select_profile_widget->render },
      { value => 'other_system_profile', label => 'With System Profile: ' . $select_server_profile_widget->render },
      { value => 'none', label => 'Do not sync package profile' },
    );

  $form->add_widget( radio_group => {name => "Sync Package Profile$plural", label => 'package_profile',
				     default => $package_profile 
				       ? $package_profile
				       : (grep { $_->{value} eq 'system_profile' } @package_profile_options)
				         ? 'system_profile' 
                                         : 'none',
				     options => [ @package_profile_options ] } );

  $form->add_widget( checkbox => { name => "Deploy Configuration", label => 'deploy_configs',
				   default => 1 } );

  my $sched_img = PXT::HTML->img(-src => '/img/rhn-icon-schedule.gif', -alt => 'Date Selection');

  $form->add_widget( radio_group => {name => 'Schedule', label => 'ks_schedule',
    default => 'asap',
    options => [ { value => 'asap', label => "<strong>Begin kickstart$plural at next system check in.</strong>" },
		 { value => 'pickbox', label => "<strong>Schedule kickstart$plural no sooner than:</strong><br/>"
		                                . $sched_img . Sniglets::ServerActions::date_pickbox($pxt) },
	       ] } );

  if ($sid) {
    $form->add_widget( new RHN::Form::Widget::Hidden(name => 'sid', value => $sid) );
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'kstid', value => $kstid) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'kickstart_type', value => $kickstart_type) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:schedule-kickstart-cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Schedule Kickstart') );

  return $form;
}

# Adds a widget to the form to select an RHN Proxy if the Org has any.
sub add_proxy_widget_to_ks_form {
  my $form = shift;
  my $pxt = shift;
  my $server = shift;

  my $proxy_ds = new RHN::DataSource::System(-mode => 'org_proxy_servers');
  my $proxy_servers = $proxy_ds->execute_full(-org_id => $pxt->user->org_id);

  return unless (@{$proxy_servers});

  my $current_proxy_sid = $server ? $server->proxy_sid : 0;
  my $select_rhn_proxy_widget =
    new RHN::Form::Widget::Select(name => 'Select RHN Proxy',
				  label => 'proxy_server_id',
				  options => [ { value => 0, label => 'None' },
					       map { { value => $_->{ID},
						       label => sprintf('%s (%d)', $_->{NAME}, $_->{ID})
						     }
						   } @{$proxy_servers}
					     ],
				  default => $current_proxy_sid);

  if ($server) {
    $form->add_widget($select_rhn_proxy_widget);
  } else {
    $form->add_widget(radio_group => {name => 'Select RHN Proxy',
				      label => 'rhn_proxy_config',
				      default => 'preserve_proxy_route',
				      options => [ { value => 'preserve_proxy_route', label => 'Preserve existing configuration' },
						   {
						    value => 'select', label => 'Use RHN Proxy: ' . $select_rhn_proxy_widget->render },
						 ],
				     }
		     );
  }

  return;
}

sub schedule_kickstart_cb {
  my $pxt = shift;

  my @error_free_servers;
  my @servers;
  my $kickstart;
  my $manual_reboots_needed;

  my $kickstart_options = $pxt->session->get('kickstart_options') || { };
  $pxt->session->unset('kickstart_options');

  my $sid = $pxt->param('sid') || $kickstart_options->{sid};
  my $ksid = $pxt->param('ksid') || $kickstart_options->{ksid};
  my $kstid = $pxt->param('kstid') || $kickstart_options->{kstid};
  my $prid = $pxt->param('prid') || $kickstart_options->{prid};

  my @tids = $pxt->param('tid');
  if ((not @tids) and $kickstart_options->{tids}) {
    @tids = @{$kickstart_options->{tids}};
  }

  my $package_profile = $pxt->dirty_param('package_profile') || $kickstart_options->{package_profile};
  my $sync_sid = $pxt->param('sync_sid') || $kickstart_options->{sync_sid};
  my $kickstart_type = $pxt->dirty_param('kickstart_type') || $kickstart_options->{kickstart_type};
  my $activation_type = $pxt->dirty_param('activation_type') || $kickstart_options->{activation_type};
  my $kernel_params = $pxt->dirty_param('kernel_params') || $kickstart_options->{kernel_params};
  my $deploy_configs = $pxt->dirty_param('deploy_configs') || $kickstart_options->{deploy_configs};

  my $missing_packages_option = $kickstart_options->{missing_packages_option} || 'new_profile';

  my $kstree = RHN::KSTree->lookup(-id => $kstid);
  my $boot_image = $kstree->boot_image;

  my $earliest_date = $kickstart_options->{earliest_date} || Sniglets::ServerActions->parse_date_pickbox($pxt);
  my $pretty_earliest_date = $pxt->user->convert_time($earliest_date);

  if ($ksid) {
    $kickstart = RHN::Kickstart->lookup(-id => $ksid);
  }

  if ($sid) {
    @servers = ($sid);
  }
  else {
    my $ds = new RHN::DataSource::System(-mode => 'provisioning_systems_in_ks_set');
    my $provisioning_systems = $ds->execute_query(-user_id => $pxt->user->id, -kstid => $kstid);
    @servers = map {$_->{ID}} @{$provisioning_systems};
  }

  my $failed_count = 0;
  my $trans = RHN::DB->connect;
  $trans->nest_transactions;

  my %needed_chan_families;

  foreach my $server_id (@servers) {
    my $server = RHN::Server->lookup(-id => $server_id);

    unless ($server->base_channel_id) {
      $pxt->push_message(local_alert => 'System <strong>' . $server->name . '</strong> cannot be kickstarted because it does not have a base channel.');
      $failed_count++;
      next;
    }

    my $reboot_ok = 0;
    my %package_install_params;

    my $pid;

    eval {
      $pid = $server->get_rhn_kickstart_package($pxt->user->id, $boot_image, $kstree);
    };
    if ($@) {
      my $E = $@;

      if ($E =~ /channel_family_no_subscriptions/) {
	$trans->nested_rollback;

	if ($sid) {
	  $pxt->push_message(site_info => 'You have no remaining subscriptions to the RHN provisioning channel for this system\'s current base channel.');
	  $pxt->redirect("/network/systems/details/kickstart/index.pxt?sid=${sid}");
	}
	else {
	  $pxt->push_message(site_info => 'You do not have enough subscriptions to the RHN provisioning channels for these systems.');
	  $pxt->redirect('/network/systems/ssm/provisioning/kickstart.pxt');
	}
      }
      else {
	throw $E;
      }
    }

    if (not $pid) {
      $pxt->push_message(local_alert => 'Could not find the needed RHN provisioning packages given this system\'s current base channel and desired target channel.');
      return;
    }

    my $proper_up2date;

    eval {
      $proper_up2date = $server->up2date_version_at_least(version => "2.9.0");
    };
    if ($@ =~ /no up2date/) {
      $pxt->push_message(site_info => sprintf(<<EOM,
A kickstart was not scheduled for <strong><a href="/rhn/systems/details/Overview.do?sid=%d">%s</a></strong>
because the package profile did not contain the 'up2date' package.
An update of that system's package profile may be required.
EOM
						$server->id, $server->name));
      $failed_count++;
      next;
    }

    if ($proper_up2date) {
      $reboot_ok = 1;
    }
    else {
      my $up2date_pid = $server->installable_up2date_version_at_least(version => "2.9.0");
      if ($up2date_pid) {
	$reboot_ok = 1;

	$package_install_params{-package_ids} = [ $up2date_pid ];

	if ($sid) {
	  my $msg = <<EOM;
The latest version of up2date has been scheduled for install before the kickstart action,
because the currently-installed version does not support automatic reboot.
EOM
	  $pxt->push_message(site_info => sprintf($msg, $server->id));
	}
      }
    }

    if ($package_install_params{-package_ids}) {
      push @{$package_install_params{-package_ids}}, $pid;
    }
    else {
      $package_install_params{-package_id} = $pid;
    }

    my $install_aid = RHN::Scheduler->schedule_package_install(-org_id => $pxt->user->org_id,
							       -user_id => $pxt->user->id,
							       -earliest => $earliest_date,
							       -server_id => $server_id,
							       %package_install_params,
							      );

    RHN::Kickstart::Session->fail_inprogress(-org_id => $pxt->user->org_id, -sid => $server_id);

    my $session = new RHN::Kickstart::Session (-org_id => $pxt->user->org_id,
					       -kickstart_id => $ksid,
					       -kstree_id => $kstid,
					       -kickstart_mode => $kickstart_type,
					       -old_server_id => $server_id,
					       -action_id => $install_aid,
					       -scheduler => $pxt->user->id,
					      );

    $session->commit;

    my $rhn_proxy_config = $pxt->dirty_param('rhn_proxy_config') || '';
    my $preserve_proxy_route = ($pxt->dirty_param('preserve_proxy_route')
				or $rhn_proxy_config eq 'preserve_proxy_route') ? 1 : 0;

    if ($preserve_proxy_route and $server->proxy_hostname) {
      return if check_ca_cert_for_proxy($pxt);
      $session->system_rhn_host($server->proxy_hostname);
    }
    elsif (my $proxy_sid = $pxt->dirty_param('proxy_server_id')) {
      my $proxy_server = RHN::Server->lookup(-id => $proxy_sid);

      throw "Attempt to use a different org's proxy: $proxy_sid"
	unless $proxy_server->org_id == $pxt->user->org_id;

      if ($proxy_server->guess_hostname) {
	return if check_ca_cert_for_proxy($pxt);
	$session->system_rhn_host($proxy_server->guess_hostname);
      }
      else {
	$pxt->push_message(local_alert =>
			   sprintf('Could not find a hostname for proxy server %s (%d)',
				   $proxy_server->name, $proxy_server->id));
	return;
      }
    }

    my $token;
    my @channel_ids;

    if ($kstree->channel_id == $server->base_channel_id) {
      @channel_ids = $server->server_channel_ids;
    }
    else {
      my $rhn_extras_cid = RHN::Channel->get_rhn_extras_channel($kstree->channel_id, $pxt->user->org_id);

      unless ($rhn_extras_cid) {
	my $target_base_channel = RHN::Channel->lookup(-id => $kstree->channel_id);

	$trans->nested_rollback;

	$pxt->push_message(site_info => sprintf(<<EOQ, $target_base_channel->id, $target_base_channel->name));
Could not look up the Satellite Tools channel for
<a href="/network/software/channels/details.pxt?cid=%d">%s</a>
EOQ

	if ($sid) {
	  $pxt->redirect("/network/systems/details/kickstart/index.pxt?sid=${sid}");
	}
	else {
	  $pxt->redirect('/network/systems/ssm/provisioning/kickstart.pxt');
	}
      }
      @channel_ids = ($kstree->channel_id, $rhn_extras_cid);
    }

    if ($activation_type eq 'system_key') {
      my $orig_token = RHN::Token->lookup(-sid => $server_id);

      if ($orig_token) {
	$orig_token->purge;
	undef $orig_token;
      }

      $token = Sniglets::ActivationKeys->create_token($pxt);
      $token->create_new_key;
      $token->server_id($server_id);
      $token->note("Kickstart re-activation key for " . $server->name . ".");
      $token->usage_limit(1);
      $token->activation_key_ks_session_id($session->id);

      $token->commit;

      # Do these after token is committed b/c we need a row rhnRegToken first.
      $token->set_entitlements(map { $_->{LABEL} } $server->entitlements);
      $token->set_channels(-channels => \@channel_ids);
    }
    elsif ($activation_type eq 'activation_key') {
      unless (@tids) {
	$pxt->push_message(local_alert => 'No activation keys selected.');
	return;
      }

      my %cids;
      foreach my $tid (@tids) {
	$token = RHN::Token->lookup(-id => $tid);

	foreach my $cid ($kstree->channel_id, $token->channels) {
	  $cids{$cid} = 1;
	}

	unless ($missing_packages_option eq 'subscribe_to_channels') {
	  $token->create_new_key;
	  $token->activation_key_ks_session_id($session->id);

	  $token->commit;
	}
      }
    }
    else {
      die "Invalid activation type: '$activation_type'";
    }

    my $profile;

    if ($package_profile eq 'system_profile') {
      $profile = RHN::Profile->create_from_system(-sid => $server->id,
						  -org_id => $pxt->user->org_id,
						  -name => "Profile for kickstart session " . $session->id,
						  -description => "Profile for kickstart session " . $session->id,
						  -type => 'sync_profile',
						 );

      $session->server_profile_id($profile->id);
    }
    elsif ($package_profile eq 'other_system_profile') {
      $profile = RHN::Profile->create_from_system(-sid => $sync_sid,
						  -org_id => $pxt->user->org_id,
						  -name => "Profile for kickstart session " . $session->id,
						  -description => "Profile for kickstart session " . $session->id,
						  -type => 'sync_profile',
						 );

      $session->server_profile_id($profile->id);
    }
    elsif (($package_profile eq 'stored_profile') and $prid) {
      $profile = RHN::Profile->create_from_profile(-prid => $prid,
						   -org_id => $pxt->user->org_id,
						   -name => "Profile for kickstart session " . $session->id,
						   -description => "Profile for kickstart session " . $session->id,
						   -type => 'sync_profile',
						  );

      $session->server_profile_id($profile->id);
    }

    if ($deploy_configs) {
      $session->deploy_configs('Y');
    }
    else {
      $session->deploy_configs('N');
    }

    if ($profile) { # we are synching package profiles
      my %packages;

      my %missing_packages = map { ($_->id => $_) }
	$profile->profile_packages_missing_from_channels(channels => \@channel_ids);

      if (%missing_packages) {
	if ($missing_packages_option eq 'remove_packages') {
	  $profile->remove_packages_by_id_combo(keys %missing_packages);
	}
	elsif ($missing_packages_option eq 'subscribe_to_channels') {
	  my $base_channel_id = $profile->base_channel;
	  my @valid_child_channels =
	    grep { $pxt->user->verify_channel_access($_) } RHN::Channel->children($base_channel_id);

	  my %token_channels = map { ( $_ => 'old' ) } $token->channels;
	  my %found_packages;

	  foreach my $cid (@valid_child_channels) {
	    my @channel_packages = grep { RHN::Package->is_package_in_channel(-cid => $cid,
									      -evr_id => $_->evr_id,
									      -name_id => $_->name_id) } values %missing_packages;
	    if (@channel_packages) { # some of the missing packages are in this channel
	      $token_channels{$cid} = 'new';
	      delete $missing_packages{$_->id} foreach (@channel_packages);
	    }
	  }

	  if (grep { $_ eq 'new' } values %token_channels) { #one or more new channels

	    if ($activation_type eq 'system_key') {
	      $token->set_channels(-channels => [ keys %token_channels ]);
	    }
	    elsif ($activation_type eq 'activation_key') { # we have to create a new token
	      my $new_token = $token->clone_token;

	      $new_token->note("Kickstart activation key for " . $server->name . ".");
	      $new_token->usage_limit(1);
	      $new_token->activation_key_ks_session_id($session->id);
	      $new_token->set_channels(-channels =>  [ keys %token_channels ]);

	      $new_token->commit;

	      $new_token->set_entitlements('enterprise_entitled', 'provisioning_entitled');

	      $token = $new_token; # overrite old token, in case we use it later
	    }
	  }

	  $profile->remove_packages_by_id_combo(keys %missing_packages)
	}
	elsif ($missing_packages_option eq 'new_profile') {

	  $trans->nested_rollback;
	  my %params = (
			sid => $sid,
			tids => \@tids,
			ksid => $ksid,
			kstid => $kstid,
			prid => $prid,
			package_profile => $package_profile,
			sync_sid => $sync_sid,
			kickstart_type => $kickstart_type,
			activation_type => $activation_type,
			earliest_date => $earliest_date,
			channels => \@channel_ids,
			kssid => $session->id,
			kernel_params => $kernel_params,
			deploy_configs=> $deploy_configs,
		       );

	  $pxt->session->set('kickstart_options' => \%params);

	  if ($sid) {
	    $pxt->redirect("/network/systems/details/kickstart/missing_packages.pxt?sid=${sid}");
	  }
	  else {
	    $pxt->redirect("/network/systems/ssm/provisioning/missing_packages.pxt");
	  }
	}
      }
    }

    foreach my $cid ($server->server_channel_ids) {
      my $cfam = RHN::Channel->family($cid);
      $needed_chan_families{$cfam->{ID}}--;  # a slot is freed
    }

    foreach my $cid (@channel_ids) {
      my $cfam = RHN::Channel->family($cid);
      $needed_chan_families{$cfam->{ID}}++;  # a slot is used
    }

    my ($tiny_url, $url_token) = $session->get_tiny_url(-expected_time => $earliest_date);
    my $append_string = 'ks=' . $tiny_url;

    my $static_device = '';
    my $extra_params = ' ksdevice=eth0';

    if ($kickstart) {
      $static_device = $kickstart->static_device || '';

      if ($static_device =~ /^dhcp:(\S+)$/) {
	$extra_params = " ksdevice=$1";
	$static_device = '';
      }
      elsif ($static_device =~ /^static:(\S+)$/) {
	$static_device = $1;
	$extra_params = '';
      }

      $kernel_params ||= $kickstart->kernel_params;
    }

    if ($kernel_params) {
      $extra_params .= " ${kernel_params}";
    }

    $append_string .= $extra_params;

    my $inject_aid = RHN::Scheduler->schedule_kickstart_inject(-org_id => $pxt->user->org_id,
							       -user_id => $pxt->user->id,
							       -earliest => $earliest_date,
							       -server_id => $server_id,
							       -kstree_id => $kstid,
							       -append_string => $append_string,
							       -prerequisite => $install_aid,
							       -static_device => $static_device,
							       -ksid => $ksid,
							      );

    my $restart_aid;

    if ($reboot_ok) {
      $restart_aid = RHN::Scheduler->schedule_reboot(-org_id => $pxt->user->org_id,
						     -user_id => $pxt->user->id,
						     -earliest => $earliest_date,
						     -server_id => $server_id,
						     -prerequisite => $inject_aid,
						    );
    }

    $manual_reboots_needed = 1 unless $restart_aid;

    #if we made it this far, declare the server error free
    push @error_free_servers, $server->name;

    $session->commit;
  }

  my @missing_entitlement_messages;
  my %avail_chan_families = map { ( $_->{ID} => $_->{AVAILABLE_MEMBERS} ) }
    @{$pxt->user->org->channel_entitlements};

  foreach my $cfid (keys %needed_chan_families) {

    if (exists $avail_chan_families{$cfid}) { # subtract avail subscriptions, or set to 0 if unlimited
      $needed_chan_families{$cfid} = defined $avail_chan_families{$cfid}
	? ($needed_chan_families{$cfid} - $avail_chan_families{$cfid})
	: 0;
    }

    next unless $needed_chan_families{$cfid} > 0;

    my $cfam = RHN::Channel->family_details($cfid);
    push @missing_entitlement_messages,
      sprintf('<strong>%d</strong> more <strong>%s</strong> entitlement%s',
	      $needed_chan_families{$cfid}, $cfam->{NAME}, $needed_chan_families{$cfid} == 1 ? '' : 's');
  }

  if (@missing_entitlement_messages) {
    $pxt->push_message(local_alert => 'To complete this kickstart, you need:');
    $pxt->push_message(local_alert => $_) foreach @missing_entitlement_messages;

    $pxt->session->set('kickstart_options', $kickstart_options);
    $trans->nested_rollback;

    return;
  }

  $trans->nested_commit;

  if ($sid and not $failed_count) {
    # We are dealing with a single system and there were no errors.
    my $msg = <<EOM;
System Kickstart <strong><a href="/network/systems/details/kickstart/session_status.pxt?sid=%d">scheduled</a></strong> for %s.
EOM
    $pxt->push_message( site_info => sprintf($msg, $sid, $pretty_earliest_date) );

    if ($manual_reboots_needed) {
      $msg = <<EOM;
This system does not support remote rebooting.
You will need to reboot the system manually after the kickstart packages have been installed.
EOM
      $pxt->push_message( site_info => $msg );
    }

    $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid");
  }
  elsif ($sid) {
    $pxt->redirect("/rhn/systems/details/Overview.do?sid=$sid");
  }
  else {
    # We are dealing with multiple systems and at least one was kickstarted successfully
    my $success_msg;
    if (scalar(@error_free_servers) > 1) {
        #Use plural version of success msg
        $success_msg = scalar(@error_free_servers) . " systems were scheduled for kickstart.";
    }
    else {
        #Use singular version of success msg
        $success_msg = scalar(@error_free_servers) . " system was scheduled for kickstart.";
    }

    my $failed_msg;
    if ($failed_count > 1) {
        #Use plural version of success msg
        $failed_msg = $failed_count . " systems had problems and will <strong>not</strong> be kickstarted.";
    }
    else {
        #Use singular version of success msg
        $failed_msg = $failed_count . " system had problems and will <strong>not</strong> be kickstarted.";
    }
    
    if (scalar(@error_free_servers) > 0) {
        $pxt->push_message(site_info => $success_msg);
    }
    if ($failed_count > 0) {
        $pxt->push_message(site_info => $failed_msg);
    }
    $pxt->redirect("/network/systems/ssm/index.pxt");
  }

}

# Not a real handler, just a helper method
# returns '1' if there are no SSL keys in the org
# returns '2' if there are no SSL keys associated with the select ks profile
# return '0' otherwise.
sub check_ca_cert_for_proxy {
  my $pxt = shift;

  my $ksid = $pxt->param('ksid');
  my $ks;

  if ($ksid) {
    $ks = RHN::Kickstart->lookup(-id => $ksid);
  }

  my $ds = new RHN::DataSource::Simple(-querybase => 'General_queries',
				       -mode => 'crypto_keys_for_org');
  my $org_keys = $ds->execute_query(-org_id => $pxt->user->org_id);

  if (not grep { $_->{LABEL} eq 'SSL' } @{$org_keys}) {
    my $message = <<EOQ;
You have no SSL CA certificates defined for your Organization.  You
must <a href="/network/keys/key_list.pxt">add an SSL CA certificate</a>
EOQ

    if ($ksid) {
      $message .= sprintf(<<EOQ, $ks->id, $ks->name);
 and then <a
href="/rhn/kickstart/KickstartCryptoKeysList.do?ksid=%d">associate
it with kickstart profile %s</a>
EOQ
    }

    $message .= '.'; # <- more info link goes here

    $pxt->push_message(local_alert => $message);
    return 1;
  }

 # If we are doing an ip-address based ks, for instance, we can't tell
 # which ks profile we're going to get.  So bail out now.
  return 0 unless $ksid;

  $ds = new RHN::DataSource::Simple(-querybase => 'General_queries',
				    -mode => 'crypto_keys_for_ks_profile');
  my $ks_keys = $ds->execute_query(-ksid => $ksid);

  if (not grep { $_->{LABEL} eq 'SSL' } @{$ks_keys}) {
    my $sid = $pxt->param('sid');
    my $sys_part = $sid ? 'this system' : 'these systems';

    my $message = sprintf(<<EOQ, $sys_part, $ks->id, $ks->name);
This kickstart action cannot be completed because you have chosen to
connect %s through an RHN Proxy, but the selected kickstart profile
does not have any SSL CA Certificates associated with it.  You must <a
href="/rhn/kickstart/KickstartCryptoKeysList.do?ksid=%d">associate
your RHN Proxy SSL CA Certificate with kickstart profile %s</a>, or
select a different kickstart profile.
EOQ
    # more info link goes here, too ---------^

    $pxt->push_message(local_alert => $message);

    return 2;
  }

  return 0;
}

sub cancel_kickstart_cb {
  my $pxt = shift;

  my $kssid = $pxt->param('kssid');
  my $sid = $pxt->param('sid');
  my $session;

  if ($sid) {
    $session = RHN::Kickstart::Session->lookup(-sid => $sid, -org_id => $pxt->user->org_id, -expired => 1);
  }
  else {
    $session = RHN::Kickstart::Session->lookup(-id => $kssid);
  }

  my $redir = $pxt->dirty_param('redirect') . ($sid ? "?sid=${sid}" : "?kssid=${kssid}");

  unless (grep { $session->session_state_label eq $_ } qw/created deployed injected/) {
    my $name = $session->session_state_name;

    $pxt->push_message(local_alert => "This session has already proceeded to the <strong>$name</strong> state, and cannot be cancelled.");
    $pxt->redirect($redir);
  }

  $session->mark_failed("Kickstart cancelled by user '" . $pxt->user->login . "'.");

  $pxt->push_message(site_info => "Kickstart session cancelled.");
  $pxt->redirect($redir);

  return;
}

sub session_details {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};
  my $kssid = $pxt->param('kssid');
  my $sid = $pxt->param('sid') || 0;
  my $session;

  if ($sid) {
    $session = RHN::Kickstart::Session->lookup(-sid => $sid, -org_id => $pxt->user->org_id, -expired => 1);
  }
  else {
    $session = RHN::Kickstart::Session->lookup(-id => $kssid);
  }

  my %subst;

  $subst{"session_$_"} = $session->$_ || '' foreach (qw/id kickstart_id org_id old_server_id new_server_id state_id server_profile_id action_id/);

  $subst{$_} = (defined $session->$_ ? $session->$_ : '')
    foreach qw/session_state_name session_state_label ks_label ks_active
	       last_file_request package_fetch_count/;

  my $kstree = RHN::KSTree->lookup(-id => $session->kstree_id);
  if ($kstree->tree_type_label ne 'rhn-managed') {
    $subst{package_fetch_count} = $subst{last_file_request} = "(unavailable for externally hosted distributions)";
  }

  if (my $url = $attr{cancel_session_link}) {
    my $last_history_event = $session->last_history_event;

    if (grep { $session->session_state_label eq $_ } qw/created deployed injected/ and $session->action_id) {
      $subst{session_state_name} .= ' (' . PXT::HTML->link($url, 'cancel kickstart') . ')';
    }
    elsif ($last_history_event and $last_history_event->{MESSAGE}) {
      $subst{session_state_name} .= ' (' . $last_history_event->{MESSAGE} . ')';
    }
  }

  my $old_server = $session->old_server;
  my $new_server = $session->new_server;
  my $current_server = $session->current_server;

  if (not $current_server) {
    $subst{session_system_link} = '(none)';
    $subst{session_for_string} = '';
  }
  else {
    $subst{session_system_link} = PXT::HTML->link('/rhn/systems/details/Overview.do?sid=' . $current_server->id,
						  $current_server->name);
    $subst{session_for_string} = ' for ' . $subst{session_system_link};
  }

  if ($session->kickstart_id) {
    $subst{session_kickstart_link} =
      PXT::HTML->link('/rhn/kickstart/KickstartDetailsEdit.do?ksid=' . $session->kickstart_id,
		      $session->ks_label);

    my $enc_session = RHN::SessionSwap->encode_data($session->id);

    $subst{session_kickstart_link} .= "<br/>("
      . PXT::HTML->link("/kickstart/ks/view_session/${enc_session}",
			"view", '', "_new") . ")";
  }
  elsif (not $session->kickstart_mode) {
    $subst{session_kickstart_link} = '(none yet)';
  }
  else {
    $subst{session_kickstart_link} = $kickstart_types{$session->kickstart_mode};
  }

  if ($session->action and $current_server) {
    $subst{session_action_name} = $session->action->action_type_name;
    my $aid = $session->action_id;

    $subst{session_action_link} = PXT::HTML->link("/network/systems/details/history/event.pxt?sid=" . $current_server->id . "&amp;hid=$aid",
						    $session->action->action_type_name);

  }
  else {
    my $label = $session->session_state_label;
    my $msg = 'waiting for system';

    if ($label eq 'failed') {
      $msg = 'kickstart failed';
    }
    elsif ($label eq 'complete') {
      $msg = 'kickstart complete';
    }

    $subst{session_action_name} = "None - ${msg}.";
    $subst{session_action_link} = "None - ${msg}.";
  }

  $subst{session_last_action} = $pxt->user->convert_time($session->last_action);
  $subst{last_file_request} ||= '(none)';

  my @activation_keys = $session->activation_keys;

  if (not @activation_keys) {
    $subst{activation_type} = '(none)';
  }
  elsif (grep { $_->server_id } @activation_keys) {
    $subst{activation_type} = 'Use existing profile';
  }
  else {
    my @key_html;
    if ($pxt->user->is('org_admin')) {
      @key_html = map { PXT::HTML->link('/rhn/activationkeys/Edit.do?tid=' . $_->id,
					$_->note) } @activation_keys;
    }
    else {
      @key_html = map { $_->note } @activation_keys;
    }

    $subst{activation_type} = join("<br/>\n", @key_html) || '&#168;';

    if ( ($new_server and $old_server) and ($new_server->id != $old_server->id) ) {
      my $old_server_link = PXT::HTML->link('/rhn/systems/details/Overview.do?sid=' . $old_server->id,
					    $old_server->name);
      my $new_server_link = PXT::HTML->link('/rhn/systems/details/Overview.do?sid=' . $new_server->id,
					    $new_server->name);
      $subst{activation_type} .= sprintf('<br />Kickstarted from: %s to %s', $old_server_link, $new_server_link);
    }
  }

  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub tiny_url_handler {
  my $pxt = shift;

  my (undef, $tu, @rest) = split m(/), $pxt->path_info;

  my $stored_url = RHN::TinyURL->lookup(-token => $tu);
  $pxt->redirect("/errors/404.pxt") unless $stored_url;

  my $final_url = join("/", $stored_url, @rest);
  $pxt->manual_content(1);
  $pxt->internal_redirect($final_url);
}

sub update_ck_set {
  my $class = shift;
  my $node = shift;
  my $pxt = shift;
  my $params = shift;

  my $set_label = 'kickstart_keys';
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my $ksid = $pxt->param('ksid');
  throw "No ks id" unless $ksid;

  my $ks = RHN::Kickstart->lookup(-id => $ksid);

  my @current_keys = map { $_->{ID} } $ks->crypto_keys;

  $set->empty;
  $set->add(@current_keys);
  $set->commit;

  return;
}

sub kstree_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_kstree_edit_form($pxt, %attr);
  unless (ref $form and $form->isa('RHN::Form')) {
    return $form;
  }

  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style();
  my $html = $rform->render($style);

  return $html;
}

sub build_kstree_edit_form {
  my $pxt = shift;
  my %attr = @_;

  my $ktsid = $pxt->param('kstid');
  my $kstree;
  $kstree = RHN::KSTree->lookup(-id => $ktsid)
    if $ktsid;

  my $form = new RHN::Form::ParsedForm(name => 'Edit Kickstart Tree',
				       label => 'kstree_edit',
				       action => "edit-tree.pxt",
				       method => "POST",
				      );

  $form->add_widget(new RHN::Form::Widget::Text(name => 'Distribution Label',
						label => 'label',
						size => 40,
						default => $kstree ? $kstree->label : '',
						requires => { regexp => qr/^[a-zA-Z\d\-\._]*$/,
							      'min-length' => 4 },
					       ));
  $form->add_widget(new RHN::Form::Widget::Text(name => 'External Location',
						label => 'base_path',
						size => 60,
						default => $kstree ? $kstree->base_path : '',
						requires => { response => 1 },
					       ));


  my $data = RHN::Package->package_names_by_provide(org_id => $pxt->user->org_id,
						    cap_name => 'rhn.kickstart.boot_image',
						   );

  if (PXT::Config->get('satellite') and not @{$data}) {
    return <<EOQ;
<strong>
  Could not find any Autokickstart RPMs.  These RPMs are located in
  the RHN Tools channels for each supported parent channel.  You may
  need to perform a satellite sync of the RHN Tools channels before
  performing a kickstart or creating a new kickstart distribution.
</strong>
EOQ
  }

  my @boot_image_rpms = map { { label => (split(/auto-kickstart-/, $_->{NAME}))[1],
				value => (split(/auto-kickstart-/, $_->{NAME}))[1]} } @{$data};
  $form->add_widget(new RHN::Form::Widget::Select(name => 'Autokickstart RPM',
						  label => 'boot_image',
						  size => 1,
						  value => $kstree ? $kstree->boot_image : -1,
						  options => \@boot_image_rpms,
						  requires => { response => 1 },
						 ));

  my $ds = new RHN::DataSource::Channel(-mode => 'kickstartable_base_channels');
  my $base_channels = $ds->execute_query(-org_id => $pxt->user->org_id);

  my @channels;
  foreach my $candidate (@$base_channels) {
    push @channels, { label => $candidate->{CHANNEL_NAME}, value => $candidate->{CHANNEL_ID} };
  }

  my $channel_widget =
    new RHN::Form::Widget::Select(name => 'Base Channel',
				  label => 'cid',
				  size => 1,
				  value => $kstree ? $kstree->channel_id : -1,
				  options => \@channels,
				  requires => { response => 1 },
				 );


  $form->add_widget($channel_widget);

  if ($kstree) {
    $form->add_widget(literal => { name => 'Installer Generation',
				   value => $kstree->install_type_name,
				 } );
  }
  else {
    $form->add_widget(select => { name => 'Installer Generation',
				  label => 'install_type_label',
				  size => 1,
				  value => $kstree ? $kstree->install_type_label : -1,
				  options => [ map { { label => $_->{NAME}, value => $_->{LABEL} } }
					       @{RHN::KSTree->install_types} ],
				  requires => { response => 1 },
				}
		     );
  }

  $form->add_widget(new RHN::Form::Widget::Hidden(name => 'kstid', value => $kstree->id))
    if $kstree;

  $form->add_widget(new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:kstree-edit-cb'));
  $form->add_widget(new RHN::Form::Widget::Submit(name => ($kstree ? 'Update Distribution' : 'Create')));

  return $form;
}

sub kstree_edit_cb {
  my $pxt = shift;

  my $form = build_kstree_edit_form($pxt);
  my $response = $form->prepare_response;
  my $errors = Sniglets::Forms::load_params($pxt, $response);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my $kstid = $pxt->param('kstid');
  my $base_path = $pxt->dirty_param('base_path');

  unless ($base_path =~ /^(http|ftp)/) {
    $pxt->push_message(local_alert => 'Your external repository must be hosted via http or ftp.');
    return;
  }

  eval {
    my $kstree;
    if (not $kstid) {
      $kstree = RHN::KSTree->create_tree(-org_id => $pxt->user->org_id,
					 -tree_type => 'externally-managed',
					 -boot_image => $pxt->dirty_param('boot_image'),
					 -label => $pxt->dirty_param('label'),
					 -path => $base_path,
					 -channel_id => $pxt->param('cid'),
					 -install_type_label => $pxt->dirty_param('install_type_label'),
					);
      $pxt->push_message(site_info => 'Kickstart distribution created.');
    }
    else {
      $kstree = RHN::KSTree->lookup(-id => $kstid);
      $kstree->$_($pxt->dirty_param($_)) for qw/boot_image label base_path/;
      $kstree->channel_id($pxt->param('cid'));
      $pxt->push_message(site_info => 'Kickstart distribution updated.');
    }

    $kstree->commit;
  };
  if ($@) {
    my $E = $@;

    if ($E =~ /RHN_KSTREE_OID_LABEL_UQ/) {
      $pxt->push_message( local_alert => 'A kickstart distribution with that label already exists.' );
      return;
    }
    else {
      die $E;
    }
  }

  $pxt->redirect("trees.pxt");
}

sub kstree_delete_cb {
  my $pxt = shift;
  my $kstid = $pxt->param('kstid');

  RHN::KSTree->delete_tree($kstid);

  $pxt->push_message(site_info => 'Kickstart distribution deleted.');

  $pxt->redirect("trees.pxt");
}

sub edit_file_preservation {
    my $pxt = shift;
    my %params = @_;

    my $block = $params{__block__};
    my $flid = $pxt->param('flid');
    my $list;

    if ($flid) {
      $list = RHN::FileList->lookup(-id => $flid);
    }
    else {
      $list = RHN::FileList->blank_list();
      $list->org_id($pxt->user->org_id);
    }

    my %subs;

    if ($flid) {
      my $none = '<span class="no-details">(none)</span>';
      $subs{"list_id"} = PXT::Utils->escapeHTML($list->id());
      $subs{created} = $list->created();

# Add this back, once the last_modified column problems are resolved.
#      $subs{modified} = $list->modified();

      $subs{label} = PXT::Utils->escapeHTML($list->label());
      $subs{file_list} = PXT::Utils->escapeHTML(join ("\n", @{$list->get_file_list()}) || '');
    }
    else {
      $subs{label} = PXT::HTML->text(-name => 'label', -value => '', -size => 30, -length => 64);
      $subs{file_list} = '';
    }
    return PXT::Utils->perform_substitutions($block, \%subs);
}

sub edit_file_preserv_cb {
  my $pxt = shift;

  my $flid = $pxt->param('flid');
  my $list;

  if ($flid) {
    $list = RHN::FileList->lookup(-id => $flid);
  }
  else {
    $list = RHN::FileList->blank_list();
    $list->org_id($pxt->user->org_id);

    # only allow label on initial creation
    $list->label($pxt->dirty_param('label')) if not $flid;
    if (not $list->label) {
      $pxt->push_message(local_alert => "You must specify a label");
      $pxt->redirect("/network/systems/custominfo/edit.pxt");
      return;
    }
  }

  eval {
    $list->commit;
  };

  my @flist = split (/[\r\n]+/, $pxt->dirty_param('file:list') || "");

  for (@flist) { s/^\s+//; s/\s+$//; } #strip whitespace from elements

  $list->set_file_list(file_list => \@flist);

  if ($@) {
    my $E = $@;

    if ($E->constraint_value('RHN_CDATAKEY_LABEL_UQ')) {
      $pxt->push_message(local_alert => "A file list already exists with that label. Please choose another label.");
      $pxt->redirect("/network/systems/custominfo/edit.pxt");
      return;
    }
    die $E;
  }

  if ($flid) {
      $pxt->push_message(site_info => PXT::Utils->escapeHTML($list->label) . " details updated.");
  }
  else {
      $pxt->push_message(site_info => "New file list " . PXT::Utils->escapeHTML($list->label) . " created.");
  }

  $pxt->redirect('/network/systems/provisioning/preservation/preservation_list.pxt');
}

sub delete_file_preserv {
    my $pxt = shift;

    my $flid = $pxt->param('flid');
    die "no file list id" unless $flid;
    
    my $list = RHN::FileList->lookup(-id => $flid);

    $list->delete_list();
    $pxt->push_message(site_info => "File List <strong>" . $list->label() . "</strong> deleted.");

    $pxt->redirect("/network/systems/provisioning/preservation/preservation_list.pxt");

}

#given an org_id, return a list of file preservation lists.
sub file_preservation_lists {
  my $org_id = shift;

  my $ds = new RHN::DataSource::General(-mode => 'preservations_for_org');
  my $all_lists = $ds->execute_query(-org_id => $org_id);

  return @{$all_lists};
}

1;
