# -*- perl -*-
#############################################################################
# Pod/HTML.pm -- converts Pod to HTML
#
# Copyright (C) 1999,2000 by Marek Rouchal. All rights reserved.
# This package is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#############################################################################

package Marek::Pod::HTML;

=head1 NAME

Marek::Pod::HTML - convert Perl POD documents to HTML

=head1 SYNOPSIS

  use Pod::HTML;
  pod2html( { -dir => 'html' },
    { '/usr/lib/perl5/Pod/HTML.pm' => 'Pod::HTML' });

=head1 DESCRIPTION

THIS IS PRELIMINARY SOFTWARE! The C<Marek::> namespace is strictly
preliminary until a regular place in CPAN is found.

B<Pod::HTML> converts one or more Pod documents into individual HTML
files. This is meant to be a successor of Tom Christiansen's original
Pod::HTML. However it is not a plug-in replacement as there are
significant differences.

When no document is specified, this script acts as a filter
(from STDIN to STDOUT). No index or table of contents is generated.
In any other case one or more corresponding F<.html> file(s) is/are
created.

Optionally B<Pod::HTML> can generate a table of contents and an index.
As it makes use of the L<HTML::Element|HTML::Element> module, it can
also generate Postscript output using L<HTML::FormatPS|HTML::FormatPS>.

There is a hook for customization of the translation result before
writing the actual HTML.

=head2 Pod directives and their translation

The following section gives an overview of the translation equivalences.

=over 4

=item C<=head>I<n>

A heading is turned into a HTML heading, e.g. C<=head1> corresponds to
C<E<lt>H2E<gt>>. The C<E<lt>H1E<gt>> heading is reserved for page titles.

=item S<C<=over> I<n>>, C<=item>, C<=back>

Itemized lists are turned into either C<E<lt>OLE<gt>> (numbered list),
C<E<lt>ULE<gt>> (buletted list), or C<E<lt>DLE<gt>> (definition list),
depending on whether the first item in the list starts with a digit,
a number or nothing, or anything else, respectively.

=item C<S<=for html>>, C<S<=begin html>>, C<=end>

Paragraphs starting with C<=for html> or encapsulated in
C<S<=begin html>> are parsed as HTML and included into the document.
All other C<=for>/C<=begin> paragraphs are ignored.

=item C<BE<lt>...E<gt>>

Turned into bold text using E<lt>BE<gt>...E<lt>/BE<gt>.

=item C<IE<lt>...E<gt>>

Turned into italic text using E<lt>IE<gt>...E<lt>/IE<gt>.

=item C<CE<lt>...E<gt>> C<FE<lt>...E<gt>>

Turned into monospaced (typewriter) text using 
E<lt>CODEE<gt>...E<lt>/CODEE<gt>.

=item C<EE<lt>...E<gt>>

Pod entities are mapped to the corresponding HTML characters or
entities. The most important HTML entities (e.g. C<EE<lt>copyE<gt>>)
are recognized. See also L<HTML::Entities>.

=item C<SE<lt>...E<gt>>

All whitespace in this sequence is turned into C<&nbsp;>, i.e.
non-breakable spaces.

=item C<XE<lt>...E<gt>>

The text of this sequence is included in the index (along with all
non-trivial C<=item> entries), pointing to the place of its ocurrence
in the text.

=item C<LE<lt>...E<gt>>

Pod hyperlinks are turned into active HTML hyperlinks if the destination
has been found in the Pod documents processed in this conversion session.
Otherwise the link text is simply underlined.

Note: There is no caching mechanism for deliberate reasons: a) One does
not run huge conversion jobs three times a day, so performance is not
the most important goal, b) caching is hard to code, and c) although
following conversion jobs could make profit of the existing cache of
destination nodes in the already converted documents, these will not
notice that some of their previously unresolved links may now be ok
because the required document has been converted. Conclusion: Run
B<pod2html> over I<all> your Pod documents after adding new ones and
you will have a consistent state.

As a special unofficial feature HTML hyperlinks are also supported:
C<LE<lt>http://www.perl.comE<gt>>.

=back

=head2 Options

B<pod2html> recognizes the following options. Those passed to the
B<Pod::HTML> class directly are marked with (*).

=over 4

=item B<-converter> I<module>

The converter class to use, defaults to C<Pod::HTML>. This hook allows
for simple customization, see also L<"Customizing">.

=item B<-suffix> I<string>

Use this string for links to other converted Pod documents. The default
is C<.html> and also sets the filename suffix unless B<-filesuffix> has
been specified. The dot must be included!

=item B<-filesuffix> I<string>

Use this string as a suffix for the output HTML files. This does not
change the suffix used in the hyperlinks to different documents. This
feature is meant to be used if some (Makefile based) postprocessing
of the generated files has to be performed, but without having to
adapt the links.

=item B<-dir> I<path>

Write the generated HTML files (can be a directory hierarchy) to this
path. The default is the current working directory.

=item B<-libpods> I<name1,name2,...>

This option activates a highly magical feature: The C<=item> nodes of
the specified Pod documents (given by Pod name, e.g. C<Pod::Parser>)
serve as destinations for highlighted text in all converted Pod
documents. Typical usage: When converting your Perl installation's
documentation, you may want to say

  pod2html -libpods perlfunc,perlvar,perlrun -script -inc

then you will get a hyperlink to L<perlvar|perlvar> in the text
C<IE<lt>$|E<gt>>.

=item B<-localtoc> I<bool>

This is by default true, so that at the top of the page a local
table of contents with all the C<=head>I<n> lines is generated.

=item B<-navigation> I<bool>

When using the default customization, this flag enables or disables
the navigation in the header of each Pod document.

=item B<-toc> I<bool>

If true, a table of contents is built from the processed Pod documents.

=item B<-idx> I<bool>

If true, an index is built from all C<=item>s of the processed Pod
documents.

=item B<-tocname> I<name>

Use I<name> as the filename of the table of contents. Default is
F<podtoc>. The general file suffix is added to this name.

=item B<-idxname> I<name>

Use I<name> as the filename of the index. Default is
F<podindex>. The general file suffix is added to this name.

=item B<-toctitle> I<string>

The string that is used as the heading of the table of contents.
Default is `Table of Contents'.

=item B<-idxtitle> I<string>

The string that is used as the heading of the table of contents.
Default is `Index'.

=item B<-ps> I<bool>

In addition to HTML, generate also Postscript output. The suffix is
F<.ps>.

=item B<-psdir>

The root directory where to write Postscript files. Defaults to the
same as B<-dir>.

=item B<-psfont> I<fontname>

Generate Postscript files using the font I<fontname>. Default is
`Helvetica'.

=item B<-papersize> I<size>

Generate Postscript files using the paper size I<size>. Default is
`A4'.

=item B<-warnings> I<bool>

