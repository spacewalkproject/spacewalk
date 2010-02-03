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

package Sniglets::Packages;

use Carp;

use PXT::HTML;
use RHN::Package;
use RHN::Utils;
use RHN::Form;
use Sniglets::ListView::PackageList;

use RHN::Exception qw/throw/;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-lookup-package-nvre' => \&lookup_package_nvre);

  $pxt->register_tag('rhn-package-dependencies' => \&package_dependencies);

  $pxt->register_tag('rhn-package-details' => \&package_details);
  $pxt->register_tag('rhn-package-change-log' => \&package_change_log);


  $pxt->register_tag('rhn-unknown-package-nvre' => \&unknown_package_nvre);

  $pxt->register_tag('rhn-upload-answerfile-form' => \&upload_answerfile_form);

  $pxt->register_tag('rhn-package-raw-pkgmap' => \&raw_pkgmap);
  $pxt->register_tag('rhn-package-raw-readme' => \&raw_readme);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:sscd_confirm_patch_installations' => \&sscd_confirm_package_installations_cb);
  $pxt->register_callback('rhn:sscd_confirm_patchset_installations' => \&sscd_confirm_package_installations_cb);
  $pxt->register_callback('rhn:sscd_confirm_patch_removals' => \&sscd_confirm_package_removals_cb);

  $pxt->register_callback('rhn:upload-answerfile-cb' => \&upload_answerfile_cb);
}

sub unknown_package_nvre {
  my $pxt = shift;
  my %params = @_;

  my $id_combo = $pxt->dirty_param('id_combo');
  die "no id_combo" unless $id_combo;

  my ($name_id, $evr_id) = split /[|]/, $id_combo;
  return RHN::Package->lookup_nvre($name_id, $evr_id);
}


sub lookup_package_nvre {
  my $pxt = shift;
  my %params = @_;

  my ($name_id, $evr_id) = map { $pxt->dirty_param($_) } qw/name_id evr_id/;

  PXT::Debug->log(7, "looking up package with name_id == $name_id, evr_id == $evr_id");

  my $nvre = RHN::Package->lookup_nvre($name_id, $evr_id);

  die 'no nvre for given name id and evr id!' unless $nvre;

  return $nvre;
}

sub package_dependencies {
  my $pxt = shift;
  my %params = @_;

  my $ret = $params{__block__};

  my $pid = $pxt->param('pid');

  my $package;
  $package = RHN::Package->lookup(-id => $pid);
  $pxt->pnotes(package_name => $package->nvre);

  foreach my $dependency (qw/requires provides obsoletes conflicts/) {
    my @list = $package->$dependency();
    my $dep_list;
    foreach my $dep (@list) {
      $dep_list .= $dep->[0];
      if($dep->[1] && $dep->[2]) {

        $dep_list .= ' ';
        if ($dep->[2] & 4) {
          $dep_list .= '&gt;';
        } elsif ($dep->[2] & 2) {
          $dep_list .= '&lt;';
        } 
        if ($dep->[2] & 8) {
          $dep_list .= '=';
        }
        $dep_list .= ' ' . $dep->[1];

      }
      else {
        $dep_list .= "-" . $dep->[1] if $dep->[1];
      }
      $dep_list .= "<br />";
    }
    $ret =~ s/\{package_$dependency\}/ defined $dep_list ? $dep_list : '&#160;'/eig;
  }

  return $ret;
}

sub package_change_log {
  my $pxt = shift;
  my %params = @_;

  my $pid = $pxt->param('pid');

  die "no pid!" unless $pid;

  my $package = RHN::Package->lookup(-id => $pid);

  my @changelog;
  @changelog = $package->change_log;

  my $block = $params{__block__};
  my $ret;
  foreach my $change (@changelog) {
    my $current = $block;
    $current =~ s({time})(PXT::HTML->htmlify_text($change->{TIME}))egims;
    for (qw(NAME TEXT)) {
      utf8::encode($change->{$_}); utf8::decode($change->{$_});
    }
    $current =~ s({modifier})(PXT::HTML->htmlify_text($change->{NAME}))egism;
    $current =~ s({entry})(PXT::HTML->htmlify_text($change->{TEXT}))egims;
    $ret .= $current;
  }

  $ret = "No change log entries." unless $ret;

  return $ret;
}

