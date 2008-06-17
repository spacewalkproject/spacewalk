use lib "./t";

use MIME::Entity;
use MIME::Parser;
use ExtUtils::TBone;
use Globby;
use strict;

my $line;
my $LINE;


#------------------------------------------------------------
# BEGIN
#------------------------------------------------------------

# Create checker:
my $T = typical ExtUtils::TBone;
$T->begin(29);


#------------------------------------------------------------
$T->msg("Testing build()");
#------------------------------------------------------------
{local $SIG{__WARN__} = sub { die "caught warning: ",@_ };
 {   
     my $e = MIME::Entity->build(Path     => "./testin/short.txt");
     my $name = 'short.txt';
     my $got;
     
     #-----test------
     $got = $e->head->mime_attr('content-type.name');
     $T->ok($got eq $name,
	    "Path: with no Filename, got default content-type.name",
	    Got => $got);
     
     #-----test------
     $got = $e->head->mime_attr('content-disposition.filename');
     $T->ok($got eq $name,
	    "Path: with no Filename, got default content-disp.filename",
	    Got => $got);

     #-----test------
     $got = $e->head->recommended_filename;
     $T->ok($got eq $name,
	    "Path: with no Filename, got default recommended filename",
	    Got => $got);
 }
 { 
     #-----test------
     my $e = MIME::Entity->build(Path     => "./testin/short.txt",
				 Filename => undef);
     my $got = $e->head->mime_attr('content-type.name');
     $T->ok(!$got,
	    "Path: with explicitly undef Filename, got no filename",
	    Got => $got);
 }
 { 
     #-----test------
     my $e = MIME::Entity->build(Path     => "./testin/short.txt",
				 Filename => "foo.txt");
     my $got = $e->head->mime_attr('content-type.name');
     $T->ok($got eq "foo.txt",
	    "Path: verified explicit 'Filename'",
	    Got => $got);
 }
 {
     #-----test------
     my $e = MIME::Entity->build(Path     => "./testin/sig"
				 );
     my $got = $e->head->mime_attr('content-type');
     $T->ok($got eq 'text/plain',
	    "Type: default ok",
	    Got => $got);
 }
 {
     #-----test------
     my $e = MIME::Entity->build(Path     => "./testin/sig",
				 Type     => "text/foo");
     my $got = $e->head->mime_attr('content-type');
     $T->ok($got eq 'text/foo',
	    "Type: explicit ok",
	    Got => $got);
 }
 {
     #-----test------
     my $e = MIME::Entity->build(Path     => "./testin/sig",
				 Encoding => '-SUGGEST');
     my $got = $e->head->mime_attr('content-transfer-encoding');
     $T->ok($got eq '7bit',
	    "Encoding: -SUGGEST yields 7bit",
	    Got => $got);
 }
 {
     #-----test------
     my $e = MIME::Entity->build(Path     => "./testin/short.txt",
				 Encoding => '-SUGGEST');
     my $got = $e->head->mime_attr('content-transfer-encoding');
     $T->ok($got eq 'quoted-printable',
	    "Encoding: -SUGGEST yields qp",
	    Got => $got);
 }
 {
     #-----test------
     my $e = MIME::Entity->build(Type     => 'image/gif',
				 Path     => "./testin/mime-sm.gif",
				 Encoding => '-SUGGEST');
     my $got = $e->head->mime_attr('content-transfer-encoding');
     $T->ok($got eq 'base64',
	    "Encoding: -SUGGEST yields base64",
	    Got => $got);
 }
 {
     #-----test------
     my $e = MIME::Entity->build(Path     => "./testin/short.txt"
				 );
     my $got = $e->head->mime_attr('content-type.charset');
     $T->ok(!$got,
	    "Charset: default ok",
	    Got => $got);
 }
 {
     #-----test------
     my $e = MIME::Entity->build(Path     => "./testin/short.txt",
				 Charset  => 'iso8859-1');
     my $got = $e->head->mime_attr('content-type.charset');
     $T->ok($got eq 'iso8859-1',
	    "Charset: explicit",
	    Got => $got);
 }
}

#------------------------------------------------------------
$T->msg("Create an entity");
#------------------------------------------------------------

# Create the top-level, and set up the mail headers in a couple
# of different ways:
my $top = MIME::Entity->build(Type  => "multipart/mixed",
			      -From => "me\@myhost.com",
			      -To   => "you\@yourhost.com");
$top->head->add('subject', "Hello, nurse!");
$top->preamble([]);
$top->epilogue([]);

# Attachment #0: a simple text document: 
attach $top  Path=>"./testin/short.txt";

# Attachment #1: a GIF file:
attach $top  Path        => "./testin/mime-sm.gif",
             Type        => "image/gif",
             Encoding    => "base64",
	     Disposition => "attachment";

# Attachment #2: a document we'll create manually:
my $attach = new MIME::Entity;
$attach->head(new MIME::Head ["X-Origin: fake\n",
			      "Content-transfer-encoding: quoted-printable\n",
			      "Content-type: text/plain\n"]);
$attach->bodyhandle(new MIME::Body::Scalar);
my $io = $attach->bodyhandle->open("w");
$io->print(<<EOF
This  is the first line.
This is the middle.
This is the last.
EOF
);
$io->close;
$top->add_part($attach);

# Attachment #3: a document we'll create, not-so-manually:
$LINE = "This is the first and last line, with no CR at the end.";
$attach = attach $top Data=>$LINE;

