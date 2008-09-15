package Apache::RegistryBB;

use strict;
use vars qw(@ISA);
use Apache::Constants qw(NOT_FOUND FORBIDDEN OK DECLINED);
use Apache::RegistryNG (); 
@ISA = qw(Apache::RegistryNG);

#Apache::Registry - Bare-Bones
#configure like so:
# PerlModule Apache::RegistryBB
# <Location /perl>
# SetHandler perl-script
# PerlHandler ApacheRegistryBB->handler
# </Location>

#skip -x, OPT_EXEC, etc. checks
sub can_compile {
    my $r = shift->{r};
    unless (-r $r->finfo) {
	$r->log_reason("file does not exist");
	return NOT_FOUND;
    }
    if (-d _) {
	$r->log_reason("attempt to invoke directory as script");
	return DECLINED;
    }
    return OK;
}

#only cache once, don't re-compile if updated on disk
sub should_compile {
    not shift->cached;
}

#don't chdir() to the script file directory
sub chdir_file {
   #noop
}

1;

__END__
