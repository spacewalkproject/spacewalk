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

package Sniglets::Downloads;

use PXT::HTML;
use PXT::Config;

use RHN::TokenGen::Generator;
use RHN::TokenGen::Local;
use RHN::SessionSwap;
use RHN::DataSource::Channel;

use File::Spec;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-channel-download-categories' => \&channel_download_categories, 2);
  $pxt->register_tag('rhn-channel-downloads' => \&channel_downloads, 3);

  $pxt->register_tag('rhn-recent-iso-channels', \&recent_iso_channels, 1);
  $pxt->register_tag('rhn-ftp-download', \&ftp_download, 4);
  $pxt->register_tag('rhn-akamai-redirect' => \&akamai_redirect);
  $pxt->register_tag('rhn-download-package', \&download_package, 1);
}

sub recent_iso_channels {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__} || '';
  my $limit = $params{limit};

  my @channels = split /\s*,\s*/, PXT::Config->get("popular_iso_channels");

  my $ret;
  foreach my $i (0 .. $#channels) {
    last if $limit and $i >= $limit;
    my $channel_id = RHN::Channel->channel_id_by_label($channels[$i]);
    next unless $pxt->user->verify_channel_access($channel_id);
    my $channel = RHN::Channel->lookup(-id => $channel_id);

    my %s;
    $s{channel_label} = $channel->label;
    $s{channel_name} = $channel->name;
    PXT::Utils->escapeHTML_multi(\%s);

    $ret .= PXT::Utils->perform_substitutions($block, \%s);
  }

  return $ret;
}

# algorithm: sum the config weights of the various locations.  pick a
# random choice in (0 .. $sum - 1).  walk the list of choices,
# subtracting the weight from the choice we made.  when the result is
# negative, we found where in the list of choices our random choice
# has hit.  default to the first choice if somehow this does not work
# (which it never should, but...).

sub choose_download_location {
  my $class = shift;
  my @locations = @_;

  # only one location?  use it
  return $locations[0] if @locations == 1;

  my @weights = map { PXT::Config->get("download_${_}_weight") || 0 } @locations;

  my $sum = 0;
  $sum += $_ for @weights;
  my $choice = int(rand($sum));

  for my $i (0 .. $#locations) {
    $choice -= $weights[$i];
    if ($choice < 0) {
      return $locations[$i];
    }
  }

  return $locations[0]
}

sub channel_download_categories {
  my $pxt = shift;
  my %params = @_;
  my $channel = $params{channel};
  my $block = $params{__block__};
  my $mode = $params{mode};
  my $type = $params{type};
  my $limit = $params{limit};

  my %cat_urls;

  my $ds = new RHN::DataSource::Channel(-mode => $mode);
  my $cats = $ds->execute_query(-channel_label => $channel, -download_type => $type);
  my $url_ds = new RHN::DataSource::Channel(-mode => 'release_notes_url_by_category');
  my $urls = $url_ds->execute_query(-channel_label => $channel, -download_type => $type);
  for my $row (@$urls) {
    if ($row->{RELEASE_NOTES_URL}) {
      $cat_urls{$row->{CATEGORY}} = $row->{RELEASE_NOTES_URL};
    }
  }

  my $ret;
  my $i = 0;
  for my $cat (@$cats) {
    my %s;
    last if $limit and ++$i > $limit;

    $s{download_category} = $cat->{CATEGORY};
    $s{download_type} = $type;
    PXT::Utils->escapeHTML_multi(\%s);

    if (exists $cat_urls{$cat->{CATEGORY}}) {
      $s{release_notes_url} = '<a href="' . $cat_urls{$cat->{CATEGORY}}
                                          . '">Release Notes</a>';
    }
    else {
      $s{release_notes_url} = '';
    }

    $ret .= PXT::Utils->perform_substitutions($block, \%s);
  } return $ret;
}

sub channel_downloads {
  my $pxt = shift;
  my %params = @_;

  my $channel = $params{channel};
  my $category = $params{category};
  my $mode = $params{mode};
  my $type = $params{type};
  my $block = $params{__block__};

  my $ret;

  my $file_ds = new RHN::DataSource::Channel(-mode => $mode);
  my $isos = $file_ds->execute_full(-channel_label => $channel, -download_type => $type);

  my $i = 0;
  foreach my $iso (@$isos) {
    next unless $iso->{CATEGORY} eq $category;
    my %s;

    $s{download_name} = $iso->{DOWNLOAD_NAME};
    $s{download_path} = $iso->{DOWNLOAD_PATH};
    $s{download_file_id} = $iso->{ID};
    $s{download_size} = PXT::Utils->humanify($iso->{DOWNLOAD_SIZE});
    $s{download_checksum} = $iso->{DOWNLOAD_CHECKSUM};
    $s{download_trclass} = $i++ % 2 ? "#eeeeee" : "#ffffff";

    if ($iso->{LOCATIONS} and @{$iso->{LOCATIONS}} > 0) {
      $s{download_location} = Sniglets::Downloads->choose_download_location(@{$iso->{LOCATIONS}});
    }
    else {
      $s{download_location} = "local";
    }

    PXT::Utils->escapeHTML_multi(\%s);

    $ret .= PXT::Utils->perform_substitutions($block, \%s);
  }

  return $ret;
}


