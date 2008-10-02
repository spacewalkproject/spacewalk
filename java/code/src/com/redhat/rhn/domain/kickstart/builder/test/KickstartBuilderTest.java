/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.domain.kickstart.builder.test;

import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartRawData;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.domain.kickstart.builder.KickstartParser;
import com.redhat.rhn.domain.kickstart.builder.KickstartParsingException;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidVirtualizationTypeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.LabelAlreadyExistsException;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.LinkedList;
import java.util.List;

public class KickstartBuilderTest extends RhnBaseTestCase {
    
    private String kickstartFileContents;
    private User user;
    private final String KICKSTART_HOST = "localhost"; // really doesn't matter

    public void setUp() throws Exception {
        
        user = UserTestUtils.findNewUser("testUser", "testOrg", true);
        
    }
    
    private KickstartParser createKickstartParser(String filename) throws Exception {
        kickstartFileContents = TestUtils.readAll(
                TestUtils.findTestData(filename));
        return new KickstartParser(kickstartFileContents);
    }
    
    
    public void testDirector() throws Exception {
        KickstartParser parser = createKickstartParser("samplekickstart1.ks");
        assertEquals(27, parser.getOptionLines().size());
        assertEquals(102, parser.getPackageLines().size());
        assertTrue(((String)parser.getPackageLines().get(0)).startsWith("%packages"));
        assertEquals(40, parser.getPreScriptLines().size());
        assertEquals(0, parser.getPostScriptLines().size());
    }

    public void testBuildCommands() throws Exception {
        KickstartParser parser = createKickstartParser("samplekickstart1.ks");
        KickstartBuilder builder = new KickstartBuilder(user);
        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();

        List<String> lines = parser.getOptionLines();

        KickstartData ksData = createBareKickstartData();
        builder.buildCommands(ksData, lines, tree, null);
        assertEquals(19, ksData.getCommands().size()); // TODO: one is ignored

        KickstartCommand rootpw = ksData.getCommand("rootpw");
        assertTrue(rootpw.getArguments().indexOf("--iscrypted") < 0);
        assertTrue(rootpw.getArguments().startsWith("$1$"));
    }


    private KickstartData createBareKickstartData() {
        KickstartData ksData = new KickstartData();
        ksData.setOrg(user.getOrg());
        ksData.setName("Test Kickstart");
        ksData.setLabel("testlabel");
        ksData.setActive(Boolean.TRUE);
        ksData.setIsOrgDefault(Boolean.FALSE);
        KickstartFactory.saveKickstartData(ksData);
        return ksData;
    }
    
    private KickstartRawData createRawData(String label, 
                                        KickstartableTree tree,
                                            String virtType) {
        KickstartBuilder builder = new KickstartBuilder(user);
        KickstartRawData data = builder.createRawData(label, tree, virtType);
        assertNotNull(data);
        assertEquals(label, data.getLabel());
        assertEquals(virtType, 
                    data.getKsdefault().getVirtualizationType().getLabel());
        assertEquals(tree, data.getKsdefault().getKstree());
        assertEquals(user.getOrg(), data.getOrg());
        return data;
    }

    public void testKickstartRawData() throws Exception {

        
        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();
        try {
            createRawData("badvirttype", tree, "whatever");
            fail();
        }
        catch (InvalidVirtualizationTypeException e) {
            // expected
        }
        createRawData("decent", tree, KickstartVirtualizationType.PARA_GUEST);
        KickstartRawData data = createRawData("boring", tree, 
                                    KickstartVirtualizationType.PARA_HOST);
        
        
    }   
    
    public void testLookupAndSaveKickstartRawData() throws Exception {
        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();
        
        KickstartRawData data = createRawData("boring" + TestUtils.randomString(), tree, 
                KickstartVirtualizationType.PARA_HOST);
        String text = "I am a genius!!!!"; 
        data.setData(text);
        KickstartFactory.saveKickstartData(data);
        long id = data.getId();
        flushAndEvict(data);
        KickstartData checker = KickstartFactory.
                    lookupKickstartDataByIdAndOrg(user.getOrg(), id);
        assertTrue(checker instanceof KickstartRawData);
        assertEquals(text, ((KickstartRawData) checker).getData());
    }
    
