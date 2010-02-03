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

package Sniglets::ListUtils;
use PXT::Utils;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-fix-list", \&fix_list, 30);
}

#  if a list is empty, render a message.
#  paginator should set up the pnote automagically I think.
sub fix_list {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $total = $pxt->pnotes("$params{list_type}_total");

  if (!defined $total) {
    die "can't find $params{list_type}_total pnote!";
  }
  elsif ($total <= 0) {
    $block =~ m{<empty_list_mesg>(.*?)</empty_list_mesg>}igsm;
    my $empty_mesg = $1;
    return $empty_mesg;
  }

  $block =~ s{<empty_list_mesg>.*?</empty_list_mesg>}{}gism;
  $block =~ s(<a href=[^>]*>0</a>)(0)g;

  return $block;
}

1;
