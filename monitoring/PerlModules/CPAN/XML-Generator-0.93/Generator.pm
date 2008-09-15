package XML::Generator;

use strict;
use Carp;
use vars qw/$VERSION $AUTOLOAD/;

$VERSION = '0.93';

=head1 NAME

XML::Generator - Perl extension for generating XML

=head1 SYNOPSIS

   use XML::Generator;
  
   my $xml = XML::Generator->new(escape => 'always',
                                 pretty => 2,
                                 conformance => 'strict');

   print $xml->foo($xml->bar({ baz => 3 }, $xml->bam),
		   $xml->bar([ 'qux' ], "Hey there, world"));
 
   # The above would yield:
   <foo>
     <bar baz="3">
       <bam />
     </bar>
     <qux:bar>Hey there, world</qux:bar>
   </foo>

=head1 DESCRIPTION

In general, once you have an XML::Generator object, you then simply call
methods on that object named for each XML tag you wish to generate. 
Say you want to generate this XML:

   <person>
     <name>Bob</name>
     <age>34</age>
     <job>Accountant</job>
   </person>

Here's a snippet of code that does the job, complete with pretty printing:

   use XML::Generator;
   my $gen = XML::Generator->new(escape => 'always', pretty => 2);
   print $gen->person(
            $gen->name("Bob"),
            $gen->age(34),
            $gen->job("Accountant")
         );

The only problem with this is if you want to use a tag name that Perl's
lexer won't understand as a method name, such as "shoe-size".  Fortunately,
since you can always call methods as variable names, there's a simple
work-around:

   my $shoe_size = "shoe-size";
   $xml = $gen->$shoe_size("12 1/2");

Which correctly generates:

   <shoe-size>12 1/2</shoe-size>

You can use a hash ref as the first parameter if the tag should include
atributes.  An array ref can be supplied as the first argument to indicate
a namespace for the element and the attributes (the elements of the array
are concatenated with ':').  Under strict conformance, however, you are
only allowed one namespace component.

If you want to specify a namespace as well as attributes, you can make the
second argument a hash ref.  If you do it the other way around, the array ref
will simply get stringified and included as part of the content of the tag.
If an XML::Generator object has a namespace set, and a namespace is also
supplied to the tag, the supplied namespace overrides the default.

Here's an example to show how the attribute and namespace parameters work:

   $xml = $gen->account({ type => 'checking', id => '34758'},
	    $gen->open(['transaction'], 2000),
	    $gen->deposit(['transaction'], { date => '1999.04.03'}, 1500)
          );

This generates:

   <account type="checking" id="34578">
     <transaction:open>2000</transaction:open>
     <transaction:deposit transaction:date="1999.04.03">1500</transaction:deposit>
   </account>

=head1 CONSTRUCTOR

XML::Generator-E<gt>new(option => 'value', option => 'value');

The following options are available:

=head2 namespace

The value of this option is used as the global default namespace.
For example,

   my $html = XML::Generator->new(namespace => 'HTML');
   print $html->font({ face => 'Arial' }, "Hello, there");

would yield

   <HTML:font HTML:face="Arial">Hello, there</HTML:font>

See HTML::Generator for routines specific to HTML generation.

=head2 escape