# non-tag access to RHN download links
sub rhn_download_url {
  my $class = shift;
  my %params = validate(@_, { pxt => 1, path => 1, label => 1, location => { default => "local" }});

  return ftp_download($params{pxt}, (-location => $params{location}, -path => $params{path}, __block__ => $params{label}));
}

sub download_package {
  my $pxt = shift;
  my %params = validate(@_, { channel => 1, name => 1, __block__ => 1 });

  my $cid = RHN::Channel->channel_id_by_label($params{channel});
  my $channel = RHN::Channel->lookup(-id => $cid);

  my @pkg_ids = map { $channel->latest_package_by_name($_) } split /,\s*/, $params{name};

  my $ret;
  my $expires = time + PXT::Config->get('download_url_lifetime');

  for my $pkg_id (@pkg_ids) {
    my $pkg = RHN::Package->lookup(-id => $pkg_id);
    my $user_id = $pxt->user ? $pxt->user->id : 0;
    my $uri = RHN::TokenGen::Generator->generate_url($user_id, 0, $pkg->path, "/download", "local", $expires, $pxt->ssl_available);
	
    my $copy = $params{__block__};
    $ret .= PXT::Utils->perform_substitutions($copy,
					      { nvre => PXT::HTML->link($uri, join(".", $pkg->nvre, $pkg->arch_label, "rpm")),
						channel => $channel->name, md5sum => $pkg->md5sum });
  }

  return $ret;
}

sub ftp_download {
  my $pxt = shift;
  my %params = validate(@_, { path => 1, location => { default => "local" },
			      __block__ => 1, base_url => { default => "/download" },
			      "file-id" => 0 });
  my $path = $params{path};
  my $location = $params{location};
  my $file_id = $params{"file-id"} || 0;

  if ($path !~ /^local/ and not -e File::Spec->catfile(PXT::Config->get('mount_point'), $path)) {
    warn "Missing file: $path";
    return "<strong>Missing file:</strong> " . (split m(/), $path)[-1];
  }

  my $base_url = $params{base_url};
  my $user_id = $pxt->user ? $pxt->user->id : 0;

  my $label = $params{__block__};
  $label =~ s/^\s*//gms;
  $label =~ s/\s*$//gms;

  my $uri;

  my $expires = time + PXT::Config->get('download_url_lifetime');

  my $require_paid = $file_id ? 1 : 0;
  if ($require_paid and not ($pxt->user and $pxt->user->org->is_paying_customer)) {
    $uri = new URI::URL "/network/software/cannot_download.pxt";
  }
  else {
    $uri = RHN::TokenGen::Generator->generate_url($user_id, $file_id, $path, $base_url, $location, $expires, $pxt->ssl_available);
  }

  my $ret = PXT::HTML->link($uri, $label);

  return $ret;
}

sub akamai_redirect {
  my $pxt = shift;
  my $user_id  =  $pxt->user_id;

  my $file_path = $pxt->param('iso_path');
  my $base_url = $pxt->dirty_param('base_url'); #'/download' probably we need this from akamai
  my $location = $pxt->dirty_param('location');

  my $expires = time + PXT::Config->get('download_url_lifetime');
  my $file_id = RHN::TokenGen::Local->get_file_id($file_path);

  my $redirect_url = RHN::TokenGen::Generator->generate_url($user_id, $file_id, $file_path, $base_url, $location, $expires, $pxt->ssl_available);

  $pxt->redirect($redirect_url); #redirect to new tampa/local url

  return;
}

sub send_partial_file {
  my $fh = shift;
  my $filename = shift;
  my $pxt = shift;
  my $header = $pxt->header_in('Range');
  my $range_start = $header;
  my $range_end = $header;
  my $distance = -1;
  my $chunk;
  $range_start =~ s{bytes=([0-9]*)-([0-9]*)}{$1};
  $range_end =~ s{bytes=([0-9]*)-([0-9]*)}{$2};
  if ($range_start eq $header) {
    $range_start =~ s{bytes=([0-9]*)}{$1};
    $range_end = -1;
  }
  if ($range_end > $range_start) {
    $distance = $range_end - $range_start;
  }
  if ($distance > -1) {
    if ($range_start > 0) {
      seek($fh, 0, $range_start);
    }
    read($fh, $chunk, $distance);
    $pxt->header_out('Content-length' => $distance);
    $pxt->send_http_header;
    $pxt->print($chunk);
  }
  else {
    $pxt->header_out('Content-length' => -s $filename);
    $pxt->send_http_header;
    $pxt->sendfile($filename);
  }
}
1;