# shows the detailed view of a package
sub package_details {
  my $pxt = shift;
  my %params = @_;

  my $ret = $params{__block__};
  my $pid = $pxt->param('pid');
  my $package;

  if (not defined $pid) {
    # might have any of the following (basically, to figure out arch):
    my $cid = $pxt->param('cid');
    my $sid = $pxt->param('sid');

    my $id_combo = $pxt->dirty_param('id_combo');
    my ($name_id, $evr_id) = split /[|]/, $id_combo;

    $pid = RHN::Package->guestimate_package_id(-channel_id => $cid, -server_id => $sid, -name_id => $name_id, -evr_id => $evr_id);

    $pxt->redirect('/network/software/packages/unknown_package.pxt?id_combo='.$id_combo) unless $pid;

    $pxt->redirect('/rhn/software/packages/Details.do?pid='.$pid);
  }

  $package = RHN::Package->lookup(-id => $pid);

  die "no package" unless $package;

  if (defined $package->org_id and ($package->org_id ne $pxt->user->org_id)) {
    $pxt->redirect('/errors/permission.pxt') unless RHN::Package->org_permission_check($pid, $pxt->user->org_id);
  }

  my @package_channels = $package->channels($pxt->user->org_id);

  my %subst;
  my $no_data = '<span class="no-details">(none)</span>';

  $subst{package_channels} = join("<br/>", map { sprintf(q(<a href="/network/software/channels/details.pxt?cid=%d">%s</a>), $_->[0], $_->[1]) } @package_channels) || '';

  $pxt->pnotes(package_name => $package->nvre);

  $subst{"package_$_"} = PXT::Utils->escapeHTML($package->$_() || '') || $no_data
    foreach qw/id arch_name arch_label arch_type_label arch_type_name
    package_group_name rpm_version build_host build_time vendor copyright/;

  my ($relative_path, $size) = $package->source_rpm_path;

  my $pkg_type = $package->download_link_type();

  if ($relative_path and $size) {
    my $srpm = "/pub/" . $relative_path;
    my $basename = (split m(/), $srpm)[-1];

    $size = PXT::Utils->commafy($size);
    my $str = "$basename ($size bytes)";

    my $href = qq{<rhn-ftp-download path="$relative_path">Download Source $pkg_type</rhn-ftp-download>};

    $subst{srpm_download_link} = $href;
    $subst{srpm_download_str} = $str;
  }
  else {
    $subst{srpm_download_str} = "(Source $pkg_type not available)";
    $subst{srpm_download_link} = '&#160;';
  }

  $subst{package_s_rpm_name} = PXT::Utils->escapeHTML($package->s_rpm_name || '');

  ($relative_path, $size) = ($package->path, $package->package_size);
  if ($relative_path and $size) {
    my $srpm = "/pub/" . $relative_path;
    my $basename = (split m(/), $srpm)[-1];

    $size = PXT::Utils->commafy($size);
    my $str = "$basename ($size bytes)";

    my $href = qq{<rhn-ftp-download path="$relative_path">Download $pkg_type</rhn-ftp-download>};

    $subst{rpm_download_link} = $href;
    $subst{rpm_download_str} = $str;
    
    # Compute debuginfo rpm path.  Will look something like this:
    # ftp://ftp.redhat.com/pub/redhat/linux/enterprise/3/en/os/i386/Debuginfo/ggv-debuginfo-2.0.1-4.i386.rpm
    my $debugname = $package->package_name_name . "-debuginfo-" . 
    	$package->package_evr_version . "-" . 
	$package->package_evr_release . "." .
	$package->arch_label . "." .
	$package->arch_type_label;
    #warn(" debugname : " . $debugname);

    my $channelrev;
    foreach my $carray (@package_channels) {
      my @namearr = split("v. ", $carray -> [1]);
      @namearr = split(" ", $namearr[1]);
      $channelrev = $namearr[0];
    }
    
    if (!$channelrev) {
      $subst{debug_rpm_download_link} = "(debug info package not available)";
      $subst{debug_rpm_download_str} = "";
    }   
    else {
      my $debugpath = "ftp://ftp.redhat.com/pub/redhat/linux/enterprise/" . 
    	$channelrev . "/en/os/" . $package->arch_label . "/Debuginfo/" . $debugname;

      $subst{debug_rpm_download_link} = "<a href=\"" . $debugpath . "\">Download Debug Info Package</a>";
      $subst{debug_rpm_download_str} = $debugname;
    }    
    
  }
  else {
    $subst{rpm_download_str} = "($pkg_type not available)";
    $subst{rpm_download_link} = '&#160;';
  }

  $subst{package_nvre} = $package->nvre_epochless;

  $subst{"package_$_"} = PXT::HTML->htmlify_text($package->$_() || '') || $no_data
    foreach qw/description summary/;

  $subst{"package_$_"} = PXT::Utils->commafy($package->$_()) . " bytes"
    foreach qw/package_size payload_size/;

  my @other_archs = $package->other_archs_available($pxt->user->org_id);

  my %archs;
  foreach my $arch (@other_archs) {
    $archs{$arch->[1]} = "<a href=\"/rhn/software/packages/Details.do?pid=".$arch->[0]."\">".$arch->[1]."</a>";
  }

  $archs{$package->arch_name} = $package->arch_name;

  my @sorted_archs = map {$archs{$_}} sort (keys %archs);

  my $other_archs_str = join(", ", @sorted_archs);

  $subst{package_other_archs} = $other_archs_str || '';

  # Solaris Package specific:
  if ($package->isa('RHN::Package::SolarisPackage')) {
    $subst{"package_$_"} = PXT::Utils->escapeHTML($package->$_() || '') || $no_data
      foreach qw/solaris_pkgmap solaris_category/;

    $subst{package_solaris_pkginfo} = PXT::HTML->htmlify_text($package->solaris_pkginfo || '');
    $subst{package_interaction_required} = $package->solaris_intonly() eq 'Y' ? 'Yes' : 'No';
  }
  elsif ($package->isa('RHN::Package::SolarisPatch')) {
    $subst{"package_$_"} = PXT::Utils->escapeHTML($package->$_() || '') || $no_data
      foreach qw/solaris_solaris_release solaris_sunos_release solaris_pt_name/;

    $subst{package_solaris_patchinfo} = PXT::HTML->htmlify_text($package->solaris_patchinfo || '');
    $subst{package_solaris_readme} = PXT::HTML->htmlify_text($package->solaris_readme || '');
    $subst{package_solaris_readme_link} = PXT::HTML->link("/network/software/packages/view_readme/$pid", 'Download');

    my @patch_patch_sets = $package->patch_sets;

    $subst{package_solaris_patch_sets_containing_patch} = 
      join("<br/>\n",
	   map { sprintf(q(<a href="/rhn/software/packages/Details.do?pid=%d">%s - %s</a>),
			 $_->{ID}, $_->{NVRE}, $_->{SET_DATE})
	       } @patch_patch_sets
	  ) || $no_data;
  }
  elsif ($package->isa('RHN::Package::SolarisPatchSet')) {
    $subst{"package_$_"} = PXT::Utils->escapeHTML($package->$_() || '') || $no_data
      foreach qw/solaris_set_date/;

    $subst{package_solaris_readme} = PXT::HTML->htmlify_text($package->solaris_readme || '');
    $subst{package_solaris_readme_link}
      = PXT::HTML->link("/network/software/packages/view_readme/$pid", 'Download');
  }

  return PXT::Utils->perform_substitutions($ret, \%subst);
}

