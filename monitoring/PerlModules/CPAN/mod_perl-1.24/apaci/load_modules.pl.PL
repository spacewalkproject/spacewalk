#! /usr/local/bin/perl
use File::Find;
use strict;
my $APACHE_SRC = shift;

my $LoadModule_conf = "t/conf/LoadModule.conf";
my $tmp = "t/conf/httpd.conf.new";
my $orig = "t/conf/httpd.conf";

local *ORIG;
open ORIG, $orig or die "can't open $orig $!";
while(<ORIG>) {
    if(/^LoadModule/) {
	exit 0; #already cat-ed
    } 
}
unless (-d "t") {
    chdir "..";
}
#phooey, this mess should have been cleaned up before 1.3.0
my $name_map = {
    log_config => "config_log",
    include => "includes",
    actions => "action",
    auth_anon => "anon_auth",
    auth_dbm => "dbm_auth",
    log_agent => "agent_log",
    log_referer => "referer_log"
};

my @sh_mods = ();
finddepth(sub {
    return unless /(mod_|lib)(.*)\.s[ol]$/;
    my $name = $name_map->{$2} || $2;
    my $full = "$File::Find::dir/$_";
    if($full !~ m,^/,) {
	if($full =~ m,^\.\./,) {
	    $full = "../$full";
	}
    }
    return if $name =~ /(auth|autoindex|digest)/; #a few that screw make test
    push @sh_mods, "LoadModule ${name}_module $full";
}, $APACHE_SRC);

my($perl_mod) = grep /perl/, @sh_mods;
unshift @sh_mods, $perl_mod; #must come before mod_include/USE_PERL_SSI
  
local *FH;
open FH, ">$LoadModule_conf" or
    die "can't open $LoadModule_conf $!";
print FH join "\n", @sh_mods, "";
close FH;

system "cat $LoadModule_conf $orig > $tmp && mv $tmp $orig";

