package NOCpulse::Probe::test::TestProbeResult;

use strict;

use Error(':try');

use NOCpulse::Probe::Error;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::ItemStatus;
use NOCpulse::Probe::Config::Command;
use NOCpulse::Probe::Config::CommandParameter;

use base qw(Test::Unit::TestCase);

sub test_statuses {
    my $self = shift;
    my %values = (okeydoke =>  {value => 123, message => "I'm OK"},
                  notsogood => {value => 456, message => "I'm not so good"},
                  whoknows =>  {value => 789, message => "I forget who I am"},
                  uhoh =>      {value => 1000, message => "I'm in big trouble"},
                 );
    my $result = $self->empty_result();
    $result->item_ok('okeydoke',  $values{okeydoke}->{value}, 
                     message => $values{okeydoke}->{message});
    $result->item_warning ('notsogood', $values{notsogood}->{value}, 
                           message => $values{notsogood}->{message});
    $result->item_unknown ('whoknows', $values{whoknows}->{value},
                           message => $values{whoknows}->{message});
    $result->item_critical('uhoh', $values{uhoh}->{value},
                           message => $values{uhoh}->{message});
    $self->check_status($result->item_named('okeydoke'),
                        $result->OK, $values{okeydoke}->{value});
    $self->check_status($result->item_named('notsogood'),
                        $result->WARNING, $values{notsogood}->{value});
    $self->check_status($result->item_named('whoknows'),
                        $result->UNKNOWN, $values{whoknows}->{value});
    $self->check_status($result->item_named('uhoh'), 
                        $result->CRITICAL, $values{uhoh}->{value});
}

sub check_status {
    my ($self, $item, $status_string, %args) = @_;
    $self->assert(qr/$status_string/, $item->status);
    $self->assert(qr/$args{message}/, $item->message);
    $self->assert(qr/$args{value}/, $item->value);
}

sub test_overall_status {
    my $self = shift;
    my $result = $self->empty_result();

    $result->item_ok('a', 1);
    $result->finish();
    $self->assert(qr/OK/, $result->overall_status);

    $result->item_warning('b', 2);
    $result->finish();
    $self->assert(qr/WARNING/, $result->overall_status);

    $result->item_unknown('c', 3);
    $result->finish();
    $self->assert(qr/UNKNOWN/, $result->overall_status);

    $result->item_critical('d', 4);
    $result->finish();
    $self->assert(qr/CRITICAL/, $result->overall_status);
}

sub test_format {
    my $self = shift;

    my ($val, $expect, $item);

    $val = 1.234565;
    $expect = '1.235';
    $item = NOCpulse::Probe::ItemStatus->new(value => $val, value_format => "%.3f");
    $self->assert(qr/^$expect$/, $item->formatted_value);

    $val = 1.234e-8;
    $expect = '0.000';
    $item = NOCpulse::Probe::ItemStatus->new(value => $val, value_format => "%.3f");
    $self->assert(qr/^$expect$/, $item->formatted_value);

    $val = 123456578.910;
    $expect = '123,456,578.9';
    $item = NOCpulse::Probe::ItemStatus->new(value => $val, value_format => "%.1f");
    $self->assert(qr/^$expect$/, $item->formatted_value);
}

sub test_changed {
    my $self = shift;

    my $prior_status = $self->empty_result();
    my $result = $self->empty_result();
    my $item;
    my @changes = ();

    # No prior state, should trigger a change
    $item = $result->item_ok('a', 2);
    $item = $result->item_ok('w', 99);
    @changes = $result->changed_items();
    $self->assert(@changes == 2, "Initial state not flagged as changed: ", scalar(@changes));

    # No status change
    my $prior_item = $prior_status->item_ok('a', 1);
    $prior_status->item_ok('b', 3);

    $item = $result->item_ok('a', 2);
    $item->mark_status_change($prior_item->status);
    $self->assert(!$item->status_changed, "Unchanged status marked as changed");

    $item = $result->item_warning('a', 2);
    $item->mark_status_change($prior_item->status);
    $self->assert($item->status_changed, "Changed status marked as unchanged");

    $item = $result->item_unknown('a', 8);
    $item = $result->item_critical('b', 2);

    $result->prior_item_named($prior_status->item_named);

    @changes = $result->changed_items();
    $self->assert(@changes == 2, "Wrong number changed: ", join(', ', @changes));
}

