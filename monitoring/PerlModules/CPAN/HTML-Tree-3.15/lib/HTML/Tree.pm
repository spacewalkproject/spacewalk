
require 5; # -*-Text-*- Time-stamp: "2002-11-06 23:43:40 MST"
package HTML::Tree;
$VERSION = $VERSION = 3.15;
  # This is where the dist gets its version from.

# Basically just a happy alias to HTML::TreeBuilder
use HTML::TreeBuilder ();

sub new {
  shift; unshift @_, 'HTML::TreeBuilder';
  goto &HTML::TreeBuilder::new;
}
sub new_from_file {
  shift; unshift @_, 'HTML::TreeBuilder';
  goto &HTML::TreeBuilder::new_from_file;
}
sub new_from_content {
  shift; unshift @_, 'HTML::TreeBuilder';
  goto &HTML::TreeBuilder::new_from_content;
}

1;  

__END__

=head1 NAME

HTML::Tree - overview of HTML::TreeBuilder et al

=head1 SYNOPSIS

  use HTML::TreeBuilder;
  my $tree = HTML::TreeBuilder->new();
  $tree->parse_file($filename);
   #
   # Then do something with the tree, using HTML::Element
   # methods -- for example $tree->dump
   #
   # Then:
  $tree->delete;

=head1 DESCRIPTION

HTML-Tree is a suite of Perl modules for making parse trees out of
HTML source.  It consists of mainly two modules, whose documentation
you should refer to: L<HTML::TreeBuilder|HTML::TreeBuilder>
and L<HTML::Element|HTML::Element>.

HTML::TreeBuilder is the module that builds the parse trees.  (It uses
HTML::Parser to do the work of breaking the HTML up into tokens.)

The tree that TreeBuilder builds for you is made up of objects of the
class HTML::Element.

If you find that you do not properly understand the documentation
for HTML::TreeBuilder and HTML::Element, it may be because you are
unfamiliar with tree-shaped data structures, or with object-oriented
modules in general.  I have written some articles for I<The Perl
Journal> (C<www.tpj.com>) that seek to provide that background:
my article "A User's View of Object-Oriented Modules" in TPJ17;
my article "Trees" in TPJ18;
and
my article "Scanning HTML" in TPJ19.
The full text of those articles is contained in this distribution, as:

L<HTML::Tree::AboutObjects|HTML::Tree::AboutObjects>
-- article: "User's View of Object-Oriented Modules"

L<HTML::Tree::AboutTrees|HTML::Tree::AboutTrees>
-- article: "Trees"

L<HTML::Tree::Scanning|HTML::Tree::Scanning>
-- article: "Scanning HTML"

Readers already familiar with object-oriented modules and tree-shaped
data structures should read just the last article.  Readers without
that background should read the first, then the second, and then the
third.

=head1 SEE ALSO

L<HTML::TreeBuilder>, L<HTML::Element>, L<HTML::Tagset>,
L<HTML::Parser>

L<HTML::DOMbo>

The book I<Perl & LWP> by me, Sean M. Burke, published by
O'Reilly and Associates, 2002.  ISBN: 0-596-00178-9

It has several chapters to do with HTML processing in general,
and HTML-Tree specifically.  There's more info at:

  http://www.oreilly.com/catalog/perllwp/
  http://www.amazon.com/exec/obidos/ASIN/0596001789

=head1 COPYRIGHT

Copyright 1995-1998 Gisle Aas; copyright 1999-2002 Sean M. Burke.
(Except the articles contained in HTML::Tree::AboutObjects,
HTML::Tree::AboutTrees, and HTML::Tree::Scanning, which are all
copyright 2000 The Perl Journal.)

Except for those three TPJ articles, the whole HTML-Tree distribution,
of which this file is a part, is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

Those three TPJ articles may be distributed under the same terms as
Perl itself.

The programs and documentation in this dist are distributed in
the hope that they will be useful, but without any warranty; without
even the implied warranty of merchantability or fitness for a
particular purpose.

=head1 AUTHOR

Original HTML-Tree author Gisle Aas E<lt>gisle@aas.noE<gt>; current
maintainer Sean M. Burke, E<lt>sburke@cpan.orgE<gt>

=cut

