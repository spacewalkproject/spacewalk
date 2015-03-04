#
# Copyright (c) 2008--2012 Red Hat, Inc.
# Copyright (c) 2010 SUSE LINUX Products GmbH, Nuernberg, Germany.
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

package Sniglets::Errata;

use Carp;
use File::Spec;

use RHN::Access;
use RHN::Errata;
use RHN::ErrataTmp;
use PXT::Utils;
use PXT::HTML;
use RHN::Exception;

use RHN::Date ();

sub register_tags {
  my $class = shift;
  my $pxt = shift;
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

}


my %e_icons = ('Security Advisory' => { image => '/img/rhn-icon-security.gif',
                                        white => '/img/wrh_security-white.gif',
                                        grey => '/img/wrh_security-grey.gif',
                                        alt => 'Security Advisory' },
             'Enhancement Advisory' => { image => '/img/rhn-icon-enhancement.gif',
                                         white => "/img/wrh_feature-white.gif",
                                         grey => "/img/wrh_feature-grey.gif",
                                         alt => "Enhancement Advisory" },
             'Product Enhancement Advisory' => { image => '/img/rhn-icon-enhancement.gif',
                                                 white => "/img/wrh_feature-white.gif",
                                                 grey => "/img/wrh_feature-grey.gif",
                                                 alt => "Enhancement Advisory" },
              'Bug Fix Advisory' => { image => '/img/rhn-icon-bug.gif',
                                      white => "/img/wrh_bug-white.gif",
                                      grey => "/img/wrh_bug-grey.gif",
                                      alt => "Bug Fix Advisory" } );


1;