When processing the first pass, print warnings. See L<Pod::Checker>
for more information on warnings. Note: This can procude a lot of
output if the Pod source does not correspond to strict guidelines.

=back

=cut

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
use File::Basename;
use File::Path;
use Pod::Parser;
use Pod::Checker;
use HTML::Entities;
use HTML::TreeBuilder;

$VERSION = '0.44';
@ISA = qw(Exporter Pod::Parser);

@EXPORT = qw();
@EXPORT_OK = qw(&pod2html &_construct_file_name);

##############################################################################

# this is used everywhere
my $NBSP = HTML::Entities::decode_entities('&nbsp;');

# This makes HTML::Element print properly opened and closed <P> tags
$HTML::Tagset::optionalEndTag{'p'} = 0;

##---------------------------------
## Function definitions begin here
##---------------------------------

sub pod2html {
    my (%opts,%PODS);
    # options hash
    if(ref $_[0]) {
        %opts = %{shift()};
    }
    # PODs hash
    if(ref $_[0]) {
        %PODS = %{shift()};
    }
    else {
        %PODS = map { $_ => do {
            my $name = ref($_) ? 'STDIN' : $_;
            $name =~ s:^.*/::;
            $name =~ s:\.(pod|pm|pl)$::i;
            $name =~ s:\.(bat|exe|cmd)$::i if($^O =~ /win|os2/i);
            $name;
            } } @_;
    }
    # set defaults
    _default(\%opts, '-converter', 'Pod::HTML');
    _default(\%opts, '-filter', 0);
    _default(\%opts, '-suffix', '.html');
    _default(\%opts, '-filesuffix', $opts{-suffix});
    _default(\%opts, '-dir', '.');
    _default(\%opts, '-libpods', '');
    _default(\%opts, '-localtoc', 1);
    _default(\%opts, '-navigation', 1);
    _default(\%opts, '-toc', 1);
    _default(\%opts, '-idx', 1);
    _default(\%opts, '-tocname', 'podtoc');
    _default(\%opts, '-idxname', 'podindex');
    _default(\%opts, '-toctitle', 'Table of Contents');
    _default(\%opts, '-idxtitle', 'Index');
    _default(\%opts, '-ps', 0);
    _default(\%opts, '-psdir', $opts{-dir});
    _default(\%opts, '-psfont', 'Helvetica');
    _default(\%opts, '-papersize', 'A4');
    _default(\%opts, '-warnings', 0);

    # only a single file?
    if($opts{-filter}) {
        $opts{-toc} = $opts{-idx} = 0;
    }
    # nothing to do
    return 0 unless(keys %PODS);

    ###################################################
    # first pass: run Pod::Checker on all the files
    # and extract hyperlink nodes
    ###################################################

    my $cache = Pod::Cache->new();
    foreach my $infile (keys %PODS) {
        warn "\n+++ Scanning $infile\n";
        ## Now create a pod scanner, based on Pod::Checker
        my $scanner = Pod::Checker->new(-warnings => $opts{'-warnings'},
                      -name => $PODS{$infile} || 'STDIN');

        ## Now check the pod document for errors
        $scanner->parse_from_file($infile, \*STDERR);
    
        ## Return the number of errors found
        my $errs = $scanner->num_errors();
        if($errs == -1) {
            warn "Warning: No POD in `$infile', skipping\n";
            next;
        }
        elsif($errs > 0) {
            warn "Warning: Conversion may be garbled because of errors above\n";
        }

        my $name = $scanner->name();
        my @nodes = _unique_ids($scanner->node());

        # hack for perlrun - get the nodes for all switches
        if($name eq 'perlrun') {
            my @addnodes = ();
            my %have = map { $_->[0] => 1 } @nodes;
            foreach(@nodes) {
                if($_->[0] =~ /^(-\w)\S/ && !$have{$1}++) {
                    push(@addnodes, [ $1 , $_->[1] ]);
                }
            }
            push(@nodes,@addnodes);
        }

        ## remember settings
        $cache->item(
            -file => $infile,
            -page => $name,
            -nodes => [ @nodes ]);
    } # end first pass

    # build lookup table for libpods
    my %lib;
    foreach my $pod (split(/,/, $opts{-libpods})) {
        warn "\n+++ Adding $pod to autolink lookup table\n";
        my $have_it = $cache->find_page($pod);
        unless($have_it) {
            warn "Error: Could not find the library POD '$pod'.\n";
            next;
        }
        foreach ($have_it->nodes()) {
            my ($name,$id) = @$_;
            # only add significant nodes. The first libpod takes precedence
            if($name ne '*' && !defined $lib{$name}) {
                $lib{$name} = [ $have_it->page(), $id ];
            }
        }
    }

    #######################################################
    # second pass: do the conversion
    #######################################################

    # Schwartzian transform to reduce sort effort
    # compare case-insensitively, only in case of equality compare
    # case sensitively
    my @cache = map { $_->[0] } sort { $a->[1] cmp $b->[1] || $a->[0]->page() cmp $b->[0]->page() } 
                map { [ $_ , lc($_->page()) ] } $cache->item();
    my @index;
    # propagate some of the options
    my %conv_opts;
    for(qw(-suffix -navigation -localtoc -toc -tocname -toctitle -idx
        -idxname -idxtitle)) {
        $conv_opts{$_} = $opts{$_};
    }
    
    $conv_opts{-cache} = $cache;
    $conv_opts{-lib} = \%lib;
    $conv_opts{-mycache} = '';
    $conv_opts{'-next'} = '';
    $conv_opts{-prev} = '';

    for(my $i = 0; $i< scalar(@cache); $i++) {
        ## Now create a pod converter
        $_ = $cache[$i];
        my $infile = $_->file();
        warn "\n+++ Converting $infile\n";

        my %current_opts = %conv_opts;
        $current_opts{-name} = $_->page();
        $current_opts{-mycache} = $_;
        $current_opts{'-next'} = ($i < $#cache) ? $cache[$i+1]->page() :
            $current_opts{-idxname};
        $current_opts{-prev} = ($i > 0) ? $cache[$i-1]->page() :
            $current_opts{-tocname};

        my $converter = $opts{-converter}->new(%current_opts);

        ## Now convert it
        my $outfile;
        my $outpath = _construct_file_name($_->page(), 0, $opts{-filesuffix});
        if($opts{-filter}) {
            $outfile = \*STDOUT;
        }
        else {
            $outfile = $opts{-outfile} ? $opts{-outfile} :
              $opts{-dir} . '/' . $outpath;
            my $ddir = dirname($outfile);
            mkpath($ddir) unless(-d $ddir);
        }
        $converter->parse_from_file($infile,$outfile);
        $_->description($converter->description());
        $_->path($outpath);
        push(@index, map { $$_[1] = "$outpath#$$_[1]"; $$_[2] = $current_opts{-name}; $_ }
          $converter->indices());
        # dump postscript if requested
        if($opts{-ps}) {
            my $pspath = $opts{-psdir} . '/' . _construct_file_name(
                $_->page(), 0, '.ps');
            my $ddir = dirname($pspath);
            mkpath($ddir) unless(-d $ddir);
            _write_ps($pspath,$converter->{_html},\%opts);
        }

        # kill the HTML tree, required by HTML::Element
        $converter->{_html}->delete();

    } # end second pass

    ################################################
    # create a table of contents
    ################################################

    if($opts{-toc}) {
        # Style classes in TOC:
        # H1 CLASS=PODTOC      : Table of contents heading
        # TD CLASS=PODTOC_NAME : POD name (appears as link)
        # TD CLASS=PODTOC_DESC : Description
        warn "\n+++ Creating table of contents\n";

        # create a Pod::HTML object to gain access to the customize
        # method
        my $tocobj = bless { %conv_opts, '-next' => $cache[0]->page() },
            $opts{-converter};
        ($tocobj->{_html}, $tocobj->{_head}, $tocobj->{_body}) =
            _basic_html();
        $tocobj->depth(0);

        my $table = HTML::Element->new('table');
        $tocobj->{_body}->push_content($table, "\n");

        foreach(sort { lc $a->page() cmp lc $b->page() } $cache->item()) {
            my $anchor = HTML::Element->new('a', CLASS => 'POD_NAVLINK',
                href => $_->path());
            $anchor->push_content($_->page());
            my $row = HTML::Element->new('tr');
            my $name = HTML::Element->new('td', CLASS => 'PODTOC_NAME');
            my $text = HTML::Element->new('td', CLASS => 'PODTOC_DESC');
            $row->push_content($name, $text);
            $table->push_content($row,"\n");
            $name->push_content($anchor);
            # $desc is either a simple string or a reference to an array
            # of HTML::Element's
            if(my $desc = $_->description()) {
                $text->push_content(ref $desc ? @{$desc} : $desc);
                # correct POD_LINKs
		foreach($text->find_by_tag_name('a')) {
                    my $class = $_->attr('CLASS');
                    next unless($class && $class eq 'POD_LINK');
                    my $href = $_->attr('href');
                    $href =~ s:^(\.\./)+::; # the TOC is on top!
                    $_->attr('href', $href);
		}
            }
            else {
                # we have no description
                $text->push_content('<no description>');
            }
        }

        # add all the HTML gimmicks
        $tocobj->customize($opts{-toctitle});

        # write HTML file
        _write_html($tocobj->{_html},
            "$opts{-dir}/$opts{-tocname}$opts{-filesuffix}");

        # dump postscript output
        if($opts{-ps}) {
            _write_ps("$opts{-psdir}/$opts{-tocname}.ps",
                $tocobj->{_html}, \%opts);
        }

        # remove the HTML
        $tocobj->{_html}->delete();
    }

    ################################################
    # create an index
    ################################################

    if($opts{-idx}) {
        # Style classes in Index:
        # H1 CLASS=PODIDX     : Index heading
        # H2 CLASS=PODIDX     : Index section heading
        warn "\n+++ Creating index\n";

        my $idxobj = bless { %conv_opts, '-prev' => $cache[-1]->page() },
            $opts{-converter};
        ($idxobj->{_html}, $idxobj->{_head}, $idxobj->{_body}) =
            _basic_html();
        $idxobj->depth(0);

        # now generate the real index

        my %idx;
        foreach(@index) {
            my ($text,$id, $page) = @$_;
            my $key;
            if($text =~ /^\W*([a-z])/i) {
                $key = uc($1);
            }
            elsif($text =~ /^\W*([0-9])/) {
                $key = '0-9';
            }
            else {
                $key = 'Sym';
            }
            push(@{$idx{$key}{$text}}, [ $id, $page ]);

        }
        foreach my $key (qw(Sym 0-9), sort keys %idx) {
            next unless(defined $idx{$key});
            my $heading = HTML::Element->new('h2', CLASS => 'PODIDX');
            $heading->push_content($key);
            $idxobj->{_body}->push_content($heading, "\n");
            foreach my $text (sort {lc $a cmp lc $b} keys %{$idx{$key}}) {
                $idxobj->{_body}->push_content($text);
                foreach(@{$idx{$key}{$text}}) {
                    my $anchor = HTML::Element->new('a', HREF => $$_[0],
                       CLASS => 'POD_NAVLINK');
                    $anchor->push_content("[$$_[1]]");
                    $idxobj->{_body}->push_content($NBSP x 2, $anchor);
                }
                $idxobj->{_body}->push_content(HTML::Element->new('br'),"\n");
            }
            delete $idx{$key};
        }

        # add all the HTML gimmicks
        $idxobj->customize($opts{-idxtitle});

        _write_html($idxobj->{_html},
            "$opts{-dir}/$opts{-idxname}$opts{-filesuffix}");

        # dump postscript if requested
        if($opts{-ps}) {
            _write_ps("$opts{-psdir}/$opts{-idxname}.ps",
            $idxobj->{_html}, \%opts);
        }

        # remove the HTML::Element objects
        $idxobj->{_html}->delete();
    }
}

# write HTML tree as PostScript
sub _write_ps
{
    my ($file,$html,$opts) = @_;

    warn "Writing PostScript $file\n";
    unless(open(PS,">$file")) {
        warn "Error: Cannot write '$file': $!\n";
        return 0;
    }
    require HTML::FormatPS;
    my $formatter = new HTML::FormatPS
                        FontFamily => $opts->{-psfont},
                        HorizontalMargin => HTML::FormatPS::mm(15),
                        VerticalMargin => HTML::FormatPS::mm(20),
                        PaperSize  => $opts->{-papersize};
    print PS $formatter->format($html);
    close(PS);
}

##-------------------------------
## Method definitions begin here
##-------------------------------

=head2 OO Interface

The B<Pod::HTML> module has an object oriented interface that allows
to customize the converter for special requirements or for
proprietary conversion tools. This section describes the most important
methods.

=over 4

=item new()

Create a new converter object. Idiom:

  my $converter = new Pod::HTML;

=cut

# set up a new object
sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my %params = @_;
    my $self = {%params};
    bless $self, $class;
    $self->initialize();
    return $self;
}

