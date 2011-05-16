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

package RHN::I18N;

use strict;

use XML::LibXML 1.53;
use Time::HiRes;

# are xml catalogs available?  I bet they are.  so let's use them for entity references.
my $parser;
if (-e "/etc/xml/catalog") {
  $parser = new XML::LibXML ext_ent_handler => sub { return "<!-- -->"; };
}
else {
  $parser = new XML::LibXML;
  $parser->load_catalog("/etc/xml/catalog");
}

sub translate {
  my $class = shift;
  my $input = shift;

  $input =~ s/\A\s+//gms;
  my $then = Time::HiRes::time;
  my $doc = eval { $parser->parse_string($input) };

  if (not $doc) {
    warn "I18N XML Parsing failed: $@";
    return $input;
  }

  $then = Time::HiRes::time;

  my @todo;
  push @todo, $doc->documentElement();

  while (@todo) {
    my $node = shift @todo;
    push @todo, $node->childNodes();
    if (ref $node eq 'XML::LibXML::Text') {
      my $text = $node->data;
#      $text =~ s#([a-z])([a-z]+)#$2\L$1ay#gi;
      $node->setData($text);
    }
  }

  $doc->setEncoding("UTF-8");
  return $doc->toString(0);
}


# an alternate node walk; this seems slower
#  my $iter = new XML::LibXML::Iterator($doc);
#  while ($iter->next) {
#    my $node = $iter->current;
#    if (ref $node eq 'XML::LibXML::Text') {
#      $node->setData(scalar reverse $node->data);
#    }
#  }


1;
