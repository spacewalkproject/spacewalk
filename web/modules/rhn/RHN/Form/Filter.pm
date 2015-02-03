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

package RHN::Form::Filter;

use strict;

use RHN::Exception qw/throw/;

my %filters = (text => \&text_filter,
               password => \&password_filter,
               valid_option_filter => \&valid_option_filter,
               remove_blanks => \&remove_blanks_filter,
              );

sub text_filter {
  my $widget = shift;
  my $text = shift || '';

  return PXT::Utils->escapeHTML($text);
}

sub password_filter {
  my $widget = shift;
  my $text = shift || '';

  $text =~ s/\s*(.*)\s*/$1/; #

  return $text;
}

sub valid_option_filter {
  my $widget = shift;
  my $text = shift || '';

  throw "Widget '" . $widget->label . "' is not a valid widget for the valid_option_filter."
    unless (ref $widget and $widget->can('options'));

  return $text if grep { $text eq $_->{value} } $widget->options;

  return;
}

sub remove_blanks_filter {
  my $widget = shift;
  my $text = shift || '';

  $text =~ s/^\s*(.*)\s*$/$1/;

  return $text;
}

sub lookup_filter {
  my $widget = shift;
  my $label = shift;

  throw "Unknown filter '$label'."
    unless exists $filters{$label};

  return $filters{$label};
}
