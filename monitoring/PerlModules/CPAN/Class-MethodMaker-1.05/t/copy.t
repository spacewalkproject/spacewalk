#!/usr/local/bin/perl

package X;

use Class::MethodMaker
  get_set  => [qw/ a b /],
  copy     => 'copy';

sub new { bless {}, shift; }

package main;
use lib qw ( ./t );
use Test;

my $o = new X;

TEST { 1 };
TEST { $o->a ('foo') eq 'foo' };
TEST { $c = $o->copy; };
TEST { $c->a eq 'foo' };
TEST { $c->a ('bar') eq 'bar' };
TEST { $o->a eq 'foo' };
TEST { $o->a ('baz') eq 'baz' };
TEST { $c->a eq 'bar' };

exit 0;

