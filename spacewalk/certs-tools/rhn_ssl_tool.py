#!/usr/bin/python
#
# Copyright (c) 2008--2010 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
#
# RHN SSL Maintenance Tool (main module)
#     
# *NOTE*
# This module is intended to be imported and not run directly though it can
# be. At the time of this note, the excutable wrapping this module was
# /usr/bin/rhn-ssl-tool.
# 
# Generate and maintain SSL keys & certificates. One can also build RPMs in
# the RHN product context.
# 
# NOTE: this tool is geared for RHN product usage, but can be used outside of
# that context to some degree.
# 
# Author: Todd Warner <taw@redhat.com>
#
# $Id$


## language imports
import os
import sys
import glob
import pwd
import time
import string
import shutil
import getpass

## local imports
from sslToolCli import processCommandline, CertExpTooShortException, \
        CertExpTooLongException, InvalidCountryCodeException

from sslToolLib import RhnSslToolException, \
        gendir, chdir, getMachineName, fixSerial, TempDir, parseRPMFilename, \
        errnoGeneralError, errnoSuccess

from spacewalk.common.fileutils import rotateFile, rhn_popen, cleanupAbsPath, maketemp

from spacewalk.common.rhn_rpm import hdrLabelCompare, sortRPMs, get_package_header, \
        getInstalledHeader

from sslToolConfig import ConfigFile, figureSerial, getOption, CERT_PATH, \
        DEFS, MD, CRYPTO, LEGACY_SERVER_RPM_NAME1, LEGACY_SERVER_RPM_NAME2, \
        CA_OPENSSL_CNF_NAME, SERVER_OPENSSL_CNF_NAME, POST_UNINSTALL_SCRIPT, \
        SERVER_RPM_SUMMARY, CA_CERT_RPM_SUMMARY, BASE_SERVER_RPM_NAME


class GenPrivateCaKeyException(RhnSslToolException):
    """ private CA key generation error """
class GenPublicCaCertException(RhnSslToolException):
    """ public CA cert generation error """
class GenServerKeyException(RhnSslToolException):
    """ private server key generation error """
class GenServerCertReqException(RhnSslToolException):
    """ server cert request generation error """
class GenServerCertException(RhnSslToolException):
    """ server cert generation error """
class GenCaCertRpmException(RhnSslToolException):
    """ CA public certificate RPM generation error """
class GenServerRpmException(RhnSslToolException):
    """ server RPM generation error """
class GenServerTarException(RhnSslToolException):
    """ server tar archive generation error """
class FailedFileDependencyException(Exception):
    """ missing a file needed for this step """


def dependencyCheck(filename):
    if not os.path.exists(filename):
        raise FailedFileDependencyException(filename)


def pathJoin(path, filename):
    filename = os.path.basename(filename)
    return os.path.join(path, filename)


def legacyTreeFixup(d):
    """ move old server.* files to and "unknown" machinename directory
        Most of this is RHN Satellite 2.* and 3.* changes. Near the end
        we get to 3.6 changes.
    """

    topdir = cleanupAbsPath(d['--dir'])

    oldTree = '/etc/sysconfig/rhn/ssl'
    if topdir != oldTree and os.path.exists(oldTree):
        sys.stderr.write("""\
WARNING: %s
         still exists even though
         %s
         is the currently configured build tree. You may wish to either
         (a) move %s to
             %s, or
         (b) point directly at the old tree by via the --dir option.
""" % (oldTree, topdir, oldTree, topdir))
        sys.stderr.write("Pausing for 5 secs")
        for i in range(5):
            sys.stderr.write("."); time.sleep(1)
        sys.stderr.write("\n")

    unknown = os.path.join(topdir, 'unknown')
    server_rpm_name = os.path.basename(d.get('--server-rpm', ''))
    serverKeyPairDir = None
    if d.has_key('--set-hostname'):
        serverKeyPairDir = os.path.join(d['--dir'],
                                        getMachineName(d['--set-hostname']))

    while os.path.exists(unknown):
        # to avoid clashing with a possible "unknown" machinename
        unknown = unknown + '_'

    old_server_splat = os.path.join(topdir, 'server.')

    moveMessage = ""
    for ext in ('key', 'csr', 'crt'):
        if os.path.exists(old_server_splat+ext):
            gendir(unknown)
            files = glob.glob(old_server_splat+ext+'*')
            moved = []
            for f in files:
                # move the files to the "unknown" directory
                new_server_splat = os.path.join(unknown, os.path.basename(f))
                if not os.path.exists(new_server_splat):
                    shutil.copy2(f, new_server_splat)
                    os.unlink(f)
                    moved.append(f)

            #if files and verbosity:
            if moved:
                s = 'server.' + ext + '*'
                moveMessage = moveMessage + (
                  '  <BUILD_DIR>/%s --> <BUILD_DIR>/%s/%s\n'
                  % (s, os.path.basename(unknown), s))

    # move legacy server SSL RPMs. But if server_rpm_name is the same name
    # as the target RPM name, then we move the RPMs into the appropriate 
    # machine name directory.
    for name in [LEGACY_SERVER_RPM_NAME1, LEGACY_SERVER_RPM_NAME2]:
        old_server_rpms = glob.glob(os.path.join(topdir, name+'-*-*.*.rpm'))
        movedYN = 0
        for old_rpm in old_server_rpms:
            targetDir = unknown
            if parseRPMFilename(old_rpm)[0] == server_rpm_name and serverKeyPairDir:
                targetDir = serverKeyPairDir
            gendir(targetDir)
            # move the files to the targetDir directory
            new_rpm = os.path.join(targetDir, os.path.basename(old_rpm))
            if not os.path.exists(new_rpm):
                shutil.copy2(old_rpm, new_rpm)
                os.unlink(old_rpm)
                movedYN = 1
        if movedYN:
            s = name+'-*-*.{noarch,src}.rpm'
            moveMessage = moveMessage + """\
  <BUILD_DIR>/%s
      --> <BUILD_DIR>/%s/%s\n""" % (s, os.path.basename(targetDir), s)

    # I move the first 100 .pem files I find
    # if there is more than that... oh well
    movedYN = 0
    for i in range(100):
        serial = fixSerial(hex(i))
        oldPemPath = os.path.join(topdir, serial+'.pem')
        newPemPath = os.path.join(unknown, serial+'.pem')
        if os.path.exists(oldPemPath) and not os.path.exists(newPemPath):
            gendir(unknown)
            shutil.copy2(oldPemPath, newPemPath)
            os.unlink(oldPemPath)
            movedYN = 1
    if movedYN:
        moveMessage = moveMessage + (
          '  <BUILD_DIR>/HEX*.pem --> <BUILD_DIR>/%s/HEX*.pem\n'
          % os.path.basename(unknown))

    if moveMessage:
        sys.stdout.write('\nLegacy tree structured file(s) moved:\n%s'
                         % moveMessage)

    # move rhn-org-httpd-ssl-MACHINENAME-VERSION.*.rpm files to the
    # MACHINENAME directory! (an RHN 3.6.0 change)
    rootFilename = pathJoin(topdir, 'rhn-org-httpd-ssl-key-pair-')
    filenames = glob.glob(rootFilename+'*')
    for filename in filenames:
        # note: assuming version-rel is of that form.
        machinename = filename[len(rootFilename):]
        machinename = string.join(string.split(machinename, '-')[:-2], '-')
        serverKeySetDir = pathJoin(topdir, machinename)
        gendir(serverKeySetDir)
        fileto = pathJoin(serverKeySetDir, filename)
        if os.path.exists(fileto):
            rotateFile(filepath=fileto, verbosity=0)
        shutil.copy2(filename, fileto)
        os.unlink(filename)
        print """\
Moved (legacy tree cleanup):
    %s
    ...moved to...
    %s""" % (filename, fileto)