sub test_unknown_to_ok {
    my $self = shift;

    my $prior_status = $self->empty_result();
    my $result = $self->empty_result();
    my $item;
    my @changes = ();

    my $prior_item = $prior_status->item_unknown('a', 1);
    $item = $result->item_ok('b', 2);
    $result->prior_item_named('a', $prior_item);
    $result->finish();
    $self->assert($result->status_changed, "Status change from unknown to OK not seen");
}


sub test_metric_thresholds {
    my $self = shift;
    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new
      ({ recid      => 111,
         command_id => 1234,
         parameters => { config_stuff => 'Stuff', a_critical_maximum => '345.67' },
         notification_interval => 5,
         notify_recovery => 1,
         notify_warning  => 1,
         notify_critical => 1,
       }
      );
    my $command_param = NOCpulse::Probe::Config::CommandParameter->new
      ( command_id  => 1234,
        param_name  => 'a_critical_maximum',
        description => 'i am critical max',
        param_type  => 'threshold',
        threshold_metric_id => 'my_metric_id',
        threshold_type_name => 'crit_max',
      );
    my $metric = NOCpulse::Probe::Config::CommandMetric->new
      (
       command_class => 'module',
       metric_id     => 'my_metric_id',
       label         => 'Things',
       unit_label    => 'things/sec',
      );
    my $command = NOCpulse::Probe::Config::Command->new
      (command_id => 1234,
       parameters => {a_critical_maximum => $command_param},
       metrics =>    {my_metric_id => $metric},
      );
    my $result = NOCpulse::Probe::Result->new(probe_record   => $probe_rec,
                                              command_record => $command);
    my $item = $result->metric_value('my_metric_id', 343.98, '%.3f');
    $self->assert(qr/OK/, $item->status);

    my $item = $result->metric_value('my_metric_id', 567.22, '%.1f');
    $self->assert(qr/CRITICAL/, $item->status);

#    try {
#        my $item = $result->metric_value('NOT_A_metric_id', 567.22, '%.1f');
#        $self->fail("Bad metric allowed");
#    } catch NOCpulse::Probe::InternalError with {
#    };
}

sub test_value_thresholds {
    my $self = shift;
    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new
      ({ recid      => 111,
         command_id => 1234,
         parameters => { config_stuff => 'Stuff', a_critical_maximum => '345.67' },
         notification_interval => 5,
         notify_recovery => 1,
         notify_warning  => 1,
         notify_critical => 1,
       }
      );
    my $result = NOCpulse::Probe::Result->new(probe_record  => $probe_rec,
                                              command_record => 
                                              NOCpulse::Probe::Config::Command->new());
    my $item;
    my $thresh = { crit_max => 12, warn_max => 10 };
    my %item_args = (label => 'Foo', units => 'foos/sec', remove_if_ok => 1);
    $item = $result->item_thresholded_value('foo', 8, '%d', $thresh, %item_args);
    $self->assert(qr/OK/, $item->status);
    $self->assert(! $result->item_named('foo'), 'foo item added to result with OK status');

    $item = $result->item_thresholded_value('foo', 11, '%d', $thresh, %item_args);
    $self->assert(qr/WARNING/, $item->status);
    $self->assert($result->item_named('foo'), 'foo item NOT added to result with WARN status');

    $item = $result->item_thresholded_value('foo', 20, '%d', $thresh, %item_args);
    $self->assert(qr/CRITICAL/, $item->status);

    # Test zero threshold vals.
    $thresh->{crit_max} = 0;
    $item = $result->item_thresholded_value('foo', 1, '%d', $thresh, %item_args);
    $self->assert(qr/CRITICAL/, $item->status);
}

