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
use PXT::Config;

package RHN::TokenGen::Generator;

sub generate_url {
  my $clazz = shift(@_);
  my $user_id  = shift(@_);
  my $file_id  = shift(@_);
  my $path     = shift(@_);
  my $base_url = shift(@_);
  my $location = shift(@_);
  my $expires = shift(@_);
  my $ssl_available = shift(@_);

  my $module = PXT::Config->get("${location}_token_gen");

  die "no valid token module for location $location"
    unless (defined $module);

  eval "require $module;";

  if ($@) {
    my $E = $@;
    die "CRITICAL ERROR:  token generation problem:  $E";
  }

  return $module->generate_url($user_id, $file_id, $path, $base_url, $location, $expires, $ssl_available);
}

1;

