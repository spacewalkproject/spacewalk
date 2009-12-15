/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.testing;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigContent;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileState;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigInfo;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.common.ChecksumFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;

import java.util.Date;

import junit.framework.Assert;

/**
 * ConfigTestUtils
 * @version $Rev 95653 $
 */
public class ConfigTestUtils extends Assert {
    
    /**
     * Creates a test configuration channel and saves it to the database
     * with the given information.  Note: does not flush hibernate.
     * Note2: users of the same org do not automatically have access to this channel.
     * Use the giveUserChanAccess method to accomplish that.
     * @param org The org
     * @param name The channel name
     * @param label The channel label
     * @param type The channel type (from ConfigurationFactory constant types)
     * @return The newly created ConfigChannel
     */
    public static ConfigChannel createConfigChannel(Org org, String name, String label,
                                                    ConfigChannelType type) {
        ConfigChannel cc = ConfigurationFactory.newConfigChannel();
        cc.setConfigChannelType(type);
        cc.setOrg(org);
        cc.setName(name);
        cc.setLabel(label);
        cc.setDescription("test-config-channel-description-" + TestUtils.randomString());
        cc.setCreated(new Date());
        cc.setModified(new Date());
        ConfigurationFactory.saveNewConfigChannel(cc);
        assertTrue(cc.getId().longValue() > 0L);
        return cc;
    }
    
    /**
     * See createConfigChannel(Org,String,String,ConfigChannelType) 
     * @param org The org
     * @param name The channel name
     * @param label The channel label
     * @return The newly created ConfigChannel
     */
    public static ConfigChannel createConfigChannel(Org org, String name, String label) {
        return createConfigChannel(org, name, label,
                ConfigChannelType.global());
    }
    
    /**
     * See createConfigChannel(Org,String,String,ConfigChannelType)
     * @param org The org
     * @return The newly created ConfigChannel 
     */
    public static ConfigChannel createConfigChannel(Org org) {
        return createConfigChannel(org, 
                "test-config-channel-name-" + TestUtils.randomString(),
                "test-config-channel-label-" + TestUtils.randomString(),
                ConfigChannelType.global());
    }
    
    /**
     * See createConfigChannel(Org,String,String,ConfigChannelType)
     * @param org The org
     * @param type The channel type (from ConfigurationFactory constant types)
     * @return The newly created ConfigChannel 
     */
    public static ConfigChannel createConfigChannel(Org org, ConfigChannelType type) {
        return createConfigChannel(org, 
                "test-config-channel-name-" + TestUtils.randomString(),
                "test-config-channel-label-" + TestUtils.randomString(),
                type);
    }
    
    /**
     * See createConfigFile(ConfigChannel, ConfigFileState, ConfigFileName).
     * Will create a ConfigChannel for this file to live in.
     * @param org The org that this file will belong to.
     * @return The newly created ConfigFile
     */
    public static ConfigFile createConfigFile(Org org) {
        ConfigChannel cc = createConfigChannel(org);
        ConfigFileState state = ConfigFileState.normal();
        String name = "test-name" + TestUtils.randomString();
        return cc.createConfigFile(state, name);
    }
    
    /**
     * See createConfigFile(ConfigChannel, ConfigFileState, ConfigFileName).
     * @param channel The channel that this file belongs to.
     * @return The newly created ConfigFile
     */
    public static ConfigFile createConfigFile(ConfigChannel channel) {
        ConfigFileState state = ConfigFileState.normal();
        String name = "test-name" + TestUtils.randomString();
        return channel.createConfigFile(state, name);
    }
    
    /**
     * See createConfigFile(ConfigChannel, ConfigFileState, ConfigFileName).
     * Will create a ConfigChannel for this file to live in.
     * @param org The org that this file will belong to.
     * @param path The path on the system for this config file.
     * @return The newly created ConfigFile
     */
    public static ConfigFile createConfigFile(Org org, String path) {
        ConfigChannel cc = createConfigChannel(org);
        ConfigFileState state = ConfigFileState.normal();
        return cc.createConfigFile(state, path);
    }
    
    /**
     * See createConfigFile(ConfigChannel, ConfigFileState, ConfigFileName).
     * Will create a ConfigChannel for this file to live in.
     * @param org The org that this file will belong to.
     * @param state The state of the file (dead or alive)
     * @return The newly created ConfigFile
     */
    public static ConfigFile createConfigFile(Org org, ConfigFileState state) {
        ConfigChannel cc = createConfigChannel(org);
        String name = "test-name" + TestUtils.randomString();
        return cc.createConfigFile(state, name);
    }
    
