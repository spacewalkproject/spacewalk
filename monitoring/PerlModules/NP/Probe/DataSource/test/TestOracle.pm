
package NOCpulse::Probe::DataSource::test::TestOracle;

use strict;

use Error ':try';
use NOCpulse::Probe::DataSource::Oracle;

use base qw(Test::Unit::TestCase);

my %connect_args = 
  (
   ORACLE_HOME  => '/home/oracle/OraHome1',
   ora_host     => 'dev-01.nocpulse.net',
   ora_port     => 1521,
   ora_sid      => 'dev01a',
   ora_user     => 'guest',
   ora_password => 'guest'
  );

sub test_bad_login {
    my $self = shift;

    my %args;

    %args = %connect_args;
    $args{ora_user} = "nobody_i_know";
    $self->try_login("username", %args);

    %args = %connect_args;
    $args{ora_password} = "notright";
    $self->try_login("password", %args);

    %args = %connect_args;
    $args{ora_sid} = "no_such";
    $self->try_login("sid", %args);

    %args = %connect_args;
    $args{ora_host} = "not_there";
    $self->try_login("host", %args);

    %args = %connect_args;
    $args{ora_port} = 999;
    $self->try_login("port", %args);
}

sub try_login {
    my ($self, $context, %args) = @_;

    try {
        NOCpulse::Probe::DataSource::Oracle->new(%args);
        $self->fail("Did not catch with incorrect $context");

    } catch NOCpulse::Probe::DbLoginError with {
        $self->assert($context eq "username" || $context eq "password",
                      "Caught login error for $context");

    } catch NOCpulse::Probe::DbInstanceError with {
        $self->assert($context eq "sid", "Caught SID error for $context");

    } catch NOCpulse::Probe::DbHostError with {
        $self->assert($context eq "host", "Caught host error for $context");

    } catch NOCpulse::Probe::DbPortError with {
        $self->assert($context eq "port", "Caught port error for $context");
    };
}

sub test_tnsnames {
    my $self = shift;

    my %args;

    %args = %connect_args;
    delete $args{ora_host};
    $args{use_tnsnames} = 1;

    my $ora = NOCpulse::Probe::DataSource::Oracle->new(%connect_args);
    $self->assert($ora->connected, "Cannot connect to Oracle with tnsnames.ora: ", $ora->errors);
}

sub test_sql {
    my $self = shift;

    my $ora = NOCpulse::Probe::DataSource::Oracle->new(%connect_args);
    $self->assert($ora->connected, "Cannot connect to Oracle: ", $ora->errors);

    my $result;
   #PGPORT_1:NO Change
    $result = $ora->fetch_first('select count(*) from dual');
    $self->assert(ref($result) eq 'HASH', "Dual count results not hash: ", ref($result));
    my $count = $result->{'COUNT(*)'};
    $self->assert($count == 1, "Dual row count not one: $count");
  #PGPORT_5:POSTGRES_VERSION_QUERY(ROWNUM)
    $result = $ora->fetch(q{
        select recid, description
        from probe where rownum < 10
        order by recid
    });
    $self->assert(ref($result) eq 'ARRAY', "Probe query not an array ref: ", ref($result));
    my $rowcount = scalar(@$result);
    $self->assert($rowcount == 9, "Select probes return wrong row count: $rowcount");
    $self->assert(ref($result->[0]) eq 'HASH', "Result row not a hash: ", ref($result->[0]));

    my $recid = $result->[1]->{'RECID'};
    $self->assert($recid == 2, "Wrong recid for second row: $recid");
    my $descr = $result->[1]->{'DESCRIPTION'};
    $self->assert($descr eq 'lab-2', "Wrong description for second row: $descr");
   #PGPORT_5:POSTGRES_VERSION_QUERY(CATALOG)
    $result = $ora->fetch_first(q{
        select a.value as SPACE_REQS, b.value as ALLOC_RETRIES
        from   v$sysstat a, v$sysstat b
        where  a.name = 'redo log space requests'
        and    b.name = 'redo buffer allocation retries'
    });
    $self->assert(ref($result) eq 'HASH', "Sysstat query not an array ref: ", ref($result));
    $self->assert(defined $result->{SPACE_REQS}, "Sysstat query got no space requests");
    $self->assert(defined $result->{ALLOC_RETRIES}, "Sysstat query got no allocation retries");
#PGPORT_1:NO Change
    try {
        $result = $ora->fetch('select foo from no_such_table, another_bad_one',
                              ['no_such_table', 'another_bad_one']);
        $self->fail("No error with bad table names");
    } catch NOCpulse::Probe::DbTableNotFoundError with {
        my $err = shift;
        $self->assert(qr/no_such_table/, $err->text);
    } otherwise {
        $self->fail("Caught wrong kind of error: ", shift);
    };

    try {
        $result = $ora->fetch('xxx yyy zzz');
        $self->fail("Bogus SQL did not raise an error");
    } catch NOCpulse::Probe::InternalError with {
    } otherwise {
        $self->fail("Caught wrong error for bogus SQL: ", shift);
    };  
    $ora->disconnect();
}

1;
