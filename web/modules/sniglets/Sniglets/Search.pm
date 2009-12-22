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
package Sniglets::Search;

use Sniglets::Packages;

use RHN::Search;
use RHN::SearchTypes;
use RHN::Server;
use RHN::Exception;
use PXT::Utils;

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:package_search_handler' => \&package_search_handler);
}

sub validate_search_string {
  my $class = shift;
  my $pxt = shift;
  my $search = shift;
  my $search_string = shift;

  if ($search_string =~ /[^-a-zA-Z0-9_.]/) {
    $pxt->push_message(local_alert => 'Search strings must contain only letters, numbers, hyphens and dashes.');
    return;
  }

  if (length $search_string < 2) {
    $pxt->push_message(local_alert => 'Search strings must be longer than two characters.');
    return;
  }

  if ($search) {
    my $result = $search->valid_search_string($search_string);

    # returned value is error message to display, or undef/emptystring
    # if there are no errors

    if ($result) {
      $pxt->push_message(local_alert => $result);
      return;
    }
  }

  $pxt->pnotes(searched => 1);
}

my @integer_types = qw/search_id search_cpu_mhz_lt search_cpu_mhz_gt search_ram_lt search_ram_gt search_checkin search_registered/;

#################################
# Package Searching
#################################

my $package_searches = new RHN::SearchType;
$package_searches->add_mode(simple_package_search => "Name and Summary", 'Summary');
$package_searches->add_mode(package_search_by_name => "Name Only", 'Summary');
$package_searches->set_name('package_search');

RHN::SearchTypes->register_type('package', $package_searches);

sub package_search_handler {
  my $pxt = shift;

  my $search = RHN::SearchTypes->find_type('package');
  my $selected = new RHN::DB::Set $search->set_name, $pxt->user->id;
  $selected->empty;
  $selected->commit;

  my $search_string = $pxt->dirty_param('search_string') || '';
  my $search_mode = $pxt->dirty_param('view_mode') || $search->default_search_type;

  my @arch_labels;
  for my $arch (qw/ia32 ia64 x86_64/) {
    push @arch_labels, "channel-$arch"
      if $pxt->dirty_param("channel_arch_$arch");
  }

  my $smart_search = $pxt->dirty_param('search_subscribed_channels');

  if (not $smart_search and not @arch_labels) {
    $pxt->push_message(local_alert => 'You must choose at least one architecture, or to search relevant channels.');
    return;
  }

  if ($smart_search and @arch_labels) {
    $pxt->push_message(local_alert => 'Either do a smart search -or- an arch search, not both.');
    return;
  }

  if (Sniglets::Search->validate_search_string($pxt, $search, $search_string)) {
    RHN::Search->package_search($pxt->user, $search_mode, $search_string, \@arch_labels, $smart_search);
  }
}

# Utility functions

sub strip_rpm_extensions { #strips the extensions off of an rpm file name
#e.g. 'kernel-2.2-19.i686.rpm' becomes 'kernel-2.2-19'

  my $string = shift;

  my @archs = sort { length($b) <=> length($a) } RHN::Package->valid_package_archs;
  my $rxp = join "|", map { ".$_" } @archs, 'rpm';
  $rxp = qr/$rxp/;
  $string =~ s/$rxp//g;

  return $string;

}

sub strip_invalid_chars {
  my $class = shift;
  my $search_string = shift;
  my $view_mode = shift;

  if ($view_mode =~ /package/) {
    $search_string = strip_rpm_extensions($search_string);
  }

  if (grep { $view_mode eq $_ } @integer_types) {
    $search_string =~ s/\D//g;
  }

  return $search_string;
}

1;