    /**
     * See createConfigFile(ConfigChannel, ConfigFileState, ConfigFileName).
     * @param channel The channel for this file to live in
     * @param state The state of the file (dead or alive)
     * @return The newly created ConfigFile
     */
    public static ConfigFile createConfigFile(ConfigChannel channel,
            ConfigFileState state) {
        String name = "test-name" + TestUtils.randomString();
        return channel.createConfigFile(state, name);
    }
    
    /**
     * Creates a test configuration revision and saves it to the database
     * with the given information.  Note: does not flush hibernate.
     * Note2: users of the same org do not automatically have access to this revision.
     * See rhn_config_channel.get_user_revision_access
     * @param file The file for this revision to belong to.
     * @param content The content of this revision. 
     * @param info Permissions and file information.
     * @param revision The revision number.
     * @return The newly created ConfigRevision
     */
    public static ConfigRevision createConfigRevision(ConfigFile file,
            ConfigContent content, ConfigInfo info, Long revision) {
        return createConfigRevision(file, content, info, revision, 
                                    ConfigFileType.file());
    }
    
    /**
     * Creates a test configuration revision and saves it to the database
     * with the given information.  Note: does not flush hibernate.
     * Note2: users of the same org do not automatically have access to this revision.
     * See rhn_config_channel.get_user_revision_access
     * @param file The file for this revision to belong to.
     * @param content The content of this revision. 
     * @param info Permissions and file information.
     * @param revision The revision number.
     * @param type the desired fileType for this revision  
     * @return The newly created ConfigRevision
     * 
     */
    public static ConfigRevision createConfigRevision(ConfigFile file,
            ConfigContent content, ConfigInfo info, Long revision, 
            ConfigFileType type) {
        ConfigRevision cr = ConfigurationFactory.newConfigRevision();
        cr.setRevision(revision);
        cr.setCreated(new Date());
        cr.setModified(new Date());
        cr.setConfigContent(content);
        cr.setDelimStart("{@");
        cr.setDelimEnd("@}");
        cr.setConfigFile(file);
        cr.setConfigInfo(info);
        cr.setConfigFileType(type);            
        ConfigurationFactory.commit(cr);
        return cr;
    }    
    
    /**
     * See createConfigRevision(ConfigFile, ConfigContent, ConfigInfo, Long).
     * @param file The file for this revision to belong to.
     * @param revision The revision number.
     * @return The newly created ConfigRevision.
     */
    public static ConfigRevision createConfigRevision(ConfigFile file, Long revision) {
        ConfigContent content = createConfigContent();
        ConfigInfo info = createConfigInfo();
        return createConfigRevision(file, content, info, revision);
    }
    
    /**
     * See createConfigRevision(ConfigFile, ConfigContent, ConfigInfo, Long).
     * @param file The file for this revision to belong to.
     * @param type the desired fileType for this revision
     * @return The newly created ConfigRevision.
     */
    public static ConfigRevision createConfigRevision(ConfigFile file, 
                                                        ConfigFileType type) {
        ConfigInfo info = createConfigInfo();
        Long revision = new Long(1);
        ConfigContent content = createConfigContent();
        if (!ConfigFileType.dir().equals(type)) {
            content.setContents(null);
            content.setBinary(false);
            content.setFileSize(new Long(0));
        }
        return createConfigRevision(file, content, info, revision, type);    
    } 
     
    /**
     * See createConfigRevision(ConfigFile, ConfigContent, ConfigInfo, Long).
     * @param file The file for this revision to belong to.
     * @return The newly created ConfigRevision.
     */
    public static ConfigRevision createConfigRevision(ConfigFile file) {
        return createConfigRevision(file, 
                    ConfigFileType.file());
    }
    
    /**
     * See createConfigRevision(ConfigFile, ConfigContent, ConfigInfo, Long).
     * Will create a ConfigFile and ConfigChannel for this ConfigRevision to belong to.
     * @param org The org for this file to belong to.
     * @return The newly created ConfigRevision.
     */
    public static ConfigRevision createConfigRevision(Org org) {
        ConfigFile file = createConfigFile(org);
        ConfigContent content = createConfigContent();
        ConfigInfo info = createConfigInfo();
        Long revision = new Long(1);
        return createConfigRevision(file, content, info, revision);
    }
    
