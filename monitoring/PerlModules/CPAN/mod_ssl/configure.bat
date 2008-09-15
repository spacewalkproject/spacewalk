@rem = '--*-CPerl-*--
@echo off
perl -x -S %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
@rem ';
#!perl -w
#line 8
##
##  configure.bat -- mod_ssl configuration script (Win32 version)
##
##  ====================================================================
##  Copyright (c) 1998-2000 Ralf S. Engelschall. All rights reserved.
## 
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions
##  are met:
## 
##  1. Redistributions of source code must retain the above copyright
##     notice, this list of conditions and the following disclaimer. 
## 
##  2. Redistributions in binary form must reproduce the above copyright
##     notice, this list of conditions and the following
##     disclaimer in the documentation and/or other materials
##     provided with the distribution.
## 
##  3. All advertising materials mentioning features or use of this
##     software must display the following acknowledgment:
##     "This product includes software developed by 
##      Ralf S. Engelschall <rse@engelschall.com> for use in the
##      mod_ssl project (http://www.modssl.org/)."
## 
##  4. The names "mod_ssl" must not be used to endorse or promote
##     products derived from this software without prior written
##     permission. For written permission, please contact
##     rse@engelschall.com.
## 
##  5. Products derived from this software may not be called "mod_ssl"
##     nor may "mod_ssl" appear in their names without prior
##     written permission of Ralf S. Engelschall.
## 
##  6. Redistributions of any form whatsoever must retain the following
##     acknowledgment:
##     "This product includes software developed by 
##      Ralf S. Engelschall <rse@engelschall.com> for use in the
##      mod_ssl project (http://www.modssl.org/)."
## 
##  THIS SOFTWARE IS PROVIDED BY RALF S. ENGELSCHALL ``AS IS'' AND ANY
##  EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
##  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
##  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL RALF S. ENGELSCHALL OR
##  HIS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
##  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
##  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
##  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
##  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
##  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
##  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
##  OF THE POSSIBILITY OF SUCH DAMAGE.
##  ====================================================================
##

                             # ``Perl: The only language you can
                             #   uuencode and not notice.''
                             #              -- Unknown

require 5.003;
use strict;

#
#   configuration
#
my $prefix  = ' +';
my $prefixo = '   o';
my $prefixe = '    ';
my $apache  = '';
my $ssl     = '';
my $patch   = 'etc\patch.exe';

(my $progname = $0) =~ s|.*[/\\]||;

#
#   determine versions and give a friendly header
#
open(FP, '<pkg.sslmod\libssl.version');
my $v = <FP>;
$v =~ s|\n||;
close(FP);
my ($V_MODSSL, $V_APACHE) = ($v =~ m|^.*/(.+?)-(.+?)$|);
my $V_MODSSL_NUM;
if ($V_MODSSL =~ m|(\d+).(\d+)b(\d+)|) {
    $V_MODSSL_NUM = sprintf("%d%02d0%02d", $1, $2, $3);
}
if ($V_MODSSL =~ m|(\d+).(\d+)\.(\d+)|) {
    $V_MODSSL_NUM = sprintf("%d%02d1%02d", $1, $2, $3);
}

