#!/usr/bin/perl -w

package Test::Unit::TkTestRunner;

use strict;

use base qw(Test::Unit::Runner);

use constant COPYRIGHT_NOTICE => <<'END_COPYRIGHT_NOTICE';
This the PerlUnit Tk Test Runner. 
Copyright (C) 2000 Christian Lemburg, Brian Ewins,
Cayte Lindner, J. E. Fritz, Zhon Johansen.

PerlUnit is a Unit Testing framework based on JUnit.
See http://c2.com/cgi/wiki?TestingFrameworks

PerlUnit is free software, redistributable under the
same terms as Perl.

$Id: TkTestRunner.pm,v 1.1.1.1 2004-01-05 18:34:58 kja Exp $
END_COPYRIGHT_NOTICE

use Tk;
use Tk::BrowseEntry;
use Benchmark;

use Test::Unit::Result;
use Test::Unit::Loader;

sub new {
    my $self = bless {}, shift;
    return $self;
}  

sub about {
    my $self = shift;
    my $dialog = $self->{frame}->DialogBox(
        -title => 'About PerlUnit',
        -buttons => [ 'OK' ]
    );
    my $text = $dialog->add("ROText"); #, -width => 80, -height => 20);
    $text->insert("end", COPYRIGHT_NOTICE);
    $text->pack();
    $dialog->Show();
}

sub add_error {
    my $self = shift;
    $self->{number_of_errors} = $self->{result}->error_count();
    $self->append_failure("Error", @_);
    $self->update();
}

sub add_failure {
    my $self = shift;
    $self->{number_of_failures} = $self->{result}->failure_count();
    $self->append_failure("Failure", @_);
    $self->update();
}

sub append_failure {
    my ($self, $kind, $test, $exception)=@_;
    my $message = $test->name();	#bad juju!!
    if ($message) {
	$kind .= ":".substr($message, 0, 100);
    }
    $self->{failure_list}->insert("end", $message);
    push @{$self->{failed_tests}}, $test;
    push @{$self->{exceptions}}, $exception;
}

sub plan{
    my $self = shift;
    $self->{planned} = shift;
}


sub choose_file {
    my $self = shift;
    my $name = $self->{suite_name};
    my @types = ([ 'All Files', '*' ]);
    my $dir   = undef;
    if (defined $name) {
	require File::Basename;
	my $sfx;
	($name, $dir, $sfx) = File::Basename::fileparse($name, '\..*');
	if (defined($sfx) && length($sfx)) {
            unshift(@types, [ 'Similar Files', [$sfx]]);
            $name .= $sfx;
	}
    }
    my $file = $self->{frame}->getOpenFile(
        -title       => "Select test case",
        -initialdir  => $dir, 
        -initialfile => $name,
        -filetypes   => \@types
    );
    if (defined $file) {
	$file=~s/\/+/\//g;
    }
    $self->{suite_name} = $file;
}

sub create_punit_menu {
    my $self = shift;
    my $main_menu = $self->{frame}->Menu(
        -type => 'menubar',
        -menuitems =>  [
            [
                cascade => 'F~ile',
                -menuitems =>  [
                    [
                        command  => 'O~pen',
                        -command => sub { $self->choose_file() }
                    ],
                    [
                        command  => 'Ex~it',
                        -command => sub { $self->{frame}->destroy() }
                    ],
               ],
            ],
            [
                cascade => 'H~elp',
                -menuitems =>  [
                    [
                        command  => 'A~bout PerlUnit',
                        -command => sub { $self->about() }
                    ],
                ],
            ],
        ],
    );
    return $main_menu;
}

sub create_menus {
    my $self = shift;
    $self->{frame}->configure(-menu => $self->create_punit_menu());
}

