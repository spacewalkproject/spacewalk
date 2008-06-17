#!/usr/local/bin/perl

package X;


use Class::MethodMaker
  abstract => [ qw / a b / ],
  abstract => 'c';

sub new { bless {}, shift; }

package Y;
use vars '@ISA';
@ISA = qw ( X );

package main;
use lib qw ( ./t );
use Test;

my $o = new Y;

TEST { 1 };
TEST {
  eval { $o->a } ;
  $@ =~ /\QCan't locate abstract method "a" declared in "X" via "Y"./ or
  $@ =~ /\QCan't locate abstract method "a" declared in "X", called from "Y"./;
};

exit 0;

