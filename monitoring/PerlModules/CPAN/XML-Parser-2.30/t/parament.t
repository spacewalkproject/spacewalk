BEGIN {print "1..12\n";}
END {print "not ok 1\n" unless $loaded;}
use XML::Parser;
$loaded = 1;
print "ok 1\n";

my $internal_subset =<<'End_of_internal;';
[
  <!ENTITY % foo "IGNORE">
  <!ENTITY % bar "INCLUDE">
  <!ENTITY more SYSTEM "t/ext2.ent">
]
End_of_internal;

my $doc =<<"End_of_doc;";
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE foo SYSTEM "t/foo.dtd"
$internal_subset>
<foo>Happy, happy
<bar>&joy;, &joy;</bar>
<ext/>
&more;
</foo>
End_of_doc;

my $gotinclude = 0;
my $gotignore = 0;
my $doctype_called = 0;
my $internal_exists = 0;
my $gotmore = 0;

my $bartxt = '';

sub start {
  my ($xp, $el, %atts) = @_;

  if ($el eq 'foo') {
    print "not " if defined($atts{top});
    print "ok 2\n";
    print "not " unless defined($atts{zz});
    print "ok 3\n";
  }
  elsif ($el eq 'bar') {
    print "not " unless (defined $atts{xyz} and $atts{xyz} eq 'b');
    print "ok 4\n";
  }
  elsif ($el eq 'ext') {
    print "not " unless (defined $atts{type} and $atts{type} eq 'flag');
    print "ok 5\n";
  }
  elsif ($el eq 'more') {
    $gotmore = 1;
  }
}

sub char {
  my ($xp, $text) = @_;

  $bartxt .= $text if $xp->current_element eq 'bar';
}

sub attl {
  my ($xp, $el, $att, $type, $dflt, $fixed) = @_;

  $gotinclude = 1 if ($el eq 'bar' and $att eq 'xyz' and $dflt eq "'b'");
  $gotignore = 1 if ($el eq 'foo' and $att eq 'top' and $dflt eq '"hello"');
}

sub dtd {
  my ($xp, $name, $sysid, $pubid, $internal) = @_;

  $doctype_called = 1;
  $internal_exists = $internal;
}

$p = new XML::Parser(ParseParamEnt => 1,
		     ErrorContext  => 2,
		     Handlers => {Start   => \&start,
				  Char    => \&char,
				  Attlist => \&attl,
				  Doctype => \&dtd
				 }
		    );

$p->parse($doc);

print "not " unless $gotmore;
print "ok 6\n";

print "not " unless $bartxt eq "\xe5\x83\x96, \xe5\x83\x96";
print "ok 7\n";

print "not " unless $gotinclude;
print "ok 8\n";

print "not " if $gotignore;
print "ok 9\n";

print "not " unless $doctype_called;
print "ok 10\n";

print "not " unless $internal_exists;
print "ok 11\n";

$doc =~ s/[\s\n]+\[[^]]*\][\s\n]+//m;

$p->setHandlers(Start => sub {
		          my ($xp,$el,%atts) = @_;
			  if ($el eq 'foo') {
			    print "not " unless defined($atts{zz});
			    print "ok 12\n";
			  }
			});

$p->parse($doc);