    /**
     * Creates a test ConfigContent with the given information.
     * The ConfigContent is not saved and can not be saved until associated with a
     * ConfigRevision.
     * @param fileSize The supposed size of the contents.
     * @param isBinary Whether the contents are binary.
     * @return The newly created ConfigContent.
     */
    public static ConfigContent createConfigContent(Long fileSize, boolean isBinary) {
        ConfigContent cc = ConfigurationFactory.newConfigContent();
        cc.setChecksum(ChecksumFactory.safeCreate(
            "d41d8cd98f00b204e9800998ecf8427e", "md5"));
        cc.setContents(new byte[0]);
        cc.setFileSize(fileSize);
        cc.setBinary(isBinary);
        cc.setCreated(new Date());
        cc.setModified(new Date());
        return cc;
    }
    
    /**
     * See createConfigContent(Long, boolean)
     * @return The newly created ConfigContent.
     */
    public static ConfigContent createConfigContent() {
        Long size = new Long(0);
        return createConfigContent(size, false);
    }
    
    /**
     * Creates a test ConfigInfo with the given information.
     * The ConfigInfo is not saved and can not be saved until associated with a
     * ConfigRevision.
     * @param user The owner of the file.
     * @param group The group for the file.
     * @param fileMode The three-digit permissions for the file.
     * @return The newly created ConfigInfo.
     */
    public static ConfigInfo createConfigInfo(String user, String group, Long fileMode) {
        return ConfigurationFactory.lookupOrInsertConfigInfo(user, group, fileMode, "");
    }
    
    /**
     * See createConfigInfo(String, String, Long)
     * @param fileMode The three-digit permissions for the file.
     * @return The newly created ConfigInfo.
     */
    public static ConfigInfo createConfigInfo(Long fileMode) {
        String user = "rhnjava";
        return createConfigInfo(user, user, fileMode);
    }
    
    /**
     * See createConfigInfo(String, String, Long)
     * @return The newly created ConfigInfo.
     */
    public static ConfigInfo createConfigInfo() {
        String user = "rhnjava";
        Long fileMode = new Long(655);
        return createConfigInfo(user, user, fileMode);
    }
    
    /**
     * This method will give a user access to a channel (as dictated by the database
     * function rhn_config_channel.get_user_chan_access).  This method will create a
     * server for the given user and subscribe that server to the given config channel
     * as long as both the channel and the user belong to the same org.  Alternatively,
     * if you don't wish to create a server for the user, giving the user config_admin
     * or org_admin status will also give them acces to the config channel.
     * 
     * Note: Giving access to config files and config revisions is done the same way.
     * Just give the user access the channel and they will have access to all files and
     * revisions in that channel. (satisfying rhn_config_channel.get_user_*_access)
     * @param user The user to be given access.
     * @param channel The channel for which to give access.
     * @return The server created and subscribed to the config channel.
     * @throws Exception yep.
     */
    public static Server giveUserChanAccess(User user, ConfigChannel channel) 
                throws Exception {
        if (!user.getOrg().getId().equals(channel.getOrgId())) {
            throw new IllegalArgumentException("User and channel " +
                    "must be from the same org!");
        }
        Server srv = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());
        if (channel.isGlobalChannel()) {
            srv.subscribe(channel);    
        }
        else if (channel.isLocalChannel()) {
            srv.setLocalOverride(channel);
        }
        else if (channel.isSandboxChannel()) {
            srv.setSandboxOverride(channel);
        }
        
        return srv;
    }
    
    /**
     * Creating revisions requires org quota because they take up quota.
     * This must be called before creating a revision, but it need only
     * be called once.
     * @param org The org we are giving quota.
     */
    public static void giveOrgQuota(Org org) {
        //there is no quota in satellite...  is unlimited.
    }
    
    /**
     * Gives  all the config capabilites to a server
     * @param server the server that you want to be config enabled
     * @throws Exception In the case of DB errors or sql exceptions.
     */
    public static void giveConfigCapabilities(Server server) throws Exception {
        SystemManagerTest.giveCapability(server.getId(), 
                SystemManager.CAP_CONFIGFILES_DEPLOY, 1L);
        SystemManagerTest.giveCapability(server.getId(), 
                 SystemManager.CAP_CONFIGFILES_DIFF, 1L);
        
        SystemManagerTest.giveCapability(server.getId(), 
                SystemManager.CAP_CONFIGFILES_BASE64_ENC, 1L);
        
        SystemManagerTest.giveCapability(server.getId(), 
                SystemManager.CAP_CONFIGFILES_UPLOAD, 1L);
        SystemManagerTest.giveCapability(server.getId(), 
                SystemManager.CAP_CONFIGFILES_MTIME_UPLOAD, 1L);
        
    }
}
