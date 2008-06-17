#!/usr/bin/perl

use strict;

use NOCpulse::TSDB::LocalQueue::test::Enqueuer;

NOCpulse::TSDB::LocalQueue::test::Enqueuer::run(@ARGV);