_workDirObj = None
def _getWorkDir():
    global _workDirObj
    if not _workDirObj:
        _workDirObj = TempDir()
    return _workDirObj.getdir()


def getCAPassword(options, confirmYN=1):
    global DEFS
    while not options.password:
        pw = _pw = None
        while not pw:
            pw = getpass.getpass("CA password: ")
        if confirmYN:
            while not _pw:
                _pw = getpass.getpass("CA password confirmation: ")
            if pw != _pw:
                print "Passwords do not match.\n"
                pw = None
        DEFS['--password'] = options.password = pw
    return options.password


def genPrivateCaKey(password, d, verbosity=0, forceYN=0):
    """ private CA key generation """

    gendir(d['--dir'])
    ca_key = os.path.join(d['--dir'], os.path.basename(d['--ca-key']))

    if not forceYN and os.path.exists(ca_key):
        sys.stderr.write("""\
ERROR: a CA private key already exists:
       %s
       If you wish to generate a new one, use the --force option.
""" % ca_key)
        sys.exit(errnoGeneralError)

    args = ("/usr/bin/openssl genrsa -passout pass:%s %s -out %s 2048"
            % ('%s', CRYPTO, repr(cleanupAbsPath(ca_key))))

    if verbosity >= 0:
        print "Generating private CA key: %s" % ca_key
        if verbosity > 1:
            print "Commandline:", args % "PASSWORD"
    try:
        rotated = rotateFile(filepath=ca_key, verbosity=verbosity)
        if verbosity>=0 and rotated:
            print "Rotated: %s --> %s" \
                  % (d['--ca-key'], os.path.basename(rotated))
    except ValueError:
        pass

    cwd = chdir(_getWorkDir())
    try:
        ret, out_stream, err_stream = rhn_popen(args % repr(password))
    finally:
        chdir(cwd)

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()
    if ret:
        raise GenPrivateCaKeyException("Certificate Authority private SSL "
                                       "key generation failed:\n%s\n%s"
                                       % (out, err))
    if verbosity > 2:
        if out:
            print "STDOUT:", out
        if err:
            print "STDERR:", err

    # permissions:
    os.chmod(ca_key, 0600)


def genPublicCaCert_dependencies(password, d, forceYN=0):
    """ public CA certificate (client-side) generation """

    gendir(d['--dir'])
    ca_key = os.path.join(d['--dir'], os.path.basename(d['--ca-key']))
    ca_cert = os.path.join(d['--dir'], os.path.basename(d['--ca-cert']))

    if not forceYN and os.path.exists(ca_cert):
        sys.stderr.write("""\
ERROR: a CA public certificate already exists:
       %s
       If you wish to generate a new one, use the --force option.
""" % ca_cert)
        sys.exit(errnoGeneralError)

    dependencyCheck(ca_key)

    if password is None:
        sys.stderr.write('ERROR: a CA password must be supplied.\n')
        sys.exit(errnoGeneralError)