#-----test------
$T->ok(1, "built a message");
unlink globby("testout/entity.msg*");

#------------------------------------------------------------
$T->msg("Check body");
#------------------------------------------------------------
my $bodylines = $top->parts(0)->body;
#-----test------
$T->ok($bodylines > 0, 
       "old-style body call ok");
my $preamble_str = join '', @{$top->preamble || []};
my $preamble_len = length($preamble_str);
my $epilogue_str = join '', @{$top->epilogue || []};
my $epilogue_len = length($epilogue_str);

#------------------------------------------------------------
$T->msg("Output msg1 to explicit filehandle glob");
#------------------------------------------------------------
open TMP, ">testout/entity.msg1" or die "open: $!";
$top->print(\*TMP);
close TMP;
#-----test------
$T->ok((-s "testout/entity.msg1"), 
       "wrote msg1 to filehandle glob");

#------------------------------------------------------------
$T->msg("Output msg2 to selected filehandle");
#------------------------------------------------------------
open TMP, ">testout/entity.msg2" or die "open: $!";
my $oldfh = select TMP;
$top->print;
select $oldfh;
close TMP;
#-----test------
$T->ok((-s "testout/entity.msg2"), 
       "write msg2 to selected filehandle");

#------------------------------------------------------------
$T->msg("Compare");
#------------------------------------------------------------
# Same?
$T->ok(((-s "testout/entity.msg1") == (-s "testout/entity.msg2")),
	"message files are same length");

#------------------------------------------------------------
$T->msg("Parse it back in, to check syntax");
#------------------------------------------------------------
my $parser = new MIME::Parser;
$parser->output_dir("testout");
open IN, "./testout/entity.msg1" or die "open: $!";
$top = $parser->parse(\*IN);
$T->msg($parser->results->msgs);

#-----test------
$T->ok($top, "parsed msg1 back in");

my $preamble_str2 = join '', @{$top->preamble || []};
my $preamble_len2 = length($preamble_str2);
my $epilogue_str2 = join '', @{$top->epilogue || []};
my $epilogue_len2 = length($epilogue_str2);
#-----test------
$T->ok(($preamble_len == $preamble_len2), 
	"preambles match ($preamble_len == $preamble_len2)",
	Pre1 => $preamble_str,
	Pre2 => $preamble_str2,
	);
#-----test------
$T->ok(($epilogue_len == $epilogue_len2), 
	"epilogues match ($epilogue_len == $epilogue_len2)",
	Epi1 => $epilogue_str,
	Epi2 => $epilogue_str2,
	);

#------------------------------------------------------------
$T->msg("Check the number of parts");
#------------------------------------------------------------
$T->ok(($top->parts == 4), 
       "number of parts is correct (4)");

#------------------------------------------------------------
$T->msg("Check attachment 1 [the GIF]");
#------------------------------------------------------------
my $gif_real = (-s "./testin/mime-sm.gif");
my $gif_this = (-s "./testout/mime-sm.gif");
#-----test------
$T->ok(($gif_real == $gif_this),
	"GIF is right size (real = $gif_real, this = $gif_this)");
my $part = ($top->parts)[1];
#-----test------
$T->ok(($part->head->mime_type eq 'image/gif'), 
	"GIF has correct MIME type");

#------------------------------------------------------------
$T->msg("Check attachment 3 [the short message]");
#------------------------------------------------------------
$part = ($top->parts)[3];
$io = $part->bodyhandle->open("r");
$line = ($io->getline);
$io->close;
#-----test------
$T->ok(($line eq $LINE), 
	"getline gets correct value (IO = $io, <$line>, <$LINE>)");
#-----test------
$T->ok(($part->head->mime_type eq 'text/plain'), 
	"MIME type okay");
#-----test------
$T->ok(($part->head->mime_encoding eq 'binary'),
	"MIME encoding okay");

#------------------------------------------------------------
$T->msg("Write it out, and compare");
#------------------------------------------------------------
open TMP, ">testout/entity.msg3" or die "open: $!";
$top->print(\*TMP);
close TMP;
#-----test------
$T->ok(((-s "testout/entity.msg2") == (-s "testout/entity.msg3")),
	"msg2 same size as msg3");

#------------------------------------------------------------
$T->msg("Duplicate");
#------------------------------------------------------------
my $dup = $top->dup;
open TMP, ">testout/entity.dup3" or die "open: $!";
$dup->print(\*TMP);
close TMP;
my $msg3_s = -s "testout/entity.msg3";
my $dup3_s = -s "testout/entity.dup3";
#-----test------
$T->ok(($msg3_s == $dup3_s),
	"msg3 size ($msg3_s) is same as dup3 size ($dup3_s)");

#------------------------------------------------------------
$T->msg("Test signing");
#------------------------------------------------------------
$top->sign(File=>"./testin/sig");
$top->remove_sig;
$top->sign(File=>"./testin/sig2", Remove=>56);
$top->sign(File=>"./testin/sig3");

#------------------------------------------------------------
$T->msg("Write it out again, after synching");
#------------------------------------------------------------
$top->sync_headers(Nonstandard=>'ERASE',
		   Length=>'COMPUTE');	
open TMP, ">testout/entity.msg4" or die "open: $!";
$top->print(\*TMP);
close TMP;

#------------------------------------------------------------
$T->msg("Purge the files");
#------------------------------------------------------------
$top->purge;
#-----test------
$T->ok((! -e "./testout/mime-sm.gif"), 
       "purge worked");

# Done!
exit(0);
1;




