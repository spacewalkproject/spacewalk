use lib "./t";
use MIME::Head;
use ExtUtils::TBone;

#------------------------------------------------------------
# BEGIN
#------------------------------------------------------------

# Create checker:
my $T = typical ExtUtils::TBone;
$T->begin(17);

#------------------------------------------------------------
$T->msg("Read a bogus file (this had better fail...)");
#------------------------------------------------------------
my $WARNS = $SIG{'__WARN__'}; $SIG{'__WARN__'} = sub { };
my $head = MIME::Head->from_file('BLAHBLAH');
$T->ok(!$head, "parse failed as expected?");
$SIG{'__WARN__'} = $WARNS;

#------------------------------------------------------------
$T->msg("Parse in the crlf.hdr file:");
#------------------------------------------------------------
($head = MIME::Head->from_file('./testin/crlf.hdr'))
    or die "couldn't parse input";  # stop now
$T->ok('HERE', 
	"parse of good file succeeded as expected?");

#------------------------------------------------------------
$T->msg("Did we get all the fields?");
#------------------------------------------------------------
my @actuals = qw(path
		 from
		 newsgroups
		 subject
		 date
		 organization
		 lines
		 message-id
		 nntp-posting-host
		 mime-version
		 content-type
		 content-transfer-encoding
		 x-mailer
		 x-url
		 );
push(@actuals, "From ");
my $actual = join '|', sort( map {lc($_)} @actuals);
my $parsed = join '|', sort( map {lc($_)} $head->tags);
$T->ok($parsed eq $actual, 
	"got all fields we expected?");

#------------------------------------------------------------
$T->msg("Could we get() the 'subject'? (it'll end in \\r\\n)");
#------------------------------------------------------------
my $subject;
($subject) = ($head->get('subject',0));    # force array context, see if okay
$T->ok($subject eq "EMPLOYMENT: CHICAGO, IL UNIX/CGI/WEB/DBASE\r\n",
	"got the subject okay?",
	Subject => $subject);

#------------------------------------------------------------
$T->msg("Could we replace() the 'Subject', and get it as 'SUBJECT'?");
#------------------------------------------------------------
my $newsubject = "Hellooooooo, nurse!\r\n";
$head->replace('Subject', $newsubject);
$subject = $head->get('SUBJECT');
$T->ok($subject eq $newsubject, 
	"able to set Subject, and get SUBJECT?");

#------------------------------------------------------------
$T->msg("Does the count() method work?");
#------------------------------------------------------------
$T->ok($head->count('NNTP-Posting-Host') and
        $head->count('nntp-POSTING-HOST') and
        !($head->count('Doesnt-Exist')),
	"count method working?");

#------------------------------------------------------------
$T->msg("Create a custom structured field, and extract parameters");
#------------------------------------------------------------
$head->replace('X-Files', 
	       'default ; name="X Files Test"; LENgth=60 ;setting="6"');
my $params;
{ local $^W = 0;
  $params = $head->params('X-Files');
}
$T->ok($params,					"got the parameter hash?");
$T->ok($$params{_}         eq 'default',    	"got the default field?");
$T->ok($$params{'name'}    eq 'X Files Test',	"got the name?");
$T->ok($$params{'length'}  eq '60',		"got the length?");
$T->ok($$params{'setting'} eq '6',		"got the setting?");

#------------------------------------------------------------
$T->msg("Output to a desired file");
#------------------------------------------------------------
open TMP, ">./testout/tmp.head" or die "open: $!";
$head->print(\*TMP);
close TMP;
$T->ok((-s "./testout/tmp.head") > 50,
	"output is a decent size?");      # looks okay

#------------------------------------------------------------
$T->msg("Parse in international header, decode and unfold it");
#------------------------------------------------------------
($head = MIME::Head->from_file('./testin/encoded.hdr'))
    or die "couldn't parse input";  # stop now
$head->decode;
$head->unfold;
$subject = $head->get('subject',0); $subject =~ s/\r?\n\Z//; 
my $to   = $head->get('to',0);      $to      =~ s/\r?\n\Z//; 
my $tsubject = "If you can read this you understand the example... cool!";
my $tto      = "Keld J\370rn Simonsen <keld\@dkuug.dk>";
$T->ok($to      eq $tto,      "Q decoding okay?");
$T->ok($subject eq $tsubject, "B encoding and compositing okay?");

#------------------------------------------------------------
$T->msg("Parse in header with 'From ', and check field order");
#------------------------------------------------------------

# Prep:
($head = MIME::Head->from_file('./testin/third.hdr'))
    or die "couldn't parse input";  # stop now
my @orighdrs;
my @realhdrs = qw(From 
		  Path:	
		  From:		
		  Newsgroups:
		  Subject:
		  Date:
		  Organization:
		  Lines:
		  Message-ID:
		  NNTP-Posting-Host:
		  Mime-Version:
		  Content-Type:
		  Content-Transfer-Encoding:
		  X-Mailer:
		  X-URL:);
my @curhdrs;

# Does it work?
@orighdrs = map {/^\S+:?/ ? $& : ''} (split(/\r?\n/, $head->stringify));
@curhdrs  = @realhdrs;
$T->ok(lc(join('|',@orighdrs)) eq lc(join('|',@curhdrs)),
      "field order preserved under stringify?");

# Does it work if we add/replace fields?
$head->replace("X-New-Addition", "Hi there!");
$head->replace("Subject",        "Hi there again!");
@curhdrs  = (@realhdrs, "X-New-Addition:");
@orighdrs = map {/^\S+:?/ ? $& : ''} (split(/\r?\n/, $head->stringify));
$T->ok(lc(join('|',@orighdrs)) eq lc(join('|',@curhdrs)),
      "field order preserved under stringify after fields added?");

# Does it work if we decode the header?
$head->decode;
@orighdrs = map {/^\S+:?/ ? $& : ''} (split(/\r?\n/, $head->stringify));
$T->ok(lc(join('|',@orighdrs)) eq lc(join('|',@curhdrs)),
      "field order is preserved under stringify after decoding?");

# Done!
exit(0);
1;