# initalize, set defaults
sub initialize {
    my $self = shift;

    ## Options
    # the POD name
    $self->{-name} ||= '';

    # the suffix for links
    $self->{-suffix} ||= '.html';

    # the short description, taken from NAME
    $self->{-description} ||= '';

    # generate local navigation
    $self->{-localtoc} = 1 unless(defined $self->{-localtoc});

    # global navigation
    $self->{-navigation} = 1 unless(defined $self->{-navigation});

    ## Internal
    # counter for headings and items
    $self->{_current_node} = 0;

    # a stack for nested lists
    $self->{_list_stack} = [];

    # a stack for nested lists
    $self->{_current_anchor} = '';

    # no parser errors here, we've seen them in the first pass
    $self->SUPER::errorsub(sub { return 1; });
}

=item customize($name)

This method is called after the complete Pod source code has been
converted, thus allowing for customizations like title, navigation
and footer. I<$name> should contain the page title.
This method also reads properties of the current Pod::HTML object
to do the customizations. It is executed for each POD file processed and
-- if enabled -- the index and the table of contents.

X<Customizing>It is quite simple to build a proprietary
customization by writing a new module that inherits from B<Pod::HTML>:

  package POD::HTML::mystyle;
  use Pod::HTML qw(pod2html);
  use vars qw(@ISA @EXPORT @EXPORT_OK);
  require Exporter;
  @ISA = qw(Pod::HTML);
  @EXPORT_OK = qw(&pod2html);
  sub customize {
    my ($self,$name) = @_;
    # if you just want to add things, use this line first:
    $self->SUPER::customize($name);
    # do your own things here
    #...
  }

