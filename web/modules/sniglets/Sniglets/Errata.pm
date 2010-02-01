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

package Sniglets::Errata;

use Carp;
use Data::Dumper;
use File::Spec;

use RHN::Access;
use RHN::Errata;
use RHN::ErrataTmp;
use PXT::Utils;
use PXT::HTML;
use Sniglets::Downloads;
use RHN::Exception;


sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-errata-details' => \&errata_details);

  $pxt->register_tag('rhn-errata-name' => \&errata_name, 2);
  $pxt->register_tag('rhn-errata-advisory' => \&errata_advisory, 2);
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


sub errata_name {
  my $pxt = shift;

  my $errata = $pxt->pnotes('errata');
  return $$errata->synopsis if $errata;

  my $eid = $pxt->param('eid');
  return "no errata" unless $eid;

  $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  die "no valid errata" unless $errata;

  $pxt->pnotes(errata => \$errata);
  return $errata->synopsis;
}

sub errata_advisory {
  my $pxt = shift;

  my $errata = $pxt->pnotes('errata');
  return $$errata->advisory if $errata;

  my $eid = $pxt->param('eid');
  return "no errata" unless $eid;

  $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  die "no valid errata" unless $errata;

  $pxt->pnotes(errata => \$errata);
  return $errata->advisory;
}

sub errata_details {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $errata_id = $pxt->param('eid');
  my $advisory = $pxt->param('adv');

  if ($advisory) {
    my ($type, $version, $release) = split /-/, $advisory;

    unless ($type and $version) {
      throw "advisory ($advisory) did not contain type and version info";
    }

    my @errata = RHN::Errata->find_by_advisory(-type => $type,
					       -version => $version,
					       -release => $release);

    if ($release and @errata > 1) {
      die "specific errata $advisory asked for, but returned multiple (@errata)";
    }
    # there's only one, take it, or, returned list of matching errata.
    # take the first one, since it is in order of descending date

    my $id = $errata[0]->[0];

    # redirect so that formvars are right for rest of page to render
    $pxt->redirect("/network/errata/details/Details.do?eid=$id");
  }

  my $e;

  eval {
    $e = RHN::ErrataTmp->lookup_managed_errata(-id => $errata_id);
  };

  $pxt->redirect("/errors/404.pxt")
    unless $e;

  $pxt->pnotes(errata => \$e);

  my $icon = "";
  my $icon_file = "";
  if (exists $e_icons{$e->advisory_type}) {
    my $data = $e_icons{$e->advisory_type};
    $icon = PXT::HTML->img(-src => $data->{image},
			   -alt => $data->{alt},
			   -title => $data->{alt},
			   -class => 'errata-details');
    $icon_file = $data->{image};
  }

  my @cves = $e->related_cves;

  my %subst;
  my $no_data = '<span class="no-details">(none)</span>';

  $subst{errata_id} = $e->id;
  $subst{errata_advisory_id} = PXT::Utils->escapeHTML($e->advisory);
  $subst{errata_advisory_type} = defined $e->advisory_type ? PXT::Utils->escapeHTML($e->advisory_type) : $no_data;
  $subst{errata_advisory_name} = defined $e->advisory_name ? PXT::Utils->escapeHTML($e->advisory_name) : $no_data;
  $subst{errata_synopsis} = defined $e->synopsis ? PXT::Utils->escapeHTML($e->synopsis) : $no_data;
  $subst{errata_description} = defined $e->description ? PXT::HTML->htmlify_text($e->description) : $no_data;
  $subst{errata_product} = defined $e->product ? $e->product : $no_data;
  $subst{errata_icon} = $icon;
  $subst{errata_icon_file} = $icon_file;
  $subst{errata_topic} = defined $e->topic ? PXT::HTML->htmlify_text($e->topic) : $no_data;
  $subst{errata_solution} = defined $e->solution ? PXT::HTML->htmlify_text($e->solution) : $no_data;
  $subst{errata_references} = defined $e->refers_to ? PXT::HTML->htmlify_text($e->refers_to) : $no_data;
  $subst{errata_notes} = defined $e->notes ? PXT::HTML->htmlify_text($e->notes) : $no_data;

  $subst{errata_issue_date} = RHN::Date->new(string => $e->issue_date, user => $pxt->user)->short_date;
  $subst{errata_update_date} = RHN::Date->new(string => $e->update_date, user => $pxt->user)->short_date;

  $subst{errata_cves} = @cves ? join("<br />\n", map { PXT::HTML->link("http://cve.mitre.org/cgi-bin/cvename.cgi?name=$_", $_) } @cves) : $no_data;

  my $i = 0;
  my $bugs_fixed = '<table border="0" cellspacing="0" cellpadding="2">';
  foreach my $bug ($e->bugs_fixed) {
    $i = 1;
    $bugs_fixed .= '<tr valign="middle"><td><a href="https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id='.$bug->[0].'">' . PXT::Utils->escape_html($bug->[1])  . "</a></td></tr>";
  }
  $bugs_fixed .= "</table>";
  $subst{errata_bugs_fixed} = $i eq 1 ? $bugs_fixed : $no_data;
  my @keywords = $e->keywords;
  $subst{errata_keywords} = @keywords ? join(", ", @keywords) : $no_data;


  my @files = $e->rhn_files_overview($pxt->user->org_id);
  my $verification_info = '<table border="0" cellspacing="0" cellpadding="2">';
  $i = 0;
  my $last_channel;

  foreach my $file (@files) {
    $i = 1;
    my $file_name = $file->{FILENAME};

    if ($file->{CHANNEL_NAME} and (!defined $last_channel or ($file->{CHANNEL_NAME} ne $last_channel))) {
      $verification_info .= '<tr><td colspan="2"><strong>' . ($last_channel ? "<br />" : '') . $file->{CHANNEL_NAME} . ":</strong></td></tr>";
      $last_channel = $file->{CHANNEL_NAME};
    }

    my $md5sum = $file->{MD5SUM};
    my $name = (split /[\/]/, $file->{FILENAME})[-1];

    my $pid = $file->{PACKAGE_ID} || undef;
    if ($pid) {
      $name = sprintf('<a href="/rhn/software/packages/Details.do?pid=%d">%s</a>', $pid, $name);
    }

    $verification_info .= sprintf('<tr valign="middle"><td align="left"><tt>%s</tt></td><td>%s</td></tr>', $md5sum, $name);
  }

  $verification_info .= "</table>";
  $subst{errata_verification} = $i eq 1 ? $verification_info : $no_data;

  my @affected_channels;
  @affected_channels = $e->affected_channels($pxt->user->org_id);
  my $channel_list = "<table>";
  $i = 0;

  foreach my $channel (@affected_channels) {
    $i = 1;
    $channel_list .= '<tr><td><a href="/network/software/channels/packages.pxt?cid='.$channel->[0].'">' . $channel->[1]  . "</a></td></tr>";
  }
  $channel_list .= "</table>";

  $subst{errata_affected_channels} = $i == 1 ? $channel_list : $no_data;

  return PXT::Utils->perform_substitutions($block, \%subst);
}

1;
