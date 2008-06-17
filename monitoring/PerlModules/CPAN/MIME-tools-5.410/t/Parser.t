use lib "./t";
use MIME::Tools;

use ExtUtils::TBone;
use Globby;

use strict;
config MIME::Tools DEBUGGING=>0;

use MIME::Parser;

#------------------------------------------------------------

# Set the counter, for filenames:
my $Counter = 0;

# Create checker:
my $T = typical ExtUtils::TBone;
$T->begin(12);

# Check and clear the output directory:
my $DIR = "./testout";
((-d $DIR) && (-w $DIR)) or die "no output directory $DIR";
unlink globby("$DIR/[a-z]*");


#------------------------------------------------------------
# BEGIN
#------------------------------------------------------------

my $parser;
my $entity;
my $msgno;
my $infile;
my $type;
my $enc;


#------------------------------------------------------------
$T->msg("Create a parser");
#------------------------------------------------------------





#------------------------------------------------------------
package MyParser;
@MyParser::ISA = qw(MIME::Parser);
sub output_path {
    my ($parser, $head) = @_;

    # Get the recommended filename:
    my $filename = $head->recommended_filename;
    if (defined($filename) && $parser->evil_filename($filename)) {
	$T->msg("Parser.t: ignoring an evil recommended filename ($filename)");
	$filename = undef;      # forget it: it was evil
    }
    if (!defined($filename)) {  # either no name or an evil name
	++$Counter;
	$filename = "message-$Counter.dat";
    }

    # Get the output filename:
    my $outdir = $parser->output_dir;
    "$outdir/$filename";
}
package main;

#------------------------------------------------------------

$parser = new MyParser;
$parser->output_dir($DIR);

#------------------------------------------------------------
$T->msg("Read a nested multipart MIME message");
#------------------------------------------------------------
open IN, "./testmsgs/multi-nested.msg" or die "open: $!";
$entity = $parser->parse(\*IN);
$T->ok($entity, "parse of nested multipart");

#------------------------------------------------------------
$T->msg("Check the various output files");
#------------------------------------------------------------
$T->ok((-s "$DIR/3d-vise.gif" == 419), "vise gif");
$T->ok((-s "$DIR/3d-eye.gif" == 357) , "3d-eye gif");
for $msgno (1..4) {
    $T->ok((-s "$DIR/message-$msgno.dat"), "message $msgno");
}

#------------------------------------------------------------
$T->msg("Same message, but CRLF-terminated and no output path hook");
#------------------------------------------------------------
$parser = new MIME::Parser;
{ local $^W = undef;
$parser->output_dir($DIR);
open IN, "./testmsgs/multi-nested2.msg" or die "open: $!";
$entity = $parser->parse(\*IN);
$T->ok($entity, "parse of CRLF-terminated message");
}

#------------------------------------------------------------
$T->msg("Read a simple in-core MIME message, three ways");
#------------------------------------------------------------
my $data_scalar = <<EOF;
Content-type: text/html

<H1>This is test one.</H1>

EOF
my $data_scalarref = \$data_scalar;
my $data_arrayref  = [ map { "$_\n" } (split "\n", $data_scalar) ];
my $data_test;

$parser->output_to_core('ALL');
foreach $data_test ($data_scalar, $data_scalarref, $data_arrayref) {
    $entity = $parser->parse_data($data_test);
    $T->ok(($entity and $entity->head->mime_type eq 'text/html') ,
	((ref($data_test)||'NO') . "-REF"));
}
$parser->output_to_core('NONE');


#------------------------------------------------------------
$T->msg("Simple message, in two parts");
#------------------------------------------------------------
$entity = $parser->parse_two("./testin/simple.msgh", "./testin/simple.msgb");
my $es = ($entity ? $entity->head->get('subject',0) : '');
$T->ok(($es =~ /^Request for Leave$/),
      "	parse of 2-part simple message (subj <$es>)");

# Done!
exit(0);
1;