For complete customization, it is a  good starting point to copy the
customize method from B<Pod::HTML>.

You can access all the converter's methods and properties through the
C<$self->method()> and C<$self->{-property}> syntax, respectively.

=cut

# this method can be overridden to customize the HTML output
sub customize {
    my ($self,$name) = @_;

    # set document class
    my $root =  HTML::Element->new('~declaration', text => 
      'DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"');
    $root->push_content("\n", $self->{_html});
    $self->{_html} = $root;

    # customize the title
    my $title = HTML::Element->new('title');
    $title->push_content($self->{-title} || $name || 'POD');
    $self->{_head}->push_content($title, "\n");

    # prepend big heading
    if($name) {
        my $titleh = HTML::Element->new('h1', CLASS => 'POD_TITLE');
        $titleh->push_content($name);
        $self->{_body}->unshift_content("\n",$titleh,"\n",
            HTML::Element->new('hr'));
    }

    if($self->{-navigation}) {
        # add navigation
        my $table = HTML::Element->new('table', width => '100%');
        $self->{_body}->unshift_content("\n",$table);

        my $tr = HTML::Element->new('tr');
        $table->push_content("\n",$tr,"\n");

        if($self->{'-next'}) {
            my $td = HTML::Element->new('td', align => 'left', width => '1%');
            my $anchor = HTML::Element->new('a', CLASS => 'POD_NAVLINK',
             href => _construct_file_name($self->{'-next'}, $self->depth(), $self->{-suffix}));
            $anchor->push_content('Next:', HTML::Element->new('br'), $self->{'-next'});
            $td->push_content($anchor);
            $tr->push_content($td);
        }

        if($self->{'-prev'}) {
            my $td = HTML::Element->new('td', align => 'left', width => '1%');
            my $anchor = HTML::Element->new('a', CLASS => 'POD_NAVLINK',
              href => _construct_file_name($self->{'-prev'}, $self->depth(), $self->{-suffix}));
            $anchor->push_content('Previous:', HTML::Element->new('br'), $self->{'-prev'});
            $td->push_content($anchor);
            $tr->push_content($td);
        }

        my $filler = HTML::Element->new('td', width => '90%');
        $filler->push_content($NBSP);
        $tr->push_content($filler);

        if($self->{-toc}) {
            my $td = HTML::Element->new('td', align => 'right', width => '1%');
            my $anchor = HTML::Element->new('a', CLASS => 'POD_NAVLILNK',
              href => _construct_file_name($self->{-tocname}, $self->depth(), $self->{-suffix}));
            my $text = '['.$self->{-toctitle}.']';
            $text =~ s/\s+/$NBSP/g;
            $anchor->push_content($text);
            $td->push_content($anchor);
            $tr->push_content($td);
        }

        if($self->{-idx}) {
            my $td = HTML::Element->new('td', align => 'right', width => '1%');
            my $anchor = HTML::Element->new('a', CLASS => 'POD_NAVLINK',
              href => _construct_file_name($self->{-idxname}, $self->depth(), $self->{-suffix}));
            my $text = '['.$self->{-idxtitle}.']';
            $text =~ s/\s+/$NBSP/g;
            $anchor->push_content($text);
            $td->push_content($anchor);
            $tr->push_content($td);
        }
    } # end navigation

    # for finding the way back to the top
    my $anchor = HTML::Element->new('a', CLASS => 'POD_NAVLINK',
        name => 'Pod_TOP_OF_PAGE');
    $self->{_body}->unshift_content("\n",$anchor);

    # customize the footer
    $anchor = HTML::Element->new('a', CLASS => 'POD_NAVLINK',
        href => '#Pod_TOP_OF_PAGE');
    $anchor->push_content('[Top]');
    $self->{_body}->push_content(HTML::Element->new('hr'), "\n", $anchor,
        " \nGenerated by Pod::HTML $VERSION on " . localtime() . "\n");
}

=item depth()

Returns how "deep" this documents is buried in the directory
hierarchy. This value is derived from the C<-name> property and is
for instance 1 for B<Pod::Parser>.

=cut

# which hierarchy level does this POD have?
sub depth {
    my ($self,$depth) = @_;
    if(defined $depth) {
        $self->{-depth} = $depth;
    } elsif(!defined $self->{-depth}) {
        $self->{-depth} = 0;
        $self->{-depth}++ while($self->{-name} =~ /::/g);
    }
    $self->{-depth};
}

=item description()

Sets or retrieves the short description from the C<=head1 NAME> section of
the Pod document. Empty if there is no such section.

=cut

# The POD description, taken out of NAME if present
sub description {
    return (@_ > 1) ? ($_[0]->{-description} = $_[1]) : $_[0]->{-description};
}

=item indices()

Add a new item or return the list of index entries of this document.
Each index is represented by an index text (in HTML) and the unique id
(i.e. the anchor name) of the index entry in the HTML document.

=cut

# store/retrieve index entries
sub indices {
    my $self = shift;
    unless(defined $self->{_indices}) {
        $self->{_indices} = [];
    }
    if(@_) {
        push(@{$self->{_indices}}, [ @_ ]);
        return $self->{_indices}->[-1];
    }
    else {
        return @{$self->{_indices}};
    }
}

=item name()

Set/retrieve the C<-name> property, i.e. the canonical Pod name
(e.g. C<Pod::HTML>).

=back

See the F<Pod/HTML.pm> file for additional helper functions that
you may use in your code, but beware: things may change there without
notice!

=cut

# set and/or retrieve canonical name of POD
sub name {
    return (@_ > 1) ? ($_[0]->{-name} = $_[1]) : $_[0]->{-name};
}

## overrides for Pod::Parser

# things to do at start of POD
sub begin_input {
    my $self = shift;

    ($self->{_html}, $self->{_head}, $self->{_body}) = 
      _basic_html();
    $self->{_current} = $self->{_body};
    $self->{_current_head1_title} = '';
}