#
#   parse argument line
#
my $arg;
my $usage = 0;
my $help = 0;
my $verbose = 0;
my $i;
#   fix Windows brain dead %X parsing which replaced the "=" chars
for ($i = 0; $i < $#ARGV; $i++) {
    if ($ARGV[$i] =~ m/^--with-(apache|ssl|ssleay|patch)$/) {
        $ARGV[$i] .= "=" . splice(@ARGV, $i+1, 1);
    }
}
foreach $arg (@ARGV) {
    if ($arg =~ m|--with-apache=(\S+)|) {
        $apache = $1;
        $apache =~ s|/|\\|g;
        next;
    }
    elsif ($arg =~ m|--with-ssl(?:eay)?=(\S+)|) {
        $ssl = $1;
        $ssl =~ s|/|\\|g;
        next;
    }
    elsif ($arg =~ m|--with-patch=(\S+)|) {
        $patch = $1;
        $patch =~ s|/|\\|g;
        next;
    }
    elsif ($arg eq '--help') {
        $help = 1;
        last;
    }
    elsif ($arg eq '--verbose' or $arg eq '-v') {
        $verbose = 1;
        last;
    }
    $usage = 1;
    last;
}
$usage = 1 if ($#ARGV == -1);
$usage = 1 if ($apache eq '');
$usage = 1 if ($ssl eq '');
if ($usage) {
    print STDERR "$progname: Bad argument line\n";
    print STDERR "$progname: Usage: $progname [options]\n";
    $help  = 1;
}
if ($help) {
    print STDERR "Options are:\n";
    print STDERR "  --with-apache=DIR  ...path to Apache 1.3.x source tree    [REQUIRED]\n";
    print STDERR "  --with-ssl=DIR     ...path to OpenSSL source tree         [REQUIRED]\n";
    print STDERR "  --with-patch=FILE  ...path to your vendor 'patch' program [OPTIONAL]\n";
    print STDERR "  --help             ...this message                        [OPTIONAL]\n";
    print STDERR "  --verbose          ...configure with verbosity            [OPTIONAL]\n";
    exit(1);
}

#
#   give a friendly header
#
print "Configuring mod_ssl/$V_MODSSL for Apache/$V_APACHE\n";

#
#   check for Apache 1.3
#
if (not -f "$apache\\src\\include\\httpd.h") {
    print STDERR "$progname:Error: Cannot find Apache 1.3 source tree under $apache\n";
    print STDERR "$progname:Hint:  Please specify location via --with-apache=DIR\n";
    exit(1);
}
open(FP, "<$apache\\src\\include\\httpd.h");
my $data = '';
$data .= $_ while(<FP>);
close(FP);
my ($APV) = ($data =~ m|SERVER_BASEREVISION\s+\"(\d+\.\d+[.b]\d+).*?\"|);
if ($V_APACHE ne $APV) {
    print STDERR "Error: The mod_ssl/$V_MODSSL can be used for Apache/$V_APACHE only.\n";
    print STDERR "Error: Your Apache source tree under $apache is version $APV.\n";
    print STDERR "Hint:  Please use an extracted apache_$V_APACHE.tar.gz tarball\n";
    print STDERR "Hint:  with the --with-apache option, only.\n";
    exit(1);
}
print "$prefix Apache location: $apache (Version $APV)\n";

#
#   check for OpenSSL
#
if (not ((    -f "$ssl\\include\\openssl\\ssl.h" 
          and -f "$ssl\\lib\\libeay32.lib" 
          and -f "$ssl\\lib\\ssleay32.lib"      ) or
         (    -f "$ssl\\inc32\\openssl\\ssl.h" 
          and -f "$ssl\\out32dll\\libeay32.lib" 
          and -f "$ssl\\out32dll\\ssleay32.lib"      ) or
         (    -f "$ssl\\inc32\\openssl\\ssl.h" 
          and -f "$ssl\\out32lib\\libeay32.lib" 
          and -f "$ssl\\out32lib\\ssleay32.lib"      ))) {
    print STDERR "Error: Cannot find OpenSSL source or install tree under $ssl\n";
    print STDERR "Hint:  Please specify location via --with-ssl=DIR\n";
    exit(1);
}
print "$prefix OpenSSL location: $ssl\n"; 

#
#   Apply patches
#
print "$prefix Applying packages to Apache source tree:\n";

#
#   Applying: Extended API
#
print "$prefixo Extended API (EAPI)\n";
open(FP, "$patch --forward --directory=$apache <pkg.eapi\\eapi.patch |") || die "$!";
my $line;
while (defined($line = <FP>)) {
    if ($line =~ m/^\|Index:\s+(\S+).*/) {
        my $f = $1;
        $f =~ s|/|\\|g;
        print "$prefixe patching: [FILE] $f\n" if ($verbose);
    }
    if ($line =~ m/saving rejects to file/) {
        print STDERR "Error: Failed to apply patches to Apache source tree\n";
        exit(1);
    }
}
close(FP);
print "$prefixe creating: [FILE] src\\README.EAPI\n" if ($verbose);
system("copy /b pkg.eapi\\README.EAPI $apache\\src\\README.EAPI >nul:");
print "$prefixe creating: [FILE] src\\ap\\ap_hook.c\n" if ($verbose);
system("copy /b pkg.eapi\\ap_hook.c $apache\\src\\ap\\ap_hook.c >nul:");
print "$prefixe creating: [FILE] src\\ap\\ap_ctx.c\n" if ($verbose);
system("copy /b pkg.eapi\\ap_ctx.c $apache\\src\\ap\\ap_ctx.c >nul:");
print "$prefixe creating: [FILE] src\\ap\\ap_mm.c\n" if ($verbose);
system("copy /b pkg.eapi\\ap_mm.c $apache\\src\\ap\\ap_mm.c >nul:");
print "$prefixe creating: [FILE] src\\include\\ap_hook.h\n" if ($verbose);
system("copy /b pkg.eapi\\ap_hook.h $apache\\src\\include\\ap_hook.h >nul:");
print "$prefixe creating: [FILE] src\\include\\ap_ctx.h\n" if ($verbose);
system("copy /b pkg.eapi\\ap_ctx.h $apache\\src\\include\\ap_ctx.h >nul:");
print "$prefixe creating: [FILE] src\\include\\ap_mm.h\n" if ($verbose);
system("copy /b pkg.eapi\\ap_mm.h $apache\\src\\include\\ap_mm.h >nul:");

#
#   Applying: Distribution Documents
#
print "$prefixo Distribution Documents\n";
my $f;
foreach $f ('README', 'LICENSE', 'INSTALL') {
    print "$prefixe creating: [FILE] $f.SSL\n" if ($verbose);
    system("copy /b $f $apache\\$f.SSL >nul:");
}
print "$prefixe creating: [FILE] src\\CHANGES.SSL\n" if ($verbose);
system("copy /b CHANGES $apache\\src\\CHANGES.SSL >nul:");

#
#   Applying: SSL Module Source
#
print "$prefixo SSL Module Source\n";
open(FP, "$patch --forward --directory=$apache <pkg.sslmod\\sslmod.patch |") || die "$!";
while (defined($line = <FP>)) {
    if ($line =~ m/^\|Index:\s+(\S+).*/) {
        my $f = $1;
        $f =~ s|/|\\|g;
        print "$prefixe patching: [FILE] $f\n" if ($verbose);
    }
}
close(FP);
if (not -d "$apache\\src\\modules\\ssl") {
    print "$prefixe creating: [DIR]  modules\\ssl\n" if ($verbose);
    system("md $apache\\src\\modules\\ssl");
}
print "$prefixe creating: [FILE] modules\\ssl\\Makefile\n" if ($verbose);
open(SRC, "<pkg.sslmod\\Makefile.win32") or die "$!";
open(DST, ">$apache\\src\\modules\\ssl\\Makefile") or die "$!";
while (<SRC>) {
    s|^(SSL_INC\s*)=.*|$1=$ssl\\include|g;
    s|^(SSL_LIB\s*)=.*|$1=$ssl\\lib|g;
    s|^(MOD_SSL_VERS_NUM\s*)=.*|$1=$V_MODSSL_NUM|g;
    s|^(MOD_SSL_VERS_STR\s*)=.*|$1=$V_MODSSL|g;
    print DST $_;
}
close(SRC);
close(DST);
my @F = glob("pkg.sslmod\\*");
foreach $f (@F) {
    my $b = $f;
    $b =~ s|^pkg.sslmod\\||;
    next if ($b =~ m|^Makefile\..+|);
    print "$prefixe creating: [FILE] src\\modules\\ssl\\$b\n" if ($verbose);
    system("copy /b pkg.sslmod\\$b $apache\\src\\modules\\ssl >nul:");
}

#
#   Applying: SSL Support
#
print "$prefixo SSL Support\n";
open(FP, "$patch --forward --directory=$apache <pkg.sslsup\\sslsup.patch |") || die "$!";
while (defined($line = <FP>)) {
    if ($line =~ m/^\|Index:\s+(\S+).*/) {
        my $f = $1;
        $f =~ s|/|\\|g;
        print "$prefixe patching: [FILE] $f\n" if ($verbose);
    }
}
close(FP);
print "$prefixe creating: [FILE] src\\support\\mkcert.sh\n" if ($verbose);
system("copy /b pkg.sslsup\\mkcert.sh $apache\\src\\support\\mkcert.sh >nul:");

#
#   Applying: SSL Configuration Additions
#
print "$prefixo SSL Configuration Additions\n";
open(FP, "$patch --forward --directory=$apache <pkg.sslcfg\\sslcfg.patch |") || die "$!";
while (defined($line = <FP>)) {
    if ($line =~ m/^\|Index:\s+(\S+).*/) {
        my $f = $1;
        $f =~ s|/|\\|g;
        print "$prefixe patching: [FILE] $f\n" if ($verbose);
    }
}
close(FP);
if (not -d "$apache\\conf\\ssl.crt") {
    print "$prefixe creating: [DIR]  conf\\ssl.crt\n" if ($verbose);
    system("md $apache\\conf\\ssl.crt");
}
print "$prefixe creating: [FILE] conf\\ssl.crt\\README.CRT\n" if ($verbose);
system("copy /b pkg.sslcfg\\README.CRT $apache\\conf\\ssl.crt\\README.CRT >nul:");
print "$prefixe creating: [FILE] conf\\ssl.crt\\Makefile\n" if ($verbose);
system("copy /b pkg.sslcfg\\Makefile.crt $apache\\conf\\ssl.crt\\Makefile >nul:");
print "$prefixe creating: [FILE] conf\\ssl.crt\\ca-bundle.crt\n" if ($verbose);
system("copy /b pkg.sslcfg\\ca-bundle.crt $apache\\conf\\ssl.crt\\ca-bundle.crt >nul:");
print "$prefixe creating: [FILE] conf\\ssl.crt\\snakeoil-ca-rsa.crt\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-ca-rsa.crt $apache\\conf\\ssl.crt\\snakeoil-ca-rsa.crt >nul:");
print "$prefixe creating: [FILE] conf\\ssl.crt\\snakeoil-ca-dsa.crt\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-ca-dsa.crt $apache\\conf\\ssl.crt\\snakeoil-ca-dsa.crt >nul:");
print "$prefixe creating: [FILE] conf\\ssl.crt\\snakeoil-rsa.crt\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-rsa.crt $apache\\conf\\ssl.crt\\snakeoil-rsa.crt >nul:");
print "$prefixe creating: [FILE] conf\\ssl.crt\\snakeoil-dsa.crt\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-dsa.crt $apache\\conf\\ssl.crt\\snakeoil-dsa.crt >nul:");
print "$prefixe creating: [FILE] conf\\ssl.crt\\server.crt\n" if ($verbose);
system("copy /b pkg.sslcfg\\server.crt $apache\\conf\\ssl.crt\\server.crt >nul:");
if (not -d "$apache\\conf\\ssl.csr") {
    print "$prefixe creating: [DIR]  conf\\ssl.csr\n" if ($verbose);
    system("md $apache\\conf\\ssl.csr");
}
print "$prefixe creating: [FILE] conf\\ssl.csr\\README.CSR\n" if ($verbose);
system("copy /b pkg.sslcfg\\README.CSR $apache\\conf\\ssl.csr\\README.CSR >nul:");
print "$prefixe creating: [FILE] conf\\ssl.csr\\server.csr\n" if ($verbose);
system("copy /b pkg.sslcfg\\server.csr $apache\\conf\\ssl.csr\\server.csr >nul:");
if (not -d "$apache\\conf\\ssl.prm") {
    print "$prefixe creating: [DIR]  conf\\ssl.prm\n" if ($verbose);
    system("md $apache\\conf\\ssl.prm");
}
print "$prefixe creating: [FILE] conf\\ssl.prm\\README.PRM\n" if ($verbose);
system("copy /b pkg.sslcfg\\README.PRM $apache\\conf\\ssl.prm\\README.PRM >nul:");
print "$prefixe creating: [FILE] conf\\ssl.csr\\snakeoil-ca-dsa.prm\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-ca-dsa.prm $apache\\conf\\ssl.prm\\snakeoil-ca-dsa.prm >nul:");
print "$prefixe creating: [FILE] conf\\ssl.csr\\snakeoil-dsa.prm\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-dsa.prm $apache\\conf\\ssl.prm\\snakeoil-dsa.prm >nul:");
if (not -d "$apache\\conf\\ssl.crl") {
    print "$prefixe creating: [DIR]  conf\\ssl.crl\n" if ($verbose);
    system("md $apache\\conf\\ssl.crl");
}
print "$prefixe creating: [FILE] conf\\ssl.crl\\Makefile\n" if ($verbose);
system("copy /b pkg.sslcfg\\Makefile.crl $apache\\conf\\ssl.crl\\Makefile >nul:");
print "$prefixe creating: [FILE] conf\\ssl.crl\\README.CRL\n" if ($verbose);
system("copy /b pkg.sslcfg\\README.CRL $apache\\conf\\ssl.crl\\README.CRL >nul:");
if (not -d "$apache\\conf\\ssl.key") {
    print "$prefixe creating: [DIR]  conf\\ssl.key\n" if ($verbose);
    system("md $apache\\conf\\ssl.key");
}
print "$prefixe creating: [FILE] conf\\ssl.key\\README.KEY\n" if ($verbose);
system("copy /b pkg.sslcfg\\README.KEY $apache\\conf\\ssl.key\\README.KEY >nul:");
print "$prefixe creating: [FILE] conf\\ssl.key\\snakeoil-ca-rsa.key\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-ca-rsa.key $apache\\conf\\ssl.key\\snakeoil-ca-rsa.key >nul:");
print "$prefixe creating: [FILE] conf\\ssl.key\\snakeoil-ca-dsa.key\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-ca-dsa.key $apache\\conf\\ssl.key\\snakeoil-ca-dsa.key >nul:");
print "$prefixe creating: [FILE] conf\\ssl.key\\snakeoil-rsa.key\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-rsa.key $apache\\conf\\ssl.key\\snakeoil-rsa.key >nul:");
print "$prefixe creating: [FILE] conf\\ssl.key\\snakeoil-dsa.key\n" if ($verbose);
system("copy /b pkg.sslcfg\\snakeoil-dsa.key $apache\\conf\\ssl.key\\snakeoil-dsa.key >nul:");
print "$prefixe creating: [FILE] conf\\ssl.key\\server.key\n" if ($verbose);
system("copy /b pkg.sslcfg\\server.key $apache\\conf\\ssl.key\\server.key >nul:");

