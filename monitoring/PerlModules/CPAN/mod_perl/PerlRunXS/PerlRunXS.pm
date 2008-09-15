package Apache::PerlRunXS;

use strict;
use vars qw($Debug $VERSION);
use Apache::Constants qw(:common);

unless (defined $Apache::Registry::NameWithVirtualHost) {
    $Apache::Registry::NameWithVirtualHost = 1;
}

$Debug ||= 0;
my $Is_Win32 = $^O eq "MSWin32";

$VERSION = '0.03';

__PACKAGE__->mod_perl::boot($VERSION);

sub new {
    my($class, $r) = @_;
    return $r unless ref($r) eq "Apache";
    if(ref $r) {
	$r->request($r);
    }
    else {
	$r = Apache->request;
    }
    my $filename = $r->filename;
    $r->log_error("Apache::PerlRunXS->new for $filename in process $$")
	if $Debug && $Debug & 4;

    bless $r, $class;
}

1;

__END__

=head1 NAME

Apache::PerlRunXS - XS implementation of Apache::PerlRun/Apache::Registry

=head1 SYNOPSIS

 #in httpd.conf

 Alias /perl/ /perl/apache/scripts/ 
 PerlModule Apache::PerlRunXS

 <Location /perl>
 SetHandler perl-script
 PerlHandler Apache::RegistryXS
 Options +ExecCGI 
 #optional
 PerlSendHeader On
 ...
 </Location>

=head1 DESCRIPTION

This XS implementation of Apache::PerlRun and Apache::Registry will some day
replace the Perl versions.

=head1 SEE ALSO

perl(1), mod_perl(3), Apache::Registry(3)

=head1 AUTHOR

Doug MacEachern