def genPublicCaCert(password, d, verbosity=0, forceYN=0):
    """ public CA certificate (client-side) generation """

    ca_key = os.path.join(d['--dir'], os.path.basename(d['--ca-key']))
    ca_cert_name = os.path.basename(d['--ca-cert'])
    ca_cert = os.path.join(d['--dir'], ca_cert_name)
    ca_openssl_cnf = os.path.join(d['--dir'], CA_OPENSSL_CNF_NAME)

    genPublicCaCert_dependencies(password, d, forceYN)

    configFile = ConfigFile(ca_openssl_cnf)
    if d.has_key('--set-hostname'):
        del d['--set-hostname']
    configFile.save(d, caYN=1, verbosity=verbosity)

    args = ("/usr/bin/openssl req -passin pass:%s -text -config %s "
            "-new -x509 -days %s -%s -key %s -out %s"
            % ('%s', repr(cleanupAbsPath(configFile.filename)),
               repr(d['--cert-expiration']),
               MD, repr(cleanupAbsPath(ca_key)),
               repr(cleanupAbsPath(ca_cert))))

    if verbosity >= 0:
        print "\nGenerating public CA certificate: %s" % ca_cert
        print "Using distinguishing variables:"
        for k in ('--set-country', '--set-state', '--set-city', '--set-org',
                  '--set-org-unit', '--set-common-name', '--set-email'):
            print '    %s%s = "%s"' % (k, ' '*(18-len(k)), d[k])
        if verbosity > 1:
            print "Commandline:", args % "PASSWORD"

    try:
        rotated = rotateFile(filepath=ca_cert, verbosity=verbosity)
        if verbosity>=0 and rotated:
            print "Rotated: %s --> %s" \
                  % (d['--ca-cert'], os.path.basename(rotated))
    except ValueError:
        pass

    cwd = chdir(_getWorkDir())
    try:
        ret, out_stream, err_stream = rhn_popen(args % repr(password))
    finally:
        chdir(cwd)

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()
    if ret:
        raise GenPublicCaCertException("Certificate Authority public "
                                   "SSL certificate generation failed:\n%s\n"
                                   "%s" % (out, err))
    if verbosity > 2:
        if out:
            print "STDOUT:", out
        if err:
            print "STDERR:", err

    latest_txt = os.path.join(d['--dir'], 'latest.txt')
    fo = open(latest_txt, 'wb')
    fo.write('%s\n' % ca_cert_name)
    fo.close()

    # permissions:
    os.chmod(ca_cert, 0644)
    os.chmod(latest_txt, 0644)

def genServerKey(d, verbosity=0):
    """ private server key generation """

    serverKeyPairDir = os.path.join(d['--dir'],
                                    getMachineName(d['--set-hostname']))
    gendir(serverKeyPairDir)

    server_key = os.path.join(serverKeyPairDir,
                              os.path.basename(d['--server-key']))

    args = ("/usr/bin/openssl genrsa -out %s 2048"
            % (repr(cleanupAbsPath(server_key))))

    # generate the server key
    if verbosity >= 0:
        print "\nGenerating the web server's SSL private key: %s" % server_key
        if verbosity > 1:
            print "Commandline:", args

    try:
        rotated = rotateFile(filepath=server_key, verbosity=verbosity)
        if verbosity>=0 and rotated:
            print "Rotated: %s --> %s" % (d['--server-key'],
                                          os.path.basename(rotated))
    except ValueError:
        pass

    cwd = chdir(_getWorkDir())
    try:
        ret, out_stream, err_stream = rhn_popen(args)
    finally:
        chdir(cwd)

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()
    if ret:
        raise GenServerKeyException("web server's SSL key generation failed:\n%s\n%s"
                                % (out, err))
    if verbosity > 2:
        if out:
            print "STDOUT:", out
        if err:
            print "STDERR:", err

    # permissions:
    os.chmod(server_key, 0600)


def genServerCertReq_dependencies(d):
    """ private server cert request generation """

    serverKeyPairDir = os.path.join(d['--dir'],
                                    getMachineName(d['--set-hostname']))
    gendir(serverKeyPairDir)

    server_key = os.path.join(serverKeyPairDir,
                              os.path.basename(d['--server-key']))
    dependencyCheck(server_key)


def genServerCertReq(d, verbosity=0):
    """ private server cert request generation """

    serverKeyPairDir = os.path.join(d['--dir'],
                                    getMachineName(d['--set-hostname']))
    server_key = os.path.join(serverKeyPairDir,
                              os.path.basename(d['--server-key']))
    server_cert_req = os.path.join(serverKeyPairDir,
                                   os.path.basename(d['--server-cert-req']))
    server_openssl_cnf = os.path.join(serverKeyPairDir,
                                      SERVER_OPENSSL_CNF_NAME)

    genServerCertReq_dependencies(d)

    # XXX: hmm.. should private_key, etc. be set for this before the write?
    #      either that you pull the key/certs from the files all together?
    configFile = ConfigFile(server_openssl_cnf)
    if d.has_key('--set-common-name'):
        del d['--set-common-name']
    configFile.save(d, caYN=0, verbosity=verbosity)

    ## generate the server cert request
    args = ("/usr/bin/openssl req -%s -text -config %s -new -key %s -out %s "
            % (MD, repr(cleanupAbsPath(configFile.filename)),
               repr(cleanupAbsPath(server_key)),
               repr(cleanupAbsPath(server_cert_req))))

    if verbosity >= 0:
        print "\nGenerating web server's SSL certificate request: %s" % server_cert_req
        print "Using distinguished names:"
        for k in ('--set-country', '--set-state', '--set-city', '--set-org',
                  '--set-org-unit', '--set-hostname', '--set-email'):
            print '    %s%s = "%s"' % (k, ' '*(18-len(k)), d[k])
        if verbosity > 1:
            print "Commandline:", args

    try:
        rotated = rotateFile(filepath=server_cert_req, verbosity=verbosity)
        if verbosity>=0 and rotated:
            print "Rotated: %s --> %s" % (d['--server-cert-req'],
                                          os.path.basename(rotated))
    except ValueError:
        pass

    cwd = chdir(_getWorkDir())
    try:
        ret, out_stream, err_stream = rhn_popen(args)
    finally:
        chdir(cwd)

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()
    if ret:
        raise GenServerCertReqException(
                "web server's SSL certificate request generation "
                "failed:\n%s\n%s" % (out, err))
    if verbosity > 2:
        if out:
            print "STDOUT:", out
        if err:
            print "STDERR:", err

    # permissions:
    os.chmod(server_cert_req, 0600)