sub test_metric_rate {
    my $self = shift;
    my $result = $self->empty_result();

    # No prior value
    my $item = $result->metric_rate('a', 2);
    $self->assert(!defined($item->value), "Value exists for rate with no prior value: ",
                 $item->value);
    $self->assert($item->need_second_iteration(), "2nd not needed with no prior");

    # Set up prior value for remaining tests
    my $prior_item = $item;
    $prior_item->value_time(time());
    $result->prior_item_named('a', $prior_item);

    # Zero elapsed time
    my $item = $result->metric_rate('a', 12);
    $self->assert($item->need_second_iteration(), "2nd not needed with zero elapsed");
    $self->assert(!defined($item->value), "Rate calculated with zero elapsed: ", $item->value);

    # 10 seconds
    $prior_item->value_time(time() - 10);
    my $item = $result->metric_rate('a', 12);
    $self->assert(!$item->need_second_iteration(), "2nd needed with prior");
    $self->assert(defined($item->value), "Rate not calculated with 1/sec");
    $self->assert($item->value == 1, "Rate not one: ", $item->value);
    $self->assert($item->raw_value == 12, "Raw value not saved: ", $item->raw_value);

    # 10 minutes, events/minute
    my $divisor = 60;
    $prior_item->value_time(time() - 1200);
    my $item = $result->metric_rate('a', 12, undef, $divisor);
    $self->assert(!$item->need_second_iteration(), "2nd needed with prior");
    $self->assert(defined($item->value), "Rate not calculated with 1/min");
    $self->assert($item->value == 0.5, "Rate not 0.5: ", $item->value);
    $self->assert($item->raw_value == 12, "Raw value not saved: ", $item->raw_value);

    # Wrapping
    my $wrap = 100;
    $prior_item->value_time(time() - 10);
    $prior_item->raw_value(90);
    my $item = $result->metric_rate('a', 10, undef, 1, $wrap);
    $self->assert(!$item->need_second_iteration(), "2nd needed with prior");
    $self->assert(defined($item->value), "Rate not calculated with 1/sec");
    $self->assert($item->value == 2, "Rate not two: ", $item->value);
    $self->assert($item->raw_value == 10, "Raw value not saved: ", $item->raw_value);
}

sub test_metric_percent {
    my $self = shift;
    my $result = $self->empty_result();
    
    my $item;
    my $pct;

    $item = $result->metric_percentage('a', 2, 3);
    $pct = sprintf('%.2f', $item->value);
    $self->assert($pct eq '66.67', "Wrong percent for 2/3: ", $pct);
    $self->assert($item->is_ok, "Wrong status: ", $item->status);

    $item = $result->metric_percentage('a', 2, 0);
    $self->assert($item->status eq $item->OK, "Status not OK with zero total: ", $item->status);
}

sub test_attempts {
    my $self = shift;
    my $result = $self->empty_result();
    $result->probe_record->max_attempts(3);
    my $notifs = 0;
    my $item;

    $item = $result->item_critical('a', 2);
    $notifs = @{$result->notifying_items()};
    $self->assert($notifs == 0, "Count not zero with first attempt: $notifs");
    $self->assert(! $result->should_notify, "Should notify is true with zero items notifying");
    $self->assert($result->attempts == 1, "Attempt count not one with first attempt: ", 
                  $result->attempts);

    $item->status_notified_time($result->CRITICAL => 
                                $item->status_notified_time($result->CRITICAL) - 1200);
    $result->prior_item_named('a', $item);

    $item = $result->item_critical('a', 2);
    $result->finish();
    $notifs = @{$result->notifying_items()};
    $self->assert($notifs == 0, "Count not zero with second attempt: $notifs");
    $self->assert($result->attempts == 2, "Attempt count not two with second attempt: ",
                  $result->attempts);
    $self->assert($item->status_notified_time($result->CRITICAL) == -1,
                  "Status notified time not reset to -1");
    $self->assert($item->renotified_count == 0, "Renotified count not reset to 0");

    $item->status_notified_time($result->CRITICAL =>
                                $item->status_notified_time($result->CRITICAL) - 1200);
    $result->prior_item_named('a', $item);

    $item = $result->item_critical('a', 2);
    $result->finish();
    $notifs = @{$result->notifying_items()};
    $self->assert($notifs == 1, "Notifications not one with third attempt: $notifs");
    $self->assert($result->attempts == 0, "Attempt count not zero with third attempt: ",
                  $result->attempts);
}

