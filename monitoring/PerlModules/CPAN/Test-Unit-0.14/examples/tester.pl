#!/usr/bin/perl
#
# Copyright (C) 2000 Brian Ewins
# XML::Parser::PerlSAX is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# $Id: tester.pl,v 1.1 2002-03-01 01:18:20 rmcchesney Exp $
#

use Tk;
my $runner=new Test::TkRunner(@ARGV);
MainLoop;

package Test::TkRunner;
use Tk;
use Test::SuiteWrapper;
use Benchmark;
use strict;

# The pass,fail, error methods are up front here 'cos they're
# the ones that are callbacks for the test suite. The rest of them
# are pretty much ignorable.
# Not quite right yet. The callback interfaces dont use
# the TestResult object so they dont do much interesting, 
# and anyway I can't get Tk::DialogBox to do the right thing.
# Also stop quits instead of cancelling, and theres no visual
# indication of whether the tests are still running.
# Finally, SuiteWrapper is used directly, instead of being called
# by a loader, this needs changed so things like XUnit can be
# tacked on.

sub plan{
  my $self=shift;
  my ($max)=@_;
}
sub pass {
  my $self=shift;
  my ($msg,$detail)=@_;
  $self->{'passes'}++;
  $self->update();
}

sub fail {
  my $self=shift;
  $self->add_message(@_);
  $self->{'failures'}++;
  $self->update();
}

sub error {
  my $self=shift;
  my ($msg,$detail)=@_;
  $self->add_message(@_);
  $self->{'errors'}++;
  $self->update();
}

# Normal methods follow...
sub new {
  my $self=bless {}, shift;
  # fill in the test name from the command line if possible.
  $self->{'testname'}=shift; 
  map {$self->{$_}=0} qw(runs errors failures passes cancel start history_size);
  $self->{'history'}=[];
  # Lay the window out....
  $self->{'mw'}=MainWindow->new(-title=>'PerlUnit Test Harness');
  $self->{'history_list'}=$self->{'mw'}->
    BrowseEntry(-label=>"Test name",
		-width=>30,
		-variable=>\$self->{'testname'},
		-listcmd=> sub {$self->populate_history();});
  $self->{'history_list'}->grid(-row=>0,-column=>0,-columnspan=>4);
  $self->{'mw'}->Button(-text => "Run",
		-command => sub {$self->run()}
	       )->
		 grid(-row=>0,-column=>4);
  $self->{'mw'}->LabEntry(-label=>'Runs:',-text=> \$self->{'runs'},
		  -state=>'disabled',-width=>5, -relief=>'flat')->
		    grid(-row=>1,-column=>0);
  $self->{'mw'}->LabEntry(-label=>'Passed:',-text=>\$self->{'status'},
		  -state=>'disabled',-width=>10, -relief=>'flat')->
		    grid(-row=>1,-column=>1);
  $self->{'mw'}->LabEntry(-label=>'Failures:',-text=>\$self->{'failures'},
		  -state=>'disabled',-width=>5, -relief=>'flat')->
		    grid(-row=>2,-column=>0);
  $self->{'mw'}->LabEntry(-label=>'Errors:',-text=>\$self->{'errors'},
		  -state=>'disabled',-width=>5, -relief=>'flat')->
		    grid(-row=>2,-column=>1);
  $self->{'mw'}->LabEntry(-label=>'Elapsed Time:',-text=>\$self->{'elapsed'},
		  -state=>'disabled',-width=>35, -relief=>'flat')->
		    grid(-row=>1,-column=>2,-columnspan=>2);
  # There is no gauge control. Make do by having a 
  # coloured rectangle on a Tk::Canvas.
  $self->{'gauge'}=$self->{'mw'}->Canvas(-width=>200,-height=>20,
		       -relief=>"sunken",-borderwidth=>2);
  $self->{'gauge'}->createRectangle(4,4,200,20,-fill=>'red');
  $self->{'gauge'}->createRectangle(4,4,100,20,-fill=>'green',-tag=>'passes');
  $self->{'gauge'}->
    grid(-row=>2,-column=>2,-columnspan=>2);
  $self->{'list'}=$self->{'mw'}->
    Scrolled('Listbox',-scrollbars=>'e',-width=>50,-height=>10)->
      grid(-row=>3,-column=>0,-columnspan=>5);
  $self->{'mw'}->Button(-text => 'Stop',
			-command => [$self->{'mw'} => 'destroy']
		       )->
			 grid(-row=>4,-column=>0);
  $self->{'mw'}->Button(-text => 'View Details',
			-command => sub {$self->view_details()}
		       )->
			 grid(-row=>4,-column=>2);
  $self->{'mw'}->Button(-text => 'Quit',
			-command => [$self->{'mw'} => 'destroy']
		       )->
			 grid(-row=>4,-column=>4);
  return $self;
}  