The contents and the values of each attribute have any illegal XML
characters escaped if this option is supplied.  If the value is 'always',
then &, < and > (and " within attribute values) will be converted into the
corresponding XML entity.  If the value is any other true value, then the
escaping will be turned off character-by-character if the character in question
is preceded by a backslash, or for the entire string if it is supplied as a
scalar reference.  So, for example,

   my $a = XML::Generator->new(escape => 'always');
   my $b = XML::Generator->new(escape => 'true');
   print $a->foo('<', $b->bar('3 \> 4', \" && 6 < 5"), '\&', '>');

would yield

   <foo>&lt;<bar>3 > 4 && 6 < 5</bar>\&amp;&gt;</foo>

By default, high-bit data will be passed through unmodified, so that UTF-8 data
can be generated with pre-Unicode perls.  If you know that your data is ASCII,
use the value 'high-bit' for the escape option and bytes with the high bit set
will be turned into numeric entities.  You can combine this functionality with
the other escape options by comma-separating the values:

  my $a = XML::Generator->new(escape => 'always,high-bit');
  print $a->foo("<\242>");

yields

  <foo>&lt;&#162;&gt;</foo>

=head2 pretty

To have nice pretty printing of the output XML (great for config files
that you might also want to edit by hand), pass an integer for the
number of spaces per level of indenting, eg.

   my $gen = XML::Generator->new(pretty => 2);
   print $gen->foo($gen->bar('baz'),
                   $gen->qux({ tricky => 'no'}, 'quux'));

would yield

   <foo>
     <bar>baz</bar>
     <qux tricky="no">quux</qux>
   </foo>

Pretty printing does not apply to CDATA sections or Processing Instructions.

=head2 conformance

If the value of this option is 'strict', a number of syntactic
checks are performed to ensure that generated XML conforms to the
formal XML specification.  In addition, since entity names beginning
with 'xml' are reserved by the W3C, inclusion of this option enables
several special tag names: xmlpi, xmlcmnt, xmldecl, xmldtd, xmlcdata,
and xml to allow generation of processing instructions, comments, XML
declarations, DTD's, character data sections and "final" XML documents,
respectively.

See L<"XML CONFORMANCE"> and L<"SPECIAL TAGS"> for more information.

=head2 empty

There are 5 possible values for this option:

   self    -  create empty tags as <tag />  (default)
   compact -  create empty tags as <tag/>
   close   -  close empty tags as <tag></tag>
   ignore  -  don't do anything (non-compliant!)
   args    -  use count of arguments to decide between <x /> and <x></x>

Many web browsers like the 'self' form, but any one of the forms besides
'ignore' is acceptable under the XML standard.

'ignore' is intended for subclasses that deal with HTML and other
SGML subsets which allow atomic tags.  It is an error to specify both
'conformance' => 'strict' and 'empty' => 'ignore'.

'args' will produce <x /> if there are no arguments at all, or if there
is just a single undef argument, and <x></x> otherwise.

=cut

package XML::Generator;

# If no value is provided for these options, they will be set to ''

my @options = qw(
  conformance
  dtd
  encoding
  escape
  namespace
  pretty
  version
  empty
);

use constant ESCAPE_TRUE     => 1;
use constant ESCAPE_ALWAYS   => 2;
use constant ESCAPE_HIGH_BIT => 4;

my %tag_factory;

# The constructor method

sub new {
  my $class = shift;

  # If we already have a ref in $class, this means that the
  # person wants to generate a <new> tag!
  return $class->XML::Generator::util::tag('new', @_) if ref $class;

  my %options = @_;

  # We used to only accept certain options, but unfortunately this
  # means that subclasses can't extend the list. As such, we now 
  # just make sure our default options are defined.
  for (@options) { $options{$_} ||= '' }

  $options{'tags'} = {};

  if ($options{'dtd'}) {
    $options{'dtdtree'} = $class->XML::Generator::util::parse_dtd($options{'dtd'});
  }

  if ($options{'conformance'} eq 'strict' &&
      $options{'empty'} eq 'ignore') {
    croak "option 'empty' => 'ignore' not allowed while 'conformance' => 'strict'";
  }

  if (exists $options{'escape'}) {
    my $e = $options{'escape'};
    $options{'escape'} = 0;
    while ($e =~ /([-\w]+),?/g) {
      if ($1 eq 'always') {
	$options{'escape'} |= ESCAPE_ALWAYS;
      } elsif ($1 eq 'high-bit') {
	$options{'escape'} |= ESCAPE_HIGH_BIT;
      } elsif ($1) {
	$options{'escape'} |= ESCAPE_TRUE;
      }
    }
  }

  my $this = bless \%options, $class;
  $tag_factory{$this} = XML::Generator::util::c_tag($this);
  return $this;
}

# We use AUTOLOAD as a front-end to TAG so that we can
# create tags by name at will.

sub AUTOLOAD {
  my $this = shift;

  # The tag is whatever our sub name is.
  my ($tag) = $AUTOLOAD =~ /.*::(.*)/;

  unshift @_, $tag;

  goto &{ $tag_factory{$this} };
}

sub DESTROY { delete $tag_factory{$_[0]} }

=head1 XML CONFORMANCE

When the 'conformance' => 'strict' option is supplied, a number of
syntactic checks are enabled.  All entity and attribute names are
checked to conform to the XML specification, which states that they
must begin with either an alphabetic character or an underscore and
may then consist of any number of alphanumerics, underscores, periods
or hyphens.  Alphabetic and alphanumeric are interpreted according to
the current locale if 'use locale' is in effect and according to the
Unicode standard for Perl versions >= 5.6.  Furthermore, entity or
attribute names are not allowed to begin with 'xml' (in any case),
although a number of special tags beginning with 'xml' are allowed
(see L<"SPECIAL TAGS">).

In addition, only one namespace component will be allowed when strict
conformance is in effect, and attribute names can be given a specific
namespace, which will override both the default namespace and the tag-
specific namespace.  For example,

   my $gen = XML::Generator->new(conformance => 'strict',
				 namespace   => 'foo');
   my $xml = $gen->bar({ a => 1 },
               $gen->baz(['bam'], { b => 2, 'name:c' => 3 })
              );

will generate:

   <foo:bar foo:a="1"><bam:baz bam:b="2" name:c="3" /></foo:bar>

=head1 SPECIAL TAGS

The following special tags are available when running under strict
conformance (otherwise they don't act special):

=head2 xmlpi

Processing instruction; first argument is target, remaining arguments
are attribute, value pairs.  Attribute names are syntax checked, values
are escaped.

=cut

# We handle a few special tags, but only if the conformance
# is 'strict'. If not, we just fall back to AUTOLOAD.

sub xmlpi {
  my $this = shift;

  return $this->XML::Generator::util::tag('xmlpi', @_)
		unless $this->{conformance} eq 'strict';

  my $xml;
  my $tgt  = shift;

  $this->XML::Generator::util::ck_syntax($tgt);

  $xml = "<?$tgt";
  if (@_) {
     my %atts = @_;
     while (my($k, $v) = each %atts) {
       $this->XML::Generator::util::ck_syntax($k);
       XML::Generator::util::escape($v, 1, $this->{'escape'} & ESCAPE_ALWAYS,
					   $this->{'escape'} & ESCAPE_HIGH_BIT);
       $xml .= qq{ $k="$v"};
     }
  }
  $xml .= "?>";

  return XML::Generator::pi->new([$xml]);
}

=head2 xmlcmnt

Comment.  Arguments are concatenated and placed inside <!-- ... --> comment
delimiters.  Any occurences of '--' in the concatenated arguments are
converted to '-&#45;'

=cut

sub xmlcmnt {
  my $this = shift;

  return $this->XML::Generator::util::tag('xmlcmnt', @_)
		unless $this->{conformance} eq 'strict';

  my $xml = join '', @_;

  # double dashes are illegal; change them to '-&#45;'
  $xml =~ s/--/-&#45;/g;
  $xml = "<!-- $xml -->";

  return XML::Generator::comment->new([$xml]);
}

=head2 xmldecl

Declaration.  This can be used to specify the version, encoding, and other
XML-related declarations (i.e., anything inside the <?xml?> tag).

=cut

sub xmldecl {
  my $this = shift;

  return $this->XML::Generator::util::tag('xmldecl', @_)
		unless $this->{conformance} eq 'strict';

  my $version = qq{ version="}.($this->{'version'} || '1.0').qq{"};

  # there's no explicit support for encodings yet, but at the
  # least we can know to put it in the declaration
  my $encoding = $this->{'encoding'}
                    ? qq{ encoding="$this->{'encoding'}"}
                    : '';

  # similarly, although we don't do anything with DTDs yet, we
  # recognize a 'dtd' => [ ... ] option to the constructor, and
  # use it to create a <!DOCTYPE ...> and to indicate that this
  # document can't stand alone.
  my $doctype = $this->xmldtd($this->{dtd});
  my $standalone = $doctype ? "no" : "yes";

  my $xml = "<?xml$version$encoding standalone=\"$standalone\"?>";
  $xml .= "\n$doctype" if $doctype;

  $xml = "$xml\n";

  return $xml;
}

=head2 xmldtd

DTD <!DOCTYPE> tag creation. The format of this method is different from 
others. Since DTD's are global and cannot contain namespace information,
the first argument arrayref is concatenated together to form the DTD:

   print $xml->xmldtd([ 'html', 'PUBLIC', $xhtml_w3c, $xhtml_dtd ])

This would produce the following declaration:

   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "DTD/xhtml1-transitional.dtd">

Assuming that $xhtml_w3c and $xhtml_dtd had the correct values. For
shortcuts to <!DOCTYPE> generation, see the HTML::Generator module.
Note that you can also specify a DTD on creation using the new() method's
dtd option.

=cut

sub xmldtd {
  my $this = shift;
  my $dtd = shift || return undef;

  # return the appropriate <!DOCTYPE> thingy
  $dtd ? return(qq{<!DOCTYPE } . (join ' ', @{$dtd}) . q{>})
       : return('');
}

=head2 xmlcdata

Character data section; arguments are concatenated and placed inside
<![CDATA[ ... ]]> character data section delimiters.  Any occurences of
']]>' in the concatenated arguments are converted to ']]&gt;'.

=cut

sub xmlcdata {
  my $this = shift;

  $this->XML::Generator::util::tag('xmlcdata', @_)
		unless $this->{conformance} eq 'strict';

  my $xml = join '', @_;

  # ]]> is not allowed; change it to ]]&gt;
  $xml =~ s/]]>/]]&gt;/g;
  $xml = "<![CDATA[$xml]]>";

  return XML::Generator::cdata->new([$xml]);
}