sub test_catch {
    my $self = shift;
    my $result = $self->empty_result();
    my $a = $result->item_warning('a', 2);
    $a->status_notified_time($a->status, time());
    $a->renotified_count(33);

    my $err;
    my $text;
    my $internal = NOCpulse::Probe::MessageCatalog->instance->status('internal_problem');

    # Internal error
    $text = 'No damn good';
    try {
        throw NOCpulse::Probe::InternalError($text);
    } otherwise {
        $err = shift;
    };
    $result->finish($err);
    $self->assert($err, 'No error caught');
    $self->assert(qr/UNKNOWN/, $result->overall_status);
    $self->assert($result->should_notify, "Should notify flag not set for error");
    $self->assert($result->status_changed, "Status changed flag not set for error");
    $self->assert(qr/$internal/, $result->detail_text);
    $self->assert(qr/$internal/, $result->notification_text);
    $self->assert(!defined($a->status_notified_time($a->status)),
                  "Item notified time not cleared");
    $self->assert($a->renotified_count() == 0, "Item renotify count not cleared");

    # Non-object error
    $text = 'die die die';
    try {
        die $text;
    } otherwise {
        $err = shift;
    };
    $result->finish($err);
    $self->assert($err, "No error caught");
    $self->assert(qr/UNKNOWN/, $result->overall_status);
    $self->assert(qr/$internal/, $result->detail_text);
    $self->assert(qr/$internal/, $result->notification_text);

    # User-visible error
    $text = 'Cannot connect';
    try {
        throw NOCpulse::Probe::Shell::ConnectError($text);
    } otherwise {
        $err = shift;
    };
    my $prior_status = $self->empty_result();
    my $prior_item = $prior_status->item_ok('foo', 1);
    $result->prior_item_named('foo', $prior_item);
    $result->finish($err);

    $self->assert($err, "No error caught");
    $self->assert(qr/UNKNOWN/, $result->overall_status);
    $self->assert(qr/$text/, $result->detail_text);
    $self->assert(qr/$text/, $result->notification_text);
    $self->assert($result->item_named('foo')->status eq $result->UNKNOWN,
                  "Prior item not set to unknown after catch: ",
                  $result->item_named('foo')->status);

    # Notify on unknown not set
    $text = 'Cannot connect';
    try {
        throw NOCpulse::Probe::Shell::ConnectError($text);
    } otherwise {
        $err = shift;
    };
    $result->probe_record->notify_unknown(0);
    $result->finish($err);

    $self->assert($err, "No error caught");
    $self->assert(qr/UNKNOWN/, $result->overall_status);
    $self->assert(qr/$text/, $result->detail_text);
    $self->assert(!$result->should_notify, "Notifying when notify on unknown not set");
}




sub test_one_item_notify_required {
    my $self = shift;

    my $prior_status = $self->empty_result();
    my $result = $self->empty_result();
    $result->probe_record->notification_interval(5);

    my @notifs;

    my $now = time();

    # No prior, tests first run situation
    $result->item_ok('a', 2);
    @notifs = $result->notifying_items();
    $self->assert(@notifs == 0, "Count not zero with OK and no prior: ", scalar @notifs);

    # No prior with bad state
    $result->item_warning('a', 5);
    $result->finish();
    @notifs = $result->notifying_items();
    $self->assert(@notifs == 1, "Count not one with warning and no prior: ", scalar @notifs);
    $self->assert(@notifs->[0]->status_notified_time($result->WARNING) > 0,
                  "Notification time not set with no prior");

    # No prior with bad state but notify flag not set
    $result->probe_record->notify_warning(0);
    $result->item_warning('a', 5);
    $result->finish();

    @notifs = $result->notifying_items();
    $self->assert(@notifs == 0, "Count not zero with warning disabled and no prior: ",
                  scalar @notifs);

    # Prior OK, current OK, no prior notify time
    $prior_status->item_ok('a', 1);
    $result->item_ok('a', 2);
    $result->prior_item_named({$prior_status->item_named});
    $result->finish();
    @notifs = $result->notifying_items();
    $self->assert(@notifs == 0, "Count not zero with no change: ", scalar @notifs);

    # Prior OK, current critical, no prior notify time
    $prior_status->item_ok('a', 1);
    $result->item_critical('a', 2);
    $result->prior_item_named({$prior_status->item_named});
    $result->finish();
    @notifs = $result->notifying_items();
    $self->assert(@notifs == 1, "Count not 1 with change: @notifs");

    # Prior critical, current critical, time out of window
    $prior_status->item_critical('a', 555);
    $result->item_critical('a', 666);
    $prior_status->item_named('a')->status_notified_time($prior_status->item_named('a')->status,
                                                         $now - 1200);
    $result->prior_item_named({$prior_status->item_named});
    $result->finish();
    @notifs = $result->notifying_items();
    $self->assert(@notifs == 1, "Count not 1 for critical outside renotify interval: ",
                  scalar @notifs);
    $self->assert(@notifs->[0]->renotified_count == 1,
                  "Renotify count not 1 for ", @notifs->[0]->name);

    # Prior critical, current critical, time within window
    $prior_status->item_critical('a', 1);
    $result->item_critical('a', 2);
    $prior_status->item_named('a')->status_notified_time($prior_status->item_named('a')->status,
                                                         $now - 120);
    $result->prior_item_named({$prior_status->item_named});
    $result->finish();
    @notifs = $result->notifying_items();
    $self->assert(@notifs == 0, "Count not zero for change within renotify interval: ", 
                  scalar(@notifs));
}

