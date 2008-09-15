use lib "./t";
use MIME::Head;
use MIME::Parser;

use ExtUtils::TBone;

# Create checker:
my $T = typical ExtUtils::TBone;
$T->begin(7);

#------------------------------
# Bug 971008 from Michael W. Normandin <michael.normandin@csfb.com>:
#------------------------------
# I've found something you may be interested in :
# Header: 
#        Content-Type: application/vnd.ms-powerpoint; name="June97V4.0.ppt"
# Code:
#        $mtype = $pentity->head->mime_type;
#        print "$mytype\n";
#
# Produces:  
#        application/vnd
#
{
    my $head = MIME::Head->new([
	 'Content-Type: application/vnd.ms-powerpoint; name="June97V4.0.ppt"'
				]);
    $T->ok_eq($head->mime_type,
	      "application/vnd.ms-powerpoint",
	      "bug 971008-MWN: are MIME attributes parsed ok?");
}

#------------------------------
# Bug 970822 from Anselm Lingnau <lingnau@tm.informatik.uni-frankfurt.de>
#------------------------------
#   use Mail::Field;
#   use MIME::Head;
#   $field = Mail::Field->new('Content-type', 'text/HTML; charset="US-ASCII"');
#   print $field->type, "\n";
# 
# but all I see is:
#
#   Can't locate object method "parse" via package "Mail::Field::ContType"
#   at /local/pkg/perl/5.004/lib/site_perl/Mail/Field.pm line 306.
# 
# I suppose this has to do with the fact that it is `MIME::Field' rather
# than `Mail::Field', but I am at a loss as to what to do next. Maybe you
# can help? Thank you very much.
{
    use Mail::Field;
    use MIME::Head;
    my $field = Mail::Field->new('Content-type', 
				 'text/HTML; charset="US-ASCII"');
    $T->ok_eq($field->paramstr('_'),
	      "text/HTML",
	      "bug 970822-AL: Mail::Field register problem (paramstr)");
    $T->ok_eq($field->type,
	      "text/html",
	      "bug 970822-AL: Mail::Field register problem (type)");
}

#------------------------------
# Bug 970725 from Denis N. Antonioli <antonio@ifi.unizh.ch>
#------------------------------
# Were it possible to incorporate the guideline #8 from RFC 2049?
# The change involved is minim: just adding the 2 lines
#    $res =~ s/\./=2E/go;
#    $res =~ s/From /=46rom /go;
# at the start of encode_qp_really in MIME::Decoder::QuotedPrint?
{
    use MIME::Decoder::QuotedPrint;
    my $pair;
    foreach $pair (["From me",   "=46rom me"],
		   [".",         "=2E"],
		   [" From you", " From you"]) {
	my $out = MIME::Decoder::QuotedPrint::encode_qp_really($pair->[0]);
	$T->ok_eq($out, $pair->[1],
		  "bug 970725-DNA: QP use of RFC2049 guideline 8");
    }
}

#------------------------------
# Bug 970626 from Sun, Tong <TSun@FS.com>
#------------------------------
# @history = $head->get_all('Received');
#
# The above code does not work. It confused me at the beginning. Then, I
# found out it is only a spelling error: when I changed the 'Received' to
# 'received', it works ( you know why ).
{
    my $head = MIME::Head->new(["Received: first\n",
				"Received: second\n",
				"received: third\n",
				"Received: fourth\n",
				"subject: hi!\n"]);
    my @received = $head->get_all('Received');
    $T->ok_eqnum(int(@received), 
		 4,	 
		 "bug 970626-TS: header get_all() case problem fixed?");
}

#------------------------------
# Bug 980430 from Jason L Tibbitts III <tibbs@hpc.uh.edu>
#------------------------------
# Boundary-parsing errors for this message.
{
    my $parser = new MIME::Parser;
    $parser->output_to_core('ALL');
#    my $e = eval { $parser->parse_open("testin/jt-0498.msg") };
#    $T->ok_eqnum(($e and $e->parts), 
#		 2,
#		 "bug 980430-JT: did we get 2 parts?");
}

#------------------------------------------------------------
$T->end;
1;