=head2 xml

"Final" XML document.  Must be called with one and exactly one
XML::Generator-produced XML document.  Any combination of
XML::Generator-produced XML comments or processing instructions may
also be supplied as arguments.  Prepends an XML declaration, and
re-blesses the argument into a "final" class that can't be embedded.

=cut

sub xml {
  my $this = shift;

  return $this->XML::Generator::util::tag('xml', @_)
		unless $this->{conformance} eq 'strict';

  unless (@_) {
    croak "usage: object->xml( (COMMENT | PI)* XML (COMMENT | PI)* )";
  }

  my $got_root = 0;
  foreach my $arg (@_) {
    next if UNIVERSAL::isa($arg, 'XML::Generator::comment') ||
	    UNIVERSAL::isa($arg, 'XML::Generator::pi');
    if (UNIVERSAL::isa($arg, 'XML::Generator::overload')) {
      if ($got_root) {
	croak "arguments to xml() can contain only one XML document";
      }
      $got_root = 1;
    } else {
      croak "arguments to xml() must be comments, processing instructions or XML documents";
    }
  }

  return XML::Generator::final->new([$this->xmldecl(), @_]);
}

=head1 CREATING A SUBCLASS

For an example of how to subclass XML::Generator, see Nathan Wiger's 
HTML::Generator module.