sub raw_pkgmap {
  my $pxt = shift;

  my $path = File::Spec->canonpath($pxt->path_info);
  $path =~ s(^/)();

  my ($pid) = split(m(/), $path, 1);

  return unless $pid;

  unless ($pxt->user->verify_package_access($pid)) {
    die sprintf("User %s (%d) has no access to package '%s'",
		$pxt->user->login, $pxt->user->id, $pid);
  }

  # setting the content type and disposition forces most browsers to
  # pop up a 'download' dialog instead of showing the file in the
  # browser.
  $pxt->content_type('text/plain');
  $pxt->header_out('Content-disposition', "attachment; filename=pkgmap");
  $pxt->manual_content(1);
  $pxt->send_http_header;

  my $package = RHN::Package->lookup(-id => $pid);

  if ($package->can('solaris_pkgmap')) {
    $pxt->print($package->solaris_pkgmap);
  }

  return;
}

sub raw_readme {
  my $pxt = shift;

  my $path = File::Spec->canonpath($pxt->path_info);
  $path =~ s(^/)();

  my ($pid) = split(m(/), $path, 1);

  return unless $pid;

  unless ($pxt->user->verify_package_access($pid)) {
    die sprintf("User %s (%d) has no access to package '%s'",
		$pxt->user->login, $pxt->user->id, $pid);
  }

  # setting the content type and disposition forces most browsers to
  # pop up a 'download' dialog instead of showing the file in the
  # browser.
  $pxt->content_type('text/plain');
  $pxt->header_out('Content-disposition', "attachment; filename=README");
  $pxt->manual_content(1);
  $pxt->send_http_header;

  my $package = RHN::Package->lookup(-id => $pid);

  if ($package->can('solaris_readme')) {
    $pxt->print($package->solaris_readme);
  }
  else {
    throw "(no_readme) Invalid attempt to view readme for package '" . $package->id . "'";
  }

  return;
}

