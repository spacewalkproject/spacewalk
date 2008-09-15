package Apache::PerlSections;

use strict;
$Apache::PerlSections::VERSION = '1.61';

use Devel::Symdump ();
use Data::Dumper ();

sub store {
    require IO::File;

    my($self, $file) = @_;
    my $fh = IO::File->new(">$file") or die "can't open $file $!\n";
    
    $fh->print($self->dump);
    
    $fh->close;
}

sub dump {
    my @retval = "package Apache::ReadConfig;";

    local $Data::Dumper::Indent = 1;

    my $stab = Devel::Symdump->rnew('Apache::ReadConfig');

    my %dump = (
	hashes  => 'HASH',
	scalars => 'SCALAR',
	arrays  => 'ARRAY',
    );

    while(my($meth,$type) = each %dump) {
	no strict 'refs';
	push @retval, "#$meth:\n";
	for my $name ($stab->$meth()) {
            my $s = Data::Dumper->Dump([*$name{$type}], ['*'.$name]);
	    $s =~ s/Apache:{0,2}ReadConfig:://;
            if($s =~ /^\$/) {
               $s =~ s/= \\/= /; #whack backwack
            }
	    push @retval, $s unless $s =~ /= (undef|\(\));$/;
	}
    }

    return join "\n", @retval, "1;", "__END__", "";
}

1;

__END__

=head1 NAME

Apache::PerlSections - Utilities for work with <Perl> sections

=head1 SYNOPSIS

    use Apache::PerlSections ();

=head1 DESCRIPTION

It is possible to configure you server entirely in Perl using
<Perl> sections in I<httpd.conf>.  This module is here to help
you with such a task.

=head1 METHODS

=over 4

=item dump

This method will dump out all the configuration variables mod_perl
will be feeding the the apache config gears.  The output is suitable
to read back in via C<eval>.

Example:

 <Perl>

 use Apache::PerlSections ();

 $Port = 8529;

 $Location{"/perl"} = {
     SetHandler => "perl-script",
     PerlHandler => "Apache::Registry",
     Options => "ExecCGI",
 };

 @DocumentIndex = qw(index.htm index.html);

 $VirtualHost{"www.foo.com"} = {
     DocumentRoot => "/tmp/docs",
     ErrorLog => "/dev/null",
     Location => {
	 "/" => {
	     Allowoverride => 'All',
	     Order => 'deny,allow',
	     Deny  => 'from all',
	     Allow => 'from foo.com',
	 }, 
     },
 };   

 print Apache::PerlSections->dump;

 </Perl>

This will print something like so:

 package Apache::ReadConfig;
 #scalars:

 $Port = 8529;

 #arrays:

 @DocumentIndex = (
   'index.htm',
   'index.html'
 );

 #hashes:

 %Location = (
   '/perl' => {
     PerlHandler => 'Apache::Registry',
     SetHandler => 'perl-script',
     Options => 'ExecCGI'
   }
 );

 %VirtualHost = (
   'www.foo.com' => {
     Location => {
       '/' => {
         Deny => 'from all',
         Order => 'deny,allow',
         Allow => 'from foo.com',
         Allowoverride => 'All'
       }
     },
     DocumentRoot => '/tmp/docs',
     ErrorLog => '/dev/null'
   }
 );

 1;
 __END__

=item store

This method will call the C<dump> method, writing the output
to a file, suitable to be pulled in via C<require>.

Example:

   Apache::PerlSections->store("httpd_config.pl");

   require 'httpd_config.pl';

=back

=head1 SEE ALSO

mod_perl(1), Data::Dumper(3), Devel::Symdump(3)

=head1 AUTHOR

Doug MacEachern