def genServerCert_dependencies(password, d):
    """ server cert generation and signing dependency check """

    if password is None:
        sys.stderr.write('ERROR: a CA password must be supplied.\n')
        sys.exit(errnoGeneralError)

    serverKeyPairDir = os.path.join(d['--dir'],
                                    getMachineName(d['--set-hostname']))
    gendir(serverKeyPairDir)

    ca_key = os.path.join(d['--dir'], os.path.basename(d['--ca-key']))
    ca_cert = os.path.join(d['--dir'], os.path.basename(d['--ca-cert']))

    server_cert_req = os.path.join(serverKeyPairDir,
                                   os.path.basename(d['--server-cert-req']))
    ca_openssl_cnf = os.path.join(d['--dir'], CA_OPENSSL_CNF_NAME)

    dependencyCheck(ca_openssl_cnf)
    dependencyCheck(ca_key)
    dependencyCheck(ca_cert)
    dependencyCheck(server_cert_req)


def genServerCert(password, d, verbosity=0):
    """ server cert generation and signing """

    serverKeyPairDir = os.path.join(d['--dir'],
                                    getMachineName(d['--set-hostname']))

    genServerCert_dependencies(password, d)

    ca_key = os.path.join(d['--dir'], os.path.basename(d['--ca-key']))
    ca_cert = os.path.join(d['--dir'], os.path.basename(d['--ca-cert']))

    server_cert_req = os.path.join(serverKeyPairDir,
                                   os.path.basename(d['--server-cert-req']))
    server_cert = os.path.join(serverKeyPairDir,
                               os.path.basename(d['--server-cert']))
    ca_openssl_cnf = os.path.join(d['--dir'], CA_OPENSSL_CNF_NAME)

    index_txt = os.path.join(d['--dir'], 'index.txt')
    serial = os.path.join(d['--dir'], 'serial')

    try:
        os.unlink(index_txt)
    except:
        pass

    # figure out the serial file and truncate the index.txt file.
    ser = figureSerial(ca_cert, serial, index_txt)

    # need to insure the directory declared in the ca_openssl.cnf
    # file is current:
    configFile = ConfigFile(ca_openssl_cnf)
    configFile.updateDir()

    args = ("/usr/bin/openssl ca -extensions req_server_x509_extensions -passin pass:%s -outdir ./ -config %s "
            "-in %s -batch -cert %s -keyfile %s -startdate %s -days %s "
            "-md %s -out %s"
            % ('%s', repr(cleanupAbsPath(ca_openssl_cnf)),
               repr(cleanupAbsPath(server_cert_req)),
               repr(cleanupAbsPath(ca_cert)),
               repr(cleanupAbsPath(ca_key)), d['--startdate'],
               repr(d['--cert-expiration']), MD,
               repr(cleanupAbsPath(server_cert))))

    if verbosity >= 0:
        print "\nGenerating/signing web server's SSL certificate: %s" % d['--server-cert']
        if verbosity > 1:
            print "Commandline:", args % 'PASSWORD'
    try:
        rotated = rotateFile(filepath=server_cert, verbosity=verbosity)
        if verbosity>=0 and rotated:
            print "Rotated: %s --> %s" % (d['--server-cert'],
                                          os.path.basename(rotated))
    except ValueError:
        pass

    cwd = chdir(_getWorkDir())
    try:
        ret, out_stream, err_stream = rhn_popen(args % repr(password))
    finally:
        chdir(cwd)

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()

    if ret:
        # signature for a mistyped CA password
        if string.find(err, "unable to load CA private key") != -1 \
          and string.find(err, "error:0906A065:PEM routines:PEM_do_header:bad decrypt:pem_lib.c") != -1 \
          and string.find(err, "error:06065064:digital envelope routines:EVP_DecryptFinal:bad decrypt:evp_enc.c") != -1:
            raise GenServerCertException(
                    "web server's SSL certificate generation/signing "
                    "failed:\nDid you mistype your CA password?")
        else:
            raise GenServerCertException(
                    "web server's SSL certificate generation/signing "
                    "failed:\n%s\n%s" % (out, err))

    if verbosity > 2:
        if out:
            print "STDOUT:", out
        if err:
            print "STDERR:", err

    # permissions:
    os.chmod(server_cert, 0644)

    # cleanup duplicate XX.pem file:
    pemFilename = os.path.basename(string.upper(ser)+'.pem')
    if pemFilename != server_cert and os.path.exists(pemFilename):
        os.unlink(pemFilename)

    # cleanup the old index.txt file
    try:
        os.unlink(index_txt + '.old')
    except:
        pass

    # cleanup the old serial file
    try:
        os.unlink(serial + '.old')
    except:
        pass


def gen_jabberd_cert(d):
    """
    generate the jabberd ssl cert from the server cert and key
    """

    serverKeyPairDir = os.path.join(d['--dir'], getMachineName(d['--set-hostname']))
    server_key  = os.path.join(serverKeyPairDir, d['--server-key'])
    server_cert = os.path.join(serverKeyPairDir, d['--server-cert'])

    dependencyCheck(server_key)
    dependencyCheck(server_cert)

    jabberd_ssl_cert_name = os.path.basename(d['--jabberd-ssl-cert'])
    jabberd_ssl_cert = os.path.join(serverKeyPairDir, jabberd_ssl_cert_name )

    # Create the jabberd cert - need to concatenate the cert and the key
    # XXX there really should be some better error propagation here
    fd = None
    try:
        fd = os.open(jabberd_ssl_cert, os.O_WRONLY | os.O_CREAT)
        _copy_file_to_fd(cleanupAbsPath(server_cert), fd)
        _copy_file_to_fd(cleanupAbsPath(server_key), fd)
    finally:
        if fd:
            os.close(fd)
    return


