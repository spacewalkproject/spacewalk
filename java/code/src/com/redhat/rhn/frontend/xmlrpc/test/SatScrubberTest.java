/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.frontend.xmlrpc.test;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.frontend.dto.kickstart.KickstartableTreeDto;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.testing.TestCaseHelper;
import com.redhat.rhn.testing.TestUtils;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import junit.framework.TestCase;

/**
 * SatScrubberTest - this test actually cleans up old junit created test data.
 * After the 410 build is turned off on digdug/cruisecontrol we can remove this
 * test.  Didn't want to check it into our release branch.
 * @version $Rev$
 */
public class SatScrubberTest extends TestCase {
    
    private User orgAdmin;
    private static Logger log = Logger.getLogger(SatScrubberTest.class);
    

    
    public void testNothing() throws Exception {
        cleanupKickstarts();
        cleanupChannels();
        cleanupServers();
        cleanupUsers();
        cleanupOrgs();
        commitAndCloseSession();
    }
    
    public void cleanupKickstarts() throws Exception {
        orgAdmin = UserFactory.findRandomOrgAdmin(OrgFactory.getSatelliteOrg());
        List kickstarts = KickstartLister.
            getInstance().kickstartsInOrg(orgAdmin.getOrg(), null);
        for (int i = 0; i < kickstarts.size(); i++) {
            KickstartDto dto = (KickstartDto) kickstarts.get(i);
            KickstartData ksdata = KickstartFactory.
                lookupKickstartDataByIdAndOrg(orgAdmin.getOrg(), dto.getId());
            if (ksdata.getLabel().startsWith("KS Data: ")) {
                KickstartFactory.removeKickstartData(ksdata);
            }
        }
        List trees = KickstartLister.
            getInstance().kickstartTreesInOrg(orgAdmin.getOrg(), null);
        for (int i = 0; i < trees.size(); i++) {
            KickstartableTreeDto dto = (KickstartableTreeDto) trees.get(i);
            KickstartableTree tree = KickstartFactory.
                lookupKickstartTreeByIdAndOrg(dto.getId(), orgAdmin.getOrg());
            if (tree.getLabel().startsWith("ks-ChannelLabel")) {
                KickstartFactory.removeKickstartableTree(tree);
            }
        }
        
        commitAndCloseSession();
    }
    

    public void cleanupChannels() throws Exception {
        // testOrg
        DataResult dr = TestUtils.runTestQuery("get_test_channels", new HashMap());
        for (int i = 0; i < dr.size(); i++) {
            Map row = (Map) dr.get(i);
            Long id = (Long) row.get("id");
            log.debug("Deleting channel: " + id);
            try {
                deleteChannel(id);
            }
            catch (Exception e) {
                log.warn("Error deleting channel: " + id, e);
            }
            if (i % 10 == 0) {
                log.debug("Deleted [" + i + "] orgs");
                commitAndCloseSession();
            }
        }
        commitAndCloseSession();        
    }
    private void deleteChannel(long cid) throws Exception {
        CallableMode m = ModeFactory.getCallableMode(
                "Channel_queries", "delete_channel");
        Map inParams = new HashMap();
        inParams.put("cid", cid);
        m.execute(inParams, new HashMap());
    }

    public void cleanupUsers() throws Exception {
        DataResult dr = TestUtils.runTestQuery("get_test_users", new HashMap());
        for (int i = 0; i < dr.size(); i++) {
            Long uid = (Long) ((Map) dr.get(i)).get("id");
            try {
                UserFactory.deleteUser(uid);
            }
            catch (Exception e) {
                log.warn("Error deleting  user: " + uid, e);
            }
            if (i % 100 == 0) {
                log.debug("Deleted [" + i + "] users");
                commitAndCloseSession();
            }

            
        }
        commitAndCloseSession();
    }
    
    public void cleanupServers() throws Exception {
        DataResult dr = TestUtils.runTestQuery("get_test_servers", new HashMap());
        int numdeleted = 0;
        for (int i = 0; i < dr.size(); i++) {
            Long sid = (Long) ((Map) dr.get(i)).get("id");
            deleteServer(sid);
            numdeleted++;
            if (i % 100 == 0) {
                log.debug("Deleted [" + numdeleted + "] systems");
                commitAndCloseSession();
            }
        }
        
        commitAndCloseSession();
        log.debug("Done deleting [" + numdeleted + "] systems");
    }

    /**
     * @param sid
     */
    private void deleteServer(Long sid) {
        CallableMode m = ModeFactory.
            getCallableMode("System_queries", "delete_server");
        Map in = new HashMap();
        in.put("server_id", sid);
        m.execute(in, new HashMap());
    }

    
    
    
    public void cleanupOrgs() throws Exception {
        // testOrg
        DataResult dr = TestUtils.runTestQuery("get_test_orgs", new HashMap());
        for (int i = 0; i < dr.size(); i++) {
            Map row = (Map) dr.get(i);
            Long id = (Long) row.get("id");
            log.debug("Deleting org: " + id);
            try {
                OrgFactory.deleteOrg(new Long(id.longValue()));
            }
            catch (Exception e) {
                log.warn("Error deleting org: " + id, e);
            }
            if (i % 10 == 0) {
                log.debug("Deleted [" + i + "] orgs");
                commitAndCloseSession();
            }
        }
        commitAndCloseSession();
    }
    
    /**
     * Tears down the fixture, and closes the HibernateSession.
     * @see TestCase#tearDown()
     * @see HibernateFactory#closeSession()
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        TestCaseHelper.tearDownHelper();
    }
    
    /**
     * PLEASE Refrain from using this unless you really have to.
     * 
     * Try clearSession() instead
     * @throws HibernateException
     */
    protected void commitAndCloseSession() throws HibernateException {
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }    
}
