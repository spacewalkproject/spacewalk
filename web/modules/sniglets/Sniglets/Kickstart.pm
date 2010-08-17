#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
package Sniglets::Kickstart;

use PXT::Utils;
use File::Spec;
use File::stat;
use Digest::MD5;
use HTTP::Date;

use RHN::KSTree;
use RHN::Kickstart;
use RHN::TinyURL;
use RHN::Kickstart::Session;
use RHN::SessionSwap;

use RHN::DataSource::Package;
use RHN::DataSource::General;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-kickstart-tinyurl' => \&tiny_url_handler);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;
}

sub tiny_url_handler {
  my $pxt = shift;

  my (undef, $tu, @rest) = split m(/), $pxt->path_info;

  my $stored_url = RHN::TinyURL->lookup(-token => $tu);
  $pxt->redirect("/errors/404.pxt") unless $stored_url;

  my $final_url = join("/", $stored_url, @rest);
  $pxt->manual_content(1);
  $pxt->internal_redirect($final_url);
}


1;