sub sscd_confirm_package_upgrades_cb {
  my $pxt = shift;
  my $mode = $pxt->dirty_param('mode');

  if ($pxt->dirty_param('sscd_confirm_package_upgrades')) {

    my $earliest = Sniglets::ServerActions->parse_date_pickbox($pxt);

    my $actions = RHN::Scheduler->sscd_schedule_package_upgrade(-org_id => $pxt->user->org_id, -user_id => $pxt->user->id, -earliest => $earliest);
    my $package_set = RHN::Set->lookup(-label => 'package_upgradable_list', -uid => $pxt->user->id);
    $package_set->empty;
    $package_set->commit;

    $pxt->push_message(site_info => "Package upgrades scheduled.");

    if ($mode eq 'ssm_package_upgrade') {
      my $actions_by_sid;

      foreach my $sid (keys %{$actions}) {
	my @actions = map { RHN::Action->lookup(-id => $actions->{$sid}->{$_}->{action_id}) }
	  keys %{$actions->{$sid}};

	for (my $i = 1; $i <= $#actions; $i++) {
	  $actions[$i]->prerequisite($actions[$i - 1]->id);
	  $actions[$i]->commit;
	}

	$actions_by_sid->{$sid} = \@actions;
      }

      return $actions_by_sid;
    }
    else {
      $pxt->redirect('/network/systems/ssm/packages/index.pxt');
    }
  }
}

sub sscd_confirm_package_removals_cb {
  my $pxt = shift;
  my $mode = $pxt->dirty_param('mode');

  if ($pxt->dirty_param('sscd_confirm_package_removals') || $pxt->dirty_param('sscd_confirm_patch_removals')) {
    my $earliest = Sniglets::ServerActions->parse_date_pickbox($pxt);
    
    my $pkglbl = 'sscd_removable_package_list';
    $pkglbl =~ s/package/patch/ if $pxt->dirty_param('sscd_confirm_patch_removals');

    my $actions = RHN::Scheduler->sscd_schedule_package_removal(-org_id => $pxt->user->org_id, -user_id => $pxt->user->id, -earliest => $earliest, -label => $pkglbl);
    my $package_set = RHN::Set->lookup(-label => $pkglbl, -uid => $pxt->user->id);
    $package_set->empty;
    $package_set->commit;

    my $pkgstr = 'Package';
    $pkgstr = 'Patch' if $pxt->dirty_param('sscd_confirm_patch_removals');

    $pxt->push_message(site_info => "$pkgstr removals scheduled.");

    if ($mode eq 'ssm_package_remove') {
      my @actions = map { RHN::Action->lookup(-id => $_->{action_id}) } @{$actions};

      return @actions;
    }
    elsif ($pxt->dirty_param('sscd_confirm_patch_removals')) {
      $pxt->redirect("/network/systems/ssm/patches/index.pxt");
    }
    else {
      $pxt->redirect("/network/systems/ssm/packages/index.pxt");
    }
  }
  else {
    die "crap!";
  }
}

