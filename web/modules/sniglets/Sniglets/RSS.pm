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

package Sniglets::RSS;

use RHN::Errata;

use Cache::FileCache;
use XML::RSS;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-rss-recent-errata' => \&rss_recent_errata);
}

sub rss_recent_errata {
  my $pxt = shift;
  my %params = @_;

  $pxt->content_type("text/xml");

  my $num = 10;

  my $cache = new Cache::FileCache({namespace => 'rhn_recent_errata'});

  # if the cache is less than 7200 seconds old, return it, no questions
  # asked

  my $cached_errata_mtime = $cache->get("cached_errata_mtime");

  if ($cached_errata_mtime and time - $cached_errata_mtime < 7200) {
    return $cache->get('cached_errata_rss');
  }

  my @errata = RHN::Errata->rss_recent_errata($num);

  my $rss = new XML::RSS(version => '0.91');

  $rss->channel(title => "Red Hat Errata",
		link => "http://www.redhat.com/apps/support/errata/",
		description => "The latest Red Hat errata for Red Hat Linux");

  foreach my $e (@errata) {
    $e->{advisory} =~ m/^(.*?):(.*?)-(.*?)$/;
    my $advisory = "$1-$2.html";

    my @affected_prod_lines = RHN::Errata->affected_product_lines($e->{id});
    my @cves = RHN::Errata->related_cves($e->{id});
    my $affected_prod_str = @affected_prod_lines ? join(',', @affected_prod_lines) . ':  ' : '';
    my $cve_str = @cves ? ' ' . join(", ", @cves) : '';

    my $description = "${affected_prod_str}$e->{topic}${cve_str}";

    $rss->add_item(title => "$e->{advisory}: $e->{synopsis}",
		   link => qq{http://rhn.redhat.com/errata/$advisory},
                   description => PXT::Utils->escapeHTML($description));
  }

  my $ret = $rss->as_string();

  $cache->set(cached_errata_rss => $ret);
  $cache->set(cached_errata_mtime => time);

  return $ret;
}

1;
