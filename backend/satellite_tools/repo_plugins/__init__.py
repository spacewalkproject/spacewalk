#
# Copyright (c) 2008--2016 Red Hat, Inc.
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

import os
import sys
import re
import time
from Queue import Queue, Empty
from threading import Thread, Lock
try:
    #  python 2
    import urlparse
except ImportError:
    #  python3
    import urllib.parse as urlparse # pylint: disable=F0401,E0611
from urllib import quote
import pycurl
import rpm
from urlgrabber.grabber import URLGrabberOptions, PyCurlFileObject, URLGrabError
from spacewalk.common import rhn_pkg
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.server import rhnPackageUpload
from spacewalk.satellite_tools.syncLib import log, log2


class ProgressBarLogger:
    def __init__(self, msg, total):
        self.msg = msg
        self.total = total
        self.status = 0
        self.lock = Lock()

    def log(self, *_):
        self.lock.acquire()
        self.status += 1
        self._print_progress_bar(self.status, self.total, prefix=self.msg, bar_length=50)
        self.lock.release()

    # from here http://stackoverflow.com/questions/3173320/text-progress-bar-in-the-console
    # Print iterations progress
    @staticmethod
    def _print_progress_bar(iteration, total, prefix='', suffix='', decimals=2, bar_length=100):
        """
        Call in a loop to create terminal progress bar
        @params:
            iteration   - Required  : current iteration (Int)
            total       - Required  : total iterations (Int)
            prefix      - Optional  : prefix string (Str)
            suffix      - Optional  : suffix string (Str)
            decimals    - Optional  : number of decimals in percent complete (Int)
            bar_length   - Optional  : character length of bar (Int)
        """
        filled_length = int(round(bar_length * iteration / float(total)))
        percents = round(100.00 * (iteration / float(total)), decimals)
        bar_char = '#' * filled_length + '-' * (bar_length - filled_length)
        sys.stdout.write('\r%s |%s| %s%s %s' % (prefix, bar_char, percents, '%', suffix))
        sys.stdout.flush()
        if iteration == total:
            sys.stdout.write('\n')
            sys.stdout.flush()


class TextLogger:
    def __init__(self, _, total):
        self.total = total
        self.status = 0
        self.lock = Lock()

    def log(self, success, param):
        self.lock.acquire()
        self.status += 1
        if success:
            log(0, "%d/%d : %s" % (self.status, self.total, str(param)))
        else:
            log2(0, 0, "%d/%d : %s (failed)" % (self.status, self.total, str(param)), stream=sys.stderr)
        self.lock.release()


# Older versions of urlgrabber don't allow to set proxy parameters separately
# Simplified version from yumRepository class
def get_proxies(proxy, user, password):
    if not proxy:
        return {}
    proxy_string = proxy
    if user:
        auth = quote(user)
        if password:
            auth += ':' + quote(password)
        proto, rest = re.match(r'(\w+://)(.+)', proxy_string).groups()
        proxy_string = "%s%s@%s" % (proto, auth, rest)
    proxies = {'http': proxy_string, 'https': proxy_string, 'ftp': proxy_string}
    return proxies


class PyCurlFileObjectThread(PyCurlFileObject):
    def __init__(self, url, filename, opts, curl_cache):
        self.curl_cache = curl_cache
        PyCurlFileObject.__init__(self, url, filename, opts)

    def _do_open(self):
        self.curl_obj = self.curl_cache
        self.curl_obj.reset()
        self._set_opts()
        self._do_grab()
        return self.fo


class FailedDownloadError(Exception):
    pass


class DownloadThread(Thread):
    def __init__(self, parent):
        Thread.__init__(self)
        self.parent = parent
        # pylint: disable=E1101
        self.curl = pycurl.Curl()
        self.mirror = 0

    @staticmethod
    def __is_file_done(local_path=None, file_obj=None, checksum_type=None, checksum=None):
        if checksum_type and checksum:
            if local_path and os.path.isfile(local_path):
                return getFileChecksum(checksum_type, filename=local_path) == checksum
            elif file_obj:
                return getFileChecksum(checksum_type, file_obj=file_obj) == checksum
        if local_path and os.path.isfile(local_path):
            return True
        elif file_obj:
            return True
        return False

    def __can_retry(self, retry, mirrors, opts, url, e):
        retrycode = getattr(e, 'errno', None)
        code = getattr(e, 'code', None)
        if retry < (self.parent.retries - 1):
            # No codes at all or some specified codes
            # 58, 77 - Couple of curl error codes observed in multithreading on RHEL 7 - probably a bug
            if (retrycode is None and code is None) or (retrycode in opts.retrycodes or code in [58, 77]):
                log2(0, 2, "ERROR: Download failed: %s - %s. Retrying..." % (url, sys.exc_info()[1]),
                     stream=sys.stderr)
                return True

        # 14 - HTTP Error
        if retry < (mirrors - 1) and retrycode == 14:
            log2(0, 2, "ERROR: Download failed: %s - %s. Trying next mirror..." % (url, sys.exc_info()[1]),
                 stream=sys.stderr)
            return True

        log2(0, 1, "ERROR: Download failed: %s - %s." % (url, sys.exc_info()[1]),
             stream=sys.stderr)
        return False

    def __next_mirror(self, total):
        if self.mirror < (total - 1):
            self.mirror += 1
        else:
            self.mirror = 0

    def __fetch_url(self, params):
        # Skip existing file if exists and matches checksum
        if not self.parent.force:
            if self.__is_file_done(local_path=params['target_file'], checksum_type=params['checksum_type'],
                                   checksum=params['checksum']):
                return True

        opts = URLGrabberOptions(ssl_ca_cert=params['ssl_ca_cert'], ssl_cert=params['ssl_client_cert'],
                                 ssl_key=params['ssl_client_key'], range=params['bytes_range'],
                                 proxy=params['proxy'], username=params['proxy_username'],
                                 password=params['proxy_password'], proxies=params['proxies'])
        mirrors = len(params['urls'])
        for retry in max(range(self.parent.retries), mirrors):
            fo = None
            url = urlparse.urljoin(params['urls'][self.mirror], params['relative_path'])
            try:
                try:
                    fo = PyCurlFileObjectThread(url, params['target_file'], opts, self.curl)
                    # Check target file
                    if not self.__is_file_done(file_obj=fo, checksum_type=params['checksum_type'],
                                               checksum=params['checksum']):
                        raise FailedDownloadError("Target file isn't valid. Checksum should be %s (%s)."
                                                  % (params['checksum'], params['checksum_type']))
                    break
                except (FailedDownloadError, URLGrabError):
                    e = sys.exc_info()[1]
                    if not self.__can_retry(retry, mirrors, opts, url, e):
                        return False
                    self.__next_mirror(mirrors)

            finally:
                if fo:
                    fo.close()
                # Delete failed download file
                elif os.path.isfile(params['target_file']):
                    os.unlink(params['target_file'])

        return True

    def run(self):
        while not self.parent.queue.empty():
            try:
                params = self.parent.queue.get(block=False)
            except Empty:
                break
            self.mirror = 0
            success = self.__fetch_url(params)
            if self.parent.log_obj:
                # log_obj must be thread-safe
                self.parent.log_obj.log(success, os.path.basename(params['relative_path']))
            self.parent.queue.task_done()