def _disableRpmMacros():
    mac = cleanupAbsPath('~/.rpmmacros')
    macTmp = cleanupAbsPath('~/RENAME_ME_BACK_PLEASE-lksjdflajsd.rpmmacros')
    if os.path.exists(mac):
        os.rename(mac, macTmp)

def _reenableRpmMacros():
    mac = cleanupAbsPath('~/.rpmmacros')
    macTmp = cleanupAbsPath('~/RENAME_ME_BACK_PLEASE-lksjdflajsd.rpmmacros')
    if os.path.exists(macTmp):
        os.rename(macTmp, mac)


def genCaRpm_dependencies(d):
    """ generates ssl cert RPM. """

    gendir(d['--dir'])
    ca_cert_name = os.path.basename(d['--ca-cert'])
    ca_cert = os.path.join(d['--dir'], ca_cert_name)
    dependencyCheck(ca_cert)


def genCaRpm(d, verbosity=0):
    """ generates ssl cert RPM. """

    ca_cert_name = os.path.basename(d['--ca-cert'])
    ca_cert = os.path.join(d['--dir'], ca_cert_name)
    ca_cert_rpm_name = os.path.basename(d['--ca-cert-rpm'])
    ca_cert_rpm = os.path.join(d['--dir'], ca_cert_rpm_name)

    genCaRpm_dependencies(d)

    if verbosity>=0:
        sys.stderr.write("\n...working...")
    # Work out the release number.
    hdr = getInstalledHeader(ca_cert_rpm)

    #find RPMs in the directory
    filenames = glob.glob("%s-*.noarch.rpm" % ca_cert_rpm)
    if filenames:
        filename = sortRPMs(filenames)[-1]
        h = get_package_header(filename)
        if hdr is None:
            hdr = h
        else:
            comp = hdrLabelCompare(h, hdr)
            if comp > 0:
                hdr = h

    epo, ver, rel = None, '1.0', '0'
    if hdr is not None:
        epo, ver, rel = hdr['epoch'], hdr['version'], hdr['release']

    # bump the release - and let's not be too smart about it
    #                    assume the release is a number.
    if rel:
        rel = str(int(rel)+1)

    # build the CA certificate RPM
    args = (os.path.join(CERT_PATH, 'gen-rpm.sh') + " "
            "--name %s --version %s --release %s --packager %s --vendor %s "
            "--group 'RHN/Security' --summary %s --description %s "
            "/usr/share/rhn/%s=%s"
            % (repr(ca_cert_rpm_name), ver, rel, repr(d['--rpm-packager']),
               repr(d['--rpm-vendor']), repr(CA_CERT_RPM_SUMMARY),
               repr(CA_CERT_RPM_SUMMARY), repr(ca_cert_name),
               repr(cleanupAbsPath(ca_cert))))
    clientRpmName = '%s-%s-%s' % (ca_cert_rpm, ver, rel)
    if verbosity >= 0:
        print """
Generating CA public certificate RPM:
    %s.src.rpm
    %s.noarch.rpm""" % (clientRpmName, clientRpmName)
        if verbosity > 1:
            print "Commandline:", args

    _disableRpmMacros()
    cwd = chdir(d['--dir'])
    try:
        ret, out_stream, err_stream = rhn_popen(args)
    except Exception:
        chdir(cwd)
        _reenableRpmMacros()
        raise
    chdir(cwd)
    _reenableRpmMacros()

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()

    if ret or not os.path.exists("%s.noarch.rpm" % clientRpmName):
        raise GenCaCertRpmException("CA public SSL certificate RPM generation "
                                "failed:\n%s\n%s" % (out, err))
    if verbosity > 2:
        if out:
            print "STDOUT:", out
        if err:
            print "STDERR:", err
    os.chmod('%s.noarch.rpm' % clientRpmName, 0644)

    # write-out latest.txt information
    latest_txt = os.path.join(d['--dir'], 'latest.txt')
    fo = open(latest_txt, 'wb')
    fo.write('%s\n' % ca_cert_name)
    fo.write('%s.noarch.rpm\n' % os.path.basename(clientRpmName))
    fo.write('%s.src.rpm\n' % os.path.basename(clientRpmName))
    fo.close()
    os.chmod(latest_txt, 0644)

    if verbosity >= 0:
        print """
Make the public CA certficate publically available:
    (NOTE: the RHN Satellite or Proxy installers may do this step for you.)
    The "noarch" RPM and raw CA certificate can be made publically accessible
    by copying it to the /var/www/html/pub directory of your RHN Satellite or
    Proxy server."""


    return '%s.noarch.rpm' % clientRpmName


def genProxyServerTarball_dependencies(d):
    """ dependency check for the step that generates the RHN Proxy Server's
        tar archive containing its SSL key set + CA certificate.
    """

    serverKeySetDir = os.path.join(d['--dir'],
                                    getMachineName(d['--set-hostname']))
    gendir(serverKeySetDir)

    ca_cert = pathJoin(d['--dir'], d['--ca-cert'])
    server_key = pathJoin(serverKeySetDir, d['--server-key'])
    server_cert = pathJoin(serverKeySetDir, d['--server-cert'])
    server_cert_req = pathJoin(serverKeySetDir, d['--server-cert-req'])
    jabberd_ssl_cert = pathJoin(serverKeySetDir, d['--jabberd-ssl-cert'])

    dependencyCheck(ca_cert)
    dependencyCheck(server_key)
    dependencyCheck(server_cert)
    dependencyCheck(server_cert_req)
    dependencyCheck(jabberd_ssl_cert)