sub create_ui {
    my $self = shift;
    # Lay the window out....
    my $mw = $self->{frame} = MainWindow->new(
        -title => 'Run Test Suite',
        -width => 200
    );
    # I need stretchy labels, Tk doesnt have them
    my $mklabel = sub {
        my (@args)=@_;
        $self->{$args[0]} = $args[2];
        $mw->Entry(
            -textvariable => \$self->{$args[0]},
            -justify      => $args[1],
            -relief       => 'flat',
            -state        => 'disabled'
        ); 
    };
    $self->create_menus();
    $self->{suite_label} = $mw->Label(
        -text => 'Enter the name of the TestCase:'
    );
    $self->{suite_name}  = "x";
    $self->{suite_field} = $mw->BrowseEntry(
        -textvariable => \$self->{suite_name},
        -choices      => [],
    );
    $self->{add_text_listener} = sub { $self->run_suite() };
    $self->{run} = $mw->Button(
        -text    => 'Run',
        -state   => 'normal',
        -command => sub { $self->run_suite() }
    );
  
    my $lab1 = $mw->Label(-text => "Runs:");
    my $lab2 = &{$mklabel}('number_of_runs', 'right', 0);
    my $lab3 = $mw->Label(-text => "Errors:");
    my $lab4 = &{$mklabel}('number_of_errors', 'right', 0);
    my $lab5 = $mw->Label(-text => "Failures:");
    my $lab6 = &{$mklabel}('number_of_failures', 'right', 0);

    $self->{progress_bar} = $mw->ArrayBar(
        -width  => 20,
        -length => 400,
        -colors => [ 'green', 'red', 'grey' ]
    );
    $self->{failure_label} = $mw->Label(
        -text    => 'Errors and Failures:',
        -justify => 'left'
    );
    $self->{failure_list} = $mw->Scrolled('Listbox', -scrollbars => 'e');
    $self->{failure_list}->insert("end", "", "", "", "", "", "");
  
    $self->{quit_button} = $mw->Button(
        -text    => 'Quit',
        -command => sub { $mw->destroy() }
    );

    $self->{rerun_button} = $mw->Button(
        -text    => 'ReRun',
        -state   => 'normal',
        -command => sub { $self->rerun() }
    );
    $self->{show_error_button} = $mw->Button(
        -text    => 'Show...',
        -state   => 'normal',
        -command => sub { $self->show_error_trace() }
    );


    $self->{status_line_box}= &{$mklabel}('status_line', 'left', 'Status line');
    $self->{status_line_box}->configure(-relief => 'sunken', -bg => 'grey');
  
    # Bindings go here, so objects are already defined.
    $self->{failure_list}->bind('<Double-1>' => sub { $self->show_error_trace() });

    # all geometry management BELOW this point. Otherwise bindings
    # wont work.
    $self->{suite_label}->form(
        -left => [ '%0' ],
        -top  => [ '%0' ],
        -fill => 'x'
    );
    $self->{run}->form(
        -right => [ '%100' ],
        -top   => [ $self->{suite_label} ],
    );
    $self->{suite_field}->form(
        -left  => [ '%0' ],
        -right => [$self->{run}],
        -top   => [$self->{suite_label}], -fill => 'x'
    );
  
    $lab1->form(-left => ['%0'],  -top => [$self->{suite_field}, 10]);
    $lab2->form(-left => [$lab1], -top => [$self->{suite_field}, 10], -fill => 'x');
    $lab3->form(-left => [$lab2], -top => [$self->{suite_field}, 10]);
    $lab4->form(-left => [$lab3], -top => [$self->{suite_field}, 10], -fill => 'x');
    $lab5->form(-left => [$lab4], -top => [$self->{suite_field}, 10]);
    $lab6->form(-left => [$lab5], -top => [$self->{suite_field}, 10], -fill => 'x');


    $self->{progress_bar}->form(-left => [ '%0' ], -top => [$lab6, 10]);
    $self->{failure_label}->form(
        -left  => [ '%0' ],
        -top   => [$self->{progress_bar}, 10],
        -right => [ '%100' ]
    );
    $self->{failure_list}->form(
        -left  => [ '%0' ],
        -top   => [$self->{failure_label}],
        -right => [ '%100' ],
        -fill  => 'both'
    );
    # this is in a wierd order 'cos Quit keeps trying to resize.
    $self->{quit_button}->form(
        -right  => [ '%100' ],
        -bottom => [ '%100' ],
        -fill   => 'none'
    );
    $self->{show_error_button}->form(
        -right  => [ '%100' ],
        -bottom => [$self->{quit_button}],
        -top    => [$self->{failure_list}]
    );
#   Rerun doesn't work yet.
#     $self->{rerun_button}->form(
#         -right => [$self->{show_error_button}],
#         -top   => [$self->{failure_list}]
#     );
  
    $self->{status_line_box}->form(
        -left   => [ '%0' ],
        -right  => [$self->{quit_button}],
        -bottom => [ '%100' ],
        -top    => [$self->{show_error_button}],
        -fill   => 'x'
    );

    $self->reset();
    return $mw;
}

