"""
Unit Tests for testing gpg key url reading from RHN channel info.
"""

import unittest

import settestpath

import rhnplugin


class IsValidGpgKeyUrlTests(unittest.TestCase):

    def test_fail_if_location_not_url(self):
        valid_url = rhnplugin.is_valid_gpg_key_url('')
        self.assertFalse(valid_url)

    def test_fail_if_location_not_file(self):
        valid_url = rhnplugin.is_valid_gpg_key_url('http://www.foo.com')
        self.assertFalse(valid_url)

    def test_fail_if_bad_path(self):
        valid_url = rhnplugin.is_valid_gpg_key_url('file:///home/key')
        self.assertFalse(valid_url)

    def test_good_path(self):
        path = 'file:///etc/pki/rpm-gpg/bar'
        valid_url = rhnplugin.is_valid_gpg_key_url(path)
        self.assertTrue(valid_url)

    def test_good_path_proto_in_caps(self):
        path = 'FILE:///etc/pki/rpm-gpg/bar'
        valid_url = rhnplugin.is_valid_gpg_key_url(path)
        self.assertTrue(valid_url)


class GetGpgKeyUrlsTests(unittest.TestCase):

    def test_empty_string(self):
        key_urls = ""
        url_list = rhnplugin.get_gpg_key_urls(key_urls)
        self.assertEquals(0, len(url_list))

    def test_single_good_url(self):
        key_urls = 'file:///etc/pki/rpm-gpg/bar'
        url_list = rhnplugin.get_gpg_key_urls(key_urls)
        self.assertEquals(1, len(url_list))
        self.assertEquals(key_urls, url_list[0])

    def test_multiple_good_urls(self):
        url1 = 'file:///etc/pki/rpm-gpg/bar'
        url2 = 'file:///etc/pki/rpm-gpg/foo'
        key_urls = " ".join((url1, url2))
        url_list = rhnplugin.get_gpg_key_urls(key_urls)
        self.assertEquals(2, len(url_list))
        self.assertEquals(url1, url_list[0])
        self.assertEquals(url2, url_list[1])

    def test_single_good_url_extra_whitespace(self):
        key_urls = '   file:///etc/pki/rpm-gpg/bar   '
        url_list = rhnplugin.get_gpg_key_urls(key_urls)
        self.assertEquals(1, len(url_list))
        self.assertEquals(key_urls.strip(), url_list[0])

    def test_single_bad_url(self):
        key_urls = 'http:///etc/pki/rpm-gpg/bar'
        self.assertRaises(rhnplugin.InvalidGpgKeyLocation,
            rhnplugin.get_gpg_key_urls, key_urls)

    def test_multiple_urls_one_bad(self):
        url1 = 'file:///etc/pki/rpm-gpg/bar'
        url2 = 'http:///etc/pki/rpm-gpg/foo'
        key_urls = " ".join((url1, url2))
        self.assertRaises(rhnplugin.InvalidGpgKeyLocation,
            rhnplugin.get_gpg_key_urls, key_urls)


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(IsValidGpgKeyUrlTests))
    suite.addTest(unittest.makeSuite(GetGpgKeyUrlsTests))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
