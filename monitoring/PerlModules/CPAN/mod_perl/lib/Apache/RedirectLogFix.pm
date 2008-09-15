package Apache::RedirectLogFix;

use Apache::Constants qw(OK DECLINED REDIRECT);

sub handler {
    my $r = shift->last;
    return DECLINED unless $r->handler && ($r->handler eq "perl-script");

    if(my $loc = $r->header_out("Location")) {
	if($r->status == 200 and substr($loc, 0, 1) ne "/") {
	    $r->status(REDIRECT);
	    return OK
	}
    }
    return DECLINED;
}

1;

__END__

=head1 NAME

Apache::RedirectLogFix - Properly set redirect status for loggers

=head1 SYNOPSIS

PerlLogHandler Apache::RedirectLogFix

=head1 DESCRIPTION

Due the nature of how mod_perl handles redirects, the status code
is not properly logged.  This module works around that bug until
mod_perl can deal with this.

