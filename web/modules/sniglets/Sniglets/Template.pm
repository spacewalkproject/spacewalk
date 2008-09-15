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

package Sniglets::Template;

use RHN::Exception qw/throw/;

use RHN::TemplateString;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-template-replace", \&template_replace);
  $pxt->register_tag("rhn-template-block", \&template_block);

}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

}

sub template_replace {
  my $pxt = shift;
  my %params = @_;

  unless (PXT::Config->get('satellite')) {
    return $params{__block__};
  }

  my $label = $params{label};

  throw "No label." unless $label;

  return RHN::TemplateString->get_string(-label => $label);
}

sub template_block {
  my $pxt = shift;
  my %params = @_;

  unless (PXT::Config->get('satellite')) {
    return '';
  }

  my %subst = RHN::TemplateString->load_all;

  PXT::Utils->escapeHTML_multi(\%subst);
  return PXT::Utils->perform_substitutions($params{__block__}, \%subst);
}

1;
