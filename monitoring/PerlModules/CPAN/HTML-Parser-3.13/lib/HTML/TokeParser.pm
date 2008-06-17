package HTML::TokeParser;

# $Id: TokeParser.pm,v 1.1 2000-10-13 20:26:51 dfaraldo Exp $

require HTML::Parser;
@ISA=qw(HTML::Parser);
$VERSION = sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

use strict;
use Carp ();
use HTML::Entities qw(decode_entities);


sub new
{
    my $class = shift;
    my $file = shift;
    Carp::croak("Usage: $class->new(\$file)")
	  unless defined $file;

    if (!ref($file) && ref(\$file) ne "GLOB") {
	require IO::File;
	$file = IO::File->new($file, "r") || return;
    }
    my $self = $class->SUPER::new(api_version => 3);
    my $accum = $self->{accum} = [];
    $self->handler(start =>   $accum, "'S',tagname,attr,attrseq,text");
    $self->handler(end =>     $accum, "'E',tagname,text");
    $self->handler(text =>    $accum, "'T',text,is_cdata");
    $self->handler(process => $accum, "'PI',token0,text");

    # XXX The following two are not strictly V2 compatible.  We used
    # to return something that did not contain the "<!(--)?" and
    # "(--)?>" markers.
    $self->handler(comment => $accum, "'C',text");
    $self->handler(declaration => $accum, "'D',text");

    $self->{textify} = {img => "alt", applet => "alt"};
    if (ref($file) eq "SCALAR") {
	if (!defined $$file) {
	    Carp::carp("HTML::TokeParser got undefined value as document")
		if $^W;
	    $self->{toke_eof}++;
	}
	else {
	    $self->{toke_scalar} = $file;
	    $self->{toke_scalarpos}  = 0;
	}
    }
    else {
	$self->{toke_file} = $file;
    }
    $self;
}


sub get_token
{
    my $self = shift;
    while (!@{$self->{accum}} && !$self->{toke_eof}) {
	if (my $f = $self->{toke_file}) {
	    # must try to parse more from the file
	    my $buf;
	    if (read($f, $buf, 512)) {
		$self->parse($buf);
	    } else {
		$self->eof;
		$self->{toke_eof}++;
		delete $self->{toke_file};
	    }
	}
	elsif (my $sref = $self->{toke_scalar}) {
	    # must try to parse more from the scalar
	    my $pos = $self->{toke_scalarpos};
	    my $chunk = substr($$sref, $pos, 512);
	    $self->parse($chunk);
	    $pos += length($chunk);
	    if ($pos < length($$sref)) {
		$self->{toke_scalarpos} = $pos;
	    }
	    else {
		$self->eof;
		$self->{toke_eof}++;
		delete $self->{toke_scalar};
		delete $self->{toke_scalarpos};
	    }
	}
	else {
	    die;
	}
    }
    shift @{$self->{accum}};
}


sub unget_token
{
    my $self = shift;
    unshift @{$self->{accum}}, @_;
    $self;
}


sub get_tag
{
    my $self = shift;
    my $wanted = shift;
    my $token;
  GET_TOKEN:
    {
	$token = $self->get_token;
	if ($token) {
	    my $type = shift @$token;
	    redo GET_TOKEN if $type !~ /^[SE]$/;
	    substr($token->[0], 0, 0) = "/" if $type eq "E";
	    redo GET_TOKEN if defined($wanted) && $token->[0] ne $wanted;
	}
    }
    $token;
}


sub get_text
{
    my $self = shift;
    my $endat = shift;
    my @text;
    while (my $token = $self->get_token) {
	my $type = $token->[0];
	if ($type eq "T") {
	    push(@text, decode_entities($token->[1]));
	} elsif ($type =~ /^[SE]$/) {
	    my $tag = $token->[1];
	    if ($type eq "S") {
		if (exists $self->{textify}{$tag}) {
		    my $alt = $self->{textify}{$tag};
		    my $text;
		    if (ref($alt)) {
			$text = &$alt(@$token);
		    } else {
			$text = $token->[2]{$alt || "alt"};
			$text = "[\U$tag]" unless defined $text;
		    }
		    push(@text, $text);
		    next;
		}
	    } else {
		$tag = "/$tag";
	    }
	    if (!defined($endat) || $endat eq $tag) {
		 $self->unget_token($token);
		 last;
	    }
	}
    }
    join("", @text);
}


sub get_trimmed_text
{
    my $self = shift;
    my $text = $self->get_text(@_);
    $text =~ s/^\s+//; $text =~ s/\s+$//; $text =~ s/\s+/ /g;
    $text;
}

1;


__END__

