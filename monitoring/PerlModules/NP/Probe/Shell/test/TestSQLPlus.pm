package NOCpulse::Probe::Shell::test::TestSQLPlus;

use strict;

use Error ':try';
use NOCpulse::Probe::Shell::SQLPlus;

use base qw(Test::Unit::TestCase);

my %LOGIN =
  (sshuser         => 'nocpulse',
   sshhost         => 'rudder.nocpulse.net',
   sshport         => '4545',
   timeout_seconds => 20,
   ORACLE_HOME     => '/shared/nocpulse/oracle/product/8.1.6',
   ora_host        => 'dev-01.nocpulse.net',
   ora_port        => 1521,
   ora_sid         => 'dev01a',
   ora_user        => 'eng',
   ora_password    => 'jjj123'
  );


sub test_sqlplus {
    my $self = shift;

    my $shell = NOCpulse::Probe::Shell::SQLPlus->new(%LOGIN);
    $self->assert($shell->connect(), "Cannot connect to SQLPlus: ", $shell->stderr);

    my $output;

    $shell->run('select count(*) from dual;');
    $output = $shell->stdout;
    $output =~ s/^\s+//;
    $output =~ s/\s+$//;
    $self->assert($output eq '1', "Count(*) from dual not 1: '$output'");

    $shell->run("set colsep :");
    $shell->run(q{
        select 'NPP:' || a.value || ':' || b.value
        from v$sysstat a, v$sysstat b
        where a.name = 'redo log space requests'
        and b.name = 'redo buffer allocation retries';
    });
    $output = $shell->stdout;
    
    $shell->disconnect();
}

sub test_errors {
    my $self = shift;

    my $shell;
    my %login;

    try {
        %login = %LOGIN;
        $login{ora_user} = 'foo';
        $shell = NOCpulse::Probe::Shell::SQLPlus->new(%login);
        $shell->connect();
        $self->fail("Can connect to SQLPlus with bad user: ", $shell->stdout);
    } catch NOCpulse::Probe::DbLoginError with {
    };

    try {
        %login = %LOGIN;
        $login{ora_port} = 5432;
        $shell = NOCpulse::Probe::Shell::SQLPlus->new(%login);
        $shell->connect();
        $self->fail("Can connect to SQLPlus with bad port: ", $shell->stdout);
    } catch NOCpulse::Probe::DbLoginError with {
    };

    try {
        %login = %LOGIN;
        $login{sshuser} = 'popeye';
        $shell = NOCpulse::Probe::Shell::SQLPlus->new(%login);
        $shell->connect();
        $self->fail("Can connect to SQLPlus with bad SSH user: ", $shell->stdout);
    } catch NOCpulse::Probe::Shell::ConnectError with {
    };
}

1;