At times, you may find it desireable to subclass XML::Generator. For example,
you might want to provide a more application-specific interface to the XML
generation routines provided. Perhaps you have a custom database application
and would really like to say:

   my $dbxml = new XML::Generator::MyDatabaseApp;
   print $dbxml->xml($dbxml->custom_tag_handler(@data));

Here, custom_tag_handler() may be a method that builds a recursive XML
structure based on the contents of @data. In fact, it may even be named
for a tag you want generated, such as authors(), whose behavior changes
based on the contents (perhaps creating recursive definitions in the
case of multiple elements).

Creating a subclass of XML::Generator is actually relatively straightforward,
there are just three things you have to remember:

   1. All of the useful utilities are in XML::Generator::util.

   2. To construct a tag you simply have to call SUPER::tagname,
      where "tagname" is the name of your tag.

   3. You must fully-qualify the methods in XML::Generator::util.

So, let's assume that we want to provide a custom HTML table() method:

   package XML::Generator::CustomHTML;
   use base 'XML::Generator';

   sub table {
       my $self = shift;
       
       # parse our args to get namespace and attribute info
       my($namespace, $attr, @content) =
          $self->XML::Generator::util::parse_args(@_)

       # check for strict conformance
       if ( $self->XML::Generator::util::config('conformance') eq 'strict' ) {
          # ... special checks ...
       }

       # ... special formatting magic happens ...

       # construct our custom tags
       return $self->SUPER::table($attr, $self->tr($self->td(@content)));
   }

