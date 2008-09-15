package Apache::RegistryNG;

use Apache::PerlRun ();
use Apache::Constants qw(:common);
use strict;
use vars qw($VERSION @ISA);
$VERSION = '1.00';
@ISA = qw(Apache::PerlRun);

#OO replacement for Apache::Registry
#configure like so:
# <Location /perl>
# SetHandler perl-script
# PerlHandler Apache::RegistryNG->handler
# Options +ExecCGI
# </Location>
# see also: Apache::RegistryBB
 
sub namespace_from {
    shift->filename;
}

sub handler ($$) {
    my($class, $r);
    if (@_ >= 2) {
	($class, $r) = (shift, shift);
    }
    else {
	($class, $r) = (__PACKAGE__, shift);
    }
    my $pr = $class->new($r);

    my $rc = $pr->can_compile;
    return $rc unless $rc == OK;

    local $^W = $^W;

    my $package = $pr->namespace;
    $pr->set_script_name;
    $pr->chdir_file;

    if($pr->should_compile) {
	$pr->readscript;
        $pr->parse_cmdline;
	$pr->sub_wrap;
	my $rc = $pr->compile;
        return $rc if $rc != OK;
	$pr->update_mtime;
    }

    $rc = $pr->run(@_);
    $pr->chdir_file("$Apache::Server::CWD/");
    return ($rc != OK) ? $rc : $pr->status;
}

1;

__END__
