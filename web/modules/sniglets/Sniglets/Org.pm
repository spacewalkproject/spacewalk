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

package Sniglets::Org;

use POSIX qw/strftime/;
use RHN::Channel;
use RHN::API::Types;
use RHN::SatelliteCert;
use Carp;

use RHN::Exception qw/throw/;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:cert_text_cb' => \&cert_text_cb);

}

sub reset_form {
  my $pxt = shift;

    $pxt->session->unset('new_cert_info');
    reset_and_commit_set($pxt->user->id, 'new_cert_channel_set');
    reset_and_commit_set($pxt->user->id, 'new_cert_add_channel_set');
    reset_and_commit_set($pxt->user->id, 'new_cert_service_set');
}

sub reset_and_commit_set {
  my $uid = shift;
  my $label = shift;

  my $set = RHN::Set->lookup(-label => $label, -uid => $uid);
  $set->empty();
  $set->commit();
}

sub get_channel_family_map {
  my $uid = shift;
  my $set_label = shift;

  my @data = RHN::Channel->family_details_from_set($uid, $set_label);

  my $ret;
  foreach my $row (@data) {
    my $label = $row->{LABEL};
    $ret->{$label}->{QUANT} = $row->{ELEMENT_TWO};
    $ret->{$label}->{ID} = $row->{ID};
  } 

  return $ret;
}

sub get_service_map {
  my $uid = shift;

  my @data = RHN::Server->server_group_type_details_from_set($uid, 'new_cert_service_set');

  my $ret;
  foreach my $row (@data) {
    my $label = $row->{LABEL};
    $ret->{$label}->{QUANT} = $row->{ELEMENT_TWO};
    $ret->{$label}->{ID} = $row->{ID};
  } 

  return $ret;
}


sub cert_text_cb {
  my $pxt = shift;

  my $support_org_id = $pxt->param('support_org_id');
  my $action = $pxt->dirty_param('button');

  my $data = $pxt->session->get('new_cert_info');
  my %cert_info;
  if ($data and $data->{'meta_info'}->{'support_org_id'} eq $support_org_id) {
    %cert_info = %{$data};
  }
  else {
    reset_form($pxt);
    croak "No cert data!";
  }
  
  if ($action eq "Back") {
    $pxt->redirect("/internal/support/create_cert.pxt?support_org_id=" . $support_org_id);
  }
}

1;
