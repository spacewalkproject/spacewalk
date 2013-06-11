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
        master.setLabel("testMaster");
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
