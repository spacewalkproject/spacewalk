#!/usr/bin/python
#

import xmlrpclib


class SMConnect:
    """
    SM connection mixin.
    """

    def __init__(self, host, user, password):
        """
        Constructor.
        """
        self.client = xmlrpclib.Server("http://%s/rpc/api" % host, verbose=0)
        self.token = self.client.auth.login(user, password)


    def findInstalledPackagesByName(self, serverId, name):
        """
        Find needed packages.
        """
        return filter(None, [(pkg.get('name', '').lower().find(name.lower()) > -1 and pkg or None)
                             for pkg in self.client.system.listPackages(self.token, serverId)])


    def findServerByHostname(self, fullHostName):
        """
        Find needed host.
        """
        hostName = fullHostName.split(".")[0]
        for server in self.client.system.listActiveSystems(self.token):
            if server.get("name") in [hostName, fullHostName]:
                return server

        return {}




class ScenarioRunner(SMConnect):
    """
    Admin scenario for the SUSE Manager, utilizing Action Chains.
    """
    def example_01(self):
        server = self.findServerByHostname("pig.suse.de")
        if not server:
            return

        print server

        # You are already able to search for the packages
        for pkg in self.findInstalledPackagesByName(server['id'], "yum"):
            print pkg.get("name")

        # Therefore you also want to use the API in the same way
        print self.client.actionchains.addPackageUpgrade(
            self.token, 1000010000,
            [
                {
                    "name" : "alsa-lib",
                    "version" : "1.0.22",
                    },
                {
                    "name" : "java-cup",
                    "version" : "0.11",
                    },
                {
                    "name" : "javassist",
                    "version" : "3.9.0",
                    "release" : "6.el6",
                    },
                ],
            "My Great Chain")

    def example_02(self):
        """
        List action chains.
        """
        # List all action chains, available to the current user
        for chain in self.client.actionchains.listChains(self.token):
            print "Chain:", chain

            # Print the details (raw hash)
            for data in self.client.actionchains.chainActions(self.token, chain.get("name")):
                print "\t", data

    def example_03(self):
        """
        Remove action entries in the action chain.
        """
        self.client.actionchains.addPackageRemoval(
            self.token, "pig", "",
            [
                {
                    "name" : "alsa-lib",
                    # "version" : "1.0.22",
                    },
                ],
            "Test Chain")

        # Test Chain must be there
        for chain in self.client.actionchains.listChains():
            print "Chain:", chain.get("name")

        # List actions
        for data in self.client.actionchains.chainActions("Test Chain"):
            print "\t", data

        self.client.actionchains.removeActions("Test Chain", ["Package Install"])

        # List actions (should be empty)
        print "After deletion:", self.client.actionchains.chainActions("Test Chain")

        # Remove the chain itself:
        self.client.actionchains.removeChains(["Test Chain",])

        # Test Chain must be no longer there
        for chain in self.client.actionchains.listChains():
            print "Chain:", chain.get("name")


if __name__ == "__main__":
    host = "pig.suse.de"
    user = "admin"
    password = "admin"

    sr = ScenarioRunner(host, user, password)
    sr.example_03()