sub add_message {
  my $self=shift;
  my ($msg,$detail)=@_;
  $self->{'list'}->insert("end",$msg);
  push @{$self->{'detail'}},$detail;
}

sub clear_messages {
  my $self=shift;
  $self->{'list'}->delete(0,"end");
  $self->{'detail'}=[];
}


sub update {
  my $self=shift;
  my ($ratio,$percent,$total);
  my $total=0;
  map { $total+=$self->{$_}} qw(passes failures errors);
  if ($total==0) {
    $ratio=0.5;
  } else {
    $ratio=$self->{'passes'}/$total;
  }
  $self->{'status'}=$self->{'passes'}."/$total, ".(int(100*$ratio))."%";
  $self->{'gauge'}->delete('passes');
  $self->{'gauge'}->createRectangle(4,4,200*$ratio,
			  20,-fill=>'green',-tag=>'passes');
  $self->{'elapsed'}=timestr(timediff(new Benchmark(),$self->{'start'}),'nop');
  #sleep 1;
  # force entry into the event loop.
  # this makes it nearly like its threaded...
  die "Cancelled" if $self->{'cancel'};
  $self->{'mw'}->update();
}

sub run {
  my $self=shift;
  # if the test just run isn't the one at the top of the list,
  # then add it.
  $self->{'history'}=[$self->{'testname'},
		      grep { $_ ne $self->{'testname'}} 
		      (@{$self->{'history'}})[0..9]];
  $self->{'runs'}++;
  map {$self->{$_}=0} qw(errors failures passes cancel);
  $self->clear_messages();
  $self->{'start'}=new Benchmark();
  $self->update();
  $self->{'suite'}=new Test::SuiteWrapper($self->{'testname'});
  $self->{'suite'}->add_listener($self);
  $self->{'suite'}->run();
  $self->update();
}

sub populate_history {
  my $self=shift;
  my $h=$self->{'history_list'};
  $h->delete(0,$self->{'history_size'});
  foreach (@{$self->{'history'}}) {
    $h->insert("end",$_);
  }
  $self->{'history_size'}=scalar @{$self->{'history'}};
}

sub view_details {
  # pop up a text dialog containing the details.
  my $self=shift;
  my $dialog=$self->{'mw'}->Dialog(-title=>'Details',-buttons=>['OK'],
				    -text=>'Tk:DialogBox disnae wurk');
  $dialog->Show();
}

sub fake_tests {
  my $self=shift;
  # fake some tests
  # this simulates a test suite calling its listener.
  $self->pass();
  $self->pass();
  $self->fail("Failed test 1","Detail");
  $self->fail("Failed test 2","Detail");
  $self->fail("Failed test 3","Detail");
  $self->fail("Failed test 4","Detail");
  $self->error("Error in test 1","Detail");
  $self->error("Error in test 2","Detail");
  $self->error("Error in test 3","Detail");
  $self->pass();
  $self->pass();
  $self->fail("Failed test 1","Detail");
  $self->fail("Failed test 2","Detail");
  $self->fail("Failed test 3","Detail");
  $self->fail("Failed test 4","Detail");
  $self->error("Error in test 1","Detail");
  $self->error("Error in test 2","Detail");
  $self->error("Error in test 3","Detail");
  $self->pass();
  $self->pass();
  $self->fail("Failed test 1","Detail");
  $self->fail("Failed test 2","Detail");
  $self->fail("Failed test 3","Detail");
  $self->fail("Failed test 4","Detail");
  $self->error("Error in test 1","Detail");
  $self->error("Error in test 2","Detail");
  $self->error("Error in test 3","Detail");
  $self->error("Error in test 4","Detail");
  $self->update();
}
