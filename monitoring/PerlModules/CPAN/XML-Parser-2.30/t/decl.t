BEGIN {print "1..30\n";}
END {print "not ok 1\n" unless $loaded;}
use XML::Parser;
$loaded = 1;
print "ok 1\n";

my $bigval =<<'End_of_bigval;';
This is a large string value to test whether the declaration parser still
works when the entity or attribute default value may be broken into multiple
calls to the default handler.
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
01234567890123456789012345678901234567890123456789012345678901234567890123456789
End_of_bigval;

$bigval =~ s/\n/ /g;

my $docstr =<<"End_of_Doc;";
<?xml version="1.0" encoding="ISO-8859-1" ?>
<!DOCTYPE foo SYSTEM 't/foo.dtd'
  [
   <!ENTITY alpha 'a'>
   <!ELEMENT junk ((bar|foo|xyz+), zebra*)>
   <!ELEMENT xyz (#PCDATA)>
   <!ELEMENT zebra (#PCDATA|em|strong)*>	
   <!ATTLIST junk
         id ID #REQUIRED
         version CDATA #FIXED '1.0'
         color (red|green|blue) 'green'
         foo NOTATION (x|y|z) #IMPLIED>
   <!ENTITY skunk "stinky animal">
   <!ENTITY big "$bigval">
   <!-- a comment -->
   <!NOTATION gif SYSTEM 'http://www.somebody.com/specs/GIF31.TXT'>
   <!ENTITY logo PUBLIC '//Widgets Corp/Logo' 'logo.gif' NDATA gif>
   <?DWIM a useless processing instruction ?>
   <!ELEMENT bar ANY>
   <!ATTLIST bar big CDATA '$bigval'>
  ]>
<foo/>
End_of_Doc;

my $entcnt = 0;
my %ents;
my @tests;

sub enth1 {
    my ($p, $name, $val, $sys, $pub, $notation) = @_;

    $tests[2]++ if ($name eq 'alpha' and $val eq 'a');
    $tests[3]++ if ($name eq 'skunk' and $val eq 'stinky animal');
    $tests[4]++ if ($name eq 'logo' and !defined($val) and
		    $sys eq 'logo.gif' and $pub eq '//Widgets Corp/Logo'
		    and $notation eq 'gif');
}

my $parser = new XML::Parser(ErrorContext  => 2,
			     NoLWP         => 1,
			     ParseParamEnt => 1,
			     Handlers => {Entity => \&enth1});

$parser->parse($docstr);

sub eleh {
    my ($p, $name, $model) = @_;

    if ($name eq 'junk') {
	$tests[5]++ if $model eq '((bar|foo|xyz+),zebra*)';
	$tests[6]++ if $model->isseq;
	my @parts = $model->children;
	$tests[7]++ if $parts[0]->ischoice;
	my @cparts = $parts[0]->children;
	$tests[8]++ if $cparts[0] eq 'bar';
	$tests[9]++ if $cparts[1] eq 'foo';
	$tests[10]++ if $cparts[2] eq 'xyz+';
	$tests[11]++ if $cparts[2]->name eq 'xyz';
	$tests[12]++ if $parts[1]->name eq 'zebra';
	$tests[13]++ if $parts[1]->quant eq '*';
    }

    if ($name eq 'xyz') {
      $tests[14]++ if ($model->ismixed and ! defined($model->children));
    }

    if ($name eq 'zebra') {
      $tests[15]++ if ($model->ismixed and ($model->children)[1] eq 'strong');
    }

    if ($name eq 'bar') {
      $tests[16]++ if $model->isany;
    }
}

sub enth2 {
    my ($p, $name, $val, $sys, $pub, $notation) = @_;

    $tests[17]++ if ($name eq 'alpha' and $val eq 'a');
    $tests[18]++ if ($name eq 'skunk' and $val eq 'stinky animal');
    $tests[19]++ if ($name eq 'big' and $val eq $bigval);
    $tests[20]++ if ($name eq 'logo' and !defined($val) and
		    $sys eq 'logo.gif' and $pub eq '//Widgets Corp/Logo'
		    and $notation eq 'gif');
}

sub doc {
    my ($p, $name, $sys, $pub, $intdecl) = @_;

    $tests[21]++ if $name eq 'foo';
    $tests[22]++ if $sys eq 't/foo.dtd';
    $tests[23]++ if $intdecl
}

sub att {
    my ($p, $elname, $attname, $type, $default, $fixed) = @_;

    $tests[24]++ if ($elname eq 'junk' and $attname eq 'id'
		     and $type eq 'ID' and $default eq '#REQUIRED'
		     and not $fixed);
    $tests[25]++ if ($elname eq 'junk' and $attname eq 'version'
		     and $type eq 'CDATA' and $default eq "'1.0'" and $fixed);
    $tests[26]++ if ($elname eq 'junk' and $attname eq 'color'
		     and $type eq '(red|green|blue)'
		     and $default eq "'green'");
    $tests[27]++ if ($elname eq 'bar' and $attname eq 'big' and $default eq
		     "'$bigval'");
    $tests[28]++ if ($elname eq 'junk' and $attname eq 'foo'
                     and $type eq 'NOTATION(x|y|z)' and $default eq '#IMPLIED');

}
    
sub xd {
    my ($p, $version, $enc, $stand) = @_;

    if (defined($version)) {
      if ($version eq '1.0' and $enc eq 'ISO-8859-1' and not defined($stand)) {
	$tests[29]++;
      }
    }
    else {
      $tests[30]++ if $enc eq 'x-sjis-unicode';
    }
}

$parser->setHandlers(Entity  => \&enth2,
		     Element => \&eleh,
		     Attlist => \&att,
		     Doctype => \&doc,
		     XMLDecl => \&xd);

$| = 1;
$parser->parse($docstr);

for (2 .. 30) {
    print "not " unless $tests[$_];
    print "ok $_\n";
}
