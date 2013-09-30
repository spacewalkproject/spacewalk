"""
Unit Tests for testing sslCACert settings reading from up2date's
config.
"""

import unittest

import settestpath

import rhnplugin


class SslCaCertConfigTests(unittest.TestCase):

    def test_ssl_ca_cert_empty(self):
        up2date_cfg = {}
        up2date_cfg['sslCACert'] = ''

        self.assertRaises(rhnplugin.BadSslCaCertConfig,
            rhnplugin.get_ssl_ca_cert, up2date_cfg)

    def test_no_ssl_ca_cert(self):
        up2date_cfg = {}

        self.assertRaises(rhnplugin.BadSslCaCertConfig,
            rhnplugin.get_ssl_ca_cert, up2date_cfg)

    def test_single_ssl_ca_cert(self):
        up2date_cfg = {}

        expected = '/var/foo/bar'
        up2date_cfg['sslCACert'] = expected

        res = rhnplugin.get_ssl_ca_cert(up2date_cfg)
        self.assertEquals(str, type(res))
        self.assertEquals(expected, res)

    def test_single_ssl_ca_cert_in_list(self):
        up2date_cfg = {}

        expected = '/var/foo/bar'
        up2date_cfg['sslCACert'] = [expected]

        res = rhnplugin.get_ssl_ca_cert(up2date_cfg)
        self.assertEquals(str, type(res))
        self.assertEquals(expected, res)

    def test_multiple_ssl_ca_cert_in_list(self):
        # For now we just use the first one
        up2date_cfg = {}

        expected = '/var/foo/bar'
        not_expected = '/var/blech/foo/bar'
        up2date_cfg['sslCACert'] = [expected, not_expected]

        res = rhnplugin.get_ssl_ca_cert(up2date_cfg)
        self.assertEquals(str, type(res))
        self.assertEquals(expected, res)

    def test_ssl_ca_cert_empty_list(self):
        up2date_cfg = {}
        up2date_cfg['sslCACert'] = []

        self.assertRaises(rhnplugin.BadSslCaCertConfig,
            rhnplugin.get_ssl_ca_cert, up2date_cfg)


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(SslCaCertConfigTests))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
