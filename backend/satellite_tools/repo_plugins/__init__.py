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
import rpm
from Queue import Queue, Empty
from threading import Thread, Lock
import pycurl
from urlgrabber.grabber import URLGrabberOptions, PyCurlFileObject
from spacewalk.common import rhn_pkg
from spacewalk.common.rhnException import rhnFault
from spacewalk.server import rhnPackageUpload
from spacewalk.satellite_tools.syncLib import log, log2stderr


class ProgressBarLogger:
    def __init__(self, msg, total):
        self.msg = msg
        self.total = total
        self.status = 0
        self.lock = Lock()

    def log(self, params=None):
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


class DownloadThread(Thread):
    def __init__(self, parent):
        Thread.__init__(self)
        self.parent = parent
        # pylint: disable=E1101
        self.curl = pycurl.Curl()

    def __fetch_url(self, params):
        (base_urls, remote_relative, local_path, ssl_ca_cert, ssl_cert, ssl_key) = params
        url = base_urls[0] + '/' + remote_relative
        opts = URLGrabberOptions(ssl_ca_cert=ssl_ca_cert, ssl_cert=ssl_cert, ssl_key=ssl_key)
        fo = PyCurlFileObjectThread(url, local_path, opts, self.curl)
        fo.close()

    def run(self):
        while not self.parent.queue.empty():
            try:
                params = self.parent.queue.get(block=False)
            except Empty:
                break
            self.__fetch_url(params)
            if self.parent.log_obj:
                # log_obj must be thread-safe
                self.parent.log_obj.log(params=params)
            self.parent.queue.task_done()


class ThreadedDownloader:
    def __init__(self, threads=5, log_obj=None):
        self.queue = Queue()
        self.threads = threads
        self.log_obj = log_obj

    def set_log_obj(self, log_obj):
        self.log_obj = log_obj

    @staticmethod
    def _validate(ssl_ca_cert, ssl_cert, ssl_key):
        for certificate_file in (ssl_ca_cert, ssl_cert, ssl_key):
            if certificate_file and not os.path.isfile(certificate_file):
                log2stderr(0, "ERROR: Certificate file not found: %s" % certificate_file)
                return False
        return True

    def add(self, base_urls, remote_relative, local_path, ssl_ca_cert, ssl_cert, ssl_key):
        if self._validate(ssl_ca_cert, ssl_cert, ssl_key):
            self.queue.put((base_urls, remote_relative, local_path, ssl_ca_cert, ssl_cert, ssl_key))

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

    def __cmp__(self,other):
        relSelf = re.split(r".",self.release)[0]
        relOther = re.split(r".",other.release)[0]
        # pylint: disable=E1101
        return rpm.labelCompare((self.epoch,self.version,relSelf),\
                                (other.epoch,other.version,relOther))

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
