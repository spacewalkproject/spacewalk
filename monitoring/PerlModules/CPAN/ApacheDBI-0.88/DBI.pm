package Apache::DBI;

use Apache ();
use DBI ();
use strict;

# $Id: DBI.pm,v 1.1.1.1 2001-04-06 22:17:28 dfaraldo Exp $

require_version DBI 1.00;

$Apache::DBI::VERSION = '0.88';

# 1: report about new connect
# 2: full debug output
$Apache::DBI::DEBUG = 0;
#DBI->trace(2);


my %Connected;    # cache for database handles
my @ChildConnect; # connections to be established when a new httpd child is created
my %Rollback;     # keeps track of pushed PerlCleanupHandler which can do a rollback after the request has finished
my %PingTimeOut;  # stores the timeout values per data_source, a negative value de-activates ping, default = 0
my %LastPingTime; # keeps track of last ping per data_source
my $Idx;          # key of %Connected and %Rollback.


# supposed to be called in a startup script.
# stores the data_source of all connections, which are supposed to be created upon
# server startup, and creates a PerlChildInitHandler, which initiates the connections.

sub connect_on_init { 
    # provide a handler which creates all connections during server startup
    if(!@ChildConnect and Apache->can('push_handlers')) {
        Apache->push_handlers(PerlChildInitHandler => \&childinit);
    }
    # store connections
    push @ChildConnect, [@_];
}


# supposed to be called in a startup script.
# stores the timeout per data_source for the ping function.
# use a DSN without attribute settings specified within !

sub setPingTimeOut { 
    my $class       = shift;
    my $data_source = shift;
    my $timeout     = shift;
    # sanity check
    if ($data_source =~ /dbi:\w+:.*/ and $timeout =~ /\-*\d+/) {
        $PingTimeOut{$data_source} = $timeout;
    }
}


# the connect method called from DBI::connect

sub connect {

    my $class = shift;
    unshift @_, $class if ref $class;
    my $drh    = shift;
    my @args   = map { defined $_ ? $_ : "" } @_;
    my $dsn    = "dbi:$drh->{Name}:$args[0]";
    my $prefix = "$$ Apache::DBI            ";

    $Idx = join $;, $args[0], $args[1], $args[2];

    # the hash-reference differs between calls even in the same
    # process, so de-reference the hash-reference 
    if (3 == $#args and ref $args[3] eq "HASH") {
       my ($key, $val);
       while (($key,$val) = each %{$args[3]}) {
           $Idx .= "$;$key=$val";
       }
    } elsif (3 == $#args) {
        pop @args;
    }

    # don't cache connections created during server initialization; they
    # won't be useful after ChildInit, since multiple processes trying to
    # work over the same database connection simultaneously will receive
    # unpredictable query results.
    if ($Apache::ServerStarting == 1) {
        print STDERR "$prefix skipping connection during server startup, read the docu !!\n" if $Apache::DBI::DEBUG > 1;
        return $drh->connect(@args);
    }

    # this PerlCleanupHandler is supposed to initiate a rollback after the script has finished if AutoCommit is off.
    my $needCleanup = ($Idx =~ /AutoCommit[^\d]+0/) ? 1 : 0;
    if(!$Rollback{$Idx} and $needCleanup and Apache->can('push_handlers')) {
        print STDERR "$prefix push PerlCleanupHandler \n" if $Apache::DBI::DEBUG > 1;
        Apache->push_handlers("PerlCleanupHandler", \&cleanup);
        # make sure, that the rollback is called only once for every 
        # request, even if the script calls connect more than once
        $Rollback{$Idx} = 1;
    }

    # do we need to ping the database ?
    $PingTimeOut{$dsn}  = 0 unless $PingTimeOut{$dsn};
    $LastPingTime{$dsn} = 0 unless $LastPingTime{$dsn};
    my $now = time;
    my $needping = (($PingTimeOut{$dsn} == 0 or $PingTimeOut{$dsn} > 0) and $now - $LastPingTime{$dsn} > $PingTimeOut{$dsn}) ? 1 : 0;
    print STDERR "$prefix need ping: ", $needping == 1 ? "yes" : "no", "\n" if $Apache::DBI::DEBUG > 1;
    $LastPingTime{$dsn} = $now;

    # check first if there is already a database-handle cached
    # if this is the case, possibly verify the database-handle 
    # using the ping-method. Use eval for checking the connection 
    # handle in order to avoid problems (dying inside ping) when 
    # RaiseError being on and the handle is invalid.
    if ($Connected{$Idx} and (!$needping or eval{$Connected{$Idx}->ping})) {
        print STDERR "$prefix already connected to '$Idx'\n" if $Apache::DBI::DEBUG > 1;
        return (bless $Connected{$Idx}, 'Apache::DBI::db');
    }

    # either there is no database handle-cached or it is not valid,
    # so get a new database-handle and store it in the cache
    delete $Connected{$Idx};
    $Connected{$Idx} = $drh->connect(@args);
    return undef if !$Connected{$Idx};

    # return the new database handle
    print STDERR "$prefix new connect to '$Idx'\n" if $Apache::DBI::DEBUG;
    return (bless $Connected{$Idx}, 'Apache::DBI::db');
}