sub test_multiple_item_notify_required {
    my $self = shift;

    my $prior_status = $self->empty_result();
    my $result = $self->empty_result();
    $result->probe_record->notification_interval(5);
    my $notifs = 0;

    my $now = time();

    # Recovery on two items
    $prior_status->item_ok('a', 1);
    $prior_status->item_warning('b', 2);
    $prior_status->item_unknown('c', 3);
    $result->item_ok('a', 4);
    $result->item_ok('b', 5);
    $result->item_ok('c', 6);
    $result->prior_item_named({$prior_status->item_named});
    $result->finish();
    $notifs = @{$result->notifying_items()};
    $self->assert($notifs == 2, "Count not 2 with recovery: $notifs");

    $result->probe_record->notify_recovery(0);
    $result->finish();
    $notifs = @{$result->notifying_items()};
    $self->assert($notifs == 0, "Count not 0 with no notify on recovery: $notifs");

    # Worsened or same states, same outside renotify window
    $prior_status->item_ok('a', 1);
    $prior_status->item_warning('b', 2);
    $prior_status->item_unknown('c', 3);
    $prior_status->item_named('c')->status_notified_time($prior_status->item_named('c')->status,
                                                         $now - 1200);
    $result->item_warning('a', 4);
    $result->item_critical('b', 5);
    $result->item_unknown('c', 6);
    $result->prior_item_named({$prior_status->item_named});
    $result->finish();
    $notifs = @{$result->notifying_items()};
    $self->assert($notifs == 3, "Count not 3 with changes within window: $notifs");

    # Check notify flag logic.
    $result->probe_record->notify_recovery(0);
    $result->probe_record->notify_warning(1);
    $result->probe_record->notify_unknown(0);
    $result->probe_record->notify_critical(0);
    $result->item_warning('a', 4);
    $result->item_critical('b', 5);
    $result->item_unknown('c', 6);
    $result->prior_item_named({$prior_status->item_named});
    $result->finish();
    $notifs = @{$result->notifying_items()};
    $self->assert($notifs == 1,
                  "Count not 1 with changes within window but notif flags off: $notifs");
}

# Test notifications on two cases of disappearing items:

#  1) An OK item disappears, e.g. when the Oracle::Availability
#     probe goes from OK (item 'Running' in OK state) to 
#     CRITICAL (e.g. 'Cannot log in to Oracle instance dev01a on 
#     host 192.168.15.111, port 1522: ORA-12541: TNS:no listener'
#     is CRITICAL).

sub test_disappearing_ok_item_notif {
  my $self = shift;


  my $prior_status = $self->empty_result();
  my $result = $self->empty_result();

  $prior_status->item_ok('Vanishing OK item');
  $result->item_critical('Appearing CRITICAL item');

  $result->prior_item_named($prior_status->item_named);
  $result->finish();

  my @notifs = $result->notifying_items();

  $self->assert(@notifs == 1, "Disappearing OK item produced ", 
                scalar(@notifs), " notifying items (should be 1)");
  $self->assert(@notifs->[0]->status_notified_time($result->CRITICAL) > 0,
                "Notification time not set on disappearing CRITICAL item");

}


#  2) A non-OK item disappears, e.g. when a LongLegs probe goes
#     CRITICAL on a connection refused, but runs clean on the
#     subsequent run.

sub test_disappearing_critical_item_notif {
  my $self = shift;

  my $prior_status = $self->empty_result();
  my $result = $self->empty_result();

  $prior_status->item_critical('Vanishing CRITICAL item');
  $result->item_ok('Appearing OK item');

  $result->prior_item_named($prior_status->item_named);
  $result->finish();

  my @notifs = $result->notifying_items();


  $self->assert(@notifs == 1, "Disappearing CRITICAL item produced ", 
                scalar(@notifs), " notifying items (should be 1)");


}

sub empty_result {
    return NOCpulse::Probe::Result->new
      (probe_record => NOCpulse::Probe::Config::ProbeRecord->new
       ({recid => 10,
         notification_interval => 0,
         notify_recovery => 1,
         notify_warning  => 1,
         notify_unknown  => 1,
         notify_critical => 1,
        }),
       command_record => NOCpulse::Probe::Config::Command->new());
}

1;
