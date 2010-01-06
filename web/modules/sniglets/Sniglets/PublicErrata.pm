#
# Copyright (c) 2008--2009 Red Hat, Inc.
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

package Sniglets::PublicErrata;

use Data::Dumper;
use File::Spec;
use Params::Validate qw/validate/;
use Time::HiRes;

use PXT::Utils;
use PXT::HTML;

use RHN::Access;
use RHN::Errata;
use RHN::DB::Errata;
use RHN::Exception;
use RHN::Product;

use Sniglets::Downloads;


sub register_tags {
  my $class = shift;
  my $pxt = shift;

  # for www.redhat.com'ish public errata display
  $pxt->register_tag('public-errata-product-list' => \&public_errata_product_list);
  $pxt->register_tag('public-errata-affected-products' => \&public_errata_affected_products, 2);
  $pxt->register_tag('public-errata-list-vs-details' => \&public_errata_list_vs_details);
  $pxt->register_tag('public-errata-filter' => \&public_errata_filter);
  $pxt->register_tag('public-errata-filter-type-url' => \&public_errata_filter_type_url);
  $pxt->register_tag('public-errata-type' => \&public_errata_type);
  $pxt->register_tag('public-errata-list' => \&public_errata_list);
  $pxt->register_tag('public-errata-product-name' => \&public_errata_product_name);
  $pxt->register_tag('public-errata-details' => \&public_errata_details);
  $pxt->register_tag('public-errata-cves' => \&public_errata_cves, 2); # render after public_errata_details
  $pxt->register_tag('public-cve-list' => \&public_cve_list);
  $pxt->register_tag('public-cve-details' => \&public_cve_details);
  $pxt->register_tag('public-cve-heading' => \&public_cve_heading);
}


my %e_icons = ('Security Advisory' => { image => '/img/rhn-icon-security.gif',
					white => '/img/wrh-security.gif',
					grey => '/img/wrh-security.gif',
					big => '/img/rhn-icon-security.gif',
					alt => 'Security Advisory' },
	     'Enhancement Advisory' => { image => '/img/rhn-icon-enhancement.gif',
					 white => "/img/wrh_feature-white.gif",
					 grey => "/img/wrh_feature-grey.gif",
					 big => '/img/rhn-icon-enhancement.gif',
					 alt => "Enhancement Advisory" },
	     'Product Enhancement Advisory' => { image => '/img/rhn-icon-enhancement.gif',
						 white => "/img/wrh-product.gif",
						 grey => "/img/wrh-product.gif",
						 big => '/img/rhn-icon-enhancement.gif',
						 alt => "Enhancement Advisory" },
	      'Bug Fix Advisory' => { image => '/img/rhn-icon-bug.gif',
				      white => "/img/wrh-bug.gif",
				      grey => "/img/wrh-bug.gif",
				      big => '/img/rhn-icon-bug.gif',
				      alt => "Bug Fix Advisory" } );


my %errata_types = (bug_fixes => ["Bug Fixes", "Bug Fix Advisory"],
		    security => ["Security", "Security Advisory"],
		    enhancements => ["Enhancements", "Product Enhancement Advisory"]);

my %errata_types_reverse = ('Bug Fix Advisory' => 'bug_fix', 'Security Advisory' => 'security', 'Product Enhancement Advisory' => 'enhancement');


# labeling errata lists...
sub public_errata_type {
  my $pxt = shift;
  my $path_info = $pxt->path_info;

  if ($path_info) {

    if ($path_info =~ m/security/) {
      return 'Security';
    }
    elsif ($path_info =~ m/bugfixes/) {
      return 'Bug Fix';
    }
    elsif ($path_info =~ m/updates/) {
      return 'Product Enhancement';
    }
  }

  return "General";
}

# looks to see if cve exists in db.
sub cve_in_db {
    my $path_info = shift;
    $path_info =~ m/\/(CAN|CVE)(.*?)\.html/;
    # only care about the second part
    my $type = $2;
    my $errata = RHN::Errata->find_by_cve($type);

    return $errata;
}

