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
use RHN::TinyURL;
use RHN::Kickstart::Session;
use RHN::SessionSwap;

use RHN::DataSource::Package;
use RHN::DataSource::General;

use RHN::DB;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-kickstart-handler' => \&kickstart_handler);
  $pxt->register_tag('rhn-kickstart-tinyurl' => \&tiny_url_handler);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;
}

sub kickstart_handler {
  my $pxt = shift;

  my $path_info = File::Spec->canonpath($pxt->path_info);
  $path_info =~ s(^/)();

  my ($subsys, $path) = split m(/), $path_info, 2;

  if ($subsys eq 'dist') {
    return dist_handler($pxt, $path);
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
    #my $package_id = $channel->package_by_filename_in_tree($filename);
    my ($package_id, $package_path) = $channel->package_by_filename_in_tree($filename);
    
    warn ("Package Path: " . $package_path);
    
    if ($package_id) {
      # found the package in our channel repo?  good, serve it...
      $disk_path = File::Spec->catfile(PXT::Config->get('mount_point'), $package_path);
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

sub tiny_url_handler {
  my $pxt = shift;

  my (undef, $tu, @rest) = split m(/), $pxt->path_info;

  my $stored_url = RHN::TinyURL->lookup(-token => $tu);
  $pxt->redirect("/errors/404.pxt") unless $stored_url;

  my $final_url = join("/", $stored_url, @rest);
  $pxt->manual_content(1);
  $pxt->internal_redirect($final_url);
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


1;
