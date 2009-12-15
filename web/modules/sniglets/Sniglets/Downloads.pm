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
use RHN::Channel;

use File::Spec;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-ftp-download', \&ftp_download, 4);
  $pxt->register_tag('rhn-download-package', \&download_package, 1);
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

1;
