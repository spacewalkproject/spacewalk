#
# Copyright (c) 2018 Red Hat, Inc.
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
from urlgrabber.grabber import URLGrabberOptions, PyCurlFileObject, URLGrabError
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhnConfig import CFG, initCFG
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
            log(0, "    %d/%d : %s" % (self.status, self.total, str(param)))
        else:
            log2(0, 0, "    %d/%d : %s (failed)" % (self.status, self.total, str(param)), stream=sys.stderr)
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
    def __init__(self, url, filename, opts, curl_cache, parent):
        self.curl_cache = curl_cache
        self.parent = parent
        PyCurlFileObject.__init__(self, url, filename, opts)

    def _do_open(self):
        self.curl_obj = self.curl_cache
        self.curl_obj.reset()
        self._set_opts()
        self._do_grab()
        return self.fo

    def _do_perform(self):
        # WORKAROUND - BZ #1439758 - ensure first item in queue is performed alone to properly setup NSS
        if not self.parent.first_in_queue_done:
            self.parent.first_in_queue_lock.acquire()
            # If some other thread was faster, no need to block anymore
            if self.parent.first_in_queue_done:
                self.parent.first_in_queue_lock.release()
        try:
            PyCurlFileObject._do_perform(self)
        finally:
            if not self.parent.first_in_queue_done:
                self.parent.first_in_queue_done = True
                self.parent.first_in_queue_lock.release()

    def _set_opts(self, opts=None):
        if not opts:
            opts = {}
        PyCurlFileObject._set_opts(self, opts=opts)
        self.curl_obj.setopt(pycurl.FORBID_REUSE, 0) # pylint: disable=E1101


class FailedDownloadError(Exception):
    pass


class DownloadThread(Thread):
    def __init__(self, parent, queue):
        Thread.__init__(self)
        self.parent = parent
        self.queue = queue
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
                                 password=params['proxy_password'], proxies=params['proxies'],
                                 http_headers=tuple(params['http_headers'].items()))
        mirrors = len(params['urls'])
        for retry in range(max(self.parent.retries, mirrors)):
            fo = None
            url = urlparse.urljoin(params['urls'][self.mirror], params['relative_path'])
            ## BEWARE: This hack is introduced in order to support SUSE SCC channels
            ## This also needs a patched urlgrabber AFAIK
            if params['authtoken']:
                (scheme, netloc, path, query, frag) = urlparse.urlsplit(params['urls'][self.mirror])
                url = "%s://%s%s/%s?%s" % (scheme,netloc,path,params['relative_path'],query.rstrip('/'))
            try:
                try:
                    fo = PyCurlFileObjectThread(url, params['target_file'], opts, self.curl, self.parent)
                    # Check target file
                    if not self.__is_file_done(file_obj=fo, checksum_type=params['checksum_type'],
                                               checksum=params['checksum']):
                        raise FailedDownloadError("Target file isn't valid. Checksum should be %s (%s)."
                                                  % (params['checksum'], params['checksum_type']))
                    break
                except (FailedDownloadError, URLGrabError):
                    e = sys.exc_info()[1]
                    # urlgrabber-3.10.1-9 trows URLGrabError for both
                    # 'HTTP Error 404 - Not Found' and 'No space left on device', so
                    # workaround for this is check error message:
                    if 'No space left on device' in str(e):
                        self.parent.fail_download(e)
                        return False

                    if not self.__can_retry(retry, mirrors, opts, url, e):
                        return False
                    self.__next_mirror(mirrors)
                # RHEL 6 urlgrabber raises KeyboardInterrupt for example when there is no space left
                # but handle also other fatal exceptions
                except (KeyboardInterrupt, Exception):  # pylint: disable=W0703
                    e = sys.exc_info()[1]
                    self.parent.fail_download(e)
                    return False
            finally:
                if fo:
                    fo.close()
                # Delete failed download file
                elif os.path.isfile(params['target_file']):
                    os.unlink(params['target_file'])

        return True

    def run(self):
        while not self.queue.empty() and self.parent.can_continue():
            try:
                params = self.queue.get(block=False)
            except Empty:
                break
            self.mirror = 0
            success = self.__fetch_url(params)
            if self.parent.log_obj:
                # log_obj must be thread-safe
                self.parent.log_obj.log(success, os.path.basename(params['relative_path']))
            self.queue.task_done()
        self.curl.close()


class ThreadedDownloader:
    def __init__(self, retries=3, log_obj=None, force=False):
        self.queues = {}
        initCFG('server.satellite')
        try:
            self.threads = int(CFG.REPOSYNC_DOWNLOAD_THREADS)
        except ValueError:
            raise ValueError("Number of threads expected, found: '%s'" % CFG.REPOSYNC_DOWNLOAD_THREADS)
        if self.threads < 1:
            raise ValueError("Invalid number of threads: %d" % self.threads)
        self.retries = retries
        self.log_obj = log_obj
        self.force = force
        self.lock = Lock()
        self.exception = None
        # WORKAROUND - BZ #1439758 - ensure first item in queue is performed alone to properly setup NSS
        self.first_in_queue_done = False
        self.first_in_queue_lock = Lock()

    def set_log_obj(self, log_obj):
        self.log_obj = log_obj

    def set_force(self, force):
        self.force = force

    @staticmethod
    def _validate(ssl_set):
        ssl_ca_cert, ssl_cert, ssl_key = ssl_set
        for certificate_file in (ssl_ca_cert, ssl_cert, ssl_key):
            if certificate_file and not os.path.isfile(certificate_file):
                log2(0, 0, "ERROR: Certificate file not found: %s" % certificate_file, stream=sys.stderr)
                return False
        return True

    def add(self, params):
        ssl_set = (params['ssl_ca_cert'], params['ssl_client_cert'], params['ssl_client_key'])
        if self._validate(ssl_set):
            if ssl_set not in self.queues:
                self.queues[ssl_set] = Queue()
            queue = self.queues[ssl_set]
            queue.put(params)

    def run(self):
        size = 0
        for queue in self.queues.values():
            size += queue.qsize()
        if size <= 0:
            return
        log(1, "Downloading total %d files from %d queues." % (size, len(self.queues)))

        for index, queue in enumerate(self.queues.values()):
            log(2, "Downloading %d files from queue #%d." % (queue.qsize(), index))
            self.first_in_queue_done = False
            started_threads = []
            for _ in range(self.threads):
                thread = DownloadThread(self, queue)
                thread.setDaemon(True)
                thread.start()
                started_threads.append(thread)

            # wait to finish
            try:
                while any(t.isAlive() for t in started_threads):
                    time.sleep(1)
            except KeyboardInterrupt:
                e = sys.exc_info()[1]
                self.fail_download(e)
                while any(t.isAlive() for t in started_threads):
                    time.sleep(1)
                break

        # raise first detected exception if any
        if self.exception:
            raise self.exception  # pylint: disable=E0702

    def can_continue(self):
        self.lock.acquire()
        status = self.exception is None
        self.lock.release()
        return status

    def fail_download(self, exception):
        self.lock.acquire()
        if not self.exception:
            self.exception = exception
        self.lock.release()