sub end_test {
    my $self = shift;
    $self->{runs} = $self->{result}->run_count();
    $self->update();
}

sub get_test {
    my $self = shift;
    my $suite = Test::Unit::Loader->obj_load(shift);
    $self->{status_line}="";
    return $suite;
}

sub is_error_selected {
    my $self = shift;
    ($self->{listbox}->curselection>=0)?1:0;
}

sub load_frame_icon {
    # not implemented
}

sub main {
    my $main = new Test::Unit::TkTestRunner()->start(@_);
}

sub rerun {
    # not implemented and not going to!
    my $self = shift;
    my $index = $self->{failure_list}->curselection;
    return if $index < 0;
    my $test = $self->{failed_tests}->[$index];
    #if (! $test->isa("Test::Unit::TestCase")) {
    $self->show_status("Could not reload test.");
    #}
    # Not sure how to do this...
}

sub reset {
    my $self = shift;
    $self->{number_of_errors}   = 0;
    $self->{number_of_failures} = 0;
    $self->{number_of_runs}     = 0;
    $self->{planned}            = 0;
    $self->{failure_list}->delete(0, "end");
    $self->{exceptions}         = [];
    $self->{failed_tests}       = [];
    $self->{progress_bar}->value(0, 0, 1);
}

sub run {
    my $self = shift;
    $self->run_suite();
}

sub run_failed {
    my $self = shift;
    # not implemented
}

sub run_suite {
    my $self = shift;
    my $suite;
    if (defined($self->{runner})) {
	$self->{result}->stop();
    }
    else {
        $self->add_to_history();
        $self->{run}->configure(-text => "Stop");
        $self->show_info("Initializing...");
        $self->reset();
        $self->show_info("Load Test Case...");
        eval {
            $suite = $self->get_test($self->{suite_name});
        };
        if ($@ or !$suite) {
            $suite = undef;
            $self->show_status("Could not load test!");
        }
        if ($suite) {
            $self->{runner}  = 1;
            $self->{planned} = $suite->count_test_cases();
            $self->{result}  = $self->create_test_result();
            $self->{result}->add_listener($self);
            $self->show_info("Running...");
            $self->{start_time} = new Benchmark();
            $suite->run($self->{result});
            if ($self->{result}->should_stop()) {
                $self->show_status("Stopped");
            }
            else {
                $self->{finish_time} = new Benchmark();
                $self->{run_time} = timediff($self->{finish_time},
                                             $self->{start_time});
                $self->show_info("Finished: ".timestr($self->{run_time}, 'nop'));
            }
        }
        $self->{runner} = undef;
        $self->{result} = undef;
        $self->{run}->configure(-text => "Run");
    }
}

sub show_error_trace {
    # pop up a text dialog containing the details.
    my $self = shift;
    my $dialog = $self->{frame}->DialogBox(
        -title => 'Details',
        -buttons => [ 'OK' ]
    );
    my $selected = $self->{failure_list}->curselection;
    return unless defined($selected) && $self->{exceptions}[$selected];
    my $text = $dialog->add("Scrolled", "ROText", -width => 80, -height => 20)->pack;
    $text->insert("end", $self->{exceptions}[$selected]->to_string());
    $dialog->Show();
}

sub show_info {
    my $self = shift;
    $self->{status_line} = shift;
    $self->{status_line_box}->configure(-bg => 'grey');
}

sub show_status {
    my $self = shift;
    $self->{status_line} = shift;
    $self->{status_line_box}->configure(-bg => 'red');
}

