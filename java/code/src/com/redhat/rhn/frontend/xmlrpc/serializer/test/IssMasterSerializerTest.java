/**
 * Copyright (c) 2013 Red Hat, Inc.
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

package com.redhat.rhn.frontend.xmlrpc.serializer.test;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.util.HashSet;
import java.util.Set;

import org.jmock.MockObjectTestCase;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.domain.iss.IssMasterOrg;
import com.redhat.rhn.frontend.xmlrpc.serializer.IssMasterOrgSerializer;
import com.redhat.rhn.frontend.xmlrpc.serializer.IssMasterSerializer;
import com.redhat.rhn.testing.TestUtils;

public class IssMasterSerializerTest extends MockObjectTestCase {
    private String[] masterOrgNames = {"masterOrg1", "masterOrg2", "masterOrg3"};

    public void testMasterSerialize() throws XmlRpcException, IOException {
        IssMasterSerializer os = new IssMasterSerializer();
        IssMaster master = setUpMaster();

        Writer output = new StringWriter();
        os.serialize(master, output, new XmlRpcSerializer());
        String result = output.toString();
        assertEquals(os.getSupportedClass(), IssMaster.class);
        assertTrue(result.contains("<name>id</name>"));
        assertTrue(result.contains(">" + master.getId() + "<"));
        assertTrue(result.contains("name>label</name"));
        assertTrue(result.contains(">" + master.getLabel() + "<"));
        assertTrue(result.contains("name>isCurrentMaster</name"));
        assertTrue(result.contains(">" + (master.isDefaultMaster() ? "1" : "0") + "<"));
        assertTrue(result.contains("name>caCert</name"));
        assertTrue(result.contains(">" + (master.getCaCert()) + "<"));
    }

    public void testMasterOrgSerialize() throws XmlRpcException, IOException {
        IssMasterOrgSerializer os = new IssMasterOrgSerializer();
        IssMaster master = setUpMaster();
        IssMasterOrg org = master.getMasterOrgs().toArray(new IssMasterOrg[0])[0];

        Writer output = new StringWriter();
        os.serialize(org, output, new XmlRpcSerializer());
        String result = output.toString();
        assertEquals(os.getSupportedClass(), IssMasterOrg.class);
        assertTrue(result.contains("name>masterOrgId</name"));
        assertTrue(result.contains(">" + org.getMasterOrgId() + "<"));
        assertTrue(result.contains("name>masterOrgName</name"));
        assertTrue(result.contains(">" + org.getMasterOrgName() + "<"));

    }

    private IssMaster setUpMaster() {
        long baseId = 1001L;

        IssMaster master = new IssMaster();
        master.setLabel("testMaster" + TestUtils.randomString());
        master.makeDefaultMaster();
        master.setCaCert("/tmp/FOO-CA-CERT");
        Set<IssMasterOrg> orgs = new HashSet<IssMasterOrg>();
        for (String orgName : masterOrgNames) {
            IssMasterOrg anOrg = new IssMasterOrg();
            anOrg.setMasterOrgId(baseId++);
            anOrg.setMasterOrgName(orgName);
            anOrg.setLocalOrg(null);
            orgs.add(anOrg);
        }
        master.resetMasterOrgs(orgs);
        IssFactory.save(master);
        return master;
    }

}
