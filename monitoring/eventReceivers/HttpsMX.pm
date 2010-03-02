package NOCpulse::HttpsMX;

use strict;
use CGI;
use NOCpulse::Config;
use Mail::Send;
use Mail::Mailer;

my $cfg = new NOCpulse::Config;
my $target_email = $cfg->get('gritch', 'targetEmail');

sub handler {
    my $request = shift;
    $request->content_type('text/html');
    my $q = CGI->new($request->args());
    
    my $recip     = $q->param('to');
    my $subject   = $q->param('subject');
    my $body      = $q->param('body');
    
    my $err;
    if (Mail::Mailer::is_exe('sendmail')) {
	my $msg = Mail::Send->new(Subject => $subject, To => $recip, From => $target_email);
	my $fh = $msg->open('sendmail');
	print $fh $body;
	$fh->close or $err= "couldn't send whole message: $!";
    } else {
	# Couldn't find sendmail -- fall back to /bin/mail
	$subject =~ tr/'//d; # '
	open(MAIL, "|/bin/mail -s '$subject' $recip") 
	    or $err="Couldn't spawn /bin/mail: $!";
	print MAIL "$body\n";
	close(MAIL);
    }
    
    if ($err) {
	# do something with $err
	print STDERR "$err\n";
	return 500;
    }
    else {
	return 0;
    }
}


1;

