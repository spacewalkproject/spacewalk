package Apache::PerlRun;

use strict;
use vars qw($Debug);
use Apache::Constants qw(:common &OPT_EXECCGI);

BEGIN {
    OPT_EXECCGI() if $ENV{MOD_PERL}; #preload, :common are alread pre-loaded
}

unless (defined $Apache::Registry::NameWithVirtualHost) {
    $Apache::Registry::NameWithVirtualHost = 1;
}

unless (defined $Apache::Registry::MarkLine) {
    $Apache::Registry::MarkLine = 1;
}

$Debug ||= 0;
my $Is_Win32 = $^O eq "MSWin32";

@Apache::PerlRun::ISA = qw(Apache);

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
    $r->warn("Apache::PerlRun->new for $filename in process $$")
	if $Debug && $Debug & 4;

    bless {
	'_r' => $r,
    }, $class;
}

sub can_compile {
    my($pr) = @_;
    my $filename = $pr->filename;
    if (-r $filename && -s _) {
	if (!($pr->allow_options & OPT_EXECCGI)) {
	    $pr->log_reason("Options ExecCGI is off in this directory",
			   $filename);
	    return FORBIDDEN;
 	}
	if (-d _) {
	    return DECLINED;
	}
	unless (-x _ or $Is_Win32) {
	    $pr->log_reason("file permissions deny server execution",
			   $filename);
	    return FORBIDDEN;
	}

	$pr->{'mtime'} = -M _;
	return wantarray ? (OK, $pr->{'mtime'}) : OK;
    }
    return NOT_FOUND;
}

sub mark_line {
    my($pr) = @_;
    my $filename = $pr->filename;
    return $Apache::Registry::MarkLine ?
	"\n#line 1 $filename\n" : "";
}

sub sub_wrap {
    my($pr, $code, $package) = @_;

    $code    ||= $pr->{'code'};
    $package ||= $pr->{'namespace'};

    my $line = $pr->mark_line;
    my $sub = join(
		    '',
		    'package ',
		    $package,
		    ';use Apache qw(exit);',
		    'sub handler {',
		    $line,
		    $$code,
		    "\n}", # last line comment without newline?
		    );
    $pr->{'sub'} = \$sub;
}

sub cached {
    my($pr) = @_;
    exists $Apache::Registry->{$pr->namespace}{'mtime'};
}

sub should_compile {
    my($pr, $package, $mtime) = @_;
    $package ||= $pr->{'namespace'};
    $mtime   ||= $pr->{'mtime'};
    !($pr->cached
    &&
      $Apache::Registry->{$package}{'mtime'} <= $mtime);
}

sub update_mtime {
    my($pr, $mtime, $package) = @_;
    $mtime   ||= $pr->{'mtime'};
    $package ||= $pr->{'namespace'};
    $Apache::Registry->{$package}{'mtime'} = $mtime;
}

sub compile {
    my($pr, $eval) = @_;
    $eval ||= $pr->{'sub'};
    $pr->clear_rgy_endav;
    $pr->log_error("Apache::PerlRun->compile") if $Debug && $Debug & 4;
    Apache->untaint($$eval);
    {
	no strict; #so eval'd code doesn't inherit our bits
	eval $$eval;
    }
    $pr->stash_rgy_endav;
    return $pr->error_check;
}

sub run {
    my $pr = shift;
    my $package = $pr->{'namespace'};

    my $rc = OK;
    my $cv = \&{"$package\::handler"};

    my $oldwarn = $^W;
    eval { $rc = &{$cv}($pr, @_) } if $pr->seqno;
    $pr->{status} = $rc;
    $^W = $oldwarn;

    my $errsv = "";
    if($@) {
	$errsv = $@;
	$@ = ''; #XXX fix me, if we don't do this Apache::exit() breaks
	$@{$pr->uri} = $errsv;
    }

    if($errsv) {
	$pr->log_error($errsv);
	return SERVER_ERROR;
    }

    return wantarray ? (OK, $rc) : OK;
}

sub status {
    shift->{'_r'}->status;
}

sub namespace_from {
    my($pr) = @_;

    my $uri = $pr->uri; 

    $pr->log_error(sprintf "Apache::PerlRun->namespace escaping %s",
		  $uri) if $Debug && $Debug & 4;

    my $path_info = $pr->path_info;
    my $script_name = $path_info && $uri =~ /$path_info$/ ?
	substr($uri, 0, length($uri)-length($path_info)) :
	$uri;

    if ($Apache::Registry::NameWithVirtualHost && $pr->server->is_virtual) {
	my $name = $pr->get_server_name;
	$script_name = join "", $name, $script_name if $name;
    }

    $script_name =~ s:/+$:/__INDEX__:;

    return $script_name;
}

sub namespace {
    my($pr, $root) = @_;
    return $pr->{'namespace'} if $pr->{'namespace'};

    my $script_name = $pr->namespace_from;

    # Escape everything into valid perl identifiers
    $script_name =~ s/([^A-Za-z0-9_\/])/sprintf("_%2x",unpack("C",$1))/eg;

    # second pass cares for slashes and words starting with a digit
    $script_name =~ s{
			  (/+)       # directory
			  (\d?)      # package's first character
			 }[
			   "::" . (length $2 ? sprintf("_%2x",unpack("C",$2)) : "")
			  ]egx;

    $Apache::Registry::curstash = $script_name;
 
    $root ||= "Apache::ROOT";

    $pr->log_error("Apache::PerlRun->namespace: package $root$script_name")
	if $Debug && $Debug & 4;

    $pr->{'namespace'} = $root.$script_name;
    return $pr->{'namespace'};
}