# returns true if we have db knowledge of an errata.
sub errata_in_db {
  my $path_info = shift;

  $path_info =~ m/\/(.*?)-(.*?)\.html/;
  my ($type, $version) = ($1, $2);
  $version =~ s/-/:/;

  my $errata = RHN::Errata->find_by_advisory(-type => $type, -version => $version);

  return $errata;
}

sub public_errata_product_list {
  my $pxt = shift;
  my %params = @_;

  die "no product line specified!" unless $params{product_line};

  my @products = RHN::Product->products_by_line($params{product_line}, $params{order});

  my $ret = '';
  foreach my $product (@products) {
    $ret .= "<li>" . PXT::HTML->link("/errata/$product->{LABEL}-errata.html", $product->{NAME}) . "</li>\n";
  }

  return $ret;
}

# 
sub public_cve_list {
    my $pxt = shift;
    my $cache_time = PXT::Config->get("public_errata_cache_time") ||
                                      "15 minutes";

    if ($pxt->path_info eq '/') {
        # make them choose a product
        return $pxt->include('/errata_hidden/product_list.pxi');
    }
    elsif ($pxt->path_info =~ m {^/(CVE|CAN)-\d\d\d\d-\d\d\d\d.*?\.html}) {
        if (cve_in_db($pxt->path_info)) {
            $pxt->cache_document_contents($cache_time);
            return $pxt->include('/errata_hidden/cve_details.pxi');
        }
        else {
            $pxt->path_info =~ m {^/((CVE|CAN).*?)\.html$};
            my $attempted_adv = $1;
            $attempted_adv = PXT::Utils->escapeURI($attempted_adv);
            $pxt->redirect("/cve_not_found.pxt?attempted_adv=$attempted_adv");
        }
    }
    else {
        $pxt->redirect("/file_not_found.pxt");
    }
}

sub public_errata_list_vs_details {
  my $pxt = shift;

  my $cache_time = PXT::Config->get("public_errata_cache_time") || "15 minutes";

  return $pxt->include('/errata_hidden/product_list.pxi') unless ($pxt->path_info and $pxt->path_info ne '/');

  PXT::Debug->log(7, "either list or details");

  if ($pxt->path_info eq '/') {
    return $pxt->include('/errata_hidden/product_list.pxi');
  }

  if ($pxt->path_info =~ m {^/login.pxt} ) {
    return $pxt->include('/errata_hidden/login.pxi');
  }
  elsif ($pxt->path_info =~ m {^/RH[BES]A-\d\d\d\d-\d\d\d.*?\.html}) {
    # figure out if we have in db...
    if (errata_in_db($pxt->path_info)) {

      # cache details page...
      $pxt->cache_document_contents($cache_time);
      return $pxt->include('/errata_hidden/details.pxi');;
    }
    else {
      if (-e $pxt->document_root() . '/errata_hidden/static_errata' . $pxt->path_info ) {
	return $pxt->include('/errata_hidden/static_errata' . $pxt->path_info);
      }
      else {
        $pxt->path_info =~ m {^/(RH[BES]A.*?)\.html$};
        my $attempted_adv = $1;
        $attempted_adv = PXT::Utils->escapeURI($attempted_adv);
        $pxt->redirect("/errata_not_found.pxt?attempted_adv=$attempted_adv");
      }
    }
  }
  elsif ($pxt->path_info =~ m {^/(CVE|CAN)-\d\d\d\d-\d\d\d\d.*?\.html}) {
        if (cve_in_db($pxt->path_info)) {
            $pxt->cache_document_contents($cache_time);
            return $pxt->include('/errata_hidden/cve_details.pxi');
        }
        else {
            $pxt->path_info =~ m {^/((CVE|CAN).*?)\.html$};
            my $attempted_adv = $1;
            $attempted_adv = PXT::Utils->escapeURI($attempted_adv);
            $pxt->redirect("/cve_not_found.pxt?attempted_adv=$attempted_adv");
        }
    }
  elsif ($pxt->path_info =~ m {^/rh}) {

    # cache errata list page...
    $pxt->cache_document_contents($cache_time);
    return $pxt->include('/errata_hidden/list.pxi');
  }
  else {
    $pxt->redirect("/file_not_found.pxt");
  }
}