def getTarballFilename(d, version='1.0', release='1'):
    """ figure out the current and next tar archive filename
        returns current, next (current can be None)
    """

    serverKeySetDir = pathJoin(d['--dir'], getMachineName(d['--set-hostname']))
    server_tar_name = pathJoin(serverKeySetDir, d['--server-tar'])

    filenames = glob.glob("%s-%s-*.tar" % (server_tar_name, version))
    filenames.sort() # tested to be reliable

    versions = map(lambda x, n=len(server_tar_name): x[n+1:-4], filenames)
    versions.sort()

    current = None
    if filenames:
        current = filenames[-1]

    next = "%s-%s-1.tar" % (server_tar_name, version)
    if current:
        v = string.split(versions[-1], '-')
        v[-1] = str(int(v[-1])+1)
        next = "%s-%s.tar" % (server_tar_name, string.join(v, '-'))
        current = os.path.basename(current)

    # incoming release (usually coming from RPM version) is factored in
    # ...if RPM version-release is greater then that is used.
    v = next[len(server_tar_name)+1:-4]
    v = string.split(v, '-')
    v[-1] = str(max(int(v[-1]), int(release)))
    next = "%s-%s.tar" % (server_tar_name, string.join(v, '-'))
    next = os.path.basename(next)

    return current, next


def genProxyServerTarball(d, version='1.0', release='1', verbosity=0):
    """ generates the RHN Proxy Server's tar archive containing its
        SSL key set + CA certificate
    """

    genProxyServerTarball_dependencies(d)

    tarballFilepath = getTarballFilename(d, version, release)[1]
    tarballFilepath = pathJoin(d['--dir'], tarballFilepath)

    machinename = getMachineName(d['--set-hostname'])
    ca_cert = os.path.basename(d['--ca-cert'])
    server_key = pathJoin(machinename, d['--server-key'])
    server_cert = pathJoin(machinename, d['--server-cert'])
    server_cert_req = pathJoin(machinename, d['--server-cert-req'])
    jabberd_ssl_cert = os.path.join(machinename, d['--jabberd-ssl-cert'])

    ## build the server tarball
    args = '/bin/tar -cvf %s %s %s %s %s %s' \
           % (repr(os.path.basename(tarballFilepath)), repr(ca_cert),
              repr(server_key), repr(server_cert), repr(server_cert_req),
              repr(jabberd_ssl_cert))

    serverKeySetDir = pathJoin(d['--dir'], machinename)
    tarballFilepath2 = pathJoin(serverKeySetDir, tarballFilepath)

    if verbosity >= 0:
        print """
The most current RHN Proxy Server installation process against RHN hosted
requires the upload of an SSL tar archive that contains the CA SSL public
certificate and the web server's key set.

Generating the web server's SSL key set and CA SSL public certificate archive:
    %s""" % tarballFilepath2

    cwd = chdir(d['--dir'])
    try:
        if verbosity > 1:
            print "Current working directory:", os.getcwd()
            print "Commandline:", args
        ret, out_stream, err_stream = rhn_popen(args)
    finally:
        chdir(cwd)

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()

    if ret or not os.path.exists(tarballFilepath):
        raise GenServerTarException(
	  "CA SSL public certificate & web server's SSL key set tar archive\n"
	  "generation failed:\n%s\n%s" % (out, err))
    if verbosity > 2:
        if out:
            print "STDOUT:", out
        if err:
            print "STDERR:", err

    # root baby!
    os.chmod(tarballFilepath, 0600)

    # copy tarball into machine build dir
    shutil.copy2(tarballFilepath, tarballFilepath2)
    os.unlink(tarballFilepath)
    if verbosity > 1:
        print """\
Moved to final home:
    %s
    ...moved to...
    %s""" % (tarballFilepath, tarballFilepath2)

    return tarballFilepath2


def genServerRpm_dependencies(d):
    """ generates server's SSL key set RPM - dependencies check """

    serverKeyPairDir = os.path.join(d['--dir'],
                                    getMachineName(d['--set-hostname']))
    gendir(serverKeyPairDir)

    server_key_name = os.path.basename(d['--server-key'])
    server_key = os.path.join(serverKeyPairDir, server_key_name)

    server_cert_name = os.path.basename(d['--server-cert'])
    server_cert = os.path.join(serverKeyPairDir, server_cert_name)

    server_cert_req_name = os.path.basename(d['--server-cert-req'])
    server_cert_req = os.path.join(serverKeyPairDir, server_cert_req_name)

    jabberd_ssl_cert_name = os.path.basename(d['--jabberd-ssl-cert'])
    jabberd_ssl_cert = os.path.join(serverKeyPairDir, jabberd_ssl_cert_name )

    dependencyCheck(server_key)
    dependencyCheck(server_cert)
    dependencyCheck(server_cert_req)

    # if all the other dependencies exist except the server pem, 
    # just generate it
    try:
        dependencyCheck(jabberd_ssl_cert)
    except FailedFileDependencyException:
        gen_jabberd_cert(d)

