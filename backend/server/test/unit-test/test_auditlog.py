#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
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
# in this software or its documentation

import unittest
from StringIO import StringIO
from collections import defaultdict
from xmlrpclib import Error

from mock import Mock, patch

from spacewalk.server.apacheRequest import apacheRequest

import spacewalk.server.auditlog as auditlog
from spacewalk.server.auditlog import auditlog_xmlrpc, AuditLogException


class AuditLogTest(unittest.TestCase):

    @classmethod
    def setUpAll(self):
        auditlog._get_uid = Mock(return_value="42(geeko)")

    def setUp(self):
        # mock the ServerProxy.log method so we can see how it is called
        self._real_server_proxy = auditlog.ServerProxy

        self.auditlog_server = Mock()
        self.auditlog_server.log = Mock()
        auditlog.ServerProxy = Mock(return_value=self.auditlog_server)

        # mock the _get_config method
        auditlog._read_config = Mock(return_value=(True, "bogus_url"))

    def tearDown(self):
        # clean up after _mock_xmlrpc_server
        auditlog.ServerProxy = self._real_server_proxy

    def test_logging_is_disabled(self):
        auditlog._read_config = Mock(return_value=(False, ""))

        auditlog_xmlrpc("method", "method_name", "args", "request")
        self.assertFalse(self.auditlog_server.log.called)

    def test_wrong_server_url(self):
        # revert mocking of the ServerProxy.log because we want to see
        # the error it raises
        auditlog.ServerProxy = self._real_server_proxy

        myerr = StringIO()
        with patch("sys.stderr", myerr):
            self.assertRaises(AuditLogException, auditlog_xmlrpc,
                              "method", "method_name", "args", "request")
        myerr.seek(0)
        err = myerr.read()
        wanted_err = ("Could not establish a connection to the AuditLog "
                      "server. IOError: unsupported XML-RPC protocol. "
                      "Is this server url correct? bogus_url")
        assert (wanted_err in err), (
            "Error string %s\n was not found in stderr: %s" % (wanted_err, err))

    def test_dont_log_methods_without_system_id(self):
        # we need a method that doesn't have a system_id parameter
        def api_method(not_system_id):
            pass

        auditlog_xmlrpc(api_method, "method_name", "args", "request")
        self.assertFalse(self.auditlog_server.log.called)

    def test_get_server_id(self):
        def api_method(self, system_id, arg1, arg2):
            pass
        args = ('system_id_xml', 'arg1', 'arg2')

        # mock rhnServer.get rhnServer.get(sysid_xml).getid()
        rhnserver_got = Mock()
        rhnserver_got.getid = Mock(return_value="10001000")
        auditlog.rhnServer.get = Mock(return_value=rhnserver_got)

        self.assertEqual(auditlog._get_server_id(api_method, args),
                         ('10001000', ('10001000', 'arg1', 'arg2')))
        self.assertEqual(auditlog.rhnServer.get.call_args,
                         (('system_id_xml',), {}), )

    def test_successful_logging_without_proxy(self):
        request = Mock()
        request.headers_in = {"SERVER_NAME": "server_name",
                              "REMOTE_ADDR": "remote_addr",
                              "SERVER_PORT": "server_port",
                              "DOCUMENT_ROOT": "document_root",
                              "SCRIPT_FILENAME": "script_filename",
                              "SCRIPT_URI": "script_uri"}
        auditlog._get_server_id = Mock(return_value=("system_id", ("arg1", "arg2")))

        def api_method(system_id):
            pass

        auditlog_xmlrpc(api_method, "api_method_name", ["args"], request)

        self.assertEqual(self.auditlog_server.audit.log.call_args,
                         (('42(geeko)', "api_method_name('arg1', 'arg2')",
                           'server_name',
                           {'EVT.SRC': 'BACKEND_API',
                            'REQ.SCRIPT_URI': 'script_uri',
                            'REQ.SCRIPT_FILENAME': 'script_filename',
                            'REQ.REMOTE_ADDR': 'remote_addr',
                            'REQ.DOCUMENT_ROOT': 'document_root',
                            'REQ.SERVER_PORT': 'server_port'}), {}))

    def test_successful_logging_with_proxy(self):
        request = Mock()
        request.headers_in = {"SERVER_NAME": "server_name",
                              "REMOTE_ADDR": "remote_addr",
                              "SERVER_PORT": "server_port",
                              "DOCUMENT_ROOT": "document_root",
                              "SCRIPT_FILENAME": "script_filename",
                              "SCRIPT_URI": "script_uri",
                              "HTTP_X_RHN_PROXY_AUTH": "proxy_auth",
                              "HTTP_X_RHN_PROXY_VERSION": "proxy_version",
                              "HTTP_X_RHN_IP_PATH": "original_addr"}
        auditlog._get_server_id = Mock(return_value=("system_id", ("arg1", "arg2")))

        def api_method(system_id):
            pass

        auditlog_xmlrpc(api_method, "api_method_name", ["args"], request)

        self.assertEqual(self.auditlog_server.audit.log.call_args,
                         (('42(geeko)', "api_method_name('arg1', 'arg2')",
                           'server_name',
                           {'EVT.SRC': 'BACKEND_API',
                            'REQ.SCRIPT_URI': 'script_uri',
                            'REQ.SCRIPT_FILENAME': 'script_filename',
                            'REQ.REMOTE_ADDR': 'remote_addr',
                            'REQ.DOCUMENT_ROOT': 'document_root',
                            'REQ.SERVER_PORT': 'server_port',
                            'REQ.PROXY': 'proxy_auth',
                            'REQ.PROXY_VERSION': 'proxy_version',
                            'REQ.ORIGINAL_ADDR': 'original_addr'}), {}))

    def test_remote_auditlog_error(self):
        request = Mock()
        request.headers_in = defaultdict(dict)
        auditlog._get_server_id = Mock(return_value=("system_id", ("arg1", "arg2")))

        def api_method(system_id):
            pass

        self.auditlog_server.audit.log = Mock(side_effect=Error)

        myerr = StringIO()
        with patch("sys.stderr", myerr):
            self.assertRaises(AuditLogException, auditlog_xmlrpc, api_method,
                              "api_method_name", ["args"], request)
        myerr.seek(0)
        err = myerr.read()
        wanted_err = ("Got an error while talking to the AuditLogging server "
                      "at bogus_url. Error was: Error()")
        assert(wanted_err in err), (
            "Error string %s\n was not found in stderr: %s" % (wanted_err, err))

    def test_missing_header_values_sent_as_null_strings(self):
        request = Mock()
        request.headers_in = {"SERVER_NAME": "server_name"}
        auditlog._get_server_id = Mock(return_value=("system_id", ("args",)))

        def api_method(system_id):
            pass

        auditlog_xmlrpc(api_method, "method_name", ["args"], request)
        self.assertEqual(self.auditlog_server.audit.log.call_args,
                         (('42(geeko)', "method_name('args',)", 'server_name',
                           {'EVT.SRC': 'BACKEND_API',
                            'REQ.SCRIPT_URI': '',
                            'REQ.SCRIPT_FILENAME': '',
                            'REQ.REMOTE_ADDR': '',
                            'REQ.DOCUMENT_ROOT': '',
                            'REQ.SERVER_PORT': ''}), {}))

    def test_missing_header_values_in_proxy_sent_as_null_strings(self):
        request = Mock()
        request.headers_in = {"SERVER_NAME": "server_name",
                              "HTTP_X_RHN_PROXY_AUTH": "proxy"}
        auditlog._get_server_id = Mock(return_value=("system_id", ("args",)))

        def api_method(system_id):
            pass

        auditlog_xmlrpc(api_method, "method_name", ["args"], request)
        self.assertEqual(self.auditlog_server.audit.log.call_args,
                         (('42(geeko)', "method_name('args',)", 'server_name',
                           {'EVT.SRC': 'BACKEND_API',
                            'REQ.SCRIPT_URI': '',
                            'REQ.SCRIPT_FILENAME': '',
                            'REQ.REMOTE_ADDR': '',
                            'REQ.DOCUMENT_ROOT': '',
                            'REQ.SERVER_PORT': '',
                            'REQ.PROXY': 'proxy',
                            'REQ.PROXY_VERSION': '',
                            'REQ.ORIGINAL_ADDR': ''}), {}))