sub public_errata_affected_products {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  my $pkgs_ref = $pxt->pnotes('updated_packages');
  my @products = sort keys %{$pkgs_ref};

  $block =~ s{\{affected_products\}}{ join("<br />\n", map { "<a href=\"#$_\">$_</a>" } @products) }egism;

  return $block;
}


# messy little function that decides what html to render the filename link as
sub render_file_entry {
  my $pxt = shift;
  my %params = validate(@_, { -file => 1,
			      -errata_is_protected => 1 ,
			      -paid_user => 1} );

  my $file = $params{-file};
  my $errata_is_protected = $params{-errata_is_protected};
  my $paid_user = $params{-paid_user};

  my $file_entry = '';


  if ($file->{OUTDATED_BY}) {

    my $advisory_name_url = $file->{OUTDATED_BY};
    $advisory_name_url =~ s{(RH[BES]A)-(\d\d\d\d):((\d{4})|(\d{3}))}{$1-$2-$3.html};
    $file_entry = (split /[\/]/, $file->{FILENAME})[-1] . "<br />\n" . "<font color=\"#990000\">File outdated by: &#160;</font><a href=\"/errata/$advisory_name_url\">" . $file->{OUTDATED_BY} . "</a>";
  }
  elsif ($errata_is_protected) {

    $file_entry = (split /[\/]/, $file->{FILENAME})[-1];
  }
  elsif (-e File::Spec->catfile(PXT::Config->get('mount_point'), 'redhat', 'linux', 'updates', $file->{FILENAME})) {


    $file_entry = (split /[\/]/, $file->{FILENAME})[-1] . "<br />\n<a href=\"ftp://updates.redhat.com/" . $file->{FILENAME} . "\">[ via FTP ]</a>"
	. " <a href=\"http://updates.redhat.com/" . $file->{FILENAME} . "\">[ via HTTP ]</a>";

    if ($paid_user and $file->{RHN_PATH} and -e File::Spec->catfile(PXT::Config->get('mount_point'), $file->{RHN_PATH})) {
      $file_entry .= " ". Sniglets::Downloads->rhn_download_url(-pxt => $pxt,
							      -path => $file->{RHN_PATH},
							      -label => "[ via Red Hat Network ]");
    }
  }
  else {
    #  CRAP.  Missing file that shouldn't be missing.
    PXT::Debug->log(7, "missing:  " . File::Spec->catfile(PXT::Config->get('mount_point'), 'redhat', 'linux', 'updates', $file->{FILENAME}));
    $file_entry = "ftp://updates.redhat.com/" . $file->{FILENAME} . "<br />\n<font color=\"#990000\">Missing file</font>";
  }

  return $file_entry;
}

# given a filename, guess the product
# (only do this for really really really old crap, like 5.1 or 6.1 files...)
sub guess_product {
  my $filename = shift;

  my $product = 'Other';

  if ($filename =~ m{^(\d\.\d)/.*?/.*?$}) {
    # 6.1/alpha/foo.rpm
    $product = "Red Hat Linux $1";
  }
  else {
    warn "couldn't determine product for $filename";
  }

  PXT::Debug->log(7, "calculated product for $filename:  $product") ;
  return $product;
}


sub _arch_sorter {
  if ($a eq 'SRPMS') {
    return -1;
  }

  if ($b eq 'SRPMS') {
    return 1;
  }

  return ($a cmp $b);
}

