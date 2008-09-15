package NOCpulse::Probe::DataSource::test::TestSQLPlusQuery;

use strict;

use Error ':try';
use NOCpulse::Probe::Error;
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::DataSource::SQLPlusQuery;

use base qw(Test::Unit::TestCase);

my %LOGIN =
  (sshuser         => 'nocpulse',
   sshhost         => 'rudder.nocpulse.net',
   sshport         => '4545',
   timeout_seconds => 10,
   ORACLE_HOME     => '/shared/nocpulse/oracle/product/8.1.6',
   ora_host        => 'dev-01.nocpulse.net',
   ora_port        => 1521,
   ora_sid         => 'dev01a',
   ora_user        => 'eng',
   ora_password    => 'jjj123'
  );

sub set_up {
    my $self = shift;
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new();
}

sub test_query {
    my $self = shift;

    my $data_source = $self->{factory}->sqlplus_query(%LOGIN);
    $self->assert($data_source->connected, "Not connected");
    $data_source->execute("select 'DUMMY:'||dummy from dual");
    $self->assert(qr/DUMMY:X/, $data_source->results);
}

sub test_bad_login {
    my $self = shift;

    my %login = %LOGIN;
    $login{ora_user} = 'nope';
    try {
        my $data_source = $self->{factory}->sqlplus_query(%login);
        $self->fail('Connected with bad username');
    } catch NOCpulse::Probe::DbLoginError with {
    };
}

1;
