#!/usr/bin/perl -w

use lib '.','./t','./blib/lib','../blib/lib';
# can run from here or distribution base

# Before installation is performed this script should be runnable with
# `perl test4.t time' which pauses `time' seconds (1..5) between pages

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..341\n"; }
END {print "not ok 1\n" unless $loaded;}
use AltPort 0.10;		# check inheritance & export
require "DefaultPort.pm";
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# tests start using file created by test1.t

use strict;

my $file = "/dev/ttyS0";
if ($SerialJunk::Makefile_Test_Port) {
    $file = $SerialJunk::Makefile_Test_Port;
}
if (exists $ENV{Makefile_Test_Port}) {
    $file = $ENV{Makefile_Test_Port};
}

my $naptime = 0;	# pause between output pages
if (@ARGV) {
    $naptime = shift @ARGV;
    unless ($naptime =~ /^[0-5]$/) {
	die "Usage: perl test?.t [ page_delay (0..5) ] [ /dev/ttyxx ]";
    }
}
if (@ARGV) {
    $file = shift @ARGV;
}

my $cfgfile = $file."_test.cfg";
$cfgfile =~ s/.*\///;

my $fault = 0;
my $tc = 2;		# next test number
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $blk;
my $err;
my $e;
my $patt;
my $instead;
my $tick;
my $tock;
my @necessary_param = AltPort->set_test_mode_active(1);

sub is_ok {
    my $result = shift;
    printf (($result ? "" : "not ")."ok %d\n",$tc++);
    return $result;
}

sub is_zero {
    my $result = shift;
    if (defined $result) {
        return is_ok ($result == 0);
    }
    else {
        printf ("not ok %d\n",$tc++);
    }
}

sub is_bad {
    my $result = shift;
    printf (($result ? "not " : "")."ok %d\n",$tc++);
    return (not $result);
}

# 2: Constructor

