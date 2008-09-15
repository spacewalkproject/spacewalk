package Oracle::test::TestExtents;

use strict;

use Error(':try');

use NOCpulse::Probe::Error;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::Config::ProbeRecord;
use Oracle::ExtentsHelper;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new();
    $self->{factory}->canned(1);
}

sub test_table_extents {
    my $self = shift;

    my $rows =
      [
       { OWNER        => 'NOCPULSE',
         OBJECT_NAME  => 'COMMAND_PARAMETER_THRESHOLD',
         MAX_EXTENTS  => 505,
         BYTES        => 163840,
         EXTENT_COUNT => 3,
         EXTENT_PCT_OF_MAX => .594059406
       },
       { OWNER        => 'NOCPULSE',
         OBJECT_NAME  => 'HOST',
         MAX_EXTENTS  => 505,
         BYTES        => 81920,
         EXTENT_COUNT => 2,
         EXTENT_PCT_OF_MAX => .396039604
       },
      ];

    $self->{factory}->canned_results([$rows]);

    my $ora = $self->{factory}->oracle();

    my $master_params = { warn => 3, critical => 4, warnpct => 2, critpct => 2 };
    my %params = %$master_params;

    my $query_rows = Oracle::ExtentsHelper::query(\%params, $ora, "foo", []);
    $self->assert(ref($query_rows) eq 'ARRAY', "Wrong query return type: ", ref($query_rows));
    $self->assert(scalar(@$query_rows) == scalar(@$rows), "Wrong row count: ",
                  scalar(@$query_rows));

    my $result;

    $result = $self->empty_result();
    Oracle::ExtentsHelper::check_thresholds($query_rows, \%params, $result);
    $self->assert($result->overall_status eq $result->OK,
                  "Crossed threshold with OK data: ", $result->overall_status);

    $result = $self->empty_result();
    %params = %$master_params;
    $params{warn} = 1;
    Oracle::ExtentsHelper::check_thresholds($query_rows, \%params, $result);
    $self->assert($result->overall_status eq $result->WARNING,
                  "Count not warning: ", $result->overall_status);

    $result = $self->empty_result();
    %params = %$master_params;
    $params{warn} = 1;
    $params{critical} = 2;
    Oracle::ExtentsHelper::check_thresholds($query_rows, \%params, $result);
    $self->assert($result->overall_status eq $result->CRITICAL,
                  "Count not critical: ", $result->overall_status);

    $result = $self->empty_result();
    %params = %$master_params;
    $params{warnpct} = .45;
    Oracle::ExtentsHelper::check_thresholds($query_rows, \%params, $result);
    $self->assert($result->overall_status eq $result->WARNING,
                  "Percent not warning: ", $result->overall_status);

    $result = $self->empty_result();
    %params = %$master_params;
    $params{critpct} = .35;
    Oracle::ExtentsHelper::check_thresholds($query_rows, \%params, $result);
    $self->assert($result->overall_status eq $result->CRITICAL,
                  "Percent not critical: ", $result->overall_status);
}

sub test_owner_validation {
    my $self = shift;

    my %login = ( ora_sid      => 'dev01a',
                  ora_port     => 1521,
                  ora_host     => 'dev-01',
                  ora_user     => 'guest',
                  ora_password => 'guest'
                );
    my $ora = NOCpulse::Probe::DataSource::Factory->new()->oracle(%login);

    my $result;
    my $ok;

    $result = $self->empty_result();
    $ok = Oracle::ExtentsHelper::owner_is_valid({owner => 'foo'}, $result, 'tables', $ora);
    $self->assert(!$ok, "User foo valid");
    $self->assert($result->overall_status eq $result->UNKNOWN, "Status not unknown: ",
                  $result->overall_status);

    $result = $self->empty_result();
    $ok = Oracle::ExtentsHelper::owner_is_valid({owner => 'guest'}, $result, 'tables', $ora);

    $self->assert(!$ok, "User guest owns tables");
    $self->assert($result->overall_status eq $result->OK, "Status is OK for guest tables: ",
                  $result->overall_status);

    $result = $self->empty_result();
    $ok = Oracle::ExtentsHelper::owner_is_valid({owner => 'guest'}, $result, 'indexes', $ora);
    $self->assert(!$ok, "User guest owns indexes");
    $self->assert($result->overall_status eq $result->OK, "Status is OK for guest indexes: ",
                  $result->overall_status);

    # Test that wildcards work
    $result = $self->empty_result();
    $ok = Oracle::ExtentsHelper::owner_is_valid({owner => '%'}, $result, 'tables', $ora);
    $self->assert($ok, "User % does not own tables");
    $self->assert($result->overall_status eq $result->OK, "Status not OK for % tables: ",
                  $result->overall_status);

    $result = $self->empty_result();
    $ok = Oracle::ExtentsHelper::owner_is_valid({owner => '%'}, $result, 'indexes', $ora);
    $self->assert($ok, "User % does not own indexes");
    $self->assert($result->overall_status eq $result->OK, "Status not OK for % indexes: ",
                  $result->overall_status);
}

sub empty_result {
    return NOCpulse::Probe::Result->new
      (probe_record => NOCpulse::Probe::Config::ProbeRecord->new({recid => 10}),
       command_record => NOCpulse::Probe::Config::Command->new());
}


1;