# The PerlChildInitHandler creates all connections during server startup.
# Note: this handler runs in every child server, but not in the main server.

sub childinit {
    my $prefix = "$$ Apache::DBI            ";
    print STDERR "$prefix PerlChildInitHandler \n" if $Apache::DBI::DEBUG > 1;
    if (@ChildConnect) {
        for my $aref (@ChildConnect) {
            shift @$aref;
            DBI->connect(@$aref);
            $LastPingTime{@$aref[0]} = time;
        }
    }
    1;
}


# The PerlCleanupHandler is supposed to initiate a rollback after the script has finished if AutoCommit is off.
# Note: the PerlCleanupHandler runs after the response has been sent to the client

sub cleanup {
    my $prefix = "$$ Apache::DBI            ";
    print STDERR "$prefix PerlCleanupHandler \n" if $Apache::DBI::DEBUG > 1;
    my $dbh = $Connected{$Idx};
    if ($Rollback{$Idx} and $dbh and $dbh->{Active} and !$dbh->{AutoCommit} and eval {$dbh->rollback}) {
        print STDERR "$prefix PerlCleanupHandler rollback for $Idx \n" if $Apache::DBI::DEBUG > 1;
    }
    delete $Rollback{$Idx};
    1;
}


# This function can be called from other handlers to perform tasks on all cached database handles.

sub all_handlers {
  return \%Connected;
}


# patch from Tim Bunce: Apache::DBI will not return a DBD ref cursor

@Apache::DBI::st::ISA = ('DBI::st');


# overload disconnect

{ package Apache::DBI::db;
  no strict;
  @ISA=qw(DBI::db);
  use strict;
  sub disconnect {
      my $prefix = "$$ Apache::DBI            ";
      print STDERR "$prefix disconnect (overloaded) \n" if $Apache::DBI::DEBUG > 1;
      1;
  };
}


# prepare menu item for Apache::Status

Apache::Status->menu_item(

    'DBI' => 'DBI connections',
    sub {
        my($r, $q) = @_;
        my(@s) = qw(<TABLE><TR><TD>Datasource</TD><TD>Username</TD></TR>);
        for (keys %Connected) {
            push @s, '<TR><TD>', join('</TD><TD>', (split($;, $_))[0,1]), "</TD></TR>\n";
        }
        push @s, '</TABLE>';
        return \@s;
   }

) if ($INC{'Apache.pm'} and Apache->module('Apache::Status'));


1;

__END__


=head1 NAME

Apache::DBI - Initiate a persistent database connection


=head1 SYNOPSIS

 # Configuration in httpd.conf or startup.pl:

 PerlModule Apache::DBI  # this comes before all other modules using DBI

Do NOT change anything in your scripts. The usage of this module is 
absolutely transparent !


=head1 DESCRIPTION

This module initiates a persistent database connection. 

The database access uses Perl's DBI. For supported DBI drivers see: 

 http://www.symbolstone.org/technology/perl/DBI/

When loading the DBI module (do not confuse this with the Apache::DBI module) 
it looks if the environment variable GATEWAY_INTERFACE starts with 'CGI-Perl' 
and if the module Apache::DBI has been loaded. In this case every connect 
request will be forwarded to the Apache::DBI module. This looks if a database 
handle from a previous connect request is already stored and if this handle is 
still valid using the ping method. If these two conditions are fulfilled it 
just returns the database handle. The parameters defining the connection have 
to be exactly the same, including the connect attributes ! If there is no 
appropriate database handle or if the ping method fails, a new connection is 
established and the handle is stored for later re-use. There is no need to 
remove the disconnect statements from your code. They won't do anything because 
the Apache::DBI module overloads the disconnect method. 