sub _file_sorter {
    my $new_a = (split /\//, $a->{FILENAME})[-1];
    my $new_b = (split /\//, $b->{FILENAME})[-1];

    return ($new_a cmp $new_b);
}

sub updated_packages {
  my $pxt = shift;

  my $e = shift;
  my $updated_packages_block = shift;

  # to be used later in calculating what urls to render, if any...
  my $errata_is_protected = $e->is_protected();
  my $paid_user = $pxt->user ? $pxt->user->org->is_paying_customer() : undef;

  my $updated_packages = '';

  # this includes rpm and non-rpm files...
  my @errata_files = $e->files();

  #warn Data::Dumper->Dump([(\@errata_files)]);

  # needed to determine the obsoleting errata for SRPMS ...
  my %source_rpm_ids;

  # some rhnErrataFile entries come back twice, because of the outer join on product,
  # which needs to be there to show things like 5.1 files...
  my %seen_ef_id;


  # product->arch->filename, this is the data structure we render off of ...
  my %prod_arch_file;

  foreach my $file (@errata_files) {
    if ($file->{FILE_TYPE} eq 'OVAL') {
        next;
    }
    # theory for calculating the obsoleting errata for an SRPM:
    # if any rpm that is generated by the srpm is outdated by an errata,
    # that srpm is outdated by that errata as well, because you can't have
    # one without the other, right?  (only if a srpm decreases the # of rpms it creates...?)
    if (defined $file->{PACKAGE_OUTDATED_BY}) {

      # then it's an rpm...
      die "this should be an rpm, but isn't ... " unless $file->{FILE_TYPE} eq 'RPM';

      if (defined $file->{PACKAGE_SOURCE_RPM_ID}) {
	$source_rpm_ids{$file->{PACKAGE_SOURCE_RPM_ID}} = $file->{PACKAGE_OUTDATED_BY};
      }
    }

    # build the main data structure...

    # if it's an RPM, or an SRPM, there might be able to download it through RHN ...
    if ($file->{FILE_TYPE} eq 'RPM') {
      $file->{RHN_PATH} = $file->{RHN_PACKAGE_PATH};
    }
    elsif ($file->{FILE_TYPE} eq 'SRPM') {
      $file->{RHN_PATH} = $file->{RHN_PACKAGE_SOURCE_PATH};
    }

    # group files by channel architecture
    my $arch;

    # note that if package_arch is not defined, then it's either funky or an srpm
    # (where funky means i have no data about the package, munge it as best i can)
    if (defined $file->{CHANNEL_ARCH_NAME} and defined $file->{PACKAGE_ARCH}) {
      $arch = $file->{CHANNEL_ARCH_NAME};
    }
    elsif ($file->{FILE_TYPE} eq 'RPM') {
      # oddball type... never imported the package into rhn, so don't easily get
      # the arch from a query.  parse it from the filename?
      my $short_filename = (split /[\/]/, $file->{FILENAME})[-1];
      $arch = (split /[\.]/, $short_filename)[-2] || 'Files';
    }
    else {
      $arch = $file->{FILE_TYPE} . 'S';
    }

    #  some file entries come back twice, once with a good product, once with a bad one...
    #  this depends upon the channels the packages are in... there's an outer join
    #  on products to support things like 5.1 files
    #  We *are* guaranteed to pull back the ones *with* a product 1st...

    #  link off both id and arch in case of noarch files
    my $composite = $file->{ID} . $arch; 
    unless ($seen_ef_id{$composite}) {

      $seen_ef_id{$composite} = 1;

      # for really really old stuff, like 5.1, 6.1, gotta figure out the product from
      # the filename??
      unless ($file->{PRODUCT}) {
	$file->{PRODUCT} = guess_product($file->{FILENAME});
      }

      push @{$prod_arch_file{$file->{PRODUCT}}->{$arch}}, $file
    }
  }

  #return "<pre>" . Data::Dumper->Dump([(\%prod_arch_file)]) . "</pre>";
  #warn Data::Dumper->Dump([(\%prod_arch_file)]);

  $pxt->pnotes(updated_packages => \%prod_arch_file);

  # render it...
  $updated_packages_block =~ m{<_arch>(.*?)</_arch>}ism;
  my $arch_block = $1;
  $updated_packages_block =~ m{<_file_entry>(.*?)</_file_entry>}ism;
  my $file_block = $1;

  my $ret = '';

  # iterate over the products ...
  foreach my $product (sort keys %prod_arch_file) {

    my $current_product_block = $updated_packages_block;
    $current_product_block =~ s/\{product\}/$product/gism;

    my $products_str = '';

    # iterate through all the arches for a product ...
    foreach my $arch (sort _arch_sorter keys %{$prod_arch_file{$product}}) {

      my $current_arch_block = $arch_block;
      $current_arch_block =~ s/\{arch\}/$arch/gims;

      my @files = @{$prod_arch_file{$product}->{$arch}};

      my $files_str = '';
      my $count = 1;

      foreach my $file (sort _file_sorter  @files) {

	# if it's an srpm ...
	if ($file->{FILE_TYPE} eq 'SRPM') {

	  # check to see if any of it's generated rpms have reported an outdating errata;
	  # if so, that errata *should* also outdate this one...
	  $file->{OUTDATED_BY} = $source_rpm_ids{$file->{PACKAGE_SOURCE_SOURCE_RPM_ID}};
	}
	elsif( $file->{FILE_TYPE} eq 'RPM') {
	  $file->{OUTDATED_BY} = $file->{PACKAGE_OUTDATED_BY};
	}

	my %subst;
	my $entry = render_file_entry($pxt, {-file => $file, -errata_is_protected => $errata_is_protected, -paid_user => $paid_user});

	$subst{filename} = $entry;
	$subst{md5sum} = $file->{MD5SUM};
	$subst{color} = $count % 2 ? "#ffffff" : "#eeeeee";

	$files_str .= PXT::Utils->perform_substitutions($file_block, \%subst);
	$count++;
      }

      $current_arch_block =~ s/<_file_entry>.*?<\/_file_entry>/$files_str/gism;
      $products_str .= $current_arch_block;
    }

    $current_product_block =~ s/<_arch>.*?<\/_arch>/$products_str/gism;
    $ret .= $current_product_block;
  }

  if ($errata_is_protected) {
    $ret .= '<tr><td colspan="2">(The unlinked packages above are only available from the <a href="/">' . PXT::Config->get('product_name') . '</a>)<br /></td></tr>';
  }

  return $ret;
}

sub public_cve_heading {
    my $pxt = shift;
    my %params = @_;
    my $block = $params{__block__};
    my $ret = '';
    my $path_info = $pxt->path_info;

    my %subst;

    if ($path_info =~ m{(CAN|CVE)-(\d\d\d\d)-(\d+)\.html}) {
      $subst{cve_name} = "$1-$2-$3";
    }
    else {
        die "Invalid cve specified!";
    }

    $ret .= PXT::Utils->perform_substitutions($block, \%subst);

    return $ret;
}

sub public_cve_details {
    my $pxt = shift;
    my %params = @_;
    my $block = $params{__block__};
    my $errata_id;
    my $ret = '';
    my $path_info = $pxt->path_info;
    my $hostname = PXT::Config->get('public_errata_hostname');

    $path_info =~ m/\/(CAN|CVE)(.*?)\.html/;
    # only care about the second part
    my $type = $2;
    my @errata = RHN::Errata->find_by_cve($type);

    my $previous_prod = '';
    foreach my $errata (@errata) {
        my %subst;
        if ( $previous_prod ne $errata->[0] ) {
            $subst{errata_product} = $errata->[0] . ":";
            $previous_prod = $errata->[0];
        }
        else {
            $subst{errata_product} = '';
        }
        my $advisory_id = $errata->[1];
        $advisory_id =~ m/(.*?):(.*?)-/;
        $subst{errata_advisory_id_url} = 
            "<a href=\"/errata/$1-$2.html\">http://$hostname/errata/$1-$2.html</a>";
        $ret .= PXT::Utils->perform_substitutions($block, \%subst);
    }

    return $ret;
}

sub public_errata_details {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $errata_id;

  # support for /errata/advisory/details.pxt/RHSA-2002-001.html
  # and /errata/advisory/solution.pxt/RHSA-2002-001.html
  my $path_info = $pxt->path_info;

  my $type;
  my $version;

  if ($path_info =~ m/\/(.*?)-(.*?)\.html/) {
    ($type, $version) = ($1, $2);
    $version =~ s/-/:/;
  }
  else {
    $pxt->redirect("/errata/file_not_found.pxt");
  }


  my @errata = RHN::Errata->find_by_advisory(-type => $type, -version => $version);

  $pxt->redirect("/errata/file_not_found.pxt")
    unless @errata;

  $errata_id = $errata[0]->[0];

  my $e = RHN::Errata->lookup(-id => $errata_id);

  PXT::Debug->log(9, "errata:  " . Data::Dumper->Dump([($e)]));

  $pxt->redirect("/errata/file_not_found.pxt")
    unless $e;

  $pxt->redirect("/errata/file_not_found.pxt")
    unless $e->is_public();
   
  die "Non Red Hat Errata not for public display!!  eid == " . $e->id if (defined $e->org_id);

  #$pxt->pnotes(errata => \$e);

  my %subst;
  # general info
  $subst{path_info} = $path_info || '';

  my $severity_text;
  my $oval_file_name;
  my @chunks;
  my $has_severity;
  # these will always be filled out
  $subst{errata_id} = $e->id;
  $subst{errata_advisory_id} = $e->advisory;
  $subst{errata_issue_date} = $e->issue_date;
  $subst{errata_update_date} = $e->update_date;
  $subst{errata_product} = $e->product;

  if ($e->severity_id == 0) {
    $severity_text = "Critical";
  }
  elsif ($e->severity_id == 1) {
    $severity_text = "Important";
  }
  elsif ($e->severity_id == 2) {
    $severity_text = "Moderate";
  }
  elsif ($e->severity_id == 3) {
    $severity_text = "Low";
  }
  else {
    $severity_text = "N/A";
  }
  $subst{severity} = $severity_text;
  $subst{errata_synopsis} = defined $e->synopsis ? $e->synopsis : "";

  PXT::Utils->escapeHTML_multi(\%subst);

  if ($e->oval_file_count == 0) {
    $subst{oval_link} = "N/A";
  }
  else {
    $oval_file_name = $e->advisory;
    $oval_file_name =~ tr/A-Z/a-z/;
    $oval_file_name =~ s/://;
    @chunks = split(/-/, $oval_file_name);
    $oval_file_name = "com.redhat." . $chunks[0] . "-" . $chunks[1] . ".xml";
    $subst{oval_link} = PXT::HTML->link("/rhn/oval?errata=" . $e->id, $oval_file_name, , "", "");
  }

  $subst{errata_icon} = PXT::HTML->img(-align => "absmiddle",
				       -src => $e_icons{$e->advisory_type}->{big},
				       -alt => $e_icons{$e->advisory_type}->{alt},
				       );
  $subst{errata_icon_file} = $e_icons{$e->advisory_type}->{white};

  $subst{errata_advisory_type} = defined $e->advisory_type ? PXT::Utils->escapeHTML($e->advisory_type) : "&#160;";
  $subst{errata_description} = defined $e->description ? PXT::HTML->htmlify_text($e->description) : "&#160;";
  $subst{errata_solution} = defined $e->solution ? PXT::HTML->htmlify_text($e->solution) : "&#160;";

  $block = PXT::Utils->perform_substitutions($block, \%subst);

  # may or may not be filled out
  $block =~ s/<errata_topic>(.*?)\{errata_topic\}(.*?)<\/errata_topic>/defined $e->topic ? $1 . PXT::HTML->htmlify_text($e->topic) . $2 : ""/eigsm;

  my $references_str = defined $e->refers_to ? PXT::HTML->htmlify_text($e->refers_to) : "";

  my @cves = $e->related_cves;

  $pxt->pnotes(cves => \@cves) if @cves;

  if (!defined $e->refers_to and !@cves) {
    $block =~ s/<errata_references>(.*?)\{errata_references\}(.*?)<\/errata_references>//igms;
  }
  else {
    $block =~ s/<errata_references>(.*?)\{errata_references\}(.*?)<\/errata_references>/$1$references_str$2/igsm;
  }


  # bugs fixed
  my @bugs_fixed = map { '<a href="http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id='
			   . $_->[0] . '">' . $_->[0] . '</a> - ' . PXT::HTML->htmlify_text($_->[1]) } $e->bugs_fixed();


  PXT::Debug->log(9, "bugs fixed:  " . Data::Dumper->Dump([(@bugs_fixed)]));

  $block =~ s/<errata_bugs_fixed>(.*?)\{errata_bugs_fixed\}(.*?)<\/errata_bugs_fixed>/@bugs_fixed ? $1 . join("<br \/>\n", @bugs_fixed) . $2 : ""/eigsm;


  # keywords
  my @keywords = $e->keywords;
  $block =~ s/<errata_keywords>(.*?)\{errata_keywords\}(.*?)<\/errata_keywords>/@keywords ? $1 . join(", ", @keywords) . $2: ""/eigsm;

  $block =~ m/<errata_updated_packages>(.*?)<\/errata_updated_packages>/ism;
  my $updated_packages_block = $1;

  my $updated_packages = updated_packages($pxt, $e, $updated_packages_block);
  $block =~ s/<errata_updated_packages>.*?<\/errata_updated_packages>/$updated_packages/gism;

  return $block;
}


sub public_errata_cves {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  return '' unless ($block);

  my $cves_ref = $pxt->pnotes('cves');

  return '' unless $cves_ref;
  my @cves = @{$cves_ref};

  my $cve_entry_block;
  $block =~ m{<cve_entry_block>(.*?)</cve_entry_block>}ism;
  $cve_entry_block = $1;

  my $cves_details = '';
  foreach my $cve (@cves) {
    my $current = $cve_entry_block;
    $current =~ s{\{cve\}}{$cve}gism;
    $cves_details .= $current;
  }

  $block =~ s{<cve_entry_block>.*?</cve_entry_block>}{$cves_details}ism;

  return $block;
}



sub public_errata_product_name {
  my $pxt = shift;
  my %params = @_;

  my $path_info = $pxt->path_info;
  my $product;

  if ($path_info) {

    if ($path_info =~ m/\/(.*?)-errata/) {
      $product = $1;
    }
    elsif ($path_info =~ m/\/(.*?-powertools)/) {
      $product = $1;
    }
  }

  die "no product!" unless $product;

  $product = RHN::Product->name_by_label($product);
  die "no product name!" unless ($product);

  return $product;
}

sub public_errata_filter_type_url {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};

  foreach my $by_field (qw/date advisory synopsis severity/) {
    $block =~ s/\{$by_field\}/'<a href="\/errata' . $pxt->path_info . '?by=' . $by_field. ( $pxt->param('errata_type') ? '&errata_type=' . $pxt->param('errata_type') : '') . '">' . ucfirst $by_field . "<\/a>"/egism;
  }

  return $block;
}

sub public_errata_filter {
  my $pxt = shift;
  my %params = @_;

  my $errata_type = '';
  my $path_info = $pxt->path_info;

  my $product = '';

  my $is_powertools = '';

  if ($path_info) {
    if ($path_info =~ m/\/(.*?)-errata/) {
      $product = $1;
    }
    elsif ($path_info =~ m/\/(.*?-powertools)/) {
      $product = $1;
      $is_powertools = 1;
    }

    if ($path_info =~ m/security/) {
      $errata_type = 'security';
    }
    elsif ($path_info =~ m/bugfixes/) {
      $errata_type = 'bug_fixes';
    }
    elsif ($path_info =~ m/updates/) {
      $errata_type = 'enhancements';
    }
  }

  my $base_url = '/errata';


  my $all_url = $base_url . "/$product" . ($is_powertools ? "" : "-errata") . ".html";
  my $security_url = $base_url . "/$product" . ($is_powertools ? "" : "-errata") . "-security.html";
  my $bug_fix_url = $base_url . "/$product" . ($is_powertools ? "" : "-errata") . "-bugfixes.html";
  my $enhancement_url = $base_url . "/$product" . ($is_powertools ? "" : "-errata") . "-updates.html";

  return "<font style=\"color:#666666; font-family:helvetica; text-decoration:none; font-size:10pt;\"><strong>Jump to:</strong> [ <font color=\"black\"><strong>all</strong></font> | <strong><a href=\"$security_url\">security</a></strong> | <strong><a href=\"$bug_fix_url\">bug fixes</a></strong> | <strong><a href=\"$enhancement_url\">enhancements</a></strong> ]</font>" unless ($errata_type);

  if ($errata_type eq 'security') {
      return "<font style=\"color:#666666; font-family:helvetica; text-decoration:none; font-size:10pt;\"><strong>Jump to:</strong> [ <strong><a href=\"$all_url\">all</a></strong> | <font color=\"black\"><strong>security</strong></font> | <strong><a href=\"$bug_fix_url\">bug fixes</a></strong> | <strong><a href=\"$enhancement_url\">enhancements</a></strong> ]</font>";
  }

  if ($errata_type eq 'bug_fixes') {
      return "<font style=\"color:#666666; font-family:helvetica; text-decoration:none; font-size:10pt;\"><strong>Jump to:</strong> [ <strong><a href=\"$all_url\">all</a></strong> | <strong><a href=\"$security_url\">security</a></strong> | <font color=\"black\"><strong>bug fixes</strong></font> | <strong><a href=\"$enhancement_url\">enhancements</a></strong> ]</font>";
  }

  if ($errata_type eq 'enhancements') {
    return "<font style=\"color:#666666; font-family:helvetica; text-decoration:none; font-size:10pt;\"><strong>Jump to:</strong> [ <strong><a href=\"$all_url\">all</a></strong> | <strong><a href=\"$security_url\">security</a></strong> | <strong><a href=\"$bug_fix_url\">bug fixes</a></strong> | <font color=\"black\"><strong>enhancements</strong></font> ]</font>";
  }

  return '';
}

sub public_errata_list {
  my $pxt = shift;
  my %params = @_;

  #$my $product = $pxt->param('product');
  my $path_info = $pxt->path_info;
  my $product_label;

  if ($path_info) {

    if ($path_info =~ m/\/(.*?)-errata/) {
      $product_label = $1;
    }
    elsif ($path_info =~ m/\/(.*?-powertools)/) {
      $product_label = $1;
    }

  }

  $pxt->redirect('/file_not_found.pxt') unless $product_label;

  my $errata_type;
  my $order_by;

  if ($path_info =~ m/security/) {
    $errata_type = $errata_types{'security'}->[1];
  }
  elsif ($path_info =~ m/bugfixes/) {
    $errata_type = $errata_types{'bug_fixes'}->[1];
  }
  elsif ($path_info =~ m/updates/) {
    $errata_type = $errata_types{'enhancements'}->[1];
  }

  if ($pxt->dirty_param('by') and grep { $pxt->dirty_param('by') eq $_ } qw/date synopsis advisory severity/) {
    $order_by = $pxt->dirty_param('by');
  }

  my @errata;

  my $product = RHN::Product->name_by_label($product_label);
  unless ($product) {
    my $uri = $pxt->uri;
    $uri =~ s|^.*/||;
    warn "Invalid product in Sniglets::public_errata_search - '$product_label'\n";
    $pxt->redirect('http://www.redhat.com/support/errata/archives/' . $uri);
  }

  @errata = RHN::Errata->errata_list_by_product($product_label, $errata_type, $order_by);

  my $num_errata = @errata;
  $pxt->pnotes(errata_total => $num_errata);

  my $block = $params{__block__};
  my $ret = '';
  my $counter = 1;

  foreach my $errata (@errata) {
    my %subst;

    if ($counter % 2) {
      $subst{class} = 'list-row-odd';
    }
    else {
      $subst{class} = 'list-row-even';
    }

    $counter++;

    $subst{errata_advisory_name} = $errata->[1];
    $subst{errata_synopsis} = $errata->[2];
    $subst{errata_update_date} = $errata->[3];
    $subst{errata_advisory_type} = $errata->[4];
    $subst{errata_type} = $errata_types_reverse{$errata->[4]};
    $subst{errata_description} = $errata->[5];
    $subst{severity} = $errata->[7];

    PXT::Utils->escapeHTML_multi(\%subst);

    my $color = $counter % 2 ? 'grey' : 'white';

    $subst{errata_icon} = PXT::HTML->img(-src => $e_icons{$errata->[4]}->{$color},
					 -alt => $e_icons{$errata->[4]}->{alt},
					 -align => "absmiddle");

    $errata->[1] =~ m/^(.*?):(.*?)$/;
    my $advisory = "$1-$2";

    $subst{errata_advisory_html_version} = "$advisory\.html";

    $ret .= PXT::Utils->perform_substitutions($block, \%subst);
  }

  return $ret;
}

1;