def genServerRpm(d, verbosity=0):
    """ generates server's SSL key set RPM """

    serverKeyPairDir = os.path.join(d['--dir'],
                                    getMachineName(d['--set-hostname']))

    server_key_name = os.path.basename(d['--server-key'])
    server_key = os.path.join(serverKeyPairDir, server_key_name)

    server_cert_name = os.path.basename(d['--server-cert'])
    server_cert = os.path.join(serverKeyPairDir, server_cert_name)

    server_cert_req_name = os.path.basename(d['--server-cert-req'])
    server_cert_req = os.path.join(serverKeyPairDir, server_cert_req_name)

    jabberd_ssl_cert_name = os.path.basename(d['--jabberd-ssl-cert'])
    jabberd_ssl_cert = os.path.join(serverKeyPairDir, jabberd_ssl_cert_name )

    server_rpm_name = os.path.basename(d['--server-rpm'])
    server_rpm = os.path.join(serverKeyPairDir, server_rpm_name)

    postun_scriptlet = os.path.join(d['--dir'], 'postun.scriptlet')

    genServerRpm_dependencies(d)

    if verbosity>=0:
        sys.stderr.write("\n...working...\n")
    # check for old installed RPM.
    oldHdr = getInstalledHeader(LEGACY_SERVER_RPM_NAME1)
    if oldHdr and LEGACY_SERVER_RPM_NAME1 != server_rpm_name:
        sys.stderr.write("""
** NOTE ** older-styled RPM installed (%s),
           it needs to be removed before installing the web server's RPM that
           is about to generated.
""" % LEGACY_SERVER_RPM_NAME1)

    if not oldHdr:
        oldHdr = getInstalledHeader(LEGACY_SERVER_RPM_NAME2)
        if oldHdr and LEGACY_SERVER_RPM_NAME2 != server_rpm_name:
            sys.stderr.write("""
** NOTE ** older-styled RPM installed (%s),
           it needs to be removed before installing the web server's RPM that
           is about to generated.
""" % LEGACY_SERVER_RPM_NAME2)

    # check for new installed RPM.
    # Work out the release number.
    hdr = getInstalledHeader(server_rpm_name)
    
    #find RPMs in the directory as well.
    filenames = glob.glob("%s-*.noarch.rpm" % server_rpm)
    if filenames:
        filename = sortRPMs(filenames)[-1]
        h = get_package_header(filename)
        if hdr is None:
            hdr = h
        else:
            comp = hdrLabelCompare(h, hdr)
            if comp > 0:
                hdr = h

    epo, ver, rel = None, '1.0', '0'
    if hdr is not None:
        epo, ver, rel = hdr['epoch'], hdr['version'], hdr['release']

    # bump the release - and let's not be too smart about it
    #                    assume the release is a number.
    if rel:
        rel = str(int(rel)+1)

    description = SERVER_RPM_SUMMARY + """
Best practices suggests that this RPM should only be installed on the web
server with this hostname: %s
""" % d['--set-hostname']

    # Determine which jabberd user exists:
    jabberd_user = None
    possible_jabberd_users = ['jabberd', 'jabber']
    for juser_attempt in possible_jabberd_users:
        try:
            pwd.getpwnam(juser_attempt)
            jabberd_user = juser_attempt
        except:
            # user doesn't exist, try the next
            pass
    if jabberd_user is None:
        print ("WARNING: No jabber/jabberd user on system, skipping " +
                "jabberd.pem generation.")
    
    jabberd_cert_string = ""
    if jabberd_user is not None:
        jabberd_cert_string = \
            "/etc/pki/spacewalk/jabberd/server.pem:0600,%s,%s=%s" % \
            (jabberd_user, jabberd_user, repr(cleanupAbsPath(jabberd_ssl_cert)))


    ## build the server RPM
    args = (os.path.join(CERT_PATH, 'gen-rpm.sh') + " "
            "--name %s --version %s --release %s --packager %s --vendor %s "
            "--group 'RHN/Security' --summary %s --description %s --postun %s "
            "/etc/httpd/conf/ssl.key/server.key:0600=%s "
            "/etc/httpd/conf/ssl.csr/server.csr=%s "
            "/etc/httpd/conf/ssl.crt/server.crt=%s "
            "%s"
            % (repr(server_rpm_name), ver, rel, repr(d['--rpm-packager']),
               repr(d['--rpm-vendor']),
               repr(SERVER_RPM_SUMMARY), repr(description),
               repr(cleanupAbsPath(postun_scriptlet)),
               repr(cleanupAbsPath(server_key)),
               repr(cleanupAbsPath(server_cert_req)),
               repr(cleanupAbsPath(server_cert)),
               jabberd_cert_string
               ))
    serverRpmName = "%s-%s-%s" % (server_rpm, ver, rel)

    if verbosity >= 0:
        print """
Generating web server's SSL key pair/set RPM:
    %s.src.rpm
    %s.noarch.rpm""" % (serverRpmName, serverRpmName)
        if verbosity > 1:
            print "Commandline:", args

    if verbosity >= 4:
        print 'Current working directory:', os.getcwd()
        print "Writing postun_scriptlet:", postun_scriptlet
    open(postun_scriptlet, 'w').write(POST_UNINSTALL_SCRIPT)

    _disableRpmMacros()
    cwd = chdir(serverKeyPairDir)
    try:
        ret, out_stream, err_stream = rhn_popen(args)
    finally:
        chdir(cwd)
        _reenableRpmMacros()
        os.unlink(postun_scriptlet)

    out = out_stream.read(); out_stream.close()
    err = err_stream.read(); err_stream.close()

    if ret or not os.path.exists("%s.noarch.rpm" % serverRpmName):
        raise GenServerRpmException("web server's SSL key set RPM generation "
                                    "failed:\n%s\n%s" % (out, err))
    if verbosity > 2:
        if out:
            print "STDOUT:", out
        if err:
            print "STDERR:", err

    os.chmod('%s.noarch.rpm' % serverRpmName, 0600)

    # generic the tarball necessary for RHN Proxy against hosted installations
    tarballFilepath = genProxyServerTarball(d, version=ver, release=rel,
                                            verbosity=verbosity)

    # write-out latest.txt information
    latest_txt = os.path.join(serverKeyPairDir, 'latest.txt')
    fo = open(latest_txt, 'wb')
    fo.write('%s.noarch.rpm\n' % os.path.basename(serverRpmName))
    fo.write('%s.src.rpm\n' % os.path.basename(serverRpmName))
    fo.write('%s\n' % os.path.basename(tarballFilepath))
    fo.close()
    os.chmod(latest_txt, 0600)

    if verbosity >= 0:
        print """
Deploy the server's SSL key pair/set RPM:
    (NOTE: the RHN Satellite or Proxy installers may do this step for you.)
    The "noarch" RPM needs to be deployed to the machine working as a
    web server, or RHN Satellite, or RHN Proxy.
    Presumably %s.""" % repr(d['--set-hostname'])

    return "%s.noarch.rpm" % serverRpmName

