#!perl

unless (defined $ENV{MOD_PERL}) {
    die "\$ENV{MOD_PERL} not set!";
}

BEGIN {
    #./blib/lib:./blib/arch
    use ExtUtils::testlib;

    use lib map { "$Apache::Server::CWD/$_" } qw(t/docs blib/lib blib/arch);
    require "blib.pl" if -e "./t/docs/blib.pl";
    #Perl ignores w/ -T
    if ($ENV{PERL5LIB} and $ENV{PASS_PERL5LIB}) {
         unshift @INC, map { Apache->untaint($_) } split ":", $ENV{PERL5LIB};
    }

    $Apache::Server::Starting or warn "Server is not starting !?\n";
    \$Apache::Server::Starting == \$Apache::ServerStarting or 
	warn "GV alias broken\n";
    \$Apache::Server::ReStarting == \$Apache::ServerReStarting or 
	warn "GV alias broken\n";
}

if ($] >= 5.005 and -e "t/docs/local.pl") {
    eval {
	require "local.pl"; 
    }; $@='' if $@;
}

# BSD/OS 3.1 gets confused with some dynamically loaded code inside evals,
# so make sure IO::File is loaded here, rather than later within an eval.
# this should not harm any other platforms, since IO::File will be used
# by them anyhow.
use IO::File ();

use Apache ();
use Apache::Registry ();
unless ($INC{'Apache.pm'} =~ /blib/) {
    die "Wrong Apache.pm loaded: $INC{'Apache.pm'}";
}

Apache::Constants->export(qw(HTTP_MULTIPLE_CHOICES));

eval {
    require Apache::PerlRunXS;
}; $@ = '' if $@;


{
    last;
    Apache::warn("use Apache 'warn' is ok\n");

    my $s = Apache->server;

    my($host,$port) = map { $s->$_() } qw(server_hostname port);
    $s->log_error("starting server $host on port $port");

    my $admin = $s->server_admin;
    $s->warn("report any problems to server_admin $admin");
}

#use HTTP::Status ();
#use Apache::Symbol ();
#Apache::Symbol->make_universal;

$Apache::DoInternalRedirect = 1;
$Apache::ERRSV_CAN_BE_HTTP  = 1;
$Apache::Server::AddPerlVersion = 1;
#warn "ServerStarting=$Apache::ServerStarting\n";
#warn "ServerReStarting=$Apache::ServerReStarting\n";

#use Apache::Debug level => 4;
use mod_perl 1.03_01;

if(defined &main::subversion) {
    die "mod_perl.pm is broken\n";
}

if($ENV{PERL_TEST_NEW_READ}) {
    *Apache::READ = \&Apache::new_read;
}

unless($ENV{KeyForPerlSetEnv} and 
       $ENV{KeyForPerlSetEnv} eq "OK") {
    warn "PerlSetEnv is broken\n";
}

%net::callback_hooks = ();
require "net/config.pl";
if($net::callback_hooks{PERL_SAFE_STARTUP}) {
    eval "open \$0";
    unless ($@ =~ /open trapped by operation mask/) {
	die "opmask not set";
    }
}
else {
    require "docs/rl.pl";
}
#for testing perl mod_include's

$Access::Cnt = 0;
sub main::pid { print $$ }
sub main::access { print ++$Access::Cnt }

$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not set!";

sub Outside::code {4}
%Outside::hash = (one => 1);
@Outside::array = qw(one);
$Outside::scalar = 'one';

#will be redef'd during tests
sub PerlTransHandler::handler {-1}

#for testing PERL_HANDLER_METHODS
#see httpd.conf and t/docs/LoadClass.pm

require "docs/LoadClass.pm";

sub MyClass::method ($$) {
    my($class, $r) = @_;  
    #warn "$class->method called\n";
    0;
}

sub BaseClass::handler ($$) {
    my($class, $r) = @_;  
    #warn "$class->handler called\n";
    0;
}

{
    package BaseClass;
    #so 5.005-tobe doesn't complain:
    #No such package "BaseClass" in @ISA assignment at ...
}


$MyClass::Object = bless {}, "MyClass";
@MyClass::ISA = qw(BaseClass);

#testing child init/exit hooks

sub My::child_init {
    my $r = shift;
    eval {
      my $s = $r->server;
      my $sa = $s->server_admin;
      $s->warn("[notice] child_init for process $$, report any problems to $sa\n");
    }; $@='' if $@;
    0;
}

sub My::child_exit {
    warn "[notice] child process $$ terminating\n";
}

sub My::restart {
    my $r = shift;
    my $s = $r->server;
    my $sa = $s->server_admin;
    push @HTTP::Status::ISA, "Apache::Symbol";
    HTTP::Status->undef_functions;
}

sub Apache::AuthenTest::handler {
    use Apache::Constants ':common';
    my $r = shift;

    $r->custom_response(AUTH_REQUIRED, "/error.txt");

    my($res, $sent_pwd) = $r->get_basic_auth_pw;
    return $res if $res; #decline if not Basic

    my $user = lc $r->user;
    $r->notes("DoAuthenTest", 1);
    
    unless($user eq "dougm" and $sent_pwd eq "mod_perl") {
        $r->note_basic_auth_failure;
        return AUTH_REQUIRED;
    }

    return OK;                       
}

use Apache::Constants qw(DECLINED DIR_MAGIC_TYPE);

sub My::DirIndex::handler {
    my $r = shift;
    return DECLINED unless $r->content_type and 
	$r->content_type eq DIR_MAGIC_TYPE;
    require DirHandle;
    my $dh = DirHandle->new($r->filename) or die $!;
    my @entries = $dh->read;
    my $x = @entries;
    $r->send_http_header('text/plain');
    print "1..$x\n";
    my $i = 1;
    for my $e (@entries) {
	print "ok $i ($e)\n";
	++$i;
    }
    1;
}

sub My::ProxyTest::handler {
    my $r = shift;
    unless ($r->proxyreq and $r->uri =~ /proxytest/) {
	#warn sprintf "ProxyTest: proxyreq=%d, uri=%s\n",
	$r->proxyreq, $r->uri;
    }
    return -1 unless $r->proxyreq;
    return -1 unless $r->uri =~ /proxytest/;
    $r->handler("perl-script");
    $r->push_handlers(PerlHandler => sub {
	my $r = shift;
	$r->send_http_header("text/plain");
	$r->print("1..1\n");
	$r->print("ok 1\n");
	$r->print("URI=`", $r->uri, "'\n");
    });
    return 0;
}

if(Apache->can_stack_handlers) {
    Apache->push_handlers(PerlChildExitHandler => sub {
	warn "[notice] push'd PerlChildExitHandler called, pid=$$\n";
    });
}

END {
    warn "[notice] END block called for startup.pl\n";
}

package Apache::Death;
my $say_ok = <<EOF;
*** The following [error] is expected, no cause for alarm ***
EOF

sub handler {
    my $r = shift;

    my $args = $r->args || "";
    if ($args =~ /die/) {
	warn $say_ok;
	delete $INC{"badsyntax.pl"};
	require "badsyntax.pl";  # contains syntax error
    }
    if($args =~ /croak/) {
	warn $say_ok;
        Carp::croak("Apache::Death");
    }

    $r->content_type('text/html');
    $r->send_http_header();
    print "<h1>Script completed</h1>\n";
    return 0;
}

package Destruction;

sub new { bless {} }

sub DESTROY { 
    warn "[notice] Destruction->DESTROY called for \$global_object\n" 
}

#prior to 1.3b1 (and the child_exit hook), this object's DESTROY method would not be invoked
$global_object = Destruction->new;

1;