#
#   Applying: SSL Module Documentation
#
print "$prefixo SSL Module Documentation\n";
open(FP, "$patch --forward --directory=$apache <pkg.ssldoc\\ssldoc.patch |") || die "$!";
while (defined($line = <FP>)) {
    if ($line =~ m/^\|Index:\s+(\S+).*/) {
        my $f = $1;
        $f =~ s|/|\\|g;
        print "$prefixe patching: [FILE] $f\n" if ($verbose);
    }
}
close(FP);
if (not -d "$apache\\htdocs\\manual\\mod\\mod_ssl") {
    print "$prefixe creating: [DIR]  htdocs\\manual\\mod\mod_ssl\n" if ($verbose);
    system("md $apache\\htdocs\\manual\\mod\\mod_ssl");
}
@F = glob("pkg.ssldoc\\ssl_*");
push(@F, "pkg.ssldoc\\index.html");
foreach $f (@F) {
    my $b = $f;
    $b =~ s|^pkg.ssldoc\\||;
    print "$prefixe creating: [FILE] htdocs\\manual\\mod\\mod_ssl\\$b\n" if ($verbose);
    system("copy /b pkg.ssldoc\\$b $apache\\htdocs\\manual\\mod\\mod_ssl >nul:");
}
print "$prefixe creating: [FILE] htdocs\\manual\\images\\apache_pb.gif\n" if ($verbose);
system("copy /b pkg.ssldoc\\apache_pb.gif $apache\\htdocs\\manual\\images\\apache_pb.gif >nul:");
print "$prefixe creating: [FILE] htdocs\\manual\\images\\feather.jpg\n" if ($verbose);
system("copy /b pkg.ssldoc\\feather.jpg $apache\\htdocs\\manual\\images\\feather.jpg >nul:");
print "$prefixe creating: [FILE] htdocs\\manual\\images\\mod_ssl_sb.gif\n" if ($verbose);
system("copy /b pkg.ssldoc\\mod_ssl_sb.gif $apache\\htdocs\\manual\\images\\mod_ssl_sb.gif >nul:");
print "$prefixe creating: [FILE] htdocs\\manual\\images\\openssl_ics.gif\n" if ($verbose);
system("copy /b pkg.ssldoc\\openssl_ics.gif $apache\\htdocs\\manual\\images\\openssl_ics.gif >nul:");