unless (is_ok ($ob = AltPort->start ($cfgfile))) {
    printf "could not open port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

#### 3 - 11: Check Port Capabilities Match Save

is_ok ($ob->baudrate == 9600);			# 3
is_ok ($ob->parity eq "none");			# 4
is_ok ($ob->databits == 8);			# 5
is_ok ($ob->stopbits == 1);			# 6
is_ok ($ob->handshake eq "none");		# 7
is_ok ($ob->read_const_time == 0);		# 8
is_ok ($ob->read_char_time == 0);		# 9
is_ok ($ob->alias eq "AltPort");		# 10
is_ok ($ob->parity_enable == 0);		# 11

#### 12 - 18: Application Parameter Defaults

is_ok ($ob->devicetype eq 'none');		# 12
is_ok ($ob->hostname eq 'localhost');		# 13
is_zero ($ob->hostaddr);			# 14
is_ok ($ob->datatype eq 'raw');			# 15
is_ok ($ob->cfg_param_1 eq 'none');		# 16
is_ok ($ob->cfg_param_2 eq 'none');		# 17
is_ok ($ob->cfg_param_3 eq 'none');		# 18

# 19 - 21: "Instant" return for read_xx_time=0

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 19
is_bad ($in2);					# 20
$out=$tock - $tick;
is_ok ($out < 150);				# 21
print "<0> elapsed time=$out\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

print "Beginning Timed Tests at 2-5 Seconds per Set\n";

# 22 - 25: 2 Second Constant Timeout

is_ok (2000 == $ob->read_const_time(2000));	# 22
$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 23
is_bad ($in2);					# 24
$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 25
print "<2000> elapsed time=$out\n";

# 26 - 29: 4 Second Timeout Constant+Character

is_ok (100 == $ob->read_char_time(100));	# 26

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(20);
$tock=$ob->get_tick_count;

is_zero ($in);					# 27
is_bad ($in2);					# 28
$out=$tock - $tick;
is_bad (($out < 3800) or ($out > 4400));	# 29
print "<4000> elapsed time=$out\n";


# 30 - 33: 3 Second Character Timeout

is_zero ($ob->read_const_time(0));		# 30

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(30);
$tock=$ob->get_tick_count;

is_zero ($in);					# 31
is_bad ($in2);					# 32
$out=$tock - $tick;
is_bad (($out < 2800) or ($out > 3400));	# 33
print "<3000> elapsed time=$out\n";

#### 34 - 64: Verify Parameter Settings

is_zero ($ob->read_char_time(0));		# 34

is_ok ("rts" eq $ob->handshake("rts"));		# 35
is_ok ($ob->purge_rx);				# 36 
is_ok ($ob->purge_all);				# 37 
is_ok ($ob->purge_tx);				# 38 

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(1 == $ob->user_msg);			# 39
is_zero(scalar $ob->user_msg(0));		# 40
is_ok(1 == $ob->user_msg(1));			# 41
is_ok(1 == $ob->error_msg);			# 42
is_zero(scalar $ob->error_msg(0));		# 43
is_ok(1 == $ob->error_msg(1));			# 44

print "Stty Shortcut Parameters\n";

my $vstart_1 = $ob->is_xon_char;
is_ok(defined $vstart_1);			# 45
my $vstop_1 = $ob->is_xoff_char;
is_ok(defined $vstop_1);			# 46
my $vintr_1 = $ob->is_stty_intr;
is_ok(defined $vintr_1);			# 47
my $vquit_1 = $ob->is_stty_quit;
is_ok(defined $vquit_1);			# 48

my $veof_1 = $ob->is_stty_eof;
is_ok(defined $veof_1);				# 49
my $veol_1 = $ob->is_stty_eol;
is_ok(defined $veol_1);				# 50
my $verase_1 = $ob->is_stty_erase;
is_ok(defined $verase_1);			# 51
my $vkill_1 = $ob->is_stty_kill;
is_ok(defined $vkill_1);			# 52
my $vsusp_1 = $ob->is_stty_susp;
is_ok(defined $vsusp_1);			# 53

is_zero $ob->stty_echo;				# 54
my $echoe_1 = $ob->stty_echoe;
is_ok(defined $echoe_1);			# 55
my $echok_1 = $ob->stty_echok;
is_ok(defined $echok_1);			# 56

is_zero $ob->stty_echonl;			# 57
is_zero $ob->stty_istrip;			# 58
is_zero $ob->stty_icrnl;			# 59
is_zero $ob->stty_igncr;			# 60

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero $ob->stty_inlcr;			# 61
is_zero $ob->stty_opost;			# 62
is_zero $ob->stty_isig;				# 63
is_zero $ob->stty_icanon;			# 64

print "Change all the parameters\n";

#### 65 - 102: Modify All Port Capabilities

is_ok ($ob->baudrate(1200) == 1200);		# 65
is_ok ($ob->parity("odd") eq "odd");		# 66
is_ok ($ob->databits(7) == 7);			# 67
is_ok ($ob->stopbits(2) == 2);			# 68
is_ok ($ob->handshake("xoff") eq "xoff");	# 69
is_ok ($ob->read_const_time(1000) == 1000);	# 70
is_ok ($ob->read_char_time(50) == 50);		# 71
is_ok ($ob->alias("oddPort") eq "oddPort");	# 72
is_ok (scalar $ob->parity_enable(1));		# 73
is_zero ($ob->user_msg(0));			# 74
is_zero ($ob->error_msg(0));			# 75

is_ok(64 == $ob->is_xon_char(64));		# 76
is_ok(65 == $ob->is_xoff_char(65));		# 77
is_ok(66 == $ob->is_stty_intr(66));		# 78
is_ok(67 == $ob->is_stty_quit(67));		# 79
is_ok(68 == $ob->is_stty_eof(68));		# 80
is_ok(69 == $ob->is_stty_eol(69));		# 81
is_ok(70 == $ob->is_stty_erase(70));		# 82

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(71 == $ob->is_stty_kill(71));		# 83
is_ok(72 == $ob->is_stty_susp(72));		# 84

is_ok($echoe_1 != $ob->stty_echoe(! $echoe_1));	# 85
is_ok($echok_1 != $ob->stty_echok(! $echok_1));	# 86
is_ok(1 == $ob->stty_echonl(1));		# 87
is_ok(1 == $ob->stty_istrip(1));		# 88
is_ok(1 == $ob->stty_icrnl(1));			# 89
is_ok(1 == $ob->stty_igncr(1));			# 90
is_ok(1 == $ob->stty_inlcr(1));			# 91
is_ok(1 == $ob->stty_opost(1));			# 92
is_ok(1 == $ob->stty_isig(1));			# 93
is_ok(1 == $ob->stty_icanon(1));		# 94
is_ok(1 == $ob->stty_echo(1));			# 95

is_ok ($ob->devicetype('type') eq 'type');	# 96
is_ok ($ob->hostname('any') eq 'any');		# 97
is_ok ($ob->hostaddr(9000) == 9000);		# 98
is_ok ($ob->datatype('fixed') eq 'fixed');	# 99
is_ok ($ob->cfg_param_1('p1') eq 'p1');		# 100
is_ok ($ob->cfg_param_2('p2') eq 'p2');		# 101
is_ok ($ob->cfg_param_3('p3') eq 'p3');		# 102

#### 103 - 140: Check Port Capabilities Match Changes

is_ok ($ob->baudrate == 1200);			# 103
is_ok ($ob->parity eq "odd");			# 104

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->databits == 7);			# 105
is_ok ($ob->stopbits == 2);			# 106
is_ok ($ob->handshake eq "xoff");		# 107
is_ok ($ob->read_const_time == 1000);		# 108
is_ok ($ob->read_char_time == 50);		# 109
is_ok ($ob->alias eq "oddPort");		# 110
is_ok (scalar $ob->parity_enable);		# 111
is_zero ($ob->user_msg);			# 112
is_zero ($ob->error_msg);			# 113