sub start {
    my $self = shift;
    my (@args)=@_;
    my $mw = $self->create_ui();
    if (@args) {
	$self->{suite_name} = shift @args;
    }
    MainLoop;
}

sub start_test {
    my $self = shift;
    my $test = shift;
    $self->{number_of_runs} = $self->{result}->run_count();
    $self->show_info("Running: " . $test->name());
}

sub add_pass {
    my $self = shift;
    my ($test, $exception)=@_;
    $self->update();
}

sub update {
    my $self = shift;
    my $result   = $self->{result};
    my $total    = $result->run_count();
    my $failures = $result->failure_count();
    my $errors   = $result->error_count();
    my $passes   = $total-$failures-$errors;
    my $bad      = $failures+$errors;
    #$passes = $result->run_count();
    my $todo = ($total>$self->{planned})?0:$self->{planned}-$total;
    $self->{progress_bar}->value($passes, $bad, $todo);
    # force entry into the event loop.
    # this makes it nearly like its threaded...
    #sleep 1;
    $self->{frame}->update();
}

sub add_to_history {
    my $self = shift;
    my $new_item = $self->{suite_name};
    my $h = $self->{suite_field};
    my $choices = $h->cget('-choices');
    my @choices = ();
    if (ref($choices)) {
	@choices=@{$h->cget('-choices')};
    }
    elsif ($choices) {
	# extraordinarily bad - choices is a scalar if theres
	# only one, and undefined if there are none!
	@choices = ($h->cget('-choices'));
    }
    @choices = ($new_item, grep {$_ ne $new_item} @choices);
    if (@choices>10) {
	@choices=@choices[0..9];
    }
    $h->configure(-choices => \@choices);
}

package Tk::ArrayBar;
# progressbar doesnt cut it.
# This expects a variable which is an array ref, and
# a matching list of colours. Sortof like stacked progress bars.
# Heavily - ie almost totally - based on the code in ProgressBar.
use Tk;
use Tk::Canvas;
use Tk::ROText;
use Tk::DialogBox;
use Carp;
use strict;

use base qw(Tk::Derived Tk::Canvas);

Construct Tk::Widget 'ArrayBar';

sub ClassInit {
  my ($class, $mw) = @_;
  
  $class->SUPER::ClassInit($mw);
  
  $mw->bind($class, '<Configure>', [ '_layoutRequest', 1 ]);
}

sub Populate {
    my($c, $args) = @_;
  
    $c->ConfigSpecs(
        -width              => [ PASSIVE => undef, undef, 0           ],
        '-length'           => [ PASSIVE => undef, undef, 0           ],
        -padx               => [ PASSIVE => 'padX', 'Pad', 0          ],
        -pady               => [ PASSIVE => 'padY', 'Pad', 0          ],
        -colors             => [ PASSIVE => undef, undef, undef       ],
        -relief             => [ SELF => 'relief', 'Relief', 'sunken' ],
        -value              => [ METHOD  => undef, undef, undef       ],
        -variable           => [ PASSIVE  => undef, undef, [ 0 ]      ],
        -anchor             => [ METHOD  => 'anchor', 'Anchor', 'w'   ],
        -resolution         => [ PASSIVE => undef, undef, 1.0         ],
        -highlightthickness => [
            SELF => 'highlightThickness', 'HighlightThickness', 0
        ],
        -troughcolor        => [
            PASSIVE => 'troughColor', 'Background', 'grey55'
        ],
    );
  
    _layoutRequest($c, 1);
    $c->OnDestroy([ Destroyed => $c ]);
}

sub anchor {
    my $c = shift;
    my $var = \$c->{Configure}{'-anchor'};
    my $old = $$var;
  
    if (@_) {
	my $new = shift;
	croak "bad anchor position \"$new\": must be n, s, w or e"
	  unless $new =~ /^[news]$/;
	$$var = $new;
    }
  
    $old;
}

sub _layoutRequest {
    my $c = shift;
    my $why = shift;
    $c->afterIdle([ '_arrange', $c ]) unless $c->{layout_pending};
    $c->{layout_pending} |= $why;
}