That's pretty much all there is to it. We have to explicitly call
SUPER::table() since we're inside the class's table() method. The others
can simply be called directly, assuming that we don't have a tr() in the
current package.

If you want to explicitly create a specific tag by name, or just want a
faster approach than AUTOLOAD provides, you can use the tag() method
directly. So, we could replace that last line above with:

       # construct our custom tags 
       return $self->XML::Generator::util::tag('table', $attr, ...);

Here, we must explicitly call tag() with the tag name itself as its first
argument so it knows what to generate. These are the methods that you might
find useful:

=over 4

=item XML::Generator::util::parse_args()

This parses the argument list and returns the namespace (arrayref), attributes
(hashref), and remaining content (array), in that order.

=item XML::Generator::util::tag()

This does the work of generating the appropriate tag. The first argument must
be the name of the tag to generate.

=item XML::Generator::util::config()

This retrieves options as set via the new() method.

=item XML::Generator::util::escape()

This escapes any illegal XML characters.

=back

Remember that all of these methods must be fully-qualified with the
XML::Generator::util package name. This is because AUTOLOAD is used by 
the main XML::Generator package to create tags. Simply calling parse_args()
will result in a set of XML tags called <parse_args>.

Finally, remember that since you are subclassing XML::Generator, you do not
need to provide your own new() method. The one from XML::Generator is designed
to allow you to properly subclass it.

=cut

package XML::Generator::util;

# The ::util package space actually has all the utilities
# that do all the work. It must be separate from the
# main XML::Generator package space since named subs will
# interfere with the workings of AUTOLOAD otherwise.

use strict;
use Carp;

sub parse_args {
  # this parses the args and returns a namespace and attr
  # if either were specified, with the remainer of the
  # arguments (the content of the tag) in @args. call as:
  #
  #   ($namespace, $attr, @args) = parse_args(@args);
 
  my($this, @args) = @_;
  my($namespace, $attr) = ('') x 2;

  # get any globally-set namespace (from new)
  $namespace = $this->{'namespace'} || '';

  # check for supplied namespace
  if (defined($args[0]) && ref $args[0] eq 'ARRAY') {
    my $names = shift @args;
    if ($this->{'conformance'} eq 'strict' && @$names > 1) {
      croak "only one namespace component allowed";
    }
    $namespace = join ':', @$names;
  }

  # Normalize namespace
  $namespace =~ s/:?$/:/ if $namespace;

  # check for supplied attributes
  if (defined($args[0]) && ref $args[0] eq 'HASH') {
    $attr = shift @args;
  }

  return ($namespace, $attr, @args);
}

my $parser;
sub new_dom_root {
  require XML::DOM;
  $parser ||= XML::DOM::Parser->new;
  my $root = $parser->parse('<_/>');
  $root->removeChild($root->getFirstChild);
  return $root;
}

# This routine is what handles all the automatic tag creation.
# We maintain it as a separate method so that subclasses can
# override individual tags and then call SUPER::tag() to create
# the tag automatically. This is not possible if only AUTOLOAD
# is used, since there is no way to then pass in the name of
# the tag.

sub tag {
  my $sub  = XML::Generator::util::c_tag(shift);
  goto &{ $sub } if $sub;
}
 