# things to do at end of POD
sub end_pod {
    my $self = shift;
    my $out_fh = $self->output_handle();
    #delete $self->{_p_for_reuse};
    delete $self->{_current};

    # close any lists left
    while(@{$self->{_list_stack}}) {
        my $list = shift(@{$self->{_list_stack}});
        warn "Warning: autoclosing list at EOF\n";
        # nothing to do thanks to HTML::Element
    }

    ## add local TOC
    if($self->{-localtoc}) {
        $self->_local_toc();
    }

    ## Do any page customizations
    $self->customize($self->name());

    # dump it
    _write_html($self->{_html},$self->output_file(),$out_fh);
    1;
}

sub _write_html
{
    my ($obj, $file, $handle) = @_;
    warn "Writing HTML $file\n";
    my $html = $obj->as_HTML() . "\n";
    unless($handle) {
        unless(open(OUT, ">$file")) {
            warn "Error: Cannot write: $!\n";
            return 0;
        }
        print OUT $html;
        close(OUT);
    } else {
        print $handle $html;
    }
    1;
}

# expand a POD command
sub command {
    my ($self, $command, $paragraph, $line_num, $pod_para) = @_;
    my ($file, $line) = $pod_para->file_line;

    # Heading
    if ($command =~ /^head(\d)/) {
      my $n = $1;

      # close any lists left
      while(@{$self->{_list_stack}}) {
          my $list = shift(@{$self->{_list_stack}});
          warn "Warning: autoclosing list at $command"
            . " at line $line_num of file $file\n";
      $self->{_current} = $list->parent();
      }

      # expand the heading's text
      $paragraph =~ s/[\s\n]+$//;
      my @title = $self->interpolate($paragraph, $line_num);

      # retrieve the heading's id
      my $count = ($self->{_current_node})++;
      my ($node,$id) = @{$self->{-mycache}->{-nodes}->[$count]};

      # make <H2> and <H3>, but leave space for deeper
      # levels. By special request of Achim Bohnet ;-)
      my $heading = HTML::Element->new('h'.($n + 1), CLASS => "POD_HEAD$n");
      my $anchor = HTML::Element->new('a', name => $id);
      $self->{_current_anchor} = $id;
      $anchor->push_content(@title);
      $heading->push_content($anchor);
      $self->{_current}->push_content($heading,"\n");

      # save heading details for later reference
      if($n == 1) {
        $self->{_current_head1_title} = $heading->as_text();
      }
      if($self->{-localtoc}) {
          push(@{$self->{_toc}}, [ $n, $id,
          HTML::Element->clone_list(@title) ]);
      }
    }
    # Start of List
    elsif ($command eq 'over') {
        $self->{_current_anchor} = '';
        $paragraph =~ s/[\s\n]+$//;
        unshift(@{$self->{_list_stack}},
            Pod::List->new(-indent => $paragraph,
                -parent => $self->{_current}));
    }

    # a list item
    elsif ($command eq 'item') {
      # Check for an open list
      unless(@{$self->{_list_stack}}) {
        unshift(@{$self->{_list_stack}},
            Pod::List->new(-indent => 4, -parent => 
                    $self->{_current}));
        warn "Warning: =item without =over, auto-opening `=over 4'"
           . " at line $line_num of file $file\n";
      }
      my $list = $self->{_list_stack}[0];
      $paragraph =~ s/[\s\n]+$//;
      unless($list->type()) {
          # determine type of list
          if($paragraph =~ s/^()\s*\d+\.?\s*/$1/) {
              # an ordered list
              $list->type('ol');
              $list->rx('^()\s*\d+\.?\s*');
          }
          # artificial intelligence: look behind opening tags
          elsif($paragraph =~ s/^((\s*\w<)*)\s*[*]\s*/$1/ ||
                $paragraph =~ s/^\s*$//) {
              # a bulleted list
              $list->type('ul');
              $list->rx('^((\s*\w<)*)\s*[*]\s*');
          }
          else {
              # a definition list
              $list->type('dl');
          }
          $list->tag(HTML::Element->new($list->type(), CLASS => 'POD_LIST')
                    )->push_content("\n");
      $self->{_current}->push_content($list->tag(),"\n");
      } elsif(my $rx = $list->rx()) {
          # simplify the item text
          $paragraph =~ s/$rx/$1/;
      }

      # retrieve node id
      my $count = ($self->{_current_node})++;
      my ($node,$id) = @{$self->{-mycache}->{-nodes}->[$count]};
      $self->{_current_anchor} = $id;

      my @text = $self->interpolate($paragraph, $line_num);

      my $item;
      my $anchor = HTML::Element->new('a', name => $id);
      if($list->type() eq 'dl') {
          my $dt;
          my $content = $list->tag()->content();
          if(defined $content && ref($content) && @$content &&
            ref($content->[-1]) && $content->[-1]->tag() eq 'dd' &&
            $content->[-1]->is_empty()) {
              $dt = $content->[-1];
              $dt->tag('dt');
          } else {
              $dt = HTML::Element->new('dt', CLASS => 'POD_ITEM');
              $list->tag()->push_content($dt);
          }
          $dt->push_content($anchor,"\n");
          $anchor->push_content(@text);
          $item = HTML::Element->new('dd');
          $self->{_last_p_by} = 'dd';
      } else {
          $item = HTML::Element->new('li', CLASS => 'POD_ITEM');
	  if(length $paragraph) {
            my $p = HTML::Element->new('p');
            $p->push_content(@text);
            $anchor->push_content($p);
	  } else {
            $anchor->push_content(@text);
	  }
          $item->push_content($anchor);
          $item->push_content("\n");
      }
      $list->tag()->push_content($item);
      $self->{_current} = $item;

      # save item html text for later reference
      $self->indices(_to_text(@text),$id)
          if($paragraph =~ /^\s*(\w<\s*)*(\S*)/ && $2);
    }

    # End of a list
    elsif ($command eq 'back') {
        $self->{_current_anchor} = '';
        my $list = shift(@{$self->{_list_stack}});
        unless($list) {
            warn "Warning: =back without =over, ignoring"
              . " at line $line_num of file $file\n";
        }
        else {
        $self->{_current} = $list->parent();
        }
    }

    # 'for' converter paragraph
    elsif ($command eq 'for') {
        $self->{_current_anchor} = '';
        $paragraph =~ s/[\s\n]+$//s;
        if($paragraph =~ s/^[\s\n]*(\S+)[\s\n]*// && lc($1) eq 'html') {
            my $curr = $self->{_current};
            my $p = _get_last_p_or_new($curr, 'POD_RAW');
            $self->_push_raw_html($p,$paragraph);
        }
    }

    # 'begin' converter brace
    elsif ($command eq 'begin') {
        $self->{_current_anchor} = '';
        unless($paragraph =~ /(\S+)/) {
            warn "Warning: =begin without parameter, ignoring"
              . " at line $line_num of file $file\n";
        }
        else {
            $self->{_begin} = lc($1);
            if($self->{_begin} eq 'html') {
                # set up a raw HTML storage
                $self->{_raw_html} = '';
            }
        }
    }

    # 'end' converter brace
    elsif ($command eq 'end') {
        $self->{_current_anchor} = '';
        $self->{_begin} = undef;
        # do I have html?
        if($self->{_raw_html}) {
            # try to find a preceding <P> tag
            my $curr = $self->{_current};
            my $p = _get_last_p_or_new($curr, 'POD_RAW');
            $self->_push_raw_html($p,$self->{_raw_html});
            delete $self->{_raw_html};
        }
    }
    # ignore all the rest
}

