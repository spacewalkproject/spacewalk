package Apache::test;

use strict;
use vars qw(@EXPORT $USE_THREAD $USE_SFIO $PERL_DIR);
use Exporter ();
use Config;
use FileHandle ();
*import = \&Exporter::import;

@EXPORT = qw(test fetch simple_fetch have_module skip_test 
	     $USE_THREAD $USE_SFIO $PERL_DIR WIN32 grab run_test); 

BEGIN { 
    if(not $ENV{MOD_PERL}) {
	eval { require "net/config.pl"; }; #for 'make test'
	$PERL_DIR = $net::perldir;
    } 
    if ($net::httpserver) {
	# Validate that the OS knows the name of the server in $net::httpserver     
	# if 'localhost' is not defined, the tests wouldn't pass
	(my $hostname) = ($net::httpserver =~ /(.*?):/);
	warn qq{\n*** [Crucial] You must define "$hostname" (e.g. in /etc/hosts) in order for 'make test' to pass\n}  
	unless gethostbyname $hostname;
    }
}

$PERL_DIR = $ENV{PERL_DIR} if exists $ENV{PERL_DIR};

$USE_THREAD = ($Config{extensions} =~ /Thread/) || $Config{usethreads};
$USE_SFIO = (($Config{'usesfio'} || '') eq 'true');

my $Is_Win32 = ($^O eq "MSWin32");
sub WIN32 () { $Is_Win32 };

my $UA;

eval {
    require LWP::UserAgent;
    $UA = LWP::UserAgent->new;
};

unless (defined &Apache::bootstrap) {
    *Apache::bootstrap = sub {};
    *Apache::Constants::bootstrap = sub {};
}

sub write_httpd_conf {
    my $pkg = shift;
    my %args = (conf_file => 't/httpd.conf', @_);
    my $DIR = `pwd`; chomp $DIR;

    local *CONF;
    open CONF, ">$args{conf_file}" or die "Can't create $args{conf_file}: $!";
    print CONF <<EOF;

Port $args{port}
User $args{user}
Group $args{group}
ServerName localhost
DocumentRoot $DIR/t

$args{modules}

ErrorLog $DIR/t/error_log
PidFile $DIR/t/httpd.pid
AccessConfig /dev/null
ResourceConfig /dev/null
LockFile $DIR/t/httpd.lock
TypesConfig /dev/null
TransferLog /dev/null
ScoreBoardFile /dev/null

AddType text/html .html

# Look in ./blib/lib
#PerlModule ExtUtils::testlib
<Perl>
 use lib "$DIR/blib/lib", "$DIR/t/lib";
</Perl>

$args{include}
EOF

    return 1;
}

sub _ask {
    # Just a function for asking the user questions
    my ($prompt, $default, $mustfind) = @_;

    my $response;
    do {
	print "$prompt [$default]: ";
	chomp($response = <STDIN>);
	$response ||= $default;
    } until (!$mustfind || (-e $response || !print("$response not found\n")));

    return $response;
}

sub get_test_params {
    my $pkg = shift;

    print("\nFor testing purposes, please give the full path to an httpd\n",
	  "with mod_perl enabled.  The path defaults to \$ENV{APACHE}, if present.");
    
    my %conf;
    
    my $httpd = $ENV{'APACHE'} || which('apache') || which('httpd') || '/usr/lib/httpd/httpd';

    $httpd = _ask("\n", $httpd, 1);
    system "$Config{lns} $httpd t/httpd";

    if (lc _ask("Search existing config file for dynamic module dependencies?", 'n') eq 'y') {
	my %compiled;
	for (`t/httpd -V`) {
	    if (/([\w]+)="(.*)"/) {
		$compiled{$1} = $2;
	    }
	}
	$compiled{SERVER_CONFIG_FILE} =~ s,^,$compiled{HTTPD_ROOT}/,
	    unless $compiled{SERVER_CONFIG_FILE} =~ m,^/,;
	
	my $file = _ask("  Config file", $compiled{SERVER_CONFIG_FILE}, 1);
	$conf{modules} = $pkg->_read_existing_conf($file);
    }

    # Get default user (apache doesn't like to run as root, special-case it)
    my $defuser = ($< && getpwuid $<) || 'nobody';
    $conf{user} = _ask("User to run tests under", $defuser);

    my $defgroup = ($defuser eq 'nobody' ? 'nobody' : getgrgid((getpwnam $conf{user})[3]));
    $conf{group} = _ask("Group to run tests under", $defgroup);

    $conf{port} = _ask("Port to run tests under", 8228);

    return %conf;
}