is_ok(64 == $ob->is_xon_char);			# 114
is_ok(65 == $ob->is_xoff_char);			# 115
is_ok(66 == $ob->is_stty_intr);			# 116
is_ok(67 == $ob->is_stty_quit);			# 117
is_ok(68 == $ob->is_stty_eof);			# 118
is_ok(69 == $ob->is_stty_eol);			# 119
is_ok(70 == $ob->is_stty_erase);		# 126
is_ok(71 == $ob->is_stty_kill);			# 121
is_ok(72 == $ob->is_stty_susp);			# 122

is_ok($echoe_1 != $ob->stty_echoe);		# 123
is_ok($echok_1 != $ob->stty_echok);		# 124
is_ok(1 == $ob->stty_echonl);			# 125

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(1 == $ob->stty_istrip);			# 126
is_ok(1 == $ob->stty_icrnl);			# 127
is_ok(1 == $ob->stty_igncr);			# 128
is_ok(1 == $ob->stty_inlcr);			# 129
is_ok(1 == $ob->stty_opost);			# 130
is_ok(1 == $ob->stty_isig);			# 131
is_ok(1 == $ob->stty_icanon);			# 132
is_ok(1 == $ob->stty_echo);			# 133

is_ok ($ob->devicetype eq 'type');		# 134
is_ok ($ob->hostname eq 'any');			# 135
is_ok ($ob->hostaddr == 9000);			# 136
is_ok ($ob->datatype eq 'fixed');		# 137
is_ok ($ob->cfg_param_1 eq 'p1');		# 138
is_ok ($ob->cfg_param_2 eq 'p2');		# 139
is_ok ($ob->cfg_param_3 eq 'p3');		# 140

print "Restore all the parameters\n";

is_ok ($ob->restart($cfgfile));			# 141

#### 142 - 179: Check Port Capabilities Match Original

is_ok ($ob->baudrate == 9600);			# 142
is_ok ($ob->parity eq "none");			# 143
is_ok ($ob->databits == 8);			# 144
is_ok ($ob->stopbits == 1);			# 145
is_ok ($ob->handshake eq "none");		# 146

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->read_const_time == 0);		# 147
is_ok ($ob->read_char_time == 0);		# 148
is_ok ($ob->alias eq "AltPort");		# 149
is_zero (scalar $ob->parity_enable);		# 150
is_ok ($ob->user_msg == 1);			# 151
is_ok ($ob->error_msg == 1);			# 152

is_ok($vstart_1 == $ob->is_xon_char);		# 153
is_ok($vstop_1 == $ob->is_xoff_char);		# 154
is_ok($vintr_1 == $ob->is_stty_intr);		# 155
is_ok($vquit_1 == $ob->is_stty_quit);		# 156
is_ok($veof_1 == $ob->is_stty_eof);		# 157
is_ok($veol_1 == $ob->is_stty_eol);		# 158
is_ok($verase_1 == $ob->is_stty_erase);		# 159
is_ok($vkill_1 == $ob->is_stty_kill);		# 160
is_ok($vsusp_1 == $ob->is_stty_susp);		# 161

is_ok(0 == $ob->stty_echo);			# 162
is_ok($echoe_1 == $ob->stty_echoe);		# 163
is_ok($echok_1 == $ob->stty_echok);		# 164
is_ok(0 == $ob->stty_echonl);			# 165
is_ok(0 == $ob->stty_istrip);			# 166

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0 == $ob->stty_icrnl);			# 167
is_ok(0 == $ob->stty_igncr);			# 168
is_ok(0 == $ob->stty_inlcr);			# 169
is_ok(0 == $ob->stty_opost);			# 170
is_ok(0 == $ob->stty_isig);			# 171
is_ok(0 == $ob->stty_icanon);			# 172

