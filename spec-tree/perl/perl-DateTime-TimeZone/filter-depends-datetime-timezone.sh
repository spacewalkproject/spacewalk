#!/bin/sh

/usr/lib/rpm/perl.req $* | grep -v 'perl(DateTime)' | grep -v 'perl(DateTime::Duration)' | grep -v 'perl(DateTime::TimeZoneCatalog)'
