package test::TestNotificationDB;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::NotificationDB;
use NOCpulse::Probe::DataSource::AbstractDatabase qw(:constants);
use Data::Dumper;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__, 9);

my $MODULE = 'NOCpulse::Notif::NotificationDB';

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj  = $MODULE->new();

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");

} ## end sub test_constructor

############
sub set_up {
############
  my $self = shift;

  # This method is called before each test.
  $self->{'blah'} = $MODULE->new();
}

# INSERT INTERESTING TESTS HERE

##########################
sub test__date_to_string {
##########################

  my $self       = shift;
  my $field_name = 'my_field';

  my $result = $self->{'blah'}->_date_to_string('my_field');

  my $expected_result =
      "TO_CHAR($field_name,'"
    . $self->{'blah'}->db_date_format
    . "') AS $field_name";

  $result          =~ s/\s//g;
  $expected_result =~ s/\s//g;

  #  print "actual   result:\n", &Dumper($result), "\n";
  #  print "expected result:\n", &Dumper($expected_result), "\n";

  $self->assert(lc($result) eq lc($expected_result));
} ## end sub test__date_to_string

########################
sub test__init_details {
########################

  ## NOTE:  This test is dependent upon the RHN_REDIRECTS schema and may fail if it changes.

  my $self = shift;

  my $result = $self->{'blah'}->_init_details('DUAL');

  #  print "Details for DUAL:\n", &Dumper($result); "\n";

  my $value = $result->{'cols'}->[0];
  $self->assert($value eq 'DUMMY', 'cols details (dual)');

  $result = $self->{'blah'}->_init_details('RHN_REDIRECTS');

  #  print "Details for CUSTOMER:\n", &Dumper($result); "\n";

  $value = $result->{'pk'}->[0];
  $self->assert($value eq 'RECID', 'pk details (redirects)');

  $value = $result->{'dates'}->[0];
  $self->assert($value eq 'EXPIRATION', 'dates details (redirects)');
} ## end sub test__init_details

########################
sub test__selectphrase {
########################

  my $self = shift;

  my $result = $self->{'blah'}->_selectphrase('all_tab_columns');

  my @cols = qw (
    OWNER
    TABLE_NAME
    COLUMN_NAME
    DATA_TYPE
    DATA_TYPE_MOD
    DATA_TYPE_OWNER
    DATA_LENGTH
    DATA_PRECISION
    DATA_SCALE
    NULLABLE
    COLUMN_ID
    DEFAULT_LENGTH
    DATA_DEFAULT
    NUM_DISTINCT
    LOW_VALUE
    HIGH_VALUE
    DENSITY
    NUM_NULLS
    NUM_BUCKETS);

  push(@cols, $self->{'blah'}->_date_to_string('LAST_ANALYZED'));
  push(
    @cols, qw (
      SAMPLE_SIZE
      CHARACTER_SET_NAME
      CHAR_COL_DECL_LENGTH
      GLOBAL_STATS
      USER_STATS
      AVG_COL_LEN
      CHAR_LENGTH
      CHAR_USED
      V80_FMT_IMAGE
      DATA_UPGRADED)
  );

  my $expected_result = join(",", @cols);

  $result          =~ s/\s//g;
  $expected_result =~ s/\s//g;

  my @result          = split(',', lc($result));
  my @expected_result = split(',', lc($expected_result));

  $result          = join(',', sort(@result));
  $expected_result = join(',', sort(@expected_result));

##  print "actual   result:\n", &Dumper($result),          "\n";
##  print "expected result:\n", &Dumper($expected_result), "\n";

  $self->assert($result eq $expected_result);
} ## end sub test__selectphrase

#########################
sub test__select_record {
#########################

  my $self = shift;

  my $result = $self->{'blah'}->_select_record('dual', 'DUMMY', 'X');

  # print "Record from DUAL:\n", &Dumper($result), "\n";

  my $expected_key   = 'DUMMY';
  my $expected_value = 'X';

  $self->assert(exists($result->{$expected_key}), 'key exists');
  $self->assert($result->{$expected_key} eq $expected_value, 'proper value');

  $result = $self->{'blah'}->_select_record('dual');
  $self->assert(exists($result->{$expected_key}), 'key exists (no where)');
  $self->assert($result->{$expected_key} eq $expected_value,
                'proper value (no where)');
} ## end sub test__select_record

##########################
sub test__select_records {
##########################

  my $self = shift;

  my $result = $self->{'blah'}->_select_records('dual', 'DUMMY', 'X');

  #  print "Records from DUAL:\n", &Dumper($result), "\n";

  my $expected_key   = 'DUMMY';
  my $expected_value = 'X';

  $self->assert(exists($result->[0]->{$expected_key}), 'key exists');
  $self->assert($result->[0]->{$expected_key} eq $expected_value,
                'proper value');

  $result = $self->{'blah'}->_select_records('dual');
  $self->assert(exists($result->[0]->{$expected_key}), 'key exists (no where)');
  $self->assert($result->[0]->{$expected_key} eq $expected_value,
                'proper value (no where)');
} ## end sub test__select_records
####################################
sub test__select_table_description {
####################################

  my $self = shift;

  my $result = $self->{'blah'}->_select_table_description('dual');

  my $expected_result = {
                          'DATA_TYPE'      => 'VARCHAR2',
                          'DATA_PRECISION' => undef,
                          'COLUMN_NAME'    => 'DUMMY',
                          'NULLABLE'       => 'Y'
                        };

  #  print "actual   result:\n", &Dumper($result), "\n";
  #  print "expected result:\n", &Dumper($expected_result), "\n";

  foreach (keys(%$expected_result)) {
    $self->assert($result->[0]->{$_} eq $expected_result->{$_}, "key is $_");
  }
} ## end sub test__select_table_description

