
package NOCpulse::HttpsMX;

use strict;
use CGI;
use NOCpulse::Config;

my $cfg = new NOCpulse::Config;
my $target_email = $cfg->get('gritch', 'targetEmail');

sub handler {
    
    my $request = shift;
    $request->content_type('text/html');
    
    my $sendmail;
    my $sendmail_candidate;
    foreach $sendmail_candidate ('/usr/lib/sendmail', '/usr/sbin/sendmail') {
	if ( -x $sendmail_candidate ) {
	    $sendmail = $sendmail_candidate;
	    last;
	}
    }
    
    my $q = CGI->new($request->args());
    
    my $recip     = $q->param('to');
    my $subject   = $q->param('subject');
    my $body      = $q->param('body');
    
    my $err;
    if ($sendmail) {
	$ENV{'PATH'} = '';
	open(MAIL, "|$sendmail -f $target_email -t") or $err="Couldn't spawn $sendmail: $!";
	print MAIL "To: $recip\n";
	print MAIL "Subject: $subject\n";
	print MAIL "\n";
	print MAIL "$body\n";
	close(MAIL);
	
    }
    else {
	
	# Couldn't find sendmail -- fall back to /bin/mail
	$subject =~ tr/'//d; # '
	open(MAIL, "|/bin/mail -s '$subject' $recip") 
	    or $err="Couldn't spawn /bin/mail: $!";
	print MAIL "$body\n";
	close(MAIL);
    }
    
    if ($err) {
	# do something with $err
	return 500;
    }
    else {
	return 0;
    }
}


1;