sub readscript {
    my $pr = shift;
    $pr->{'code'} = $pr->slurp_filename;
}

sub error_check {
    my $pr = shift;
    if ($@ and substr($@,0,4) ne " at ") {
	$pr->log_error("PerlRun: `$@'");
	$@{$pr->uri} = $@;
	$@ = ''; #XXX fix me, if we don't do this Apache::exit() breaks	
	return SERVER_ERROR;
    }
    return OK;
}

#XXX not good enough yet
my(%switches) = (
   'T' => sub {
       Apache::warn("Apache::PerlRun: T switch ignored, ".
		    "enable with 'PerlTaintCheck On'\n")
	   unless $Apache::__T; "";
   },
   'w' => sub { 'BEGIN {$^W = 1;}; $^W = 1;' },
);

sub parse_cmdline {
    my($pr, $code) = @_;
    $code ||= $pr->{'code'};
    my($line) = $$code =~ /^(.*)$/m;
    my(@cmdline) = split /\s+/, $line;
    return $code unless @cmdline;
    return $code unless shift(@cmdline) =~ /^\#!/;
    my($s, @s, $prepend);
    $prepend = "";
    for $s (@cmdline) {
	next unless $s =~ s/^-//;
	last if substr($s,0,1) eq "-";
	for (split //, $s) {
	    next unless $switches{$_};
	    #print STDERR "parsed `$_' switch\n";
	    $prepend .= &{$switches{$_}};
	}
    }
    $$code =~ s/^/$prepend/ if $prepend;
    return $code;
}

sub chdir_file {
    my($pr, $dir) = @_;
    $pr->{'_r'}->chdir_file($dir ? $dir : $pr->filename);
}

sub set_script_name {
    my($pr) = @_;
    *0 = \$pr->filename;
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

    my $package = $pr->namespace;
    my $code = $pr->readscript;
    $pr->parse_cmdline($code);

    $pr->set_script_name;
    $pr->chdir_file;
    my $line = $pr->mark_line;
    my %orig_inc = %INC;
    my $eval = join '',
		    'package ',
		    $package,
		    ';use Apache qw(exit);',
                    $line,
		    $$code,
                    "\n";
    $rc = $pr->compile(\$eval);

    $pr->chdir_file("$Apache::Server::CWD/");
    #in case .pl files do not declare package ...;
    for (keys %INC) {
	next if $orig_inc{$_};
	next if /\.pm$/;
	delete $INC{$_};
    }

    if(my $opt = $r->dir_config("PerlRunOnce")) {
	$r->child_terminate if lc($opt) eq "on";
    }

    $pr->flush_namespace($package);

    return $rc;
}

BEGIN {
    if ($] < 5.006) {
        $INC{'warnings.pm'} = __FILE__;
        *warnings::unimport = sub {};
    }
}

sub flush_namespace {
    my($self, $package) = @_;
    $package ||= $self->namespace;

    no strict 'refs';
    my $tab = \%{$package.'::'};

    for (keys %$tab) {
        my $fullname = join '::', $package, $_;
        #code/hash/array/scalar might be imported
        #make sure the gv does not point elsewhere
        #before undefing each
        if (%$fullname) {
            *{$fullname} = {};
            undef %$fullname;
        }
        if (@$fullname) {
            *{$fullname} = [];
            undef @$fullname;
        }
        if ($$fullname) {
            my $tmp; #argh, no such thing as an anonymous scalar
            *{$fullname} = \$tmp;
            undef $$fullname;
        }
        if (defined &$fullname) {
            no warnings;
            local $^W = 0;
            *{$fullname} = sub {};
	    undef &$fullname;
	}
        if (*{$fullname}{IO}) {
            if (fileno $fullname) {
                close $fullname;
            }
        }
    }
}

1;

__END__

=head1 NAME

Apache::PerlRun - Run unaltered CGI scripts under mod_perl

=head1 SYNOPSIS

 #in httpd.conf

 Alias /cgi-perl/ /perl/apache/scripts/ 
 PerlModule Apache::PerlRun

 <Location /cgi-perl>
 SetHandler perl-script
 PerlHandler Apache::PerlRun
 Options +ExecCGI 
 #optional
 PerlSendHeader On
 ...
 </Location>

=head1 DESCRIPTION

This module's B<handler> emulates the CGI environment,
allowing programmers to write scripts that run under CGI or
mod_perl without change.  Unlike B<Apache::Registry>, the
B<Apache::PerlRun> handler does not cache the script inside of a
subroutine.  Scripts will be "compiled" every request.  After the
script has run, it's namespace is flushed of all variables and
subroutines.

The B<Apache::Registry> handler is much faster than
B<Apache::PerlRun>.  However, B<Apache::PerlRun> is much faster than
CGI as the fork is still avoided and scripts can use modules which
have been pre-loaded at server startup time.  This module is meant for
"Dirty" CGI Perl scripts which relied on the single request lifetime
of CGI and cannot run under B<Apache::Registry> without cleanup.

=head1 CAVEATS

If your scripts still have problems running under the I<Apache::PerlRun>
handler, the I<PerlRunOnce> option can be used so that the process running
the script will be shutdown.  Add this to your httpd.conf:

 <Location ...>
 PerlSetVar PerlRunOnce On
 ...
 </Location>

=head1 SEE ALSO

perl(1), mod_perl(3), Apache::Registry(3)

=head1 AUTHOR

Doug MacEachern