class ThreadedDownloader:
    def __init__(self, retries=3, log_obj=None, force=False):
        self.queue = Queue()
        initCFG('server.satellite')
        self.threads = CFG.REPOSYNC_DOWNLOAD_THREADS
        self.retries = retries
        self.log_obj = log_obj
        self.force = force

    def set_log_obj(self, log_obj):
        self.log_obj = log_obj

    def set_force(self, force):
        self.force = force

    @staticmethod
    def _validate(ssl_ca_cert, ssl_cert, ssl_key):
        for certificate_file in (ssl_ca_cert, ssl_cert, ssl_key):
            if certificate_file and not os.path.isfile(certificate_file):
                log2(0, 0, "ERROR: Certificate file not found: %s" % certificate_file, stream=sys.stderr)
                return False
        return True

    def add(self, params):
        if self._validate(params['ssl_ca_cert'], params['ssl_client_cert'], params['ssl_client_key']):
            self.queue.put(params)

    def run(self):
        size = self.queue.qsize()
        if size <= 0:
            return
        log(1, "Downloading %s files." % str(size))
        started_threads = []
        for _ in range(self.threads):
            thread = DownloadThread(self)
            thread.setDaemon(True)
            thread.start()
            started_threads.append(thread)

        # wait to finish
        while any(t.isAlive() for t in started_threads):
            time.sleep(1)


class ContentPackage:

    def __init__(self):
        # map of checksums
        self.checksum_type = None
        self.checksum = None

        # unique ID that can be used by plugin
        self.unique_id = None

        self.name = None
        self.version = None
        self.release = None
        self.epoch = None
        self.arch = None

        self.path = None

        self.a_pkg = None

    def __cmp__(self, other):
        ret = cmp(self.name, other.name)
        if ret == 0:
            rel_self = str(self.release).split('.')[0]
            rel_other = str(other.release).split('.')[0]
            # pylint: disable=E1101
            ret = rpm.labelCompare((str(self.epoch), str(self.version), rel_self),
                                   (str(other.epoch), str(other.version), rel_other))
        if ret == 0:
            ret = cmp(self.arch, other.arch)
        return ret

    def getNRA(self):
        rel = re.match(".*?\\.(.*)",self.release)
        rel = rel.group(1)
        nra = str(self.name) + str(rel) + str(self.arch)
        return nra

    def setNVREA(self, name, version, release, epoch, arch):
        self.name = name
        self.version = version
        self.release = release
        self.arch = arch
        self.epoch = epoch

    def getNVREA(self):
        if self.epoch:
            return self.name + '-' + self.version + '-' + self.release + '-' + self.epoch + '.' + self.arch
        else:
            return self.name + '-' + self.version + '-' + self.release + '.' + self.arch

    def getNEVRA(self):
        if self.epoch is None:
            self.epoch = '0'
        return self.name + '-' + self.epoch + ':' + self.version + '-' + self.release + '.' + self.arch

    def load_checksum_from_header(self):
        if self.path is None:
            raise rhnFault(50, "Unable to load package", explain=0)
        self.a_pkg = rhn_pkg.package_from_filename(self.path)
        self.a_pkg.read_header()
        self.a_pkg.payload_checksum()
        self.a_pkg.input_stream.close()

    def upload_package(self, channel, metadata_only=False):
        if not metadata_only:
            rel_package_path = rhnPackageUpload.relative_path_from_header(
                self.a_pkg.header, channel['org_id'], self.a_pkg.checksum_type, self.a_pkg.checksum)
        else:
            rel_package_path = None
        _unused = rhnPackageUpload.push_package(self.a_pkg,
                                                force=False,
                                                relative_path=rel_package_path,
                                                org_id=channel['org_id'])