The Apache::DBI module still has a limitation: it keeps database connections 
persistent on a per process basis. The problem is, if a user accesses several 
times a database, the http requests will be handled very likely by different 
servers. Every server needs to do its own connect. It would be nice, if all 
servers could share the database handles. Currently this is not possible, 
because of the distinct name-space of every process. Also it is not possible 
to create a database handle upon startup of the httpd and then inheriting this 
handle to every subsequent server. This will cause clashes when the handle is 
used by two processes at the same time. 

With this limitation in mind, there are scenarios, where the usage of 
Apache::DBI is depreciated. Think about a heavy loaded Web-site where every 
user connects to the database with a unique userid. Every server would create  
many database handles each of which spawning a new backend process. In a short 
time this would kill the web server. 

Another problem are timeouts: some databases disconnect the client after a 
certain time of inactivity. The module tries to validate the database handle 
using the ping-method of the DBI-module. This method returns true as default. 
If the database handle is not valid and the driver has no implementation for 
the ping method, you will get an error when accessing the database. As a 
work-around you can try to replace the ping method by any database command, 
which is cheap and safe or you can deactivate the usage of the ping method 
(see CONFIGURATION below). 

Here is generalized ping method, which can be added to the driver module:

{   package DBD::xxx::db; # ====== DATABASE ======
    use strict;

    sub ping {
        my($dbh) = @_;
        my $ret = 0;
        eval {
            local $SIG{__DIE__}  = sub { return (0); };
            local $SIG{__WARN__} = sub { return (0); };
            # adapt the select statement to your database:
            $ret = $dbh->do('select 1');
        };
        return ($@) ? 0 : $ret;
    }
}

Transactions: a standard DBI script will automatically perform a rollback
whenever the script exits. In the case of persistent database connections,
the database handle will not be destroyed and hence no automatic rollback 
occurs. At a first glance it seems even to be possible, to handle a transaction 
over multiple requests. But this should be avoided, because different
requests are handled by different servers and a server does not know the state 
of a specific transaction which has been started by another server. In general 
it is good practice to perform an explicit commit or rollback at the end of 
every script. In order to avoid inconsistencies in the database in case 
AutoCommit is off and the script finishes without an explicit rollback, the 
Apache::DBI module uses a PerlCleanupHandler to issue a rollback at the
end of every request. Note, that this CleanupHandler will only be used, if 
the initial data_source sets AutoCommit = 0. It will not be used, if AutoCommit 
will be turned off, after the connect has been done. 

This module plugs in a menu item for Apache::Status. The menu lists the 
current database connections. It should be considered incomplete because of 
the limitations explained above. It shows the current database connections 
for one specific server, the one which happens to serve the current request. 
Other servers might have other database connections. The Apache::Status module 
has to be loaded before the Apache::DBI module !


=head1 CONFIGURATION

The module should be loaded upon startup of the Apache daemon.
Add the following line to your httpd.conf or startup.pl:

 PerlModule Apache::DBI

It is important, to load this module before any other modules using DBI ! 

A common usage is to load the module in a startup file via the PerlRequire 
directive. See eg/startup.pl for an example. 

There are two configurations which are server-specific and which can be done 
upon server startup: 

 Apache::DBI->connect_on_init($data_source, $username, $auth, \%attr)

This can be used as a simple way to have apache servers establish connections 
on process startup. 

 Apache::DBI->setPingTimeOut($data_source, $timeout)

This configures the usage of the ping method, to validate a connection. 
Setting the timeout to 0 will always validate the database connection 
using the ping method (default). Setting the timeout < 0 will de-activate 
the validation of the database handle. This can be used for drivers, which 
do not implement the ping-method. Setting the timeout > 0 will ping the 
database only if the last access was more than timeout seconds before. 

For the menu item 'DBI connections' you need to call Apache::Status BEFORE 
Apache::DBI ! For an example of the configuration order see startup.pl. 

To enable debugging the variable $Apache::DBI::DEBUG must be set. This 
can either be done in startup.pl or in the user script. Setting the variable 
to 1, just reports about a new connect. Setting the variable to 2 enables full 
debug output. 


=head1 PREREQUISITES

Note that this module needs mod_perl-1.08 or higher, apache_1.3.0 or higher 
and that mod_perl needs to be configured with the appropriate call-back hooks: 

  PERL_CHILD_INIT=1 PERL_STACKED_HANDLERS=1. 


=head1 SEE ALSO

L<Apache>, L<mod_perl>, L<DBI>


=head1 AUTHORS

=item *
mod_perl by Doug MacEachern <modperl@apache.org>

=item *
DBI by Tim Bunce <dbi-users@isc.org>

=item *
Apache::AuthenDBI by Edmund Mergl <E.Mergl@bawue.de>


=head1 COPYRIGHT

The Apache::DBI module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
