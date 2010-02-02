#!/usr/bin/python

import settestpath

# lots of useful util methods for building/tearing down
# test enviroments...
import testutils

from up2date_client import config

import unittest

test_up2date = "etc-sysconfig-rhn/up2date"

class TestConfig(unittest.TestCase):
    def setUp(self):
        # in this stuff, we get weird stuff existing, so restore
        # a config first, then change anything test specifc
        testutils.restoreConfig()
	self.__setupData()

    def __setupData(self):
        pass

    def tearDown(self):
        config.cfg == None 
        testutils.restoreConfig()
        
    def testEmptyInit(self):
        "Verify that the class can be created with no arguments"
        cfg = config.initUp2dateConfig(test_up2date)

    def testConfigString(self):
        "Verify that Config loads a string as a string"
        cfg = config.initUp2dateConfig(test_up2date)
        assert type(cfg['systemIdPath']) == type("") 

    def testConfigListSingleItem(self):
        "Verify that Config loads a list of one as a list"
        cfg = config.initUp2dateConfig(test_up2date)
        assert type(cfg['pkgSkipList']) == type([])

    def testConfigList(self):
        "Verify that Config loads a list as a list"
        cfg = config.initUp2dateConfig(test_up2date)
        assert type(cfg['disallowConfChanges']) == type([])

    def testConfigBool(self):
        "Verify that Config loads a bool int as a bool"
        cfg = config.initUp2dateConfig(test_up2date)
        assert type(cfg['enableProxy']) == type(1)

    def testConfigSave(self):
        "Verify that Config saves a file without error"
        cfg = config.initUp2dateConfig(test_up2date)
        cfg.save()

    def testConfigSetItem(self):
        "Verify that Config.__setitem__ works"
        cfg = config.initUp2dateConfig(test_up2date)
        cfg['blippyfoobarbazblargh'] = 1
        assert cfg['blippyfoobarbazblargh'] == 1

    def testConfigInfo(self):
        "Verify that Config.into() runs without error"
        cfg = config.initUp2dateConfig(test_up2date)
        blargh = cfg.info('enableProxy')

    def testConfigRuntimeStore(self):
        "Verify that values Config['value'] are set for runtime only and not saved"
        cfg = config.initUp2dateConfig(test_up2date)
        cfg['blippy12345'] = "wantafreehat?"
        cfg.save()
        # cfg is a fairly persistent singleton, blow it awy to get a new referece
        del config.cfg

        cfg2 = config.initUp2dateConfig(test_up2date)
        # if this returns a value, it means we saved the config file...
        assert cfg2['blippy12345'] == None

    def testConfigRuntimeStoreNoDir(self):
	"Verify that saving a file into a non existent dir works"
	# bugzilla: 125179
	cfg = config.initUp2dateConfig(test_up2date)
	cfg['blippy321'] = "blumblim"
	cfg.save()

    def testConfigKeysReturnsAList(self):
        "Verify that Config.keys() returns a list"
        cfg = config.initUp2dateConfig(test_up2date)
        blip = cfg.keys()
        assert type(blip) == type([])

    def testConfigKeys(self):
        "Verify that Config.keys() returns a list with the right stuff"
        cfg = config.initUp2dateConfig(test_up2date)
        blip = cfg.keys()
        assert "enableProxy" in blip

    def testConfigHasKeyDoesntExist(self):
        "Verify that Config.has_key() is correct on non existent keys"
        cfg = config.initUp2dateConfig(test_up2date)
        assert cfg.has_key("234wfj34ruafho34rhkfe") == 0

    def testConfigHasKeyDoesExist(self):
        "Verify that Config.has_key() is correct on existing keys"
        cfg = config.initUp2dateConfig(test_up2date)
        assert cfg.has_key("enableProxy") == 1

    def testConfigHasKeyRuntime(self):
        "Verify that Config.has_key() is correct for runtime keys"
        cfg = config.initUp2dateConfig(test_up2date)
        cfg['runtimekey'] = "blippy"
        assert cfg.has_key('runtimekey') == 1

    def testConfigValues(self):
        "Verify that Config.values() runs without error"
        cfg = config.initUp2dateConfig(test_up2date)
        ret = cfg.values()
        assert type(ret) == type([])

    def testConfigItems(self):
        "Verify that Config.items() runs without error"
        cfg = config.initUp2dateConfig(test_up2date)
        ret = cfg.items()
        assert type(ret) == type([])


    def testConfigSet(self):
        "Verify that Config.set() sets items into the persistent layer"
        cfg = config.initUp2dateConfig(test_up2date)
        cfg.set("permItem", 1)

        assert cfg.stored["permItem"] == 1

    def testConfigSetOverride(self):
        "Verify that Config.set() sets items in the persitent layer, overriding runtime"
        cfg = config.initUp2dateConfig(test_up2date)
        cfg['semiPermItem'] = 1
        cfg.set('semiPermItem',0)
        assert cfg.stored['semiPermItem'] == 0

    def testConfigLoad(self):
        "Verify that Config.load() works without exception"
        cfg = config.initUp2dateConfig(test_up2date)
        cfg.load("/etc/sysconfig/rhn/up2date")
        
        
    def testNetworkConfig(self):
        "Verify that the NetworkConfig class can be created"
        nc = config.NetworkConfig()

    def testNetworkConfigLoad(self):
        "Verify that NetworkConfig.load() runs without error"
        nc = config.NetworkConfig()
        nc.load()


    def testNetworkConfigLoadCorrectness(self):
        "Verify that NetworkConfig.load() runs and gets the right info"
        testutils.setupConfig("fc2-rpmmd-sources-1")
        nc = config.NetworkConfig()
        nc.load()
        assert nc['blargh'] == "blippyfoo"

    def testNetworkConfigLoadCorrectnessOverrides(self):
        "Verify that NetworkConfig.load() runs and overrides the default value"
        testutils.setupConfig("fc2-rpmmd-sources-1")
        nc = config.NetworkConfig()
        nc.load()
        assert nc['serverURL'] == "http://www.hokeypokeyland.com/XMLRPC"

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestConfig))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
