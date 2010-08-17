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

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-kickstart-tinyurl' => \&tiny_url_handler);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;
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
