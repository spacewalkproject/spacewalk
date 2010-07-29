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
package com.redhat.rhn.domain.config.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigContent;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.config.ConfigFileState;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigInfo;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.tools.ant.filters.StringInputStream;
import org.hibernate.Session;

import java.util.Date;

public class ConfigurationFactoryTest extends RhnBaseTestCase {

    private User user;

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        user = UserTestUtils.findNewUser("testyman", "testyorg");
    }

    @Override
    protected void tearDown() throws Exception {
        user = null;
        super.tearDown();
    }

    public void testLookupConfigChannelType() throws Exception {
        assertNotNull(ConfigChannelType.global());
        assertNotNull(ConfigChannelType.sandbox());
        assertNotNull(ConfigChannelType.local());
    }

    public void testLookupConfigFileType() throws Exception {
        assertNotNull(ConfigFileType.dir());
        assertEquals(ConfigFileType.DIR,
                ConfigFileType.dir().getLabel());
        assertNotNull(ConfigFileType.file());
        assertEquals(ConfigFileType.FILE,
                ConfigFileType.file().getLabel());
    }

    public void testLookupConfigFileState() throws Exception {
        assertNotNull(ConfigFileState.normal());
        assertNotNull(ConfigFileState.dead());
    }

    public void testSaveNewConfigChannel() {
        String label = "testlabel";
        ConfigChannel channel = ConfigurationFactory.saveNewConfigChannel(user.getOrg(),
                ConfigChannelType.global(), "testname",
                label, "testdescription");
        assertNotNull(channel.getId());

        //evict it so we can look it back up
        flushAndEvict(channel);

        ConfigChannel channel2 =
            ConfigurationFactory.lookupConfigChannelById(channel.getId());
        assertNotNull(channel2);
        assertEquals(channel.getName(), channel2.getName());

        //now change something and hopefully avoid a database problem.
        channel2.setName("newName");
        ConfigurationFactory.commit(channel2);
        //now look up the new way
        ConfigChannel channel3 =
            ConfigurationFactory.lookupConfigChannelByLabel(label, user.getOrg(),
                                    ConfigChannelType.global()
                                    );
        assertEquals(channel2, channel3);

    }

    public void testSaveNewConfigFile() {
        //Create a channel to put the file in
        ConfigChannel channel = ConfigTestUtils.createConfigChannel(user.getOrg());

        //Create a config file
        ConfigFile file = channel.createConfigFile(
                ConfigFileState.dead(), "testname");
        assertNotNull(file.getId());

        //evict it so we can look it back up
        flushAndEvict(file);

        ConfigFile file2 = ConfigurationFactory.lookupConfigFileById(file.getId());
        assertNotNull(file2);
        assertEquals(file.getConfigFileName().getPath(),
                file2.getConfigFileName().getPath());

        //now change something and hopefully avoid database problem
        file2.setModified(new Date());
        ConfigurationFactory.commit(file2);
    }

    public void testSaveNewConfigRevision() {

        //Create a file to put this revision in
        ConfigFile file = ConfigTestUtils.createConfigFile(user.getOrg());

        //Create a content and info to put into this revision
        ConfigContent content = ConfigTestUtils.createConfigContent(new Long(234L), true);
        ConfigInfo info = ConfigTestUtils.createConfigInfo("root", "root", new Long(777));
        commitAndCloseSession();
        //Create a config revision
        ConfigRevision revision =
            ConfigTestUtils.createConfigRevision(file, content, info, new Long(23));
        assertNotNull(revision.getId());

        //evict it so we can look it back up
        flushAndEvict(revision);

        ConfigRevision revision2 =
            ConfigurationFactory.lookupConfigRevisionById(revision.getId());
        assertNotNull(revision2);
        assertEquals(revision.getRevision(), revision2.getRevision());
        ConfigurationFactory.commit(revision2);
    }

    public void testLookupOrInsertConfigInfo() {

        //one problem is that looking up the same thing must be done in such a way that
        //hibernate doesn't yell about it.
        ConfigInfo info1 = ConfigurationFactory.lookupOrInsertConfigInfo("testman",
                "testgroup", new Long(665), "", null);
        ConfigInfo info2 = ConfigurationFactory.lookupOrInsertConfigInfo("testman",
                "testgroup", new Long(665), "", null);
        assertNotNull(info1.getId());
        assertNotNull(info2.getId());
        assertEquals(info1.getId(), info2.getId());

        //now let's add them to two different ConfigRevisions and make sure that we don't
        //have any trouble saving them.
        ConfigFile file = ConfigTestUtils.createConfigFile(user.getOrg());
        ConfigContent content = ConfigTestUtils.createConfigContent();

        ConfigRevision rev1 =
            ConfigTestUtils.createConfigRevision(file, content, info1, new Long(1));
        ConfigRevision rev2 =
            ConfigTestUtils.createConfigRevision(file, content, info2, new Long(2));

        //The revisions have now been inserted,  now let's see if hibernate can handle
        //an update for them.
        ConfigurationFactory.commit(rev1);
        ConfigurationFactory.commit(rev2);
    }

    public void testLookupOrInsertConfigFileName() {
        //one problem is that looking up the same thing must be done in such a way that
        //hibernate doesn't yell about it.
        String filename = "/etc/" + TestUtils.randomString();
        ConfigFileName name1 = ConfigurationFactory.lookupOrInsertConfigFileName(filename);
        ConfigFileName name2 = ConfigurationFactory.lookupOrInsertConfigFileName(filename);
        assertNotNull(name1.getId());
        assertNotNull(name2.getId());
        assertEquals(name1.getId(), name2.getId());

        //now let's add them to two different ConfigFiles and make sure that we don't
        //have any trouble saving them.
        ConfigChannel channel = ConfigTestUtils.createConfigChannel(user.getOrg());
        ConfigChannel channel2 = ConfigTestUtils.createConfigChannel(user.getOrg());

        ConfigFile file1 = channel.createConfigFile(
                ConfigFileState.normal(), name1);
        ConfigFile file2 = channel2.createConfigFile(
                ConfigFileState.normal(), name1);


        //The files have now been inserted,  now let's see if hibernate can handle
        //an update for them.
        ConfigurationFactory.commit(file1);
        ConfigurationFactory.commit(file2);
    }

    public void testRemoveConfigChannel() {

        //Let's create a channel/file/revision
        ConfigRevision cr = ConfigTestUtils.createConfigRevision(user.getOrg());
        ConfigChannel channel = cr.getConfigFile().getConfigChannel();
        assertNotNull(cr.getId());

        //now let's create another file in this channel without a revision,
        //just to test things out.
        ConfigFile file = ConfigTestUtils.createConfigFile(channel);
        assertNotNull(file.getId());

        //We have to evict everything from the session so that hibernate
        //doesn't complain that we removed things out from under its feet.
        Session session = HibernateFactory.getSession();
        session.flush();
        session.evict(channel);
        //session.evict(file); //TODO: figure out why we don't have to evict this one.
        session.evict(cr.getConfigFile());
        session.evict(cr);

        //run the method we are testing
        ConfigurationFactory.removeConfigChannel(channel);

        //confirm that the channel is gone.
        assertNull(ConfigurationFactory.lookupConfigChannelById(channel.getId()));
        //and everything that was in the channel.
        assertNull(ConfigurationFactory.lookupConfigFileById(file.getId()));
        assertNull(ConfigurationFactory.lookupConfigFileById(cr.getConfigFile().getId()));
        assertNull(ConfigurationFactory.lookupConfigRevisionById(cr.getId()));
    }

    public void testCreateNewRevisionFromStream() throws Exception {
        String startData = "this is some original data";
        StringInputStream stream = new StringInputStream(startData);
        ConfigRevision cr = ConfigTestUtils.createConfigRevision(user.getOrg());
        ConfigRevision cr2 = ConfigurationFactory.createNewRevisionFromStream(
                user, stream, new Long(startData.length()), cr.getConfigFile());
        assertEquals(user.getId(), cr2.getChangedById());
        assertEquals(user.getLogin(), cr2.getChangedBy().getLogin());
    }
}
