#!/usr/local/bin/perl

package myArray;
use Tie::Array ;

@ISA=qw/Tie::StdArray/ ;

use vars qw/$prefix/ ;

$prefix = '';

sub TIEARRAY {
  my $class = shift; 
  my $p = shift || '';
  #print "prefix $p ($prefix))\n";
  $prefix .= $p;
  return bless [], $class ;
}

sub FETCH { my ($self, $idx) = @_ ; 
            #print "fetching $idx...\n";
            return $prefix.$self->[$idx];}

sub STORE { my ($self, $idx, $value) = @_ ; 
            #print "storing $idx, $value ...\n";
            $self->[$idx]=$value;
            return $value;}

package X ;
use ExtUtils::testlib;

use Class::MethodMaker
  tie_list => 
  [
   a => ['myArray', "my "],
   ['b','c'] => ['myArray']
  ],
  new => 'new';

package main;
use ExtUtils::testlib;

use lib qw ( ./t );
use Test;
use Data::Dumper ;
my $o = new X;

TEST { 1 };
TEST {$o->a(qw/0 1 2/)} ;
TEST {$o->b(qw/1 2 3 4/)} ;
TEST {$o->c(qw/a s d f/)} ;

my @r = $o->a ;

#print Dumper $o ;

TEST { $r[1] eq "my 1" };

TEST {$o->b_shift == 1}; # SHIFT not overloaded in myArray
TEST {$o->c_count == 4};

exit 0;