is_ok ($ob->devicetype eq 'none');		# 173
is_ok ($ob->hostname eq 'localhost');		# 174
is_zero ($ob->hostaddr);			# 175
is_ok ($ob->datatype eq 'raw');			# 176
is_ok ($ob->cfg_param_1 eq 'none');		# 177
is_ok ($ob->cfg_param_2 eq 'none');		# 178
is_ok ($ob->cfg_param_3 eq 'none');		# 179

#### 180 - 182: "Instant" return for read(0)

is_ok (2000 == $ob->read_const_time(2000));	# 180
$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(0);
$tock=$ob->get_tick_count;

is_bad (defined $in);				# 181
$out=$tock - $tick;
is_ok ($out < 100);				# 182
print "<0> elapsed time=$out\n";

### 183 - 198: Defaults for lookfor

@opts = $ob->are_match;
is_ok ($#opts == 0);				# 183
is_ok ($opts[0] eq "\n");			# 184
is_ok ($ob->lookclear == 1);			# 185
is_ok ($ob->lookfor eq "");			# 186
is_ok ($ob->streamline eq "");			# 187

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 188
is_ok ($out eq "");				# 189
is_ok ($patt eq "");				# 190
is_ok ($instead eq "");				# 191
is_ok ($ob->matchclear eq "");			# 192

is_ok ("" eq $ob->output_record_separator);		# 193
is_ok ("" eq $ob->output_record_separator("ab"));	# 194
is_ok ("ab" eq $ob->output_record_separator);		# 195
is_ok ("ab" eq $ob->output_record_separator(""));	# 196
is_ok ("" eq $ob->output_record_separator);		# 197
is_ok ("" eq $ob->output_field_separator);		# 198

@opts = $ob->are_match ("END","Bye");
is_ok ($#opts == 1);				# 199
is_ok ($opts[0] eq "END");			# 200
is_ok ($opts[1] eq "Bye");			# 201
is_ok ($ob->lookclear("Good Bye, Hello") == 1);	# 202
is_ok (1);					# 203
is_ok ($ob->lookfor eq "Good ");		# 204

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 205
is_ok ($out eq ", Hello");			# 206
is_ok ($patt eq "Bye");				# 207
is_ok ($instead eq "");				# 208
is_ok ($ob->matchclear eq "Bye");		# 209

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->matchclear eq "");			# 210
is_ok ($ob->lookclear("Bye, Bye, Love. The END has come") == 1);	# 211
is_ok ($ob->lookfor eq "");			# 212

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 213
is_ok ($out eq ", Bye, Love. The END has come");# 214

is_ok ($patt eq "Bye");				# 215
is_ok ($instead eq "");				# 216
is_ok ($ob->matchclear eq "Bye");		# 217

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 218
is_ok ($out eq ", Bye, Love. The END has come");# 219
is_ok ($patt eq "Bye");				# 220
is_ok ($instead eq "");				# 221

is_ok ($ob->lookfor eq ", ");			# 222
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 223
is_ok ($out eq ", Love. The END has come");	# 224
is_ok ($patt eq "Bye");				# 225
is_ok ($instead eq "");				# 226
is_ok ($ob->matchclear eq "Bye");		# 227

is_ok ($ob->lookfor eq ", Love. The ");		# 228
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 229
is_ok ($out eq " has come");			# 230
is_ok ($patt eq "END");				# 231

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($instead eq "");				# 232
is_ok ($ob->matchclear eq "END");		# 233
is_ok ($ob->lookfor eq "");			# 234
is_ok ($ob->matchclear eq "");			# 235

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 236
is_ok ($patt eq "");				# 237
is_ok ($instead eq " has come");		# 238

is_ok ($ob->lookclear("First\nSecond\nThe END") == 1);	# 239
is_ok ($ob->lookfor eq "First\nSecond\nThe ");	# 240
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 241
is_ok ($out eq "");				# 242
is_ok ($patt eq "END");				# 243
is_ok ($instead eq "");				# 244

is_ok ($ob->lookclear("Good Bye, Hello") == 1);	# 245
is_ok ($ob->streamline eq "Good ");		# 246

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 247
is_ok ($out eq ", Hello");			# 248
is_ok ($patt eq "Bye");				# 249
is_ok ($instead eq "");				# 250

is_ok ($ob->lookclear("Bye, Bye, Love. The END has come") == 1);	# 251
is_ok ($ob->streamline eq "");			# 252

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 253

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($out eq ", Bye, Love. The END has come");# 254
is_ok ($patt eq "Bye");				# 255
is_ok ($instead eq "");				# 256
is_ok ($ob->matchclear eq "Bye");		# 257

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 258
is_ok ($out eq ", Bye, Love. The END has come");# 259
is_ok ($patt eq "Bye");				# 260
is_ok ($instead eq "");				# 261

is_ok ($ob->streamline eq ", ");		# 262
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 263
is_ok ($out eq ", Love. The END has come");	# 264
is_ok ($patt eq "Bye");				# 265
is_ok ($instead eq "");				# 266
is_ok ($ob->matchclear eq "Bye");		# 267

is_ok ($ob->streamline eq ", Love. The ");	# 268
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 269
is_ok ($out eq " has come");			# 270
is_ok ($patt eq "END");				# 271
is_ok ($instead eq "");				# 272
is_ok ($ob->matchclear eq "END");		# 273
is_ok ($ob->streamline eq "");			# 274
is_ok ($ob->matchclear eq "");			# 275

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 276
is_ok ($patt eq "");				# 277
is_ok ($instead eq " has come");		# 278

is_ok ($ob->lookclear("First\nSecond\nThe END") == 1);	# 279
is_ok ($ob->streamline eq "First\nSecond\nThe ");	# 280
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 281
is_ok ($out eq "");				# 282
is_ok ($patt eq "END");				# 283
is_ok ($instead eq "");				# 284

# 257 - 303 Test and Normal "lookclear"

@opts = $ob->are_match("\n");
is_ok ($opts[0] eq "\n");			# 285
is_ok ($ob->lookclear("Before\nAfter") == 1);	# 286
is_ok ($ob->lookfor eq "Before");		# 287

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "\n");				# 288
is_ok ($out eq "After");			# 289
is_ok ($patt eq "\n");				# 290
is_ok ($instead eq "");				# 291