# Generate a closure that encapsulates all the behavior to generate a tag
sub c_tag {
  my $this = shift;

  my $strict = $this->{'conformance'} eq 'strict';
  my $always = (my $escape = $this->{'escape'}) & XML::Generator::ESCAPE_ALWAYS;
  my $high_bit = $escape & XML::Generator::ESCAPE_HIGH_BIT;
  my $empty  = $this->{'empty'};
  my $pretty = $this->{'pretty'};

  return sub {
    my $tag = shift || return undef;   # catch for bad usage

    # parse our argument list to check for hashref/arrayref properties
    my($namespace, $attr, @args) = $this->XML::Generator::util::parse_args(@_);

    $this->XML::Generator::util::ck_syntax($tag) if $strict;

    # check for attempt to embed "final" document
    for (@args) {
      if (UNIVERSAL::isa($_, 'XML::Generator::final')) {
	croak("cannot embed XML document");
      }
    }

    # Deal with escaping if required
   if ($escape) {
      if ($attr) {
	foreach my $key (keys %{$attr}) {
	  next unless defined($attr->{$key});
	  XML::Generator::util::escape($attr->{$key}, 1, $always, $high_bit);
	}
      }
      for (@args) {
	next unless defined($_);

	# perform escaping, except on sub-documents or simple scalar refs
	if (ref $_ eq "SCALAR") {
	  # un-ref it
	  $_ = $$_;
	} elsif (! UNIVERSAL::isa($_, 'XML::Generator::overload') ) {
	  XML::Generator::util::escape($_, 0, $always, $high_bit);
	}
      }
    } else {
      # un-ref simple scalar refs
      for (@args) {
	$_ = $$_ if ref $_ eq "SCALAR";
      }
    }

    # generate the XML
    my $xml = "<$namespace$tag";

    if ($attr) {
      while (my($k, $v) = each %$attr) {
	next unless defined($k) && defined($v);
	if ($strict) {
	  # allow supplied namespace in attribute names
	  if ($k =~ s/^([^:]+)://) {
	    $this->XML::Generator::util::ck_syntax($k);
	    $k = "$1:$k";
	  } else {
	    $this->XML::Generator::util::ck_syntax($k);
	    $k = "$namespace$k";
	  }
	} else {
	  if ($k !~ /^[^:]+:/) {
	    $k = "$namespace$k";
	  }
	}
	$xml .= qq{ $k="$v"};
      }
    }

    my @xml;

    if (@args || $empty eq 'close') {
      if ($empty eq 'args' && @args == 1 && ! defined $args[0]) {
	@xml = ($xml .= ' />');
      } else {
	$xml .= '>';
	if ($pretty) {
	  my $prettyend = '';
	  my $spaces = " " x $pretty;
	  foreach my $arg (@args) {
	    next unless defined $arg;
	    if ( UNIVERSAL::isa($arg, 'XML::Generator::overload') &&
		! ( UNIVERSAL::isa($arg, 'XML::Generator::cdata') ||
		    UNIVERSAL::isa($arg, 'XML::Generator::pi') ) ) {
	      $xml .= "\n$spaces";
	      $prettyend = "\n";
	      $arg =~ s/\n/\n$spaces/gs;
	    }
	    $xml .= "$arg";
	  }
	  $xml .= $prettyend;
	  @xml = ($xml, "</$namespace$tag>");
	} else {
	  @xml = ($xml, (grep defined, @args), "</$namespace$tag>");
	}
      }
    } elsif ($empty eq 'ignore') {
      @xml = ($xml .= '>');
    } elsif ($empty eq 'compact') {
      @xml = ($xml .= '/>');
    } else {
      @xml = ($xml .= ' />');
    }

    return XML::Generator::overload->new(\@xml);
  };
}

# Fetch and store config values (those set via new())
# This is only here for subclasses

sub config {
  my $this = shift;
  my $key = shift || return undef;
  @_ ? $this->{$key} = $_[0]
     : $this->{$key};
}

