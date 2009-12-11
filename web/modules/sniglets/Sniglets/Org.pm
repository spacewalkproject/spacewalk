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

  $pxt->register_tag('rhn-cert-text' => \&cert_text);
  $pxt->register_tag('rhn-org-entitlement-name' => \&org_entitlement_name, -5);
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

sub org_entitlement_name {
  my $pxt = shift;
  my %attr = @_;

  my $slot = $attr{type};

  throw "No type in call to org_entitlement_name"
    unless $slot;

  my $block = $attr{__block__} || '{entitlement}';

  $block = PXT::Utils->perform_substitutions($block, { entitlement => $pxt->user->org->slot_name($slot) });

  return $block;
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


sub render_channel_rows {
  my $channels = shift;
  my $prefix = shift;
  my $render_zero_quant = shift;
  my $counter = 1;
  my $ret = "";

  foreach my $label (sort keys %{$channels}) {
    $counter++;
    my $row_class = ($counter % 2) ? "list-row-even" : "list-row-odd";
    my $quant = $channels->{$label}->{QUANT};
    my $id = $channels->{$label}->{ID};
    if ($render_zero_quant or $quant > 0) {
      $ret .= "<tr class=\"" . $row_class . "\"><td>" . $label . "</td><td align=\"center\">" . $quant . "</td><td align=\"center\">";
      if ($label eq 'rhn-tools') {
        $ret .= "$quant\n";
        $ret .= "<input type=\"hidden\" name=\"" . $prefix . "_" . $id . "_quant\" value=\"" . $quant . "\"/>\n";
      }
      else {
        $ret .= "<input size=\"5\" type=\"text\" name=\"" . $prefix . "_" . $id . "_quant\" value=\"" . $quant . "\"/>\n";
      }
      $ret .= "<input type=\"hidden\" name=\"" . $prefix . "\" value=\"$id\"/>";
      $ret .= "<input type=\"hidden\" name=\"" . $prefix . "_" . $id . "_label\" value=\"" . $label . "\"/>\n";
      $ret .= "<input type=\"hidden\" name=\"" . $prefix . "_" . $id . "_oldquant\" value=\"" . $quant . "\"/>\n";
      $ret .= "</td></tr>\n";
    }
  }

  return $ret;
}

# render the page that lets user view cert data
sub cert_text {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $support_org_id = $pxt->param('support_org_id');
  my $data = $pxt->session->get('new_cert_info');
  my %cert_info;
  if ($data and $data->{'meta_info'}->{'support_org_id'} eq $support_org_id) {
    %cert_info = %{$data};
  }
  else {
    reset_form($pxt);
    croak "No cert data!";
  }

  my %subs;
  $subs{support_org_id} = $support_org_id;

  # do the opening and meta info
  my $cert_text = create_cert_text($pxt, \%cert_info);
 
  $cert_text=~s/>/&gt;/g;
  $cert_text=~s/</&lt;/g;
  $subs{cert_text} = $cert_text;
  $block = PXT::Utils->perform_substitutions($block, \%subs);
  return $block;
}
 
# create the actual cert xml given the cert_info session data
sub create_cert_text {
  my $pxt = shift;
  my $data = shift;
  my %cert_info = %{$data};

  my $cert = new RHN::SatelliteCert;

  my $owner = $cert_info{meta_info}->{owner};
  my $issued = $cert_info{meta_info}->{issued};
  my $expires = $cert_info{meta_info}->{expires};
  
  $cert->set_field(product => "RHN-SATELLITE-001");
  $cert->set_field(owner => $owner);
  $cert->set_field(issued => $issued);
  $cert->set_field(expires => $expires);
  $cert->set_field('generation', RHN::SatelliteCert->current_generation());
 
  my $existing_channels = get_channel_family_map($pxt->user->id, 'new_cert_channel_set');
  foreach my $label (sort keys %{$existing_channels}) {
    my $quant = $existing_channels->{$label}->{QUANT};
    if ($quant > 0) {
      $cert->set_channel_family($label, $quant);
    }
  }

  my $additional_channels = get_channel_family_map($pxt->user->id, 'new_cert_add_channel_set');
  foreach my $label (sort keys %{$additional_channels}) {
    my $quant = $additional_channels->{$label}->{QUANT};
    if ($quant > 0) {
      $cert->set_channel_family($label, $quant);
    }
  }

  my %slot_names = (
    'enterprise_entitled'   => 'slots',
    'provisioning_entitled' => 'provisioning-slots',
    'nonlinux_entitled'     => 'nonlinux-slots',
    'monitoring_entitled'   => 'monitoring-slots');


  my $services = get_service_map($pxt->user->id);
  foreach my $label (sort keys %{$services}) {
    my $quant = $services->{$label}->{QUANT};
    # logic per bz #132461 and bz #164662
    if ($label eq 'enterprise_entitled' and $cert_info{'meta_info'}->{'version'} < 4.0) {
      $quant += $services->{'provisioning_entitled'}->{QUANT};
    }
    if ($quant > 0) {
      my $slot_name = $slot_names{$label};
      $cert->set_field($slot_name => $quant);
    }
  }

  $cert->set_field("satellite-version" => $cert_info{'meta_info'}->{'version'});

  return $cert->to_string();
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

sub download_cert {
  my $pxt = shift;
  my $data = shift;
  my %cert_info = %{$data};

  $pxt->manual_content(1);
  $pxt->content_type('application/octet-stream');

  my $filename = $cert_info{'meta_info'}->{'owner'} . ".cert";
  $filename =~s/ /-/g;
  $filename = lc($filename);

  $pxt->header_out('Content-disposition', "attachment; filename=" . $filename);

  # better mime type to force download of plain text?
  $pxt->send_http_header;
  $pxt->print (create_cert_text($pxt, \%cert_info));
}

1;
