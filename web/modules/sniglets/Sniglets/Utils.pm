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

package Sniglets::Utils;
use Data::Dumper;
use PXT::Utils;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-bugzilla-link", \&rhn_bugzilla_link);
  $pxt->register_tag("rhn-redirect", \&rhn_redirect);
}

sub rhn_redirect {
  my $pxt = shift;
  my %params = @_;
  my $url;
  if ($url = $params{'url'}) {
    $pxt->redirect($url);
  }
}

sub rhn_bugzilla_link {
  my $pxt = shift;

  return '' unless $pxt->user and not PXT::Config->get('satellite');

  if (defined $pxt->user->email and $pxt->user->email =~ /(.*?)\@redhat.com$/i) {
    my $ret = '';

    # automagic bugzilla link...
    my $bugzilla_link = "http://bugzilla.redhat.com/bugzilla/enter_bug.cgi?product=Red%20Hat%20Network&amp;version=RHN%20Stable&amp;component=RHN%2FWeb%20Site&amp;component_text=&amp;rep_platform=All&amp;op_sys=Linux&amp;priority=normal&amp;bug_severity=normal&amp;bug_status=NEW&amp;assigned_to=&amp;cc=&amp;estimated_time=0.0&amp;short_desc=&amp;keywords=&amp;dependson=&amp;blocked=&amp;bit-22=1&amp;maketemplate=Remember%20values%20as%20bookmarkable%20template&amp;form_name=enter_bug";


    my $args = $pxt->args() || '';
    my $hostname = $pxt->hostname;
    # If we give an internal web address, replace it with rhn.
    # This is special for the hosted case.
    $hostname =~ s/rhnapp\.vip\.phx/rhn/;
    my $url = 'http://' . $hostname . $pxt->uri;
    my $user = $pxt->user ? $pxt->user->login : undef;

    my $user_info_line = '';
    $user_info_line = "and login as $user" if $user;

    $bugzilla_link .= "&amp;bug_file_loc=" . PXT::Utils->escapeURI($url);;
    $bugzilla_link .= "&amp;comment=" . PXT::Utils->escapeURI(<<EOC);
How Reproducible:

Steps to Reproduce:
1. Go to $url $user_info_line
2.
3.

Actual Results:


Expected Results:


Additional Information:
EOC

    $ret .= <<EOC;
<img src="/img/wrh_bug-grey.gif" alt="Submit Bug Report" />
Something wrong with this page? &#160;Submit a <a href="$bugzilla_link">bug report</a>.
EOC

    return $ret;
  }
  else {
    return '';
  }
}

1;