sub _get_last_p_or_new
{
    my ($curr,$class) = @_;
    my $p;
    my $content = $curr->content();
    if(defined $content && ref($content) && @$content &&
      ref($content->[-2]) && $content->[-2]->tag() eq 'p') {
        $p = $content->[-2];
    } else { # need a new one
        $p = HTML::Element->new('p', CLASS => $class);
        $curr->push_content($p,"\n");
    }
    $p;
}

# process a verbatim paragraph
sub verbatim {
    my ($self, $paragraph, $line_num, $pod_para) = @_;

    $self->{_current_anchor} = '';
    # strip trailing whitespace
    $paragraph =~ s/[\s\n]+$//s;

    unless(length($paragraph)) {
        # just an empty line
        $self->{_current}->push_content(HTML::Element->new('p'), "\n");
    }
    elsif(!$self->{_begin}) {
        # a regular paragraph
        my $pre;
        my $content = $self->{_current}->content();
        # reuse last <pre> if immediate predecessor
        if(defined $content && ref($content) && @$content &&
          ref($content->[-2])) {
            if($content->[-2]->tag() eq 'pre') {
                $pre = $content->[-2];
            }
            elsif($content->[-2]->tag() eq 'p') {
                $pre = $content->[-2];
                $pre->tag('pre')
            }
            else {
                goto new_pre;
            }
        }
        else {
          new_pre:
            $pre = HTML::Element->new('pre', CLASS => 'POD_VERBATIM');
            $self->{_current}->push_content($pre,"\n");
        }
        $pre->push_content("\n");

        if($self->{_current_head1_title} eq 'NAME' && !$self->description()) {
            # save the description for further use in TOC
        my $str = $paragraph;
        $str =~ s/^[\n\s]+//;
            $self->description($str) if($str);
        }
        # this is special in perl.pod
        foreach(split(/\n/,$paragraph)) {
            # TODO expand tabs correctly?
            if(s/^(\s+)([\w:]+)(\t+)//) {
                # this is for perl.pod - an implied list
                my ($indent,$page,$postdent) = ($1,$2,$3);
                my $dest = $self->{-cache}->find_page($page);
                if($dest) {
                    my $destfile = _construct_file_name(
                        $dest->page(), $self->depth(), $self->{-suffix});
                    my $link = HTML::Element->new('a', href => $destfile,
                        CLASS => 'POD_LINK');
                    $link->push_content($page);
                    $page = $link;
                }
                $pre->push_content($indent,$page,$postdent,$_,"\n");
            } else {
                $pre->push_content($_,"\n");
            }
        }
    }
    # a "verbatim" =begin html paragraph
    elsif($self->{_begin} eq 'html') {
        $self->{_raw_html} .= $paragraph;
    }
}

# a regular text paragraph
sub textblock {
    my ($self, $paragraph, $line_num, $pod_para) = @_;

    $paragraph =~ s/[\s\n]+$//s;

    # regular context
    if(!$self->{_begin}) {
        my @text = $self->interpolate($paragraph, $line_num);
        # remember first paragraph in NAME section
        if($self->{_current_head1_title} eq 'NAME' && $paragraph &&
          !$self->description()) {
            # save the description for further use in TOC
            $self->description([ HTML::Element->clone_list(@text) ]);
        }
        my $par;
        if($self->{_last_p_by} && $self->{_last_p_by} eq 'dd') {
          $par = $self->{_current};
          delete $self->{_last_p_by};
        }
        elsif($self->{_last_p_by} && $self->{_last_p_by} eq 'beginfor') {
          $par = _get_last_p_or_new($self->{_current}, 'POD_TEXT');
        }
        else {
          $par = HTML::Element->new('p', CLASS => 'POD_TEXT');
          $self->{_current}->push_content($par, "\n");
        }
        $par->push_content("\n",@text,"\n");
        $self->{_last_p_by} = 'text';
    }
    # =begin html context
    elsif($self->{_begin} eq 'html') {
        $self->{_raw_html} .= $paragraph;
    }
    # reset currrent anchor this late so that in this par no autolinks
    # are generated
    $self->{_current_anchor} = '';
}

# expand a POD text string
sub interpolate {
    my ($self, $paragraph, $line) = @_;
    ## Check the interior sequences in the command-text
    # and return the text as array of HTML::Element's
    $self->_expand_ptree(
        $self->parse_text($paragraph,$line), $line, '');
}