sub _arrange {
    my $c = shift;
    my $why = $c->{layout_pending};
  
    $c->{layout_pending} = 0;
  
    my $w     = $c->Width;
    my $h     = $c->Height;
    my $bw    = $c->cget('-borderwidth') + $c->cget('-highlightthickness');
    my $x     = abs(int($c->{Configure}{'-padx'})) + $bw;
    my $y     = abs(int($c->{Configure}{'-pady'})) + $bw;
    my $value = $c->cget('-variable');
    my $horz  = $c->{Configure}{'-anchor'} =~ /[ew]/i ? 1 : 0;
    my $dir   = $c->{Configure}{'-anchor'} =~ /[ne]/i ? -1 : 1;
  
    if ($w == 1 && $h == 1) {
	my $bw = $c->cget('-borderwidth');
	$h = $c->pixels($c->cget('-length')) || 40;
	$w = $c->pixels($c->cget('-width'))  || 20;
	
	($w, $h) = ($h, $w) if $horz;
	$c->GeometryRequest($w, $h);
	$c->parent->update;
	$c->update;
	
	$w = $c->Width;
	$h = $c->Height;
    }
  
    $w -= $x*2;
    $h -= $y*2;
  
    my $length = $horz ? $w : $h;
    my $width  = $horz ? $h : $w;
    # at this point we have the length and width of the
    # bar independent of orientation and padding.
    # blocks and gaps are not used.
  
    # unlike progressbar I need to redraw these each time.
    # actually resizing them might be better...
    my $colors = $c->{Configure}{'-colors'} || [ 'green', 'red', 'grey55' ];	
    $c->delete($c->find('all'));	
    $c->createRectangle(
        0, 0, $w+$x*2, $h+$y*2,
        -fill    => $c->{Configure}{'-troughcolor'},
        -width   => 0,
        -outline => undef
    );
    my $total;
    my $count_value = scalar(@$value)-1;
    foreach my $val (@$value) {
	$total += $val > 0 ? $val : 0;
    }
    # prevent div by zero and give a nice initial appearance.
    $total = $total ? $total : 1;
    my $curx = $x;
    my $cury = $y;
    foreach my $index (0..$count_value) {
	my $size = ($length*$value->[$index])/$total;
	my $ud = $horz?$width:$size;
	my $lr = $horz?$size:$width;
	$c->{cover}->[$index] = $c->createRectangle(
            $curx, $cury, $curx+$lr-1, $cury+$ud-1,
            -fill    => $colors->[$index],
            -width   => 1,
            -outline => 'black'
        );
	$curx+=$horz?$lr:0;
	$cury+=$horz?0:$ud;
    }
}

sub value {
    my $c = shift;
    my $val = $c->cget('-variable');
  
    if (@_) {
	$c->configure(-variable => [@_]);
	_layoutRequest($c, 2);
    }
}

sub Destroyed {
    my $c = shift;   
    my $var = delete $c->{'-variable'};
    untie $$var if defined($var) && ref($var);
}

1;
__END__


=head1 NAME

Test::Unit::TkTestRunner - unit testing framework helper class

=head1 SYNOPSIS

    use Test::Unit::TkTestRunner;
    Test::Unit::TkTestRunner::main($my_testcase_class);

=head1 DESCRIPTION

This class is the test runner for the GUI style use of the testing
framework.

It is used by simple command line tools like the F<TkTestRunner.pl>
script provided.

The class needs as arguments the names of the classes encapsulating
the tests to be run.

=head1 AUTHOR

Framework JUnit authored by Kent Beck and Erich Gamma.

Copyright (c) 2000 Brian Ewins.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Christian Lemburg, Cayte Lindner, J.E. Fritz, Zhon Johansen.

Thanks for patches go to:
David Esposito.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Loader>

=item *

L<Test::Unit::Listener>

=item *

L<Test::Unit::Result>

=item *

L<Test::Unit::TestRunner>

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::TestSuite>

=item *

For further examples, take a look at the framework self test
collection (t::tlib::AllTests).

=back

=cut
