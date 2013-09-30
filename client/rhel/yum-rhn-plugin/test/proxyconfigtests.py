"""
Unit Tests for testing proxy settings reading from up2date's
config.
"""

import unittest

import settestpath

import rhnplugin


class ProxyConfigTests(unittest.TestCase):

    def testProxyDisabled(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = False
        up2date_cfg['enableProxyAuth'] = False
        url = rhnplugin.get_proxy_url(up2date_cfg)
        self.assertEquals(None, url)

    def testProxyEnabled(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        up2date_cfg['enableProxyAuth'] = False
        up2date_cfg['httpProxy'] = 'foobar.com:40'
        url = rhnplugin.get_proxy_url(up2date_cfg)
        self.assertNotEquals(None, url)

    def testProxyWithProto(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        up2date_cfg['enableProxyAuth'] = False

        netloc = 'foobar.com:40'
        expected_url = 'https://' + netloc
        up2date_cfg['httpProxy'] = 'http://' + netloc
        url = rhnplugin.get_proxy_url(up2date_cfg)
        self.assertEquals(expected_url, url)

    def testProxyBadProto(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        up2date_cfg['enableProxyAuth'] = False

        netloc = 'foobar.com:40'
        expected_url = 'https://' + netloc
        up2date_cfg['httpProxy'] = 'ftp://' + netloc
        url = rhnplugin.get_proxy_url(up2date_cfg)
        self.assertEquals(expected_url, url)

    def testProxyNoAuth(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        up2date_cfg['enableProxyAuth'] = False
        netloc = 'foobar.com:40'
        up2date_cfg['httpProxy'] = netloc
        expected_proxy = 'https://' + netloc
        url = rhnplugin.get_proxy_url(up2date_cfg)
        self.assertEquals(expected_proxy, url)

    def testProxyEmptyUrl(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        up2date_cfg['enableProxyAuth'] = False
        netloc = ''
        up2date_cfg['httpProxy'] = netloc
        self.assertRaises(rhnplugin.BadProxyConfig, rhnplugin.get_proxy_url,
            up2date_cfg)

    def testProxyAuthEnabled(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        netloc = 'foobar.com:40'
        up2date_cfg['httpProxy'] = netloc
        up2date_cfg['enableProxyAuth'] = True

        user = 'mruser'
        password = 'thepassword'
        up2date_cfg['proxyUser'] = user
        up2date_cfg['proxyPassword'] = password

        expected_proxy = 'https://' + user + ":" + password + '@' + netloc
        url = rhnplugin.get_proxy_url(up2date_cfg)
        self.assertEquals(expected_proxy, url)

    def testProxyAuthEnabledNoUser(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        netloc = 'foobar.com:40'
        up2date_cfg['httpProxy'] = netloc
        up2date_cfg['enableProxyAuth'] = True

        password = 'thepassword'
        up2date_cfg['proxyPassword'] = password

        self.assertRaises(rhnplugin.BadProxyConfig,
            rhnplugin.get_proxy_url, up2date_cfg)

    def testProxyAuthEnabledEmptyUser(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        netloc = 'foobar.com:40'
        up2date_cfg['httpProxy'] = netloc
        up2date_cfg['enableProxyAuth'] = True

        user = ''
        up2date_cfg['proxyUser'] = user

        password = 'thepassword'
        up2date_cfg['proxyPassword'] = password

        self.assertRaises(rhnplugin.BadProxyConfig,
            rhnplugin.get_proxy_url, up2date_cfg)

    def testProxyAuthEnabledNoPassword(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        netloc = 'foobar.com:40'
        up2date_cfg['httpProxy'] = netloc
        up2date_cfg['enableProxyAuth'] = True

        user = 'mruser'
        up2date_cfg['proxyUser'] = user

        self.assertRaises(rhnplugin.BadProxyConfig,
            rhnplugin.get_proxy_url, up2date_cfg)

    def testProxyAuthEnabledEmptyPassword(self):
        up2date_cfg = {}
        up2date_cfg['enableProxy'] = True
        netloc = 'foobar.com:40'
        up2date_cfg['httpProxy'] = netloc
        up2date_cfg['enableProxyAuth'] = True

        user = 'mruser'
        up2date_cfg['proxyUser'] = user

        password = ''
        up2date_cfg['proxyPassword'] = password

        self.assertRaises(rhnplugin.BadProxyConfig,
            rhnplugin.get_proxy_url, up2date_cfg)


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(ProxyConfigTests))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
