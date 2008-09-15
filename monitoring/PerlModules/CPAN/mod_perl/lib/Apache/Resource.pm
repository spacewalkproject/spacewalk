#! /usr/local/bin/perl
package Apache::Resource;

use strict;
use vars qw($Debug);
use BSD::Resource qw(setrlimit getrlimit get_rlimits);

$Debug ||= 0;
$Apache::Resource::VERSION = '1.71';

sub MB ($) { 
    my $num = shift;
    return ($num < (1024 * 1024)) ?  $num*1024*1024 : $num;
}

sub BM ($) { 
    my $num = shift;
    return ($num > (1024 * 1024)) ?  '(' . ($num>>20) . 'Mb)' : '';
}

sub DEFAULT_RLIMIT_DATA  () { 64 } #data (memory) size in MB
sub DEFAULT_RLIMIT_AS    () { 64 } #address space (memory) size in MB
sub DEFAULT_RLIMIT_CPU   () { 60*6 } #cpu time in seconds
sub DEFAULT_RLIMIT_CORE  () { 0  } #core file size (MB)
sub DEFAULT_RLIMIT_RSS   () { 16 } #resident set size (MB)
sub DEFAULT_RLIMIT_FSIZE () { 10 } #file size  (MB)
sub DEFAULT_RLIMIT_STACK () { 20 } #stack size (MB)

my %is_mb = map {$_,1} qw{DATA RSS STACK FSIZE CORE MEMLOCK AS};

sub debug { print STDERR @_ if $Debug }

sub install_rlimit ($$$) {
    my($res, $soft, $hard) = @_;

    my $name = $res;

    my $cv = \&{"BSD::Resource::RLIMIT_${res}"};
    eval { $res = $cv->() };
    return if $@;

    unless ($soft) { 
	my $defval = \&{"DEFAULT_RLIMIT_${name}"};
	if(defined &$defval) {
	    $soft = $defval->();
	}
	else {
	    warn "can't find default for `$defval'\n";
	}
    }

    $hard ||= $soft;

    debug "Apache::Resource: PID $$ attempting to set `$name'=$soft:$hard ...";

    ($soft, $hard) = (MB $soft, MB $hard) if $is_mb{$name};

    return setrlimit $res, $soft, $hard;
}

sub handler {
    while(my($k,$v) = each %ENV) {
	next unless $k =~ /^PERL_RLIMIT_(\w+)$/;
	$k = $1;
	next if $k eq "DEFAULTS";
	my($soft, $hard) = split ":", $v, 2; 
	$hard ||= $soft;

	my $set = install_rlimit $k, $soft, $hard;
	debug "not " unless $set;
	debug "ok\n";
	debug $@ if $@;
    }

    0;
}

sub default_handler {
    while(my($k,$v) = each %Apache::Resource::) {
	next unless $k =~ s/^DEFAULT_/PERL_/;
	$ENV{$k} = "";
    }
    handler();
}

sub status_rlimit {
    my $lim = get_rlimits();
    my @retval = ("<table border=1><tr>", 
		  (map "<th>$_</th>", qw(Resource Soft Hard)),
		  "</tr>");

    for my $res (keys %$lim) {
	my $val = eval "&BSD::Resource::${res}()";
	my ($soft,$hard) = getrlimit $val;
	(my $limit = $res) =~ s/^RLIMIT_//;
	($soft, $hard) = ("$soft " . BM($soft),"$hard ". BM($hard))
	  if $is_mb{$limit};
	push @retval, 
	"<tr>",
	(map { "<td>$_</td>" } $res, $soft, $hard),
	"</tr>";
    }

    push @retval, "</table><P>";
    push @retval, "<SMALL>Apache::Resource $Apache::Resource::VERSION</SMALL>";

    return \@retval;
}

if($ENV{MOD_PERL}) {
    if($ENV{PERL_RLIMIT_DEFAULTS}) {
	Apache->push_handlers(PerlChildInitHandler => \&default_handler);
    }

    Apache::Status->menu_item(rlimit => "Resource Limits", 
			    \&status_rlimit)
      if Apache->module("Apache::Status");
}

#perl Apache/Resource.pm
++$Debug, default_handler unless caller();

1;

__END__

=head1 NAME

Apache::Resource - Limit resources used by httpd children

=head1 SYNOPSIS

 PerlModule Apache::Resource
 #set child memory limit in megabytes
 #default is 64 Meg
 PerlSetEnv PERL_RLIMIT_DATA 32:48

 #linux does not honor RLIMIT_DATA
 #RLIMIT_AS (address space) will work to limit the size of a process
 PerlSetEnv PERL_RLIMIT_AS 32:48

 #set child cpu limit in seconds
 #default is 360 seconds
 PerlSetEnv PERL_RLIMIT_CPU 120

 PerlChildInitHandler Apache::Resource

=head1 DESCRIPTION

B<Apache::Resource> uses the B<BSD::Resource> module, which 
uses the C function C<setrlimit> to set limits on
system resources such as memory and cpu usage.

Any B<RLIMIT> operation available to limit on your system can be set
by defining that operation as an environment variable with a C<PERL_>
prefix.  See your system C<setrlimit> manpage for available resources
which can be limited.

The following limit values are in megabytes: C<DATA>, C<RSS>, C<STACK>,
C<FSIZE>, C<CORE>, C<MEMLOCK>; all others are treated as their natural unit.

If the value of the variable is of the form C<S:H>, C<S> is treated as
the soft limit, and C<H> is the hard limit.  If it is just a single
number, it is used for both soft and hard limits.

=head1 DEFAULTS

To set reasonable defaults for all RLIMITs, add this to your httpd.conf:

 PerlSetEnv PERL_RLIMIT_DEFAULTS On
 PerlModule Apache::Resource

=head1 AUTHOR

Doug MacEachern

=head1 SEE ALSO

BSD::Resource(3), setrlimit(2)

=cut




