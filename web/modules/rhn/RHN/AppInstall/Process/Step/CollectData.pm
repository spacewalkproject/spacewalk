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

package RHN::AppInstall::Process::Step::CollectData;

use strict;

use RHN::AppInstall::Process::Step;
our @ISA = qw/RHN::AppInstall::Process::Step/;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (header => 0,
		    footer => 0,
		    form => { class => 'RHN::Form',
			      optional => 1 },
		    no_cancel => 0,
		   );

sub valid_fields {
  my $class = shift;
  return ($class->SUPER::valid_fields(), %valid_fields);
}

sub get_header {
  my $self = shift;

  return $self->{header};
}

sub set_header {
  my $self = shift;
  my $header = shift;

  $self->{header} = $header;

  return;
}

sub get_footer {
  my $self = shift;

  return $self->{footer};
}

sub set_footer {
  my $self = shift;
  my $footer = shift;

  $self->{footer} = $footer;

  return;
}

sub get_form {
  my $self = shift;

  return $self->{form};
}

sub set_form {
  my $self = shift;
  my $form = shift;

  throw "(set_error) '$form' is not an RHN::Form"
    unless (ref $form and $form->isa('RHN::Form'));

  $self->{form} = $form;

  return;
}

# simple flag to decide to show a 'cancel' button on this page.
sub get_no_cancel {
  my $self = shift;

  return $self->{no_cancel};
}

sub set_no_cancel {
  my $self = shift;
  my $no_cancel = shift;

  $self->{no_cancel} = $no_cancel;

  return;
}

1;