#####################################
sub test__select_table_primary_keys {
#####################################

  ## NOTE:  This test is dependent upon the CUSTOMER schema and may fail if it changes.

  my $self = shift;

  my $result = $self->{'blah'}->_select_table_primary_keys('RHN_REDIRECTS');

  #  print "rhn_redirects primary key: ", &Dumper(@$result), "\n";

  my $expected_result = 'RECID';

  my $size = @$result;
  $self->assert($size == 1, 'return size');

  my $value = $result->[0]->{'COLUMN_NAME'};
  $self->assert($value eq $expected_result, 'return size');

} ## end sub test__select_table_primary_keys

#######################
sub test__wherephrase {
#######################

  my $self  = shift();
  my $table = 'DUAL';
  my $args = {
               'number' => 1,
               'string' => 'hello'
             };
  my $conj = 'BUT';

  my ($string, $array) = $self->{'blah'}->_wherephrase($table, $args, $conj);

  my $expected_string = "number = ? $conj string = ?";
  my $expected_array  = [qw (1 hello)];

  $string          =~ s/\s//g;
  $expected_string =~ s/\s//g;

  #  print "actual   string:\n", &Dumper($string), "\n";
  #  print "expected string:\n", &Dumper($expected_string), "\n";

  $self->assert(lc($string) eq lc($expected_string), 'where string with conj');

  $conj = 'AND';

  ($string, $array) = $self->{'blah'}->_wherephrase($table, $args);

  $expected_string = "number = ? $conj string = ?";
  $expected_array  = [qw (1 hello)];

  $string          =~ s/\s//g;
  $expected_string =~ s/\s//g;

  #  print "actual   string:\n", &Dumper($string), "\n";
  #  print "expected string:\n", &Dumper($expected_string), "\n";

  $self->assert(lc($string) eq lc($expected_string), 'where string w/o conj');
} ## end sub test__wherephrase

##############################
sub test_timestamp_to_string {
##############################
  my $self = shift;

  $ENV{TZ} = 'GMT';
  my $timestamp = time;

  #  $Log->log(9, "timestamp is $timestamp\n");
  my $string = $self->{'blah'}->timestamp_to_string($timestamp);

  #  $Log->log(9, "string is $string\n");
  my $return = $self->{'blah'}->string_to_timestamp($string);

  #  $Log->log(9, "return is $return\n");

  $self->assert($timestamp == $return);
} ## end sub test_timestamp_to_string

##################################
sub test_select_global_redirects {
##################################
  my $self = shift;
  my $ndb  = $self->{'blah'};

  # Create a global redirect
  my $redirect = {
## CUSTOMER_ID        =>  NULL
    REDIRECT_TYPE    => 'BLACKHOLE',
    DESCRIPTION      => "test_select_global",
    REASON           => "test_select_global_redirects",
    EXPIRATION       => $ndb->timestamp_to_string(time() + 3600),
    LAST_UPDATE_USER => 'system',
    START_DATE       => $ndb->timestamp_to_string(time()),
    RECURRING        => 0,
  };
  $ndb->create_redirect(%$redirect);

  my $ref = $ndb->select_global_redirects();

  my @rows = @$ref;

  $self->assert(scalar(@rows) > 0, "test_select_global_redirects");

} ## end sub test_select_global_redirects

##################################
sub test_select_active_redirects {
##################################
  my $self = shift;
  my $ndb  = $self->{'blah'};

  # Create an active redirect
  my $redirect = {
## CUSTOMER_ID        =>  NULL
    REDIRECT_TYPE       => 'BLACKHOLE',
    DESCRIPTION         => "test_select_active",
    REASON              => "test_select_active_redirects",
    EXPIRATION          => $ndb->timestamp_to_string(time() + 3600),
    LAST_UPDATE_USER    => 'system',
    START_DATE          => $ndb->timestamp_to_string(time() - 3600),
    RECURRING           => 1,
    RECURRING_FREQUENCY => 2,
    RECURRING_DURATION  => 60,
  };
  $ndb->create_redirect(%$redirect);

  my $ref = $ndb->select_global_redirects();

  my $row = pop(@$ref);
  print &Dumper($row), "\n";

  $self->assert(defined($row),                    "row count");
  $self->assert($row->{RECURRING} == 1,           "recurring");
  $self->assert($row->{RECURRING_FREQUENCY} == 2, "recurring_frequency");
  $self->assert($row->{RECURRING_DURATION} == 60, "recurring_duration");

} ## end sub test_select_active_redirects

sub test_select_max_last_update_date {
  my $self = shift;
  my $ndb  = $self->{'blah'};

  # Create an active redirect
  my $redirect = {
## CUSTOMER_ID        =>  NULL
    REDIRECT_TYPE       => 'BLACKHOLE',
    DESCRIPTION         => "test_select_active",
    REASON              => "test_select_active_redirects",
    EXPIRATION          => $ndb->timestamp_to_string(time() + 3600),
    LAST_UPDATE_USER    => 'system',
    START_DATE          => $ndb->timestamp_to_string(time() - 3600),
    RECURRING           => 1,
    RECURRING_FREQUENCY => 2,
    RECURRING_DURATION  => 60,
  };

  $ndb->create_redirect(%$redirect);
  my $date = $ndb->select_max_last_update_date('redirects');

  my (undef, undef, undef, $mday, $mon, $year) = localtime(time());
  my $s = sprintf("%i%i%i", $year + 1900, $mon + 1, $mday);

  $self->assert($date =~ /^$s/, "select_max_last_update_date");
} ## end sub test_select_max_last_update_date

1;