sub sscd_confirm_package_installations_cb {
  my $pxt = shift;
  my $mode = $pxt->dirty_param('mode') || '';

  if ($pxt->dirty_param('sscd_confirm_package_installations') or 
      $pxt->dirty_param('sscd_confirm_patch_installations') or 
      $pxt->dirty_param('sscd_confirm_patchset_installations') ) {

    my $earliest = Sniglets::ServerActions->parse_date_pickbox($pxt);

    my $channel_id = $pxt->param('cid');
    die "no channel id!" unless $channel_id;

    my $pkgtype = 'Package';
    my $pkglbl =  'package_installable_list';

    if ( $pxt->dirty_param('sscd_confirm_patch_installations') ) {
      $pkgtype = 'Patch';
      $pkglbl =  'patch_installable_list';
    } 
    elsif ( $pxt->dirty_param('sscd_confirm_patchset_installations') ) {
      $pkgtype = 'Patch Cluster';
      $pkglbl =  'patchset_installable_list';
    }

    my $actions = RHN::Scheduler->sscd_schedule_package_installations(-org_id => $pxt->user->org_id,
								      -user_id => $pxt->user->id,
								      -earliest => $earliest,
								      -channel_id => $channel_id,
                                                                      -label => $pkglbl);
    my $package_set = RHN::Set->lookup(-label => $pkglbl, -uid => $pxt->user->id);
    $package_set->empty;
    $package_set->commit;

    $pxt->push_message(site_info => "$pkgtype installations <a href=\"/rhn/schedule/PendingActions.do\">scheduled</a>.");

    my $package_answer_files = $pxt->session->get('package_answer_files');
    $pxt->session->unset('package_answer_files');

    my @actions = map { RHN::Action->lookup(-id => $actions->{$_}->{action_id}) } keys %{$actions};

    foreach my $action (@actions) {
      RHN::Scheduler->associate_answer_files_with_action($action->id, $package_answer_files);
    }

    for (my $i = 1;$i <= $#actions; $i++) {
      $actions[$i]->prerequisite($actions[$i - 1]->id);
      $actions[$i]->commit;
    }

    if ($mode eq 'ssm_package_install') {
      return @actions;
    }
    elsif ($pkgtype eq 'Package') {
      $pxt->redirect("/network/systems/ssm/packages/index.pxt");
    }
    elsif ($pkgtype eq 'Patch') {
      $pxt->redirect("/network/systems/ssm/patches/index.pxt");
    }
    elsif ($pkgtype eq 'Patch Cluster') {
      $pxt->redirect("/network/systems/ssm/patchsets/index.pxt");
    }
  }

  return;
}

sub upload_answerfile_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = build_upload_answerfile_form($pxt, %attr);
  my $rform = $form->realize;
  undef $form;

  Sniglets::Forms::load_params($pxt, $rform);

  my $style = new Sniglets::Forms::Style;
  my $html = $rform->render($style);

  return $html;
}

sub build_upload_answerfile_form {
  my $pxt = shift;
  my %attr = @_;

  my $sid = $pxt->param('sid');
  my $cid = $pxt->param('cid');
  my $id_combo = $pxt->dirty_param('id_combo');
  my $set_label = $pxt->dirty_param('set_label');
  my $mode = $pxt->dirty_param('mode');

  my $form = new RHN::Form::ParsedForm(name => "Answer File",
				       label => 'answerfile_form',
				       action => $attr{action},
				       enctype => 'multipart/form-data',
				      );

  $form->add_widget( new RHN::Form::Widget::TextArea(name => 'Answer File',
						     label => 'answerfile_contents',
						     rows => 24,
						     cols => 80,
						     default => '') );

  if ($mode eq 'ssm_package_install_answer_files') {
    $form->add_widget(hidden => { name => 'sscd_confirm_package_installations', value => 1 });
  }

  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:upload-answerfile-cb') );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'sid', value => $sid) ) if $sid;
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'cid', value => $cid) ) if $cid;
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'set_label', value => $set_label) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'id_combo', value => $id_combo) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'mode', value => $mode) );
  $form->add_widget( new RHN::Form::Widget::Submit(name => "Upload File") );

  return $form;
}

sub upload_answerfile_cb {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  my $id_combo = $pxt->dirty_param('id_combo');
  my $set_label = $pxt->dirty_param('set_label');
  my $mode = $pxt->dirty_param('mode');

  my $contents = $pxt->dirty_param('answerfile_contents') || '';

  my $package_answer_files = $pxt->session->get('package_answer_files') || { };
  $package_answer_files->{$id_combo} = $contents;
  $pxt->session->set('package_answer_files' => $package_answer_files);

  Sniglets::ListView::PackageList->default_callback($pxt, label => $mode);

  if ($mode eq 'ssm_package_install_remote_command'
      or $mode eq 'ssm_package_install_answer_files') {
    $pxt->redirect("/network/systems/ssm/packages/index.pxt?sid=$sid");
  }
  else {
    $pxt->redirect("/rhn/systems/details/packages/Packages.do?sid=$sid");
  }

  return;
}

1;