sub _read_existing_conf {
    # Returns some config text 
    shift;
    my ($server_conf) = @_;
    
    
    open SERVER_CONF, $server_conf or die "Couldn't open $server_conf: $!";
    my @lines = grep {!m/^\s*#/} <SERVER_CONF>;
    close SERVER_CONF;
    
    my @modules       =   grep /^\s*(Add|Load)Module/, @lines;
    my ($server_root) = (map /^\s*ServerRoot\s*(\S+)/, @lines);

    # Rewrite all modules to load from an absolute path.
    foreach (@modules) {
	s!(\s)([^/\s]\S+/)!$1$server_root/$2!;
    }
    
    # Directories where apache DSOs live.
    my (@module_dirs) = map {m,(/\S*/),} @modules;
    
    # Have to make sure that dir, autoindex and perl are loaded.
    my @required  = qw(dir autoindex perl);
    
    my @l = `t/httpd -l`;
    my @compiled_in = map /^\s*(\S+)/, @l[1..@l-2];
    
    my @load;
    foreach my $module (@required) {
	if (!grep /$module/i, @compiled_in, @modules) {
	    push @load, $module;
	}
    }
    
    # Finally compute the directives to load modules that need to be loaded.
 MODULE:
    foreach my $module (@load) {
	foreach my $module_dir (@module_dirs) {
	    if (-e "$module_dir/mod_$module.so") {
		push @modules, "LoadModule ${module}_module $module_dir/mod_$module.so\n"; next MODULE;
	    } elsif (-e "$module_dir/lib$module.so") {
		push @modules, "LoadModule ${module}_module $module_dir/lib$module.so\n"; next MODULE;
	    } elsif (-e "$module_dir/ApacheModule\u$module.dll") {
		push @modules, "LoadModule ${module}_module $module_dir/ApacheModule\u$module.dll\n"; next MODULE;
	    }
	}
    }
		      
    print "found the following modules: \n@modules";
    return join '', @modules;
}

# Find an executable in the PATH.
sub which {
    foreach (map { "$_/$_[0]" } split /:/, $ENV{PATH}) {
	next unless m,^/,;
	return $_ if -x;
    }
}

sub test { 
    shift() if UNIVERSAL::isa($_[0], __PACKAGE__);
    my $s = $_[1] ? "ok $_[0]\n" : "not ok $_[0]\n";
    if($ENV{MOD_PERL}) {
	Apache->request->print($s);
    }
    else {
	print $s;
    }
}

sub fetch {
    # Old code calls fetch() as a function, new code as a method
    my $want_response;
    $want_response = shift() if UNIVERSAL::isa($_[0], __PACKAGE__);
    my ($ua, $url) = (@_ == 1 ? ($UA, shift()) : @_);
    my $request = ref $url ? $url : {uri=>$url};

    # Set some defaults
    $ENV{PORT} ||= 8529;  # For mod_perl's own tests
    $request->{method} ||= 'GET';
    $request->{content} = '' unless exists $request->{content};
    $request->{uri} = "http://localhost:$ENV{PORT}$request->{uri}"    
	unless $request->{uri} =~ /^http/;
    $request->{headers}{Content_Type} = 'application/x-www-form-urlencoded'
	if (!$request->{headers} and $request->{method} eq 'POST');  # Is this necessary?

    # Create & send the request
    $request->{headers} = new HTTP::Headers(%{$request->{headers}||{}});
    my $req = new HTTP::Request(@{$request}{'method','uri','headers','content'});
    my $response = $ua->request($req);

    return $want_response ? $response : $response->content;
}

sub simple_fetch {
    my $ua = LWP::UserAgent->new;
    my $url = URI::URL->new("http://$net::httpserver");
    my($path,$q) = split /\?/, shift; 
    $url->path($path);
    $url->query($q) if $q;
    my $request = new HTTP::Request('GET', $url);
    my $response = $ua->request($request, undef, undef);   
    $response->is_success;
}

#even if eval $mod fails, the .pm ends up in %INC
#so the next eval $mod succeeds, when it shouldnot

my %really_have = (
   'Apache::Table' => sub { 
       if ($ENV{MOD_PERL}) {
	   return Apache::Table->can('TIEHASH');
       }
       else {
	   return $net::callback_hooks{PERL_TABLE_API};
       }
   },
);

for (qw(Apache::Cookie Apache::Request)) {
    $really_have{$_} = $really_have{'Apache::Table'};
}

sub have_module {
    my $mod = shift;
    my $v = shift;
    eval {# surpress "can't boostrap" warnings
	 local $SIG{__WARN__} = sub {};
	 require Apache;
	 require Apache::Constants;
    };

    eval "require $mod";
    if($v and not $@) {
	eval { 
	    local $SIG{__WARN__} = sub {};
	    $mod->UNIVERSAL::VERSION($v);
	};
	if($@) {
	    warn $@;
	    return 0;
	}
    }
    if($@ && ($@ =~ /Can.t locate/)) {
	return 0;
    }
    elsif($@ && ($@ =~ /Can.t find loadable object for module/)) {
	return 0;
    }
    elsif($@) {
	warn "$@\n";
    }

    if (my $cv = $really_have{$mod}) {
	return 0 unless $cv->();
    }

    print "module $mod is installed\n" unless $ENV{MOD_PERL};
    
    return 1;
}

sub skip_test {
    print "1..0\n";
    exit;
}

sub run {
    require Test::Harness;
    my $self = shift;
    my $args = shift || {};
    my @tests = ();

    # First we check if we already are within the "t" directory
    if (-d "t") {
	# try to move into test directory
	chdir "t" or die "Can't chdir: $!";

	# fix all relative library locations
	foreach (@INC) {
	    $_ = "../$_" unless m,^(/)|([a-f]:),i;
	}
    }

    # Pick up the library files from the ../blib directory
    unshift(@INC, "../blib/lib", "../blib/arch");
    #print "@INC\n";

    $Test::Harness::verbose = shift(@ARGV)
	if $ARGV[0] =~ /^\d+$/ || $ARGV[0] eq "-v";

    $Test::Harness::verbose ||= $args->{verbose};

    if (@ARGV) {
	for (@ARGV) {
	    if (-d $_) {
		push(@tests, <$_/*.t>);
	    } 
	    else {
		$_ .= ".t" unless /\.t$/;
		push(@tests, $_);
	    }
	}
    } 
    else {
	push @tests, <*.t>, map { <$_/*.t> } @{ $args->{tdirs} || [] };
    }

    Test::Harness::runtests(@tests);
}

sub MM_test {
    # Writes the test section for the Makefile
    shift();  # Don't need package name
    my %conf = @_;

    my $section = <<EOF;
TEST_VERBOSE=0
TEST_TYPE=test_\$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

#test:	start_httpd run_tests   kill_httpd

test :: pure_all start_httpd run_tests   kill_httpd

testdb:	start_httpd run_testsdb kill_httpd

kill_httpd:
	kill `cat t/httpd.pid`

start_httpd:
	t/httpd -f `pwd`/t/httpd.conf

run_tests :: pure_all
	PERL_DL_NONLAZY=1 PORT=$conf{port}
EOF
    chomp $section;

    $section .= <<'EOF';
 $(FULLPERL) -I$(INST_ARCHLIB) -I$(INST_LIB) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -e 'use Test::Harness qw(&runtests $$verbose); $$verbose=$(TEST_VERBOSE); runtests @ARGV;' $(TEST_FILES)

run_testsdb :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERL) $(TESTDB_SW) -I$(INST_ARCHLIB) -I$(INST_LIB) -I$(PERL_ARCHLIB) -I$(PERL_LIB) $(TEST_FILE)

EOF

    return $section;
}

sub grab {
    require IO::Socket;
    my(@args) = @_;
    @args = @ARGV unless @args;

    unless (@args > 0) { 
	die "usage: grab host:port path";
    }

    my($host, $port) = split ":", shift @args;
    $port ||= 80;
    my $url = shift @args || "/";

    my $remote = IO::Socket::INET->new(Proto     => "tcp",
				       PeerAddr  => $host,
				       PeerPort  => $port,
				       );
    unless ($remote) {
	die "cannot connect to http daemon on $host"; 
    }
    $remote->autoflush(1);
    print $remote "GET $url HTTP/1.0\n\n";
    my $response_line = 0;
    my $header_terminator = 0;
    my @msg = ();

    while ( <$remote> ) {
	#e.g. HTTP/1.1 200 OK
	if(m:^(HTTP/\d+\.\d+)[ \t]+(\d+)[ \t]*([^\012]*):i) {
	    push @msg, $_;
	    $response_line = 1;
	}
	elsif(/^([a-zA-Z0-9_\-]+)\s*:\s*(.*)/) {
	    push @msg, $_;
	}
	elsif(/^\015?\012$/) {
	    $header_terminator = 1;
	    push @msg, $_;
	}

	print;
    }
    close $remote;

    print "~" x 40, "\n", "Diagnostics:\n";
    if ($response_line and $header_terminator) {
	print " HTTP response is valid:\n";
    }
    else {
	print "     GET -> http://$host:$port$url\n";
	print " >>> No response line\n" unless $response_line;
	print " >>> No header terminator\n" unless $header_terminator;
	print " *** HTTP response is malformed\n";
    }
    print "-" x 40, "\n", @msg, "-" x 40, "\n";
}

sub run_test {
    my($test, $verbose) = @_; 
    my $cmd = "$^X -w $test|";
    my $fh = FileHandle->new;
    $fh->open($cmd) or print "can't run $test. $!\n";
    my($ok,$next,$max,$files,$totok,$totmax);
    $ok = $next = $max = 0;
    my @failed = ();
    while (<$fh>) {
	if( $verbose ){
	    print ">>> $_";
	}
	if (/^1\.\.([0-9]+)/) {
	    $max = $1;
	    $totmax += $max;
	    $files++;
	    $next = 1;
	}
	elsif ($max && /^(not\s+)?ok\b/) {
	    my $this = $next;
	    if (/^not ok\s*(\d*)/){
		$this = $1 if $1 > 0;
		push @failed, $this;
	    }
	    elsif (/^ok\s*(\d*)/) {
		$this = $1 if $1 > 0;
		$ok++;
		$totok++;
	    }
	    if ($this > $next) {
		# warn "Test output counter mismatch [test $this]\n";
		# no need to warn probably
		push @failed, $next..$this-1;
	    }
	    elsif ($this < $next) {
		#we have seen more "ok" lines than the number suggests
		warn "Confused test output: test $this answered after test ", $next-1, "\n";
		$next = $this;
	    }
	    $next = $this + 1;
	}
    }
    $fh->close; # must close to reap child resource values
    return($max, \@failed);
}

1;

__END__

=head1 NAME

Apache::Test - Facilitates testing of Apache::* modules

=head1 SYNOPSIS

 # In Makefile.PL
 use Apache::test;
 my %params = Apache::test->get_test_params();
 Apache::test->write_httpd_conf(%params, include => $more_directives);
 *MY::test = sub { Apache::test->MM_test(%params) };

 # In t/*.t script (or test.pl)
 (Some methods of Doug's that I haven't reviewed or documented yet)

=head1 DESCRIPTION

This module helps authors of Apache::* modules write test suites that
can query an actual running Apache server with mod_perl and their
modules loaded into it.  Its functionality is generally separated into
methods that go in a Makefile.PL to configure, start, and stop the
server, and methods that go in one of the test scripts to make HTTP
queries and manage the results.

=head1 METHODS

=head2 get_test_params()

This will ask the user a few questions about where the httpd binary
is, and what user/group/port should be used when running the server.
It will return a hash of the information it discovers.  This hash is
suitable for passing to the C<write_httpd_conf()> method.

=head2 write_httpd_conf(%params)

This will write a basic C<httpd.conf> file suitable for starting a
HTTP server during the 'make test' stage.  A hash of key/value pairs
that affect the written file can be passed as arguments.  The
following keys are recognized:

=over 4

=item * conf_file

The path to the file that will be created.  Default is 't/httpd.conf'.

=item * port

The port that the Apache server will listen on.

=item * user

The user that the Apache server will run as.

=item * group

The group that the Apache server will run as.

=item * include

Any additional text you want added at the end of the config file.
Typically you'll have some C<PerlModule> and C<Perl*Handler>
directives to pass control to the module you're testing.  The C<blib/>
directories will be added to the C<@INC> path when searching for
modules, so that's nice.

=back

=head2 MM_test(%params)

This method helps write a Makefile that supports running a web server
during the 'make test' stage.  When you execute 'make test', 'make'
will run 'make start_httpd', 'make run_tests', and 'make kill_httpd'
in sequence.  You can also run these commands independently if you
want.

Pass the hash of parameters returned by C<get_test_params()> as an
argument to C<MM_test()>.

To patch into the ExtUtils::MakeMaker wizardry (voodoo?), typically
you'll do the following in your Makefile.PL:

  *MY::test = sub { Apache::test->MM_test(%params) };

=head2 fetch

  Apache::test->fetch($request);
  Apache::test->fetch($user_agent, $request);

Call this method in a test script in order to fetch a page from the
running web server.  If you pass two arguments, the first should be an
LWP::UserAgent object, and the second should specify the request to
make of the server.  If you only pass one argument, it specifies the
request to make.

The request can be specified either by a simple string indicating the
URI to fetch, or by a hash reference, which gives you more control
over the request.  The following keys are recognized in the hash:

=over 4

=item * uri

The URI to fetch from the server.  If the URI does not begin with
"http", we prepend "http://localhost:$PORT" so that we make requests
of the test server.

=item * method

The request method to use.  Default is 'GET'.

=item * content

The request content body.  Typically used to simulate HTML fill-out
form submission for POST requests.  Default is null.

=item * headers

A hash of headers you want sent with the request.  You might use this
to send cookies or provide some application-specific header.

=back

If you don't provide a 'headers' parameter and you set the 'method'
to 'POST', then we assume that you're trying to simulate HTML form
submission and we add a 'Content_Type' header with a value of
'application/x-www-form-urlencoded'.

In a scalar context, fetch() returns the content of the web server's
response.  In a list context, fetch() returns the content and the
HTTP::Response object itself.  This can be handy if you need to check
the response headers, or the HTTP return code, or whatever.

=head1 EXAMPLES

No good examples yet.  Example submissions are welcome.  In the meantime, see
L<http://forum.swarthmore.edu/~ken/modules/Apache-AuthCookie/> , which
I'm retrofitting to use Apache::test.

=head1 TO DO

The MM_test method doesn't try to be very smart, it just writes the
text that seems to work in my configuration.  I am morally against
using the 'make' command for installing Perl modules (though of course
I do it anyway), so I haven't looked into this very much.  Send bug
reports or better (patches).

I've got lots of code in my Apache::AuthCookie module (etc.) that
assists in actually making the queries of the running server.  I plan
to add that to this module, but first I need to compare what's already
here that does the same stuff.

=head1 KUDOS

To Doug MacEachern for writing the first version of this module.

To caelum@debian.org (Rafael Kitover) for contributing the code to
parse existing httpd.conf files for --enable-shared=max and DSOs.

=head1 CAVEATS

Except for making sure that the mod_perl distribution itself can run
'make test' okay, I haven't tried very hard to keep compatibility with
older versions of this module.  In particular MM_test() has changed
and probably isn't usable in the old ways, since some of its
assumptions are gone.  But none of this was ever documented, and
MM_test() doesn't seem to actually be used anywhere in the mod_perl
disribution, so I don't feel so bad about it.

=head1 AUTHOR

Doug MacEachern (original version)

Ken Williams (latest changes and this documentation)

=cut