=head1 NAME

HTML::TokeParser - Alternative HTML::Parser interface

=head1 SYNOPSIS

 require HTML::TokeParser;
 $p = HTML::TokeParser->new("index.html") || die "Can't open: $!";
 while (my $token = $p->get_token) {
     #...
 }

=head1 DESCRIPTION

The HTML::TokeParser is an alternative interface to the HTML::Parser class.
It basically turns the HTML::Parser inside out.  You associate a file
(or any IO::Handle object or string) with the parser at construction time and
then repeatedly call $parser->get_token to obtain the tags and text
found in the parsed document.

Calling the methods defined by the HTML::Parser base class will be
confusing, so don't do that.  Use the following methods instead:

=over 4

=item $p = HTML::TokeParser->new( $file_or_doc );

The object constructor argument is either a file name, a file handle
object, or the complete document to be parsed.

If the argument is a plain scalar, then it is taken as the name of a
file to be opened and parsed.  If the file can't be opened for
reading, then the constructor will return an undefined value and $!
will tell you why it failed.

If the argument is a reference to a plain scalar, then this scalar is
taken to be the literal document to parse.  The value of this
scalar should not be changed before all tokens have been extracted.

Otherwise the argument is taken to be some object that the
C<HTML::TokeParser> can read() from when it needs more data.  Typically
it will be a filehandle of some kind.  The stream will be read() until
EOF, but not closed.

=item $p->get_token

This method will return the next I<token> found in the HTML document,
or C<undef> at the end of the document.  The token is returned as an
array reference.  The first element of the array will be a (mostly)
single character string denoting the type of this token: "S" for start
tag, "E" for end tag, "T" for text, "C" for comment, "D" for
declaration, and "PI" for process instructions.  The rest of the array
is the same as the arguments passed to the corresponding HTML::Parser
v2 compatible callbacks (see L<HTML::Parser>).  In summary, returned
tokens look like this:

  ["S",  $tag, %$attr, @$attrseq, $text]
  ["E",  $tag, $text]
  ["T",  $text, $is_data]
  ["C",  $text]
  ["D",  $text]
  ["PI", $token0, $text]

=item $p->unget_token($token,...)

If you find out you have read too many tokens you can push them back,
so that they are returned the next time $p->get_token is called.

=item $p->get_tag( [$tag] )

This method returns the next start or end tag (skipping any other
tokens), or C<undef> if there are no more tags in the document.  If an
argument is given, then we skip tokens until the specified tag type is
found.  The tag is returned as an array reference in the same form as
for $p->get_token above, but the type code (first element) is missing
and the name of end tags are prefixed with "/".  This means that the
tags returned look like this:

  [$tag, %$attr, @$attrseq, $text]
  ["/$tag", $text]

=item $p->get_text( [$endtag] )

This method returns all text found at the current position. It will
return a zero length string if the next token is not text.  The
optional $endtag argument specifies that any text occurring before the
given tag is to be returned.  Any entities will be converted to their
corresponding character.

The $p->{textify} attribute is a hash that defines how certain tags can
be treated as text.  If the name of a start tag matches a key in this
hash then this tag is converted to text.  The hash value is used to
specify which tag attribute to obtain the text from.  If this tag
attribute is missing, then the upper case name of the tag enclosed in
brackets is returned, e.g. "[IMG]".  The hash value can also be a
subroutine reference.  In this case the routine is called with the
start tag token content as its argument and the return value is treated
as the text.

The default $p->{textify} value is:

  {img => "alt", applet => "alt"}

This means that <IMG> and <APPLET> tags are treated as text, and that
the text to substitute can be found in the ALT attribute.

=item $p->get_trimmed_text( [$endtag] )

Same as $p->get_text above, but will collapse any sequences of white
space to a single space character.  Leading and trailing white space is
removed.

=back

=head1 EXAMPLES

This example extracts all links from a document.  It will print one
line for each link, containing the URL and the textual description
between the <A>...</A> tags:

  use HTML::TokeParser;
  $p = HTML::TokeParser->new(shift||"index.html");

  while (my $token = $p->get_tag("a")) {
      my $url = $token->[1]{href} || "-";
      my $text = $p->get_trimmed_text("/a");
      print "$url\t$text\n";
  }

This example extract the <TITLE> from the document:

  use HTML::TokeParser;
  $p = HTML::TokeParser->new(shift||"index.html");
  if ($p->get_tag("title")) {
      my $title = $p->get_trimmed_text;
      print "Title: $title\n";
  }

=head1 SEE ALSO

L<HTML::Parser>

=head1 COPYRIGHT

Copyright 1998-2000 Gisle Aas.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
