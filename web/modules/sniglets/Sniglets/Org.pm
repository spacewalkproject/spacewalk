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
use HTTP::Date qw(time2str str2time);
use RHN::Channel;
use RHN::API::Types;
use RHN::SatelliteCert;
use Carp;

use RHN::Exception qw/throw/;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-cert-info' => \&cert_info);
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

sub cert_info {

  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $support_org_id = $pxt->param('support_org_id');
  if (not $support_org_id) {
    reset_form($pxt);
    croak "No org id provided!";
  }

  my $org = RHN::Org->lookup(-id => $support_org_id);

  my $data = $pxt->session->get('new_cert_info');

  my %cert_info;

  # use the data we've got in the session if it's there
  if ($data and $data->{'meta_info'}->{'support_org_id'} eq $org->id) {

    %cert_info = %{$data};

    # overwrite the cert owner name with the correct name from web_user_personal_info
    $cert_info{'meta_info'}->{'owner'} = RHN::Org->lookup_company_name($support_org_id);

  }
  else {
    reset_form($pxt); # blank slate

    # initialize our vars from the db
    $cert_info{'meta_info'}->{'support_org_id'} = $org->id;

    # set the cert owner name with the correct name from web_user_personal_info
    $cert_info{'meta_info'}->{'owner'} = RHN::Org->lookup_company_name($support_org_id);

    # grab the latest version
    my @versions = RHN::Channel->satellite_channel_versions;
    my $ver = pop @versions;
    $cert_info{'meta_info'}->{'version'} = $ver;
    $cert_info{'meta_info'}->{'issued'} = HTTP::Date::time2str(time());
    $cert_info{'meta_info'}->{'expires'} = HTTP::Date::time2str($org->calc_cert_expiration);

    # services
    my $ent_data = $org->entitlement_data;
    my @ent_keys = keys %{$ent_data};

    my $service_set = RHN::Set->lookup(-label => 'new_cert_service_set', -uid => $pxt->user->id);
    my $service_id_map_ref = RHN::Server->server_group_type_ids_by_label();

    my $prov_quant = 0;
    foreach my $ent (sort @ent_keys) {
      if ($ent ne 'sw_mgr_entitled') {
        my $total = $ent_data->{$ent}->{max};
        $service_set->add( [ $service_id_map_ref->{$ent}, $total] );
        if ($ent eq 'provisioning_entitled') {
          $prov_quant = $total;
        }
      }
    }
    $service_set->commit();

    # channels
    my $rec;
    my %channel_quantities;
    my $channel_set = RHN::Set->lookup(-label => 'new_cert_channel_set', -uid => $pxt->user->id);
    my $rhn_slots_id = 0;
    foreach $rec ($org->ent_cert_channels) {
      my ($cid, $name, $label, $quant) = @$rec;
      if ($quant and $quant > 0) {
        $channel_set->add([$cid, $quant]);
	    }
    }

    # always make sure that rhn-tools is among the channel families.
    # quantity for rhn-tools is always the same # as provisioning 
    # entitlements.
    my $rhn_tools = RHN::Channel->family_details_by_label('rhn-tools');
    my $additional_channel_set = RHN::Set->lookup(-label => 'new_cert_add_channel_set', -uid => $pxt->user->id);
    my %contents = $channel_set->output_hash;
    if ( exists $contents{$rhn_tools->{ID}} ) {
       $channel_set->add([$rhn_tools->{ID}, $prov_quant]);
    }
    else {
       $additional_channel_set->add([$rhn_tools->{ID}, $prov_quant]);
    }
    $channel_set->commit();
    $additional_channel_set->commit();

    $pxt->session->set('new_cert_info', \%cert_info);
  }

  # do our substitutions
  my %subs;

  $subs{'support_org_id'} = $cert_info{'meta_info'}->{'support_org_id'};
  $subs{'owner'}          = $cert_info{'meta_info'}->{'owner'};

  my @possible_versions;
  foreach my $ver (RHN::Channel->satellite_channel_versions) {
    push @possible_versions, [ $ver, $ver, $ver eq $cert_info{'meta_info'}->{'version'} ? 1 : 0];
  }
  $subs{'version'} = PXT::HTML->select(-name => "version",
                          -options => \@possible_versions);

  $subs{'issued'}         = $cert_info{'meta_info'}->{'issued'};
  $subs{'expires'}        = $cert_info{'meta_info'}->{'expires'};

  my $counter = 1;

  my $services = get_service_map($pxt->user->id);
  my $servicetable = "";

  foreach my $label (sort keys %{$services}) {
    $counter++;
    my $total = $services->{$label}->{QUANT};
    my $id = $services->{$label}->{ID};
    my $row_class = ($counter % 2) ? "list-row-even" : "list-row-odd";
    $servicetable .= "<tr class=\"" . $row_class . "\">\n";
    $servicetable .= "  <td>" . $label . "</td>\n";
    $servicetable .= "  <td align=\"center\">" .  $total . "</td>\n";
    $servicetable .= "  <td align=\"center\">\n";
    $servicetable .= "    <input size=\"5\" type=\"text\" name=\"service_" . $id . "_quant\" value=\"" .  $total . "\"/>\n";
    $servicetable .= "    <input type=\"hidden\" name=\"service\" value=\"" . $id . "\"/>\n";
    $servicetable .= "    <input type=\"hidden\" name=\"service_" . $id . "_oldquant\" value=\"" . $total . "\"/>\n";
    $servicetable .= "  </td>\n";
    $servicetable .= "</tr>\n";
  }
  $subs{services} = $servicetable;


  my $existing_channels = get_channel_family_map($pxt->user->id, 'new_cert_channel_set');
  $subs{channels} = render_channel_rows($existing_channels, "chanid", 1);

  my $additional_channels = get_channel_family_map($pxt->user->id, 'new_cert_add_channel_set');
  my $addchantable = "";

  $addchantable = "<tr><td colspan=\"3\" align=\"center\">none</td></tr>" unless
    ($pxt->dirty_param('add_channel') or keys %{$additional_channels});

  $addchantable .= render_channel_rows($additional_channels, "addchanid", 0);

  # add row for entering channel manually
  if ($pxt->dirty_param('add_channel')) {
    my $add_channel_id = $pxt->dirty_param('add_channel_id');
    if( not $add_channel_id ) {
      $add_channel_id = "";
    }

    # we create an option list of available channels,
    # but we don't want to list the ones already
    # entitled or manually added
    my %skip_chan = ();
    for (keys %{$existing_channels}) { 
      $skip_chan{$_} = 1;
    }
    for (keys %{$additional_channels}) { 
      $skip_chan{$_} = 1;
    }

    my @possible_channels;

    foreach my $rec ($org->available_cert_channels) {
      my ($id, $name, $label) = @$rec;
      if (not $skip_chan{$label}) {
        push @possible_channels, 
          [ $label , $id, $id eq $add_channel_id ? 1 : 0 ];
      }
    }

    my @chankeys = keys %{$additional_channels};
    my $row_class = (($#chankeys + 1) % 2) ? "list-row-even" : "list-row-odd";
    $addchantable .= "<tr class=\"" . $row_class . "\"><td>";
    $addchantable .= PXT::HTML->select(-name => "newchannel",
                            -options => \@possible_channels);

    $addchantable .= "  </td><td align=\"center\">0</td><td align=\"center\">";
    $addchantable .= "<input size=\"5\" type=\"text\" name=\"newchannel_quant\" value=\"0\"/>\n";
    $addchantable .= "</td></tr>\n";
  }

  $subs{additional_channels} = $addchantable;

  $block = PXT::Utils->perform_substitutions($block, \%subs);
  return $block;

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
