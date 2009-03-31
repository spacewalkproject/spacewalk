package NOCpulse::Probe::DataSource::test::TestSQLServer;

use strict;

use Error ':try';
use NOCpulse::Probe::DataSource::SQLServer;

use base qw(Test::Unit::TestCase);

my %connect_args = 
  (
   serverName => 'eng-2k-server.nocpulse.net',
   port       => 1433,
   dbName     => 'Northwind',
   userName   => 'sa',
   password   => 'sa'
  );

sub test_bad_login {
    my $self = shift;

    my %args;

    %args = %connect_args;
    $args{userName} = "nobody_i_know";
    $self->try_login("username", %args);

    %args = %connect_args;
    $args{password} = "notright";
    $self->try_login("password", %args);

    %args = %connect_args;
    $args{dbName} = "no_such";
    $self->try_login("db name", %args);

    %args = %connect_args;
    $args{serverName} = "not_there";
    $self->try_login("host", %args);

    %args = %connect_args;
    $args{port} = 1434;
    $self->try_login("port", %args);
}

sub try_login {
    my ($self, $context, %args) = @_;

    try {
        NOCpulse::Probe::DataSource::SQLServer->new(%args);
        $self->fail("Did not catch with incorrect $context");

    } catch NOCpulse::Probe::DbInstanceError with {
        $self->assert($context eq "db name", "Caught DB name error for $context");

    } catch NOCpulse::Probe::DbConnectError with {
        $self->assert($context eq "username"
                      || $context eq "password"
                      || $context eq "host"
                      || $context eq "port",
                      "Caught connect error for $context");

    };
}

sub test_sql {
    my $self = shift;

    my $ss = NOCpulse::Probe::DataSource::SQLServer->new(%connect_args);
    $self->assert($ss->connected, "Cannot connect to SQLServer: ", $ss->errors);

    my $result;

    $result = $ss->fetch_first('select count(*) as num_users from sysusers');
    $self->assert(ref($result) eq 'HASH', "Sysusers count results not hash: ", ref($result));
    my $count = $result->{'num_users'};
    $self->assert($count > 0, "Sysusers row count not set: $count");

    $result = $ss->fetch(q{
        select name, createdate
        from sysusers
        where name in ('public', 'guest')
        order by name
    });
    $self->assert(ref($result) eq 'ARRAY', "User query not an array ref: ", ref($result));
    my $rowcount = scalar(@$result); 

    $self->assert($rowcount == 2, "Select users return wrong row count: $rowcount");
    $self->assert(ref($result->[0]) eq 'HASH', "Result row not a hash: ", ref($result->[0]));

    my $name;
    $name = $result->[0]->{'name'};
    $self->assert($name eq 'guest', "Wrong name for first row: $name");
    $name = $result->[1]->{'name'};
    $self->assert($name eq 'public', "Wrong name for second row: $name");

    try {
        $result = $ss->fetch('select foo from no_such_table, another_bad_one',
                              ['no_such_table', 'another_bad_one']);
        $self->fail("No error with bad table names");
    } catch NOCpulse::Probe::DbTableNotFoundError with {
        my $err = shift;
        $self->assert(qr/no_such_table/, $err->text);
    } otherwise {
        $self->fail("Caught wrong kind of error: ", shift);
    };

    try {
        $result = $ss->fetch('xxx yyy zzz');
        $self->fail("Bogus SQL did not raise an error");
    } catch NOCpulse::Probe::InternalError with {
    } otherwise {
        $self->fail("Caught wrong error for bogus SQL: ", shift);
    };  
    $ss->disconnect();
}

1;