sub _expand_ptree {
    my ($self,$ptree,$line,$nestlist) = @_;
    local($_);
    my @text = ();
    # process each node in the parse tree
    foreach(@$ptree) {
        # regular text chunk
        unless(ref) {
            my $chunk = $_;
            # do magic linebreaking
            while($chunk =~ s/^([^\n]*)\n([ \t]+)//) {
                my ($line,$indent) = ($1,$2);
                $line =~ s/\s/$NBSP/g if($nestlist =~ /S/);
                push(@text, $line, HTML::Element->new('br'),
                    _expand_tab($indent) );
            }
            # escape whitespace if in S<>
            if($chunk) {
                $chunk =~ s/\s/$NBSP/g if($nestlist =~ /S/);
                push(@text,$chunk);
            }
            next; # finished this chunk
        }
        # have an interior sequence
        my $cmd = $_->cmd_name();
        my $contents = $_->parse_tree();
        my $file;
        ($file,$line) = $_->file_line();

        # an entity
        if($cmd eq 'E') {
            my $entity = $contents->raw_text();
            $entity =~ s/^[\n\s]+|[\n\s]+$//g;
            if($entity =~ /^(0x[0-9a-f]+)$/i) {
                # hexadecimal
                push(@text, chr(hex($1)));
            }
            elsif($entity =~ /^(0[0-7]+)$/) {
                # octal
                push(@text, chr(oct($1)));
            }
            elsif($entity =~ /^(\d+)$/) {
                # decimal
                push(@text, chr($1));
            }
            elsif($entity =~ /^sol$/i) {
                # forward slash
                push(@text, '/');
            }
            elsif($entity =~ /^verbar$/i) {
                # vertical bar
                push(@text, '|');
            }
            else {
                # textual entity
                push(@text, HTML::Entities::decode_entities("&$entity;") || '');
            }
        }

        # a hyperlink
        elsif($cmd eq 'L') {
            # try to parse the hyperlink
            my $raw = $contents->raw_text();
            my $link = Pod::Hyperlink->new($raw);
            unless(defined $link) {
                # the link cannot be parsed
                my $underline = HTML::Element->new('u');
                $underline->push_content($raw);
                push(@text,$underline);
                next;
            }

            # only underline if destination not found
            $self->{_link_pagemark} = 'u';
            $self->{_link_pageopt} = +{};
            $self->{_link_sectionmark} = 'u';
            $self->{_link_sectionopt} = +{};

            # search for page
            my $page = $link->page();
            $page =~ s/[(]\w*[)]$//; # strip manpage section
            my $dest;
            my $destfile = '';
            if($page) {
                $dest = $self->{-cache}->find_page($page);
                if($dest) {
                    $destfile = _construct_file_name(
                        $dest->page(), $self->depth(), $self->{-suffix});
                    $self->{_link_pagemark} = $self->{_link_sectionmark} = 'a';
                    $self->{_link_pageopt} =
                        $self->{_link_sectionopt} = 
                        { CLASS => 'POD_LINK', HREF => $destfile };
               }
               else {
                   warn "Cannot find page `$page' at L<> on line $line\n";
               }
            } else {
                $dest = $self->{-mycache};
            }

            if($link->type() eq 'hyperlink') {
                $self->{_link_sectionmark} = 'a';
                $self->{_link_sectionopt} =
                    { CLASS => 'POD_LINK', HREF => $link->node() };
            } else {
                # search for node in page
                my $node = '';
                # use Pod::Checker's expand procedure to get the link
                # destination node
                if($link->node()) {
                    my $cruncher = Pod::Checker->new(-quiet => 1);
                    $cruncher->errorsub(sub { 1; }); # suppress any errors
                    $node = $cruncher->interpolate_and_check($link->node(),
                        $line,$file);
                }
                if($dest && $node) {
                    my $id = $dest->find_node($node);
                    if($id) {
                        $self->{_link_sectionmark} = 'a';
                        $self->{_link_sectionopt} =
                            { CLASS => 'POD_LINK', HREF => "$destfile#$id" };
                    } else {
                        my $inpage = $page ? " in page `$page'" : '';
                        warn "Cannot find node `$node'$inpage at L<> on line $line\n";
                    }
                }
            }
            $link->line($line); # remember line

            # convert the link text (expand POD markup)
            push(@text, $self->_expand_ptree($self->parse_text(
                $link->markup(), $line), $line, "$nestlist$cmd"));
        }

        # internal: hyperlink to page
        elsif($cmd eq 'P') {
            my $tag = HTML::Element->new($self->{_link_pagemark}, 
                %{$self->{_link_pageopt}});
            push(@text,$tag);
            $tag->push_content($self->_expand_ptree($contents, $line,
                 "$nestlist$cmd"));
        }

        # internal: hyperlink to section
        elsif($cmd eq 'Q') {
            my $tag = HTML::Element->new($self->{_link_sectionmark}, 
                %{$self->{_link_sectionopt}});
            push(@text,$tag);
            $tag->push_content($self->_expand_ptree($contents, $line,
                "$nestlist$cmd"));
        }

        # bold text
        elsif($cmd eq 'B') {
            $self->_autolink_and_highlight(\@text, $contents, $line, 
              "$nestlist$cmd", 'b', 0);
        }

        # code text
        elsif($cmd eq 'C') {
            $self->_autolink_and_highlight(\@text, $contents, $line, 
              "$nestlist$cmd", 'code', 1);
        }

        # file text
        elsif($cmd eq 'F') {
            $self->_autolink_and_highlight(\@text, $contents, $line, 
              "$nestlist$cmd", 'code' , 0);
        }

        # italic text
        elsif($cmd eq 'I') {
            # TODO I<...I<...>...> should be expanded to
            # <I>...</I>...<I>...</I> - according to Achim Bohnet
            $self->_autolink_and_highlight(\@text, $contents, $line, 
              "$nestlist$cmd", 'i', 0);
        }

        # non-breakable space
        elsif($cmd eq 'S') {
            # will be taken care of above, when expanding text chunk
            push(@text, $self->_expand_ptree($contents, $line, "$nestlist$cmd"));
        }

        # zero-size element
        elsif($cmd eq 'Z') {
            # do nothing - a comment would be nice
            # &#x200B; is the correct entity, but it won't work with the
            # current HTML::Entities
        }

        # custom index entries
        # TODO these should run also through Pod::Checker and result in
        # valid L<...> destinations
        elsif($cmd eq 'X') {
            # set up a fast lookup cache for node ids
            unless($self->{_ids}) {
                %{$self->{_ids}} = map { $_->[1] => 1 }
                    @{$self->{-mycache}->{-nodes}};
            }
            # tag this with a unique identifier and add it to the index
            my $id = _idfy($contents->raw_text(), $self->{_ids});
            $self->{_ids}->{$id} = 1; # remember it
            my $tag = HTML::Element->new('a', name => $id);
            my @key = $self->_expand_ptree($contents, $line, "$nestlist$cmd");
            #$tag->push_content(@key);
            push(@text,$tag);
            $self->indices(_to_text(@key),$id);
        }
        # ignore everything else
    }
    @text;
}

## Helpers

# set some default value unless already defined
sub _default
{
    $_[0]->{$_[1]} = $_[2] unless(defined $_[0]->{$_[1]});
}

# setup the basic frame for a HTML tree
sub _basic_html
{
    my $html = HTML::Element->new('html');
    my $head = HTML::Element->new('head');
    $head->push_content("\n",
      HTML::Element->new('meta', 'http-equiv' => 'Content-Type',
        content => 'text/html; charset=ISO-8859-1'), "\n",
      HTML::Element->new('meta', 'http-equiv' => 'Content-Style-Type',
        content => 'text/css'), "\n",
      HTML::Element->new('meta', 'name' => 'GENERATOR',
        content => "Pod::HTML $VERSION"), "\n");
    $html->push_content("\n",$head,"\n");
    my $body = HTML::Element->new('body');
    $body->push_content("\n");
    $html->push_content($body,"\n");
    ($html,$head,$body);
}

# create a set of unique ids
sub _unique_ids {
    my (@nodes) = @_;

    # we need the hashes both ways...
    my %hash = ();
    my %Node = ();
    foreach my $node (@nodes) {
        # start with string
        my $id = _idfy($node,\%hash);
    $hash{$id} = 1;
        $Node{$node} = $id;
    $node = [ $node, $id ];
    }
    # create secondary nodes (needed mainly for perlfunc)
    my @addnodes = ();
    foreach my $node (keys %Node) {
        if($node =~ /^(\S+)\s+\S/) { # more than one word
            push(@addnodes, [ $1, $Node{$node} ]) unless(defined $Node{$1});
        }
    }
    @nodes,@addnodes;
}