is_ok ($ob->lookfor eq "");			# 292
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 293
is_ok ($patt eq "");				# 294
is_ok ($instead eq "After");			# 295

@opts = $ob->are_match ("B*e","ab..ef","-re","12..56","END");
is_ok ($#opts == 4);				# 296
is_ok ($opts[2] eq "-re");			# 297

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->lookclear("Good Bye, the END, Hello") == 1);	# 298
is_ok ($ob->lookfor eq "Good Bye, the ");	# 299

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 300
is_ok ($out eq ", Hello");			# 301
is_ok ($patt eq "END");				# 302
is_ok ($instead eq "");				# 303

is_ok ($ob->lookclear("Good Bye, the END, Hello") == 1);	# 304
is_ok ($ob->streamline eq "Good Bye, the ");	# 305

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 306
is_ok ($out eq ", Hello");			# 307
is_ok ($patt eq "END");				# 308
is_ok ($instead eq "");				# 309

is_ok ($ob->lookclear("Good B*e, abcdef, 123456") == 1);	# 310
is_ok ($ob->lookfor eq "Good ");		# 311

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "B*e");				# 312
is_ok ($out eq ", abcdef, 123456");		# 313
is_ok ($patt eq "B*e");				# 314
is_ok ($instead eq "");				# 315

is_ok ($ob->lookfor eq ", abcdef, ");		# 316

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "123456");			# 317
is_ok ($out eq "");				# 318

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($patt eq "12..56");			# 319
is_ok ($instead eq "");				# 320
is_ok ($ob->lookclear("Good B*e, abcdef, 123456") == 1);	# 321
is_ok ($ob->streamline eq "Good ");		# 322

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "B*e");				# 323
is_ok ($out eq ", abcdef, 123456");		# 324
is_ok ($patt eq "B*e");				# 325
is_ok ($instead eq "");				# 326

is_ok ($ob->streamline eq ", abcdef, ");	# 327

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "123456");			# 328
is_ok ($out eq "");				# 329
is_ok ($patt eq "12..56");			# 330
is_ok ($instead eq "");				# 331

@necessary_param = AltPort->set_test_mode_active(0);

is_bad ($ob->lookclear("Good\nBye"));		# 332
is_ok ($ob->lookfor eq "");			# 333
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 334
is_ok ($out eq "");				# 335
is_ok ($patt eq "");				# 336

is_ok ("" eq $ob->output_field_separator(":"));	# 337
is_ok (":" eq $ob->output_field_separator);	# 338
is_ok (":" eq $ob->output_field_separator(""));	# 339
is_ok ("" eq $ob->output_field_separator);	# 340

is_ok ($ob->close);				# 341
undef $ob;