# Collect all escaping into one place
sub escape {
  # $_[0] is the argument, $_[1] is the quote " flag, $_[2] is the 'always' flag,
  # $_[0] is the high-bit flag
  if ($_[2]) {
    $_[0] =~ s/&/&amp;/g;  # & first of course
    $_[0] =~ s/</&lt;/g;
    $_[0] =~ s/>/&gt;/g;
    $_[0] =~ s/"/&quot;/g if $_[1]; 
  } else {
    $_[0] =~ s/([^\\]|^)&/$1&amp;/g;
    $_[0] =~ s/\\&/&/g;
    $_[0] =~ s/([^\\]|^)</$1&lt;/g;
    $_[0] =~ s/\\</</g;
    $_[0] =~ s/([^\\]|^)>/$1&gt;/g;
    $_[0] =~ s/\\>/>/g;
    $_[0] =~ s/([^\\]|^)"/$1&quot;/g if $_[1];
    $_[0] =~ s/\\"/"/g if $_[1];
  } 
  if ($_[3]) {
    $_[0] =~ s/([\200-\377])/'&#'.ord($1).';'/ge;
  }
}

# verify syntax of supplied name; croak if it's not valid.
# rules: 1. name must begin with a letter or an underscore
#        2. name may contain any number of letters, numbers, hyphens,
#           periods or underscores
#        3. name cannot begin with "xml" in any case
sub ck_syntax {
  my($this, $name) = @_;
  # use \w and \d so that everything works under "use locale" and 
  # "use utf8"
  if ($name =~ /^\w[\w\-\.]*$/) {
    if ($name =~ /^\d/) {
      croak "name [$name] may not begin with a number";
    }
  } else {
    croak "name [$name] contains illegal character(s)";
  }
  if ($name =~ /^xml/i) {
    croak "names beginning with 'xml' are reserved by the W3C";
  }
}

my %DTDs;
my $DTD;

sub parse_dtd {
  my $this = shift;
  my($dtd) = @_;

  my($root, $type, $name, $uri);

  croak "DTD must be supplied as an array ref" unless (ref $dtd eq 'ARRAY');
  croak "DTD must have at least 3 elements" unless (@{$dtd} >= 3);

  ($root, $type) = @{$dtd}[0,1];
  if ($type eq 'PUBLIC') {
    ($name, $uri) = @{$dtd}[2,3];
  } elsif ($type eq 'SYSTEM') {
    $uri = $dtd->[2];
  } else {
    croak "unknown dtd type [$type]";
  }
  return $DTDs{$uri} if $DTDs{$uri};

  # parse DTD into $DTD (not implemented yet)
  my $dtd_text = get_dtd($uri);

  return $DTDs{$uri} = $DTD;
}

sub get_dtd {
  my($uri) = @_;
  return;
}

# This package is needed so that embedded tags are correctly
# interpreted as such and handled properly. Otherwise, you'd
# get "<outer>&lt;inner /&gt;</outer>"

package XML::Generator::overload;

use overload '""'   => \&stringify,
             '0+'   => \&stringify,
             'bool' => \&stringify,
             'eq'   => sub { stringify($_[0]) eq stringify($_[1]) };

sub new {
  my($class, $xml) = @_;
  return bless $xml, $class;
}

sub stringify {
  return $_[0] unless UNIVERSAL::isa($_[0], 'XML::Generator::overload');
  join $, || "", @{$_[0]}
}

sub DESTROY { }

package XML::Generator::final;

use base 'XML::Generator::overload';

package XML::Generator::comment;

use base 'XML::Generator::overload';

package XML::Generator::pi;

use base 'XML::Generator::overload';

package XML::Generator::cdata;

use base 'XML::Generator::overload';

1;
__END__

=head1 AUTHORS

=over 4

=item Benjamin Holzman <bholzman@earthlink.net>

Original author and maintainer

=item Bron Gondwana <perlcode@brong.net>

First modular version

=item Nathan Wiger <nate@nateware.com>

Modular rewrite to enable subclassing

=back

=head1 SEE ALSO

=over 4

=item Perl-XML FAQ

http://www.perlxml.com/faq/perl-xml-faq.html

=item The XML::Writer module

http://search.cpan.org/search?mode=module&query=XML::Writer

=item The XML::Handler::YAWriter module

http://search.cpan.org/search?mode=module&query=XML::Handler::YAWriter

=item The HTML::Generator module

http://search.cpan.org/search?mode=module&query=HTML::Generator

=back

=cut
