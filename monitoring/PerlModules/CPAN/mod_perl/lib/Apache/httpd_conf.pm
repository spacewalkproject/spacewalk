package Apache::httpd_conf;

use strict;
use vars qw($VERSION $AUTOLOAD);
use File::Path ();
use IO::File ();
use Cwd ();

$VERSION = '0.01';

sub new {
    my $class = shift;
    my $self = bless {
	base => "",
	@_,
    }, $class;
    $self->{base} ||= (Cwd::fastcwd()."/t");
    return $self;
}

sub write {
    my $self = shift;
    my $args = {@_};
    
    while(my($k,$v) = each %$args) {
	$self->{$k} = $v;
    }

    my $base = $self->{base};

    #XXX this sucks, find a better way
    $Apache::httpd_conf::BaseDir = $base;

    unless (-d "$base/conf") {
	for (qw(conf logs docs perl)) {
	   File::Path::mkpath("$base/$_", 0, 0755);
	}
    }

    my $fh = IO::File->new(">$base/conf/httpd.conf") or 
	die "can't open $base/conf/httpd.conf $!";

    print $fh "PerlPassEnv PERL5LIB\n";
    print $fh "<Perl>\n";
    print $fh "BEGIN { \$Apache::httpd_conf::BaseDir = '$base'; }\n";
    print $fh "use ",  __PACKAGE__, "();\n";
    print $fh "</Perl>\n";     

    while(my($k,$v) = each %$self) {
	next unless $k =~ /^[A-Z]/;
	no strict;
        ${"Apache::ReadConfig::".$k} = $v;
	print $fh "$k $v\n";
    }
    print $fh "\n";
    
    $fh->close;
}

sub server_start {
    my $self = shift;
    my @args = ();
    my $args = {catch_sig => 1};
    my $know_where = 0; 

    my %not_for_httpd = map { $_,1 } qw{httpd catch_sig};

    do {
	++$know_where if /^-(d|f)/;

	if($not_for_httpd{$_}) {
	    $args->{$_} = shift;
	}
	else {
	    push @args, $_ if $_;
	}
    } while $_ = shift;

    my $httpd = $args->{httpd} || 
	prompt("where is your httpd?", "/opt/www/apache/httpd");

    push @args, "-d" => $Apache::httpd_conf::BaseDir unless $know_where;

    $self->catch_signals if $args->{catch_sig};

    system "$httpd @args &";
}

sub pid {
    my $self = shift;
    my $pid_file = join "/", $self->{base}, $self->PidFile;

    my $fh = IO::File->new($pid_file) or 
	die "can't open $pid_file $!\n";
    chomp(my $pid = <$fh>);
    return $pid;
}

sub server_stop {
    kill 9, shift->pid;
}

sub server_url {
    no strict;
    require URI::URL;
    my $url = URI::URL->new();
    $url->scheme('http');
    $url->host($Apache::ReadConfig::ServerName || "localhost");
    $url->port($Apache::ReadConfig::Port || 80);
    return $url;
}

sub catch_signals {
    my $self = shift;
    $SIG{INT} = $SIG{__DIE__} = 
	sub { print "stopping httpd\n"; $self->server_stop; exit(); }
}

sub prompt {
    my($mess,$def) = @_;
    print "$mess [$def]";
    STDIN->untaint;
    chomp(my $ans = <STDIN>);
    $ans || $def;
}

sub AUTOLOAD {
    my $self = shift;
    my $name = (split "::", $AUTOLOAD)[-1];
    my $val = shift || "";

    my $retval = ${$Apache::ReadConfig::{$name}};

    ${$Apache::ReadConfig::{$name}} = $val if $val;

    return $retval;
}

sub DESTROY {}

package Apache::ReadConfig;

no strict;

use subs qw(prompt);
*prompt = \&Apache::httpd_conf::prompt;

my $dir = $Apache::httpd_conf::BaseDir || "";

unless ($dir) {
    my $cwd = Cwd::fastcwd();
    for ($cwd, "$cwd/t") {
	$dir = $_, last if -d "$_/logs";
    }
}

my $Is_Win32 = ($^O eq "MSWin32");

$ServerRoot = $dir;

my $startup = "$ServerRoot/startup.pl";

if(-e $startup) {
    push @PerlRequire, $startup;
}


$User  = $Is_Win32 ? "nobody" : (getpwuid($>) || $>);
$Group = $Is_Win32 ? "nogroup" : (getgrgid($)) || $)); 

if($User eq "root") {
    my $other = (getpwnam('nobody'))[0];
    $User = $other if $other;
} 
if($User eq "root") {
    print "Cannot run tests as User `$User'\n";
    $User  = prompt "Which User?", "nobody";
    $Group = prompt "Which Group?", $Group; 
}
#print "Will run tests as User: '$User' Group: '$Group'\n";

$Port = 8529;
$DocumentRoot = $dir ? "$dir/docs" : "docs";
$ServerName = "localhost";
 
@Alias = () unless @Alias;

for (qw(/perl /cgi-bin)) {
    push @Alias, [$_ => $dir ? "$dir/perl" : "perl"];
}

my @mod_perl = (
    SetHandler  => "perl-script",
    PerlHandler => "Apache::Registry",
    Options     => "+ExecCGI",
);

push @AddType, ["text/x-server-parsed-html" => ".shtml"];

$Location{"/perl"} = { 
    @mod_perl,
};

$Location{"/cgi-bin"} = {
    SetHandler => "cgi-script",
    Options    => "+ExecCGI",
};

$Location{"/perl-status"} = {
    SetHandler  => "perl-script",
    PerlHandler => "Apache::Status",
};

for (qw(status info)) {
    $Location{"/server-$_"} = {
	SetHandler => "server-$_",
    };
}

$ErrorLog = "logs/error_log";
$PidFile  = "logs/httpd.pid";
$LockFile = "logs/lock";

for my $sym (
	     qw{
    ResourceConfig AccessConfig TypesConfig TransferLog ScoreBoardFile
    }
	     )
{
    $$sym = "/dev/null";
}

while (my($k,$v) = each %Apache::ReadConfig::) {
    $$k ||= $v if defined $$k; #avoid -w warnings
}

1;
__END__

=head1 NAME

Apache::httpd_conf - Generate an httpd.conf file

=head1 SYNOPSIS

  use Apache::httpd_conf ();

  Apache::httpd_conf->write(Port => 8888);

=head1 DESCRIPTION

The Apache::httpd_conf module will generate a tiny httpd.conf file,
which pulls itself back in via a <Perl> section.  Any additional
arguments passed to the C<write> method will be added to the generated
httpd.conf file, and will override those defaults set in the <Perl> 
section.  This module is handy mostly for starting httpd servers to
test mod_perl scripts and modules.

=head1 AUTHOR

Doug MacEachern

=head1 SEE ALSO

mod_perl(3), Apache::PerlSections(3)

=cut
