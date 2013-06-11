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
import com.redhat.rhn.domain.iss.IssMasterOrgs;
import com.redhat.rhn.frontend.xmlrpc.serializer.IssMasterOrgsSerializer;
import com.redhat.rhn.frontend.xmlrpc.serializer.IssMasterSerializer;

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
    }

    public void testMasterOrgsSerialize() throws XmlRpcException, IOException {
        IssMasterOrgsSerializer os = new IssMasterOrgsSerializer();
        IssMaster master = setUpMaster();
        IssMasterOrgs org = master.getMasterOrgs().toArray(new IssMasterOrgs[0])[0];

        Writer output = new StringWriter();
        os.serialize(org, output, new XmlRpcSerializer());
        String result = output.toString();
        assertEquals(os.getSupportedClass(), IssMasterOrgs.class);
        assertTrue(result.contains("name>masterOrgId</name"));
        assertTrue(result.contains(">" + org.getMasterOrgId() + "<"));
        assertTrue(result.contains("name>masterOrgName</name"));
        assertTrue(result.contains(">" + org.getMasterOrgName() + "<"));

    }

    private IssMaster setUpMaster() {
        long baseId = 1001L;

        IssMaster master = new IssMaster();
        master.setLabel("testMaster");
        Set<IssMasterOrgs> orgs = new HashSet<IssMasterOrgs>();
        for (String orgName : masterOrgNames) {
            IssMasterOrgs anOrg = new IssMasterOrgs();
            anOrg.setMasterOrgId(baseId++);
            anOrg.setMasterOrgName(orgName);
            anOrg.setLocalOrg(null);
            orgs.add(anOrg);
        }
        master.setMasterOrgs(orgs);
        IssFactory.save(master);
        return master;
    }

}