#
#   Applying: Addons
#
print "$prefixo Addons\n";
open(FP, "$patch --forward --directory=$apache <pkg.addon\\addon.patch |") || die "$!";
while (defined($line = <FP>)) {
    if ($line =~ m/^\|Index:\s+(\S+).*/) {
        my $f = $1;
        $f =~ s|/|\\|g;
        print "$prefixe patching: [FILE] $f\n" if ($verbose);
    }
}
print "$prefixe creating: [FILE] src\\modules\\extra\\mod_define.c\n";
system("copy /b pkg.addon\\mod_define.c $apache\\src\\modules\\extra\\mod_define.c >nul:");
print "$prefixe creating: [FILE] htdocs\\manual\\mod\\mod_define.html\n";
system("copy /b pkg.addon\\mod_define.html $apache\\htdocs\\manual\\mod\\mod_define.html >nul:");

#
#   Apply: Win32 DevStudio-generated Makefiles
#
print "$prefixo DevStudio Makefiles\n";
print "$prefixe patching: [FILE] src\\Makefile.nt\n" if ($verbose);
open(FP, "<$apache\\src\\Makefile.nt") || die "$!";
$data = '';
$data .= $_ while (<FP>);
close(FP);
$data =~ s|(\n\s+)(cd modules\\proxy\s*\n[^\n]+ApacheModuleProxy\.mak\n)|$1cd modules\\ssl$1nmake /nologo all$1cd ..\\..$1$2|s;
$data =~ s|(\n\s+)(copy modules\\proxy\\.*)|$1copy modules\\ssl\\ApacheModuleSSL.dll \$\(INSTDIR\)\\modules$1$2|s;
$data =~ s|(\n\s+)(cd modules\\proxy\s*\n[^\n]+ApacheModuleProxy\.mak\s+clean\n)|$1cd modules\\ssl$1nmake /nologo clean$1cd ..\\..$1$2|s;
open(FP, ">$apache\\src\\Makefile.nt") || die "$!";
print FP $data;
close(FP);
sub patch_mak {
    my ($ssl_base, $apache_base, $mak) = @_;
    my ($data, $src_base);

    #   display action
    print "$prefixe patching: [FILE] src\\$mak\n" if ($verbose);

    #   determine relative path to Apache src dir
    $src_base = '';
    my @s = split(/\\/, $mak);
    $src_base = "..\\" x $#s;
    $src_base =~ s|\\$||;
    $src_base = "." if ($src_base eq "");

    #   read Makefile
    open(FP, "<$apache_base\\src\\$mak") || die "$!";
    $data = '';
    $data .= $_ while (<FP>);
    close(FP);

    #   write backup file
    open(FP, ">$apache_base\\src\\$mak.orig") || die "$!";
    print FP $data;
    close(FP);
    
    #   patch Makefile
    $data =~ s|^(CPP_PROJ\s*)=|$1=/DEAPI /DMOD_SSL=$V_MODSSL_NUM |mg;
    
    #   write Makefile
    open(FP, ">$apache_base\\src\\$mak") || die "$!";
    print FP $data;
    close(FP);
}
my $mak;
foreach $mak (qw(
    Apache.mak
    ApacheCore.mak
    ap\ap.mak
    main\gen_test_char.mak
    main\gen_uri_delims.mak
    modules\proxy\ApacheModuleProxy.mak
    os\win32\ApacheModuleAuthAnon.mak
    os\win32\ApacheModuleCERNMeta.mak
    os\win32\ApacheModuleDigest.mak
    os\win32\ApacheModuleExpires.mak
    os\win32\ApacheModuleHeaders.mak
    os\win32\ApacheModuleInfo.mak
    os\win32\ApacheModuleRewrite.mak
    os\win32\ApacheModuleSpeling.mak
    os\win32\ApacheModuleStatus.mak
    os\win32\ApacheModuleUserTrack.mak
    os\win32\ApacheOS.mak
    os\win32\MakeModuleMak.mak
    regex\regex.mak
)) {
    patch_mak($ssl, $apache, $mak);
}

#
#   Final message
#
print "Done: source extension and patches successfully applied.\n";

#
#   Final hints
#
print "\n";
print "Now proceed with the following commands:\n";
print " \$ cd $apache\\src\n";
print " \$ nmake /f Makefile.nt\n";
print " \$ nmake /f Makefile.nt installr\n";
print "\n";

exit(0);

__END__
:endofperl