    public void testEncryptRootpw() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);
        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();

        List<String> lines = new LinkedList<String>();
        lines.add("rootpw blahblah");

        KickstartData ksData = createBareKickstartData();
        builder.buildCommands(ksData, lines, tree, null);
        KickstartCommand rootpw = ksData.getCommand("rootpw");
        assertTrue(rootpw.getArguments().indexOf("--iscrypted") < 0);
        assertTrue(rootpw.getArguments().startsWith("$1$"));
    }
    
    public void testBuildPackages() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);
        
        List<String> lines = new LinkedList<String>();

        lines.add("%packages");
        lines.add("@office");
        lines.add("@admin-tools");
        lines.add("@editors");
        lines.add("fuse");
        lines.add("-zsh");
        lines.add("awstats");
        
        KickstartData ksData = createBareKickstartData();
        builder.buildPackages(ksData, lines);
        assertEquals(6, ksData.getPackageNames().size());
    }
    
    public void testBuidEmptyPackages() throws Exception {
        // No idea if this is valid or not but I see no reason why the builder shouldn't
        // be ready for it:
        KickstartBuilder builder = new KickstartBuilder(user);
        List<String> lines = new LinkedList<String>();
        KickstartData ksData = createBareKickstartData();
        builder.buildPackages(ksData, lines);
        assertEquals(0, ksData.getPackageNames().size());
    }
    
    public void testBuildPreScripts() throws Exception {
        KickstartParser parser = createKickstartParser("samplekickstart1.ks");
        KickstartBuilder builder = new KickstartBuilder(user);

        List<String> lines = parser.getPreScriptLines();
        
        KickstartData ksData = createBareKickstartData();
        builder.buildPreScripts(ksData, lines);
        assertEquals(1, ksData.getScripts().size());
        KickstartScript script = (KickstartScript)ksData.getScripts().iterator().next();
        assertEquals(null, script.getInterpreter());
        assertEquals(KickstartScript.TYPE_PRE, script.getScriptType());
        assertEquals("Y", script.getChroot());
    }
    
    public void testBuildPreScriptWithInterpreter() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);

        List<String> lines = new LinkedList<String>();
        lines.add("%pre --interpreter /usr/bin/python");
        
        KickstartData ksData = createBareKickstartData();
        builder.buildPreScripts(ksData, lines);
        assertEquals(1, ksData.getScripts().size());
        KickstartScript script = (KickstartScript)ksData.getScripts().iterator().next();
        assertEquals("/usr/bin/python", script.getInterpreter());
    }
    
    public void testBuildPreScriptNewlines() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);

        List<String> lines = new LinkedList<String>();
        lines.add("%pre --interpreter /usr/bin/python");
        lines.add("a");
        lines.add("b");
        
        KickstartData ksData = createBareKickstartData();
        builder.buildPreScripts(ksData, lines);
        assertEquals(1, ksData.getScripts().size());
        KickstartScript script = (KickstartScript)ksData.getScripts().iterator().next();
        assertEquals("a\nb", script.getDataContents());
    }
    
    public void testBuildPreScriptWithMissingInterpreter() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);

        List<String> lines = new LinkedList<String>();
        lines.add("%pre --interpreter");
        
        KickstartData ksData = createBareKickstartData();
        try {
            builder.buildPreScripts(ksData, lines);
            fail();
        }
        catch (KickstartParsingException e) {
            // expected
        }
    }
    
    public void testBuildMultiplePreScripts() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);

        List<String> lines = new LinkedList<String>();
        lines.add("%pre");
        lines.add("echo hello");
        lines.add("");
        lines.add("%pre");
        lines.add("echo world");
        
        KickstartData ksData = createBareKickstartData();
        builder.buildPreScripts(ksData, lines);
        assertEquals(2, ksData.getScripts().size());
    }

    public void testBuidPreScriptWithNochroot() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);

        // Should not parse:
        List<String> lines = new LinkedList<String>();
        lines.add("%pre --nochroot");
        
        KickstartData ksData = createBareKickstartData();
        try {
            builder.buildPreScripts(ksData, lines);
            fail();
        }
        catch (KickstartParsingException e) {
            // expected
        }
    }
    
    public void testBuildPostScriptWithNochroot() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);

        List<String> lines = new LinkedList<String>();
        lines.add("%post --interpreter blah --nochroot");
        lines.add("echo hello");
        
        KickstartData ksData = createBareKickstartData();
        builder.buildPostScripts(ksData, lines);
        assertEquals(1, ksData.getScripts().size());
        KickstartScript script = ksData.getScripts().iterator().next();
        assertEquals(KickstartScript.TYPE_POST, script.getScriptType());
        assertEquals("N", script.getChroot());
    }
    
    public void testBuildScriptWithEmptyLines() throws Exception {
        KickstartBuilder builder = new KickstartBuilder(user);

        List<String> lines = new LinkedList<String>();
        
        KickstartData ksData = createBareKickstartData();
        builder.buildPostScripts(ksData, lines);
        assertEquals(0, ksData.getScripts().size());
    }
    
    public void testConstruct() throws Exception {
        KickstartParser parser = createKickstartParser("samplekickstart1.ks");
        KickstartBuilder builder = new KickstartBuilder(user);

        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();
        KickstartData ksData = builder.createFromParser(parser, "mykslabel", "none", tree, 
                null);
        assertEquals(19, ksData.getCommands().size());
        assertEquals(100, ksData.getPackageNames().size());
        assertEquals(1, ksData.getScripts().size());
        
        KickstartScript preScript = ksData.getScripts().iterator().next();
        assertEquals(KickstartScript.TYPE_PRE, preScript.getScriptType());
    }
    
    public void testConstructWithExistingLabel() throws Exception {
        KickstartParser parser = createKickstartParser("samplekickstart1.ks");
        KickstartBuilder builder = new KickstartBuilder(user);

        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();
        builder.createFromParser(parser, "mykslabel", "none", tree, null);
        try {
            builder.createFromParser(parser, "mykslabel", "none", tree, null);
            fail();
        }
        catch (LabelAlreadyExistsException e) {
            // expected
        }
    }
    
    public void testConstructWithInvaidVirtType() throws Exception {
        KickstartParser parser = createKickstartParser("samplekickstart1.ks");
        KickstartBuilder builder = new KickstartBuilder(user);

        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();
        try {
            builder.createFromParser(parser, "badvirttype", "whatever", tree, null);
            fail();
        }
        catch (InvalidVirtualizationTypeException e) {
            // expected
        }
    }
    
    public void testConstructUpgradeKickstart() throws Exception {
        KickstartParser parser = createKickstartParser("upgrade.ks");
        KickstartBuilder builder = new KickstartBuilder(user);
        
        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();
        KickstartData data = builder.createFromParser(parser, "upgrade-ks" , "none", tree, 
                null);
        
        assertNotNull(data.getCommand("upgrade"));
        assertNull(data.getCommand("install"));
    }
    
    public void testImportUseDefautDownloadLocation() throws Exception {
        KickstartParser parser = createKickstartParser("samplekickstart1.ks");
        KickstartBuilder builder = new KickstartBuilder(user);
        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();
        KickstartData data = builder.createFromParser(parser, "testing-profile" , "none", 
                tree, KICKSTART_HOST);
        
        assertNull(data.getCommand("nfs"));
        KickstartCommand urlCmd = data.getCommand("url"); 
        assertNotNull(urlCmd);
        assertTrue(urlCmd.getArguments().startsWith("http://"));
    }
    
}