# Helper function
def _copy_file_to_fd(filename, fd):
    f = open(filename)
    buffer_size = 16384
    count = 0
    while 1:
        buf = f.read(buffer_size)
        if not buf:
            break
        os.write(fd, buf)
        count = count + len(buf)
    return count

def genServer_dependencies(password, d):
    """ deps for the general --gen-server command.
        I.e., generation of server.{key,csr,crt}.
    """

    ca_key_name = os.path.basename(d['--ca-key'])
    ca_key = os.path.join(d['--dir'], ca_key_name)
    ca_cert_name = os.path.basename(d['--ca-cert'])
    ca_cert = os.path.join(d['--dir'], ca_cert_name)

    dependencyCheck(ca_key)
    dependencyCheck(ca_cert)

    if password is None:
        sys.stderr.write('ERROR: a CA password must be supplied.\n')
        sys.exit(errnoGeneralError)


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def _main():
    """ main routine """

    options = processCommandline()

    legacyTreeFixup(DEFS)

    if getOption(options, 'gen_ca'):
        if getOption(options, 'key_only'):
            genPrivateCaKey(getCAPassword(options), DEFS,
                            options.verbose, options.force)
        elif getOption(options, 'cert_only'):
            genPublicCaCert_dependencies(getCAPassword(options), DEFS, options.force)
            genPublicCaCert(getCAPassword(options), DEFS,
                            options.verbose, options.force)
        elif getOption(options, 'rpm_only'):
            genCaRpm_dependencies(DEFS)
            genCaRpm(DEFS, options.verbose)
        else:
            genPrivateCaKey(getCAPassword(options), DEFS,
                            options.verbose, options.force)
            genPublicCaCert(getCAPassword(options), DEFS,
                            options.verbose, options.force)
            if not getOption(options, 'no_rpm'):
                genCaRpm(DEFS, options.verbose)

    if getOption(options, 'gen_server'):
        if getOption(options, 'key_only'):
            genServerKey(DEFS, options.verbose)
        elif getOption(options, 'cert_req_only'):
            genServerCertReq_dependencies(DEFS)
            genServerCertReq(DEFS, options.verbose)
        elif getOption(options, 'cert_only'):
            genServerCert_dependencies(getCAPassword(options, confirmYN=0), DEFS)
            genServerCert(getCAPassword(options, confirmYN=0), DEFS, options.verbose)
        elif getOption(options, 'rpm_only'):
            genServerRpm_dependencies(DEFS)
            genServerRpm(DEFS, options.verbose)
        else:
            genServer_dependencies(getCAPassword(options, confirmYN=0), DEFS)
            genServerKey(DEFS, options.verbose)
            genServerCertReq(DEFS, options.verbose)
            genServerCert(getCAPassword(options, confirmYN=0), DEFS, options.verbose)
            gen_jabberd_cert(DEFS)
            if not getOption(options, 'no_rpm'):
                genServerRpm(DEFS, options.verbose)


def main():
    """ main routine wrapper (exception handler)

          1  general error

         10  private CA key generation error
         11  public CA certificate generation error
         12  public CA certificate RPM build error
     
         20  private web server key generation error
         21  public web server certificate request generation error
         22  public web server certificate generation error
         23  web server key pair/set RPM build error

         30  Certificate expiration too short exception
         31  Certificate expiration too long exception
             (integer in days
              range: 1 to # days til 1 year before the 32-bit overflow)
         32  country code length cannot exceed 2
         33  missing file created in previous step

        100  general RHN SSL tool error
    """

    def writeError(e):
        sys.stderr.write('\nERROR: %s\n' % e)

    ret = 0
    try:
        ret = _main() or 0
    # CA key set errors
    except GenPrivateCaKeyException, e:
        writeError(e)
        ret = 10
    except GenPublicCaCertException, e:
        writeError(e)
        ret = 11
    except GenCaCertRpmException, e:
        writeError(e)
        ret = 12
    # server key set errors
    except GenServerKeyException, e:
        writeError(e)
        ret = 20
    except GenServerCertReqException, e:
        writeError(e)
        ret = 21
    except GenServerCertException, e:
        writeError(e)
        ret = 22
    except GenServerRpmException, e:
        writeError(e)
        ret = 23
    # other errors
    except CertExpTooShortException, e:
        writeError(e)
        ret = 30
    except CertExpTooLongException, e:
        writeError(e)
        ret = 31
    except InvalidCountryCodeException, e:
        writeError(e)
        ret = 32
    except FailedFileDependencyException, e:
        # already wrote a nice error message
        msg = """\
can't find a file that should have been created during an earlier step:
       %s

       %s --help""" % (e, os.path.basename(sys.argv[0]))
        writeError(msg)
        ret = 33
    except RhnSslToolException, e:
        writeError(e)
        ret = 100

    return ret

#-------------------------------------------------------------------------------
if __name__ == "__main__":
    sys.stderr.write('\nWARNING: intended to be wrapped by another executable\n'
                     '           calling program.\n')
    sys.exit(abs(main() or errnoSuccess))
#===============================================================================

