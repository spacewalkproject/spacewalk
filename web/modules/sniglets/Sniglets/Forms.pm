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

package Sniglets::Forms;

use File::Spec;
use Digest::MD5;

use RHN::Form;
use RHN::Form::Parser;
use RHN::Form::ParsedForm;
use Sniglets::Forms::Style;

use PXT::Utils;

use PXT::ACL;

sub load_params {
  my $pxt = shift;
  my $form = shift;

  my @needed_params = $form->widget_labels;

  my %params;

  foreach my $param (@needed_params) {
    my @results = $pxt->passthrough_param($param);

    if (@results > 1) {
      $params{$param} = \@results;
    }
    else {
      $params{$param} = $results[0];
    }
  }

  my $errors = $form->accept_params(\%params);

  return $errors;
}

1;
