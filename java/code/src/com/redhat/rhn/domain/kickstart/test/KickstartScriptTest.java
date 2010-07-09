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
package com.redhat.rhn.domain.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import org.apache.commons.lang.RandomStringUtils;

import java.util.Iterator;

/**
 *
 * KickstartScriptTest
 * @version $Rev$
 */
public class KickstartScriptTest extends BaseTestCaseWithUser {

    public static final byte[] DATA = "echo \"hello world\"".getBytes();

    /*
    public void testRevision() throws Exception {
        KickstartData ksdata = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        KickstartScript script = KickstartScriptTest.createPost(ksdata);
        script.setRevision(new Long(1));
        System.out.println("\n\n\n\n\nSSSSSSSSSSSS\n\n\n\n");
        ksdata = (KickstartData) TestUtils.saveAndReload(ksdata);
        System.out.println("\n\n\n\n\nZZZZZZZZZZZZ\n\n\n\n");
        script = ksdata.getScripts().iterator().next();
        assertNotNull(script.getRevision());
        assertNotNull(script.getId());
        KickstartScript lookedUp = (KickstartScript)  HibernateFactory.getSession()
            .getNamedQuery("KickstartScript.findLatestScriptRevisionByID")
            .setLong("id", script.getId())
            .uniqueResult();
        assertNotNull(lookedUp);
    }*/

    public void testScript() throws Exception {
        KickstartData ksdata = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) reload(ksdata);
        assertNotNull(ksdata.getScripts());
        assertEquals(5, ksdata.getScripts().size());
        KickstartScript ks2 = (KickstartScript) ksdata.getScripts().iterator().next();

        assertNotNull(ks2.getDataContents());

        // Test delete
        ksdata.removeScript(ks2);
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) reload(ksdata);
        assertEquals(4, ksdata.getScripts().size());
    }

    public void testMultiplePreScripts() throws Exception {
        KickstartData ksdata = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        KickstartScript kss1 = createPre(ksdata);
        KickstartScript kss2 = createPre(ksdata);
        ksdata.addScript(kss1);
        ksdata.addScript(kss2);
        assertTrue(kss1.getPosition().longValue() < kss2.getPosition().longValue());
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) reload(ksdata);
        assertTrue(kss1.getPosition().longValue() < kss2.getPosition().longValue());
    }

    public void testLargeScript() throws Exception {
        String largeString = RandomStringUtils.randomAscii(4000);
        KickstartData ksdata = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        ksdata.getScripts().clear();
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) reload(ksdata);

        // Create 2 scripts, one with data, one without.
        KickstartScript script = createPost(ksdata);
        KickstartScript scriptEmpty = createPost(ksdata);
        script.setData(largeString.getBytes("UTF-8"));
        // Make sure we are setting the blob to be an empty byte
        // array.  The bug happens when one script is empty.
        scriptEmpty.setData(new byte[0]);
        ksdata.addScript(script);
        ksdata.addScript(scriptEmpty);
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) reload(ksdata);
        Iterator i = ksdata.getScripts().iterator();
        boolean found = false;
        while (i.hasNext()) {
            KickstartScript loaded = (KickstartScript) i.next();
            if (loaded.getDataContents().equals(largeString)) {
                found = true;
            }
        }
        assertTrue(found);
    }



    public static KickstartScript createPreInterpreter(KickstartData k) {
        KickstartScript ks = new KickstartScript();
        ks.setInterpreter("/usr/bin/perl");
        ks.setChroot("Y");
        ks.setData(DATA);
        ks.setPosition(new Long(1));
        ks.setScriptType(KickstartScript.TYPE_PRE);
        ks.setKsdata(k);
        ks.setRaw(true);
        return ks;
    }

    public static KickstartScript createPostInterpreter(KickstartData k) {
        KickstartScript ks = new KickstartScript();
        ks.setInterpreter("/usr/bin/python");
        ks.setChroot("Y");
        ks.setPosition(new Long(2));
        ks.setData(DATA);
        ks.setScriptType(KickstartScript.TYPE_POST);
        ks.setKsdata(k);
        ks.setRaw(true);
        return ks;
    }

    public static KickstartScript createPostChrootInt(KickstartData k) {
        KickstartScript ks = new KickstartScript();
        ks.setInterpreter("/usr/bin/python");
        ks.setData(DATA);
        ks.setChroot("N");
        ks.setPosition(new Long(3));
        ks.setScriptType(KickstartScript.TYPE_POST);
        ks.setKsdata(k);
        ks.setRaw(true);
        return ks;
    }

    public static KickstartScript createPre(KickstartData k) {
        KickstartScript ks = new KickstartScript();
        ks.setChroot("Y");
        ks.setData(DATA);
        ks.setPosition(new Long(4));
        ks.setScriptType(KickstartScript.TYPE_PRE);
        ks.setKsdata(k);
        ks.setRaw(true);
        return ks;
    }

    public static KickstartScript createPost(KickstartData k) {
        KickstartScript ks = new KickstartScript();
        ks.setChroot("Y");
        ks.setData(DATA);
        ks.setPosition(new Long(5));
        ks.setScriptType(KickstartScript.TYPE_POST);
        ks.setKsdata(k);
        ks.setRaw(true);
        return ks;
    }

}
