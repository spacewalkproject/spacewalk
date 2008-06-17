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
package Cypress::Slashdot;
use Grail::Component;

use LWP::UserAgent;
use HTTP::Request;

@Cypress::Slashdot::ISA = qw/Grail::Component/;

my @component_modes =
  (
   [ 'nav_canvas', 'slashdot_headlines', 'Slashdot Headlines', undef ],
   [ 'main_canvas_partial', 'slashdot_headlines', 'Slashdot Headlines', undef ],
  );

sub component_modes {
  return @component_modes;
}

sub slashdot_headlines {
  my $self = shift;
  my $pxt = shift;
  my %params = @_;
  my $num = $params{num} || 100;

  my $ua = new LWP::UserAgent;
  my $req = new HTTP::Request GET => "http://minbar.devel.redhat.com/network/slashdot.rdf";
  my $response = $ua->request($req);

  if ($response->is_success) {
    my $rdf = $response->content;

    my @bullets;
    my @items = $rdf =~ m(<item>(.*?)</item>)gsm;

    $#items = $num - 1 if $#items > $num - 1;

    foreach my $item (@items) {
      my ($title) = $item =~ m(<title>(.*?)</title>)gms;
      my ($link) = $item =~ m(<link>(.*?)</link>)gms;

      push @bullets, qq{<A HREF="$link">$title</A>};
    }

    return "<UL>" . join("", map { "<LI>$_</LI>\n" } @bullets) . "</UL>";
  }
  else {
    return "<pre>Error reading from slashdot: " . $response->status_line . "</pre>\n";
  }
}

1;