# turn a string into a unique id
# hashref points to a has with already existing ids
sub _idfy
{
    my ($id,$hashref) = @_;
  
    # collapse entities
    $id =~ s/E<([^>]*)>/$1/g;
    # collapse all non-alphanum characters to _
    $id =~ s/\W+/_/g;
    # collapse multiple _
    $id =~ s/_{2,}/_/g;
    # abbreviate to 20 characters
    $id = substr($id,0,20);
    # has to have some contents
    $id = '_' unless($id);
    my $ext = '';
    # find something unique
    $ext++ while($hashref->{$id.$ext});
    $id . $ext;
}


# prepend a paragraph with links to an HTML object's contents
sub _add_links {
    1;
}

# turn a POD name into a HTML file name
sub _construct_file_name {
    my ($file,$depth,$suffix) = @_;
    $file =~ s!::!/!g; #/
    $file .= $suffix if($suffix);
    ('../' x $depth) . $file;
}

# check if linkable and put into appropriate tag
sub _autolink_and_highlight
{
    my ($self,$tref,$contents,$line,$nest,$type,$doit) = @_;

    my $tag = HTML::Element->new($type);
    push(@$tref,$tag);
    # canonicalize raw_text before lookup
    my $cruncher = Pod::Checker->new(-quiet => 1);
    $cruncher->errorsub(sub { 1; }); # suppress any errors
    my $text = $cruncher->interpolate_and_check($contents->raw_text(),
        $line,'');
    $text =~ s/^\s+|\s+$//g;
    my ($node_ref); # will contain [$page,$id]
    # try to find text in the libpod nodes. Do not link if
    # currently processing the anchor paragraph itself
    # (avoid reciprocal links)
    if($doit && $self->{-lib} &&
      ($node_ref = $self->{-lib}->{$text}) &&
      !($$node_ref[0] eq $self->{-name} &&
       $$node_ref[1] eq $self->{_current_anchor})) {
        my $anchor = HTML::Element->new('a', CLASS => 'POD_LINK',
          href => _construct_file_name($$node_ref[0], $self->depth(),
            $self->{-suffix} . '#' . $$node_ref[1]));
        $tag->push_content($anchor);
        $tag = $anchor;
    }
    $tag->push_content($self->_expand_ptree($contents, $line, $nest));
}

# expand blanks and tabs to an appropriate amount of non-breaking space
sub _expand_tab {
    # TODO more magic: indent by one blank less than in $str -
    # this would allow for the missing E<br> syntax
    my ($str, $pos) = @_;
    my $new = '';
    $pos ||= 0;
    while($str =~ m/([ \t])/g) {
        if($1 eq ' ') {
            $new .= $NBSP;
            $pos++;
        }
        else {
            my $len = $pos % 8;
            $len = 8 unless($len);
            $new .= $NBSP x $len;
            $pos += $len;
        }
    }
    $new;
}

# prepend local navigation to body
sub _local_toc {
    my $self = shift;
    if(defined $self->{_toc}) {
        my $level = 1;
        my @hier = ( HTML::Element->new('ul') );
        $hier[0]->push_content("\n");
        $self->{_body}->unshift_content("\n", $hier[0], "\n",
          HTML::Element->new('hr'));
        foreach(@{$self->{_toc}}) {
            my ($l, $id, @line) = @$_;
            while($l > $level) {
                # new sublevel
                push(@hier, HTML::Element->new('ul'));
                $hier[-2]->push_content($hier[-1], "\n");
                $level++;
                $hier[-1]->push_content("\n");
            }
            while($l < $level) {
                pop(@hier);
                $level--;
            }
            my $item = HTML::Element->new('li');
            my $anchor = HTML::Element->new('a', CLASS => 'POD_NAVLINK',
                href => "#$id");
            $item->push_content($anchor);
            $anchor->push_content(@line);
            $hier[-1]->push_content($item, "\n");
        }
    }
}

# push a raw HTML string on the current contents
sub _push_raw_html {
    my ($self,$node,$str) = @_;
    my $tree = new HTML::TreeBuilder;
    $tree->warn(1);
    $tree->implicit_tags(1);
    $tree->ignore_unknown(1);
    $tree->store_comments(1);
    $tree->p_strict(1);
    #$tree->implicit_body_p_tag(1);
    $tree->parse($str);
    $tree->eof;
    my $head = $tree->find_by_tag_name('head');
    $self->{_head}->push_content(@{$head->content()},"\n")
        if($head && $head->content());
    my $body = $tree->find_by_tag_name('body');
    $node->push_content(@{$body->content()})
        if($body && $body->content());
    # this will not delete the contents, they have been pushed
    # somewhere else
    $tree->delete();

    # consolidate p tags, i.e. re-root them appropriately
    my $lastp;
    if($node->tag() eq 'p') {
      my $root = $node->parent();
      foreach($node->content_refs_list) {
        if(ref $$_ && $$_->tag() eq 'p') {
          my $parent = $$_->parent();
          my $pindex = $$_->pindex();
          my ($p,@rest) = $parent->splice_content($pindex);
          if(@rest) {
            my %attr = $node->all_attr();
            my $newp = HTML::Element->new('p', $node->all_external_attr());
            $newp->push_content(@rest);
            $root->push_content($p,"\n",$newp,"\n");
            $lastp = 'beginfor';
          } else {
            $root->push_content($p,"\n");
            $lastp = 'raw';
          }
        }
      }
    }
    $self->{_last_p_by} = $lastp || 'beginfor';
    1;
}

# process a part of HTML::Element into plain text
sub _to_text {
    my @out;
    foreach(@_) {
        if(ref $_) {
            push(@out, $_->as_text());
        }
        else {
            push(@out, HTML::Entities::decode_entities($_));
        }
    }
    join('',@out);
}

# needed to get rid of all HTML::Element's
sub DESTROY {
    my $self = shift;
    $self->{_html}->delete() if(defined $self->{_html});
}

=head1 SEE ALSO

L<Pod::Checker>, L<Pod::Parser>, L<Pod::Find>, L<HTML::Element>,
L<HTML::TreeBuilder>, L<HTML::Entities>, L<HTML::FormatPS>,
L<HTML::Tagset>, L<pod2man>, L<pod2text>, L<Pod::Man>

=head1 AUTHOR

Marek Rouchal E<lt>marekr@cpan.org<gt>

=head1 HISTORY

A big deal of this code has been recycled from a variety of existing
Pod converters, e.g. by Tom Christiansen and Russ Allbery. A lot of
ideas came from Nick Ing-Simmons' B<PodToHtml>, e.g. the usage of the
B<HTML::Element> module and the B<HTML::FormatPS> module.
Without the B<Pod::Parser> module by Brad Appleton and the
B<HTML::Element> module by Gisle Aas this module would not exist.

=cut

1;

