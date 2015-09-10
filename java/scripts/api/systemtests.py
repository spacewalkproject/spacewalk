#!/usr/bin/python

import xmlrpclib
import unittest
import random
from datetime import datetime, timedelta
from time import mktime

from config import *

class SystemTests(RhnTestCase):

    def test_get_running_kernel(self):
        kernel = client.system.getRunningKernel(self.session_key, SERVER_ID)
        self.assertTrue(kernel != None)
        self.assertTrue(len(kernel) > 0)

    def test_compare_profiles(self):
        result = client.system.comparePackages(self.session_key,
            SERVER_ID, SERVER_ID_2)
        for row in result:
            self.assertTrue(row.has_key('package_name'))
            self.assertTrue(row.has_key('this_system'))
            self.assertTrue(row.has_key('other_system'))
            self.assertTrue(row.has_key('comparison'))

    def test_unscheduled_errata(self):
        errata = client.system.getUnscheduledErrata(self.session_key,
            SERVER_ID_2)
        self.assertTrue(len(errata) > 0)

    # NOTE: Tests below will fail if re-run without clearing pending events:
    #def test_schedule_errata(self):
    #    # Will fail if you rerun without clearing the pending events on
    #    # SERVER_ID:
    #    errata = client.system.getRelevantErrata(self.session_key, SERVER_ID)
    #    self.assertTrue(len(errata) > 0)
    #    errata_ids = []
    #    for e in errata:
    #        errata_ids.append(e['id'])
    #    earliest = datetime.now() + timedelta(3) # 3 days from now
    #    dt = xmlrpclib.DateTime(earliest.timetuple())
    #    client.system.scheduleApplyErrata(self.session_key, SERVER_ID,
    #        errata_ids, dt)
    #def test_apply_errata(self):
    #    errata = client.system.getRelevantErrata(self.session_key, SERVER_ID)
    #    self.assertTrue(len(errata) > 0)
    #    errata_ids = []
    #    for e in errata:
    #        errata_ids.append(e['id'])
    #    client.system.applyErrata(self.session_key, SERVER_ID, errata_ids)

    def test_schedule_package_install(self):
        installable = client.system.listLatestInstallablePackages(
            self.session_key, SERVER_ID)
        install_these = []
        for pkg in installable[0:3]:
            install_these.append(pkg['package_id'])
        earliest = datetime.now() + timedelta(3) # 3 days from now
        dt = xmlrpclib.DateTime(earliest.timetuple())
        client.system.schedulePackageInstall(self.session_key, SERVER_ID,
            install_these, dt)

    def test_schedule_hardware_refresh(self):
        earliest = datetime.now() + timedelta(3) # 3 days from now
        dt = xmlrpclib.DateTime(earliest.timetuple())
        client.system.scheduleHardwareRefresh(self.session_key, SERVER_ID, dt)

    def test_schedule_package_refresh(self):
        earliest = datetime.now() + timedelta(3) # 3 days from now
        dt = xmlrpclib.DateTime(earliest.timetuple())
        result = client.system.schedulePackageRefresh(self.session_key, SERVER_ID, dt)
        self.assertEquals(result, 1)

    def test_schedule_script_run(self):
        script = \
"""
#!/bin/sh
cat /proc/cpuinfo
"""
        earliest = datetime.now() + timedelta(3) # 3 days
        dt = xmlrpclib.DateTime(earliest.timetuple())

        script_id = client.system.scheduleScriptRun(self.session_key,
            SERVER_ID, 'root', 'root', 600, script, dt)

    def test_get_script_output(self):
        results = client.system.getScriptResults(self.session_key, SCRIPT_ACTION_ID)
        self.assertEquals(1 ,len(results))
        for r in results:
            self.assertTrue(r.has_key('startDate'))
            self.assertTrue(r.has_key('stopDate'))
            self.assertTrue(r.has_key('returnCode'))
            self.assertTrue(r.has_key('output'))

    def test_search_by_name(self):
        results = client.system.searchByName(self.session_key, SERVER_NAME)
        self.assertTrue(len(results) > 0)
        for r in results:
            self.assertTrue(r.has_key('id'))
            self.assertTrue(r.has_key('name'))
            self.assertTrue(r.has_key('last_checkin'))

    def test_set_details(self):
        details = {}
        details['profile_name'] = "newman"
        details['base_entitlement'] = "enterprise_entitled"
        details['auto_errata_update'] = True
        details['description'] = "hello world 2!"
        details['address1'] = "address1"
        details['address2'] = "address2"
        details['city'] = "Halifax"
        details['state'] = "Nova Scotia"
        details['country'] = "CA"
        details['building'] = "The One Over There"
        details['room'] = "1401"
        details['rack'] = "I wish..."

        client.system.setDetails(self.session_key, SERVER_ID, details)

    def test_add_remove_entitlements(self):
        ents = ['enterprise_entitled']
        client.system.removeEntitlements(self.session_key, SERVER_ID, ents)
        details = client.system.getDetails(self.session_key, SERVER_ID)
        lookup_ents = details['addon_entitlements']
        self.assertFalse(ents[0] in lookup_ents)

        client.system.addEntitlements(self.session_key, SERVER_ID, ents)
        details = client.system.getDetails(self.session_key, SERVER_ID)
        lookup_ents = details['addon_entitlements']
        self.assertTrue(ents[0] in lookup_ents)

        client.system.removeEntitlements(self.session_key, SERVER_ID, ents)
        details = client.system.getDetails(self.session_key, SERVER_ID)
        lookup_ents = details['addon_entitlements']
        self.assertFalse(ents[0] in lookup_ents)

    def test_sync_to_system(self):
        packages_to_sync = [232, 260]
        diff = client.system.comparePackages(self.session_key, SERVER_ID_2,
            SERVER_ID)
        for pnid in packages_to_sync:
            found = False
            for d in diff:
                if d['package_name_id'] == pnid:
                    found = True
                    break
            self.assertTrue(found)

        earliest = datetime.now() + timedelta(3) # 3 days from now
        dt = xmlrpclib.DateTime(earliest.timetuple())
        client.system.scheduleSyncPackagesWithSystem(self.session_key,
            SERVER_ID_2, SERVER_ID, packages_to_sync, dt)

    def test_get_unscheduled_errata(self):
        results = client.system.getUnscheduledErrata(self.session_key,
                SERVER_ID)
        for r in results:
            self.assertTrue(r.has_key('id'))
            self.assertTrue(r.has_key('date'))
            self.assertTrue(r.has_key('advisory_synopsis'))
            self.assertTrue(r.has_key('advisory_name'))
            self.assertTrue(r.has_key('advisory_type'))



if __name__ == "__main__":
    unittest.main()

