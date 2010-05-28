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
package com.redhat.rhn.domain.config;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.domain.common.Checksum;
import com.redhat.rhn.domain.common.ChecksumFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;
import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Types;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ConfigurationFactory.  For use when dealing with ConfigChannel, ConfigChannelType,
 * ConfigFile, ConfigRevision, ConfigFileState, ConfigContent, and ConfigInfo.
 * 
 * When saving config channels, config files, and config revisions: please use the
 * commitConfigBlah methods.
 * @version $Rev$
 */
public class ConfigurationFactory extends HibernateFactory {
    private static ConfigurationFactory singleton = new ConfigurationFactory();
    private static Logger log = Logger.getLogger(ConfigurationFactory.class);
    
    private ConfigurationFactory() {
        super();
    }
    
    protected Logger getLogger() {
        return log;
    }
    
    /**
     * Create a new ConfigFile object.
     * @return new ConfigFile object
     */
    public static ConfigFile newConfigFile() {
        return new ConfigFile();
    }
    
    /**
     * Create a new ConfigRevision object.
     * @return new ConfigRevision object
     */
    public static ConfigRevision newConfigRevision() {
        ConfigRevision cr = new ConfigRevision();
        Date now = new Date();
        cr.setRevision(new Long(1));
        cr.setCreated(now);
        cr.setModified(now);
        return cr;
    }
    
    /**
     * Create a new ConfigChannel object.
     * @return new ConfigChannel object
     */
    public static ConfigChannel newConfigChannel() {
        return new ConfigChannel();
    }
    
    /**
     * Create a new ConfigContent object.
     * @return new ConfigContent object
     */
    public static ConfigContent newConfigContent() {
        return new ConfigContent();
    }
    
    /**
     * Create and save a new configuration channel.
     * This method creates a configuration channel and then uses the
     * saveNewConfigChannel(ConfigChannel) method to save it.
     * @param org The org for this configuration channel.
     * @param type The type.  Please use the constants located in this class.
     * @param name The name of this configuration channel.
     * @param label The label for this configuration channel.
     * @param description The description of this configuration channel.
     * @return The newly saved configuration channel.
     */
    public static ConfigChannel saveNewConfigChannel(Org org, ConfigChannelType type,
            String name, String label, String description) {
        ConfigChannel out = new ConfigChannel();
        out.setOrg(org);
        out.setName(name);
        out.setLabel(label);
        out.setDescription(description);
        out.setConfigChannelType(type);
        saveNewConfigChannel(out);
        return out;
    }
    
    /**
     * Save a new configuration channel.
     * Note, this method uses a stored procedure, so it must be used for all newly
     * created configuration channels.  
     * @param channel The channel object to persist.
     */
    public static void saveNewConfigChannel(ConfigChannel channel) {
        CallableMode m = ModeFactory.getCallableMode("config_queries",
            "create_new_config_channel");
        Map inParams = new HashMap();
        Map outParams = new HashMap();
    
        inParams.put("org_id_in", channel.getOrgId());
        inParams.put("type_in", channel.getConfigChannelType().getLabel());
        inParams.put("name_in", channel.getName());
        inParams.put("label_in", channel.getLabel()); 
        inParams.put("description_in", channel.getDescription());
        //Outparam
        outParams.put("channelId", new Integer(Types.NUMERIC));
        
        Map result = m.execute(inParams, outParams);
    
        Long channelId = (Long) result.get("channelId");
        channel.setId(channelId);
    }
    
    /**
     * Save a new configuration file.
     * Note, this method uses a stored procedure, so it must be used for all newly
     * created configuration files.
     * NOTE: This configuration file must have a persisted configuration channel
     *       attached to it.  config channels also used stored procedures for
     *       insertions, so we can't simply ask hibernate to save it for us.
     * @param file The configuration file to persist
     */
    public static void saveNewConfigFile(ConfigFile file) {
        //This is designed to catch some of the cases in which the config channel
        //was not saved before the config file.
        //There is still the possibility that the config channel hasn't been committed to
        //the database yet, but someone has set its id.  This should never happen from the
        //web site, but it might happen from tests.
        if (file.getConfigChannel() == null || file.getConfigChannel().getId() == null) {
            throw new IllegalStateException("Config Channels must be " +
                    "saved before config files");
        }
        
        //Have to commit the configFileName before we commit the 
        // ConfigFile so the stored proc will have an ID to work with
        singleton.saveObject(file.getConfigFileName());

        CallableMode m = ModeFactory.getCallableMode("config_queries",
            "create_new_config_file");
        Map inParams = new HashMap();
        Map outParams = new HashMap();
        
        //this will generate a foreign-key constraint violation if the config
        //channel is not already persisted.
        inParams.put("config_channel_id_in", file.getConfigChannel().getId());
        inParams.put("name_in", file.getConfigFileName().getPath());
        // Outparam
        outParams.put("configFileId", new Integer(Types.NUMERIC));
        
        Map result = m.execute(inParams, outParams);
        file.setId((Long)result.get("configFileId"));
    }
    
    /**
     * Save a new ConfigRevision.
     * Note, this method uses a stored procedure, so it must be used for all newly
     * created configuration revisions.
     * NOTE: This configuration revision must have a persisted config file 
     *       attached to it.  config files also used stored procedures for
     *       insertions, so we can't simply ask hibernate to save it for us.
     * @param revision the new ConfigRevision we want to store.
     */
    public static void saveNewConfigRevision(ConfigRevision revision) {
        //This is designed to catch some of the cases in which the config file
        //was not saved before the config revision.
        //There is still the possibility that the config file hasn't been committed to
        //the database yet, but someone has set its id.  This should never happen from the
        //web site, but it might happen from tests.
        if (revision.getConfigFile() == null || revision.getConfigFile().getId() == null) {
            throw new IllegalStateException("Config Channels must be " +
                    "saved before config files");
        }
        
        CallableMode m = ModeFactory.getCallableMode("config_queries",
                            "create_new_config_revision");
        
        //We need to save the content first so that we have an id for
        // the stored procedure.
        singleton.saveObject(revision.getConfigContent());
        //We do not have to save the ConfigInfo, because the info should always already be
        // in the database.  If this is not the case, please read the documentation for
        // lookupOrInsertConfigInfo(String, String, Long) and correct the problem.
        
        Map inParams = new HashMap();
        Map outParams = new HashMap();
        
        inParams.put("revision_in", revision.getRevision());
        inParams.put("config_file_id_in", revision.getConfigFile().getId());
        inParams.put("config_content_id_in", revision.getConfigContent().getId());
        inParams.put("config_info_id_in", revision.getConfigInfo().getId());
        inParams.put("delim_start_in", revision.getDelimStart());
        inParams.put("delim_end_in", revision.getDelimEnd());
        inParams.put("config_file_type_id", new Long(
                            revision.getConfigFileType().getId()));

        // Outparam
        outParams.put("configRevisionId", new Integer(Types.NUMERIC));
        
        Map result = m.execute(inParams, outParams);
        
        revision.setId((Long)result.get("configRevisionId"));
    }
    
    private static void save(ConfigChannel channel) {
        singleton.saveObject(channel);
    }
    
    private static void save(ConfigFile file) {
        singleton.saveObject(file);
    }
    
    private static void save(ConfigRevision revision) {
        singleton.saveObject(revision);
    }
    
    /**
     * Save or update a config channel.  Since config channels
     * use a stored procedure for inserting, we have to decide whether to
     * insert or update here.  If the channel's id is null, we insert.
     * @param channel The channel to save or update
     */
    public static void commit(ConfigChannel channel) {
        if (channel.getId() == null) {
            saveNewConfigChannel(channel);
        }
        else {
            save(channel);
        }
    }
    
    /**
     * Save or update a config file.  Since config files
     * use a stored procedure for inserting, we have to decide whether to
     * insert or update here.  If the file's id is null, we insert.
     * @param file The file to save or update
     */
    public static void commit(ConfigFile file) {
        commit(file.getConfigChannel());
        if (file.getId() == null) {
            saveNewConfigFile(file);
        }
        else {
            save(file);
        }
    }
    
    /**
     * Save or update a config revision.  Since config revisions
     * use a stored procedure for inserting, we have to decide whether to
     * insert or update here.  If the revision's id is null, we insert.
     * @param revision The revision to save or update
     */
    public static void commit(ConfigRevision revision) {
        ConfigFile file = revision.getConfigFile();
        commit(file);
        if (revision.getId() == null) {
            saveNewConfigRevision(revision);
            file.setLatestConfigRevision(revision);
            //and now we have to save the file again
            //it would be nice to save it only once, but we require the file id
            //in order to save the revision and the latestConfigRevision is the
            //revision id.
            commit(file);
        }
        else {
            //ConfigInfos have a unique constraint for their four data fields.
            //The config info object associated with this revision may have been
            //changed, so we need to carefully not update the database record.
            ConfigInfo info = lookupOrInsertConfigInfo(
                    revision.getConfigInfo().getUsername(),
                    revision.getConfigInfo().getGroupname(),
                    revision.getConfigInfo().getFilemode(),
                    revision.getConfigInfo().getSelinuxCtx());
            //if the object did not change, we now have two hibernate objects
            //with the same identifier.  Evict one so that hibernate doesn't get mad.
            getSession().evict(revision.getConfigInfo());
            revision.setConfigInfo(info);
        }
        // And now, because saveNewConfigRevision doesn't store -every-thing
        // about a revision, we have to commit it -again-.  Sigh.  See BZ212236
        save(revision);
    }
    
    /**
     * Lookup a ConfigChannel by its id
     * @param id The identifier for the ConfigChannel
     * @return the ConfigChannel found or null if not found.
     */
    public static ConfigChannel lookupConfigChannelById(Long id) {
        Session session = HibernateFactory.getSession();
        ConfigChannel c = (ConfigChannel)session.get(ConfigChannel.class, id);
        return c;
    }

    /**
     * Lookup a ConfigChannel by its label. A config channel 
     * is uniquely identified by label, org id and channel type
     * @param label The label for the ConfigChannel
     * @param org the org to which the config channel belongs.
     * @param cct the config channel type of the config channel.
     * @return the ConfigChannel found or null if not found.
     */
    public static ConfigChannel lookupConfigChannelByLabel(String label,
                                                            Org org,
                                                          ConfigChannelType cct) {
        Session session = HibernateFactory.getSession();
        ConfigChannel c = (ConfigChannel) session.createCriteria(ConfigChannel.class).
                        add(Restrictions.eq("org", org)).
                        add(Restrictions.eq("label", label)).
                        add(Restrictions.eq("configChannelType", cct)).
                        uniqueResult();
        return c;
    }    

    /**
     * Lookup a ConfigFile by its id
     * @param id The identifier for the ConfigFile
     * @return the ConfigFile found or null if not found.
     */
    public static ConfigFile lookupConfigFileById(Long id) {
        Session session = HibernateFactory.getSession();
        ConfigFile c = (ConfigFile)session.get(ConfigFile.class, id);
        return c;
    }
    
    /**
     * Lookup a ConfigFile by its channel's id and config file name's id
     * @param channel The file's config channel id
     * @param name The file's config file name id
     * @return the ConfigFile found or null if not found.
     */
    public static ConfigFile lookupConfigFileByChannelAndName(Long channel, Long name) {
        Session session = HibernateFactory.getSession();
        return (ConfigFile)
            session.getNamedQuery("ConfigFile.findByChannelAndName")
                    .setLong("channel_id", channel.longValue())
                    .setLong("name_id", name.longValue())
                    .setLong("state_id", ConfigFileState.normal().
                                                    getId().longValue())
                    //Retrieve from cache if there
                    .setCacheable(true)
                    .uniqueResult();
    }
    
    /**
     * Finds a ConfigRevision from the database with a given id.
     * @param id The identifier for the ConfigRevision
     * @return The sought for ConfigRevision or null if not found.
     */
    public static ConfigRevision lookupConfigRevisionById(Long id) {
        Session session = HibernateFactory.getSession();
        ConfigRevision a = (ConfigRevision)session.get(ConfigRevision.class, id);
        return a;
    }
    
    /**
     * Finds a ConfigInfo from the database with a given id.
     * @param id The identifier for the ConfigInfo
     * @return The sought for ConfigInfo or null if not found.
     */
    public static ConfigInfo lookupConfigInfoById(Long id) {
        Session session = HibernateFactory.getSession();
        ConfigInfo c = (ConfigInfo)session.get(ConfigInfo.class, id);
        return c;
    }
    
    /**
     * Finds a ConfigFileName from the database with a given id.
     * @param id The identifier for the ConfigFileName
     * @return The sought for ConfigFileName or null if not found.
     */
    public static ConfigFileName lookupConfigFileNameById(Long id) {
        Session session = HibernateFactory.getSession();
        ConfigFileName c = (ConfigFileName)session.get(ConfigFileName.class, id);
        return c;
    }
    
    
    /**
     * Used to look up ConfigChannelTypes.  Note: there is a static list of
     * ConfigChannelTypes and therefore a static list of labels.  This method
     * is private because there are public static member variables for each
     * ConfigChannelType
     * @param label The unique label of the type.
     * @return A sought for ConfigChannelType or null
     */
     static ConfigChannelType lookupConfigChannelTypeByLabel(String label) {
        Session session = HibernateFactory.getSession();
        return (ConfigChannelType)
            session.getNamedQuery("ConfigChannelType.findByLabel")
                                        .setString("label", label)
                                        //Retrieve from cache if there
                                        .setCacheable(true)
                                        .uniqueResult();
    }
    

     /**
      * List all Config channels for an org
      * @param org the org
      * @return the config chanenls
      */
      public static List<ConfigChannel> listConfigChannels(Org org) {
         Session session = HibernateFactory.getSession();
         Map params = new HashMap();
         params.put("org", org);
         return singleton.listObjectsByNamedQuery("ConfigChannel.listByOrg", params);
     }


    /**
     * Used to look up ConfigFileStates.  Note: there is a static list of
     * ConfigFileStates and therefore a static list of labels.  This method
     * is private because there are public static member variables for each
     * ConfigChannelType
     * @param label The unique label of the type.
     * @return A sought for ConfigFileState or null
     */
    static ConfigFileState lookupConfigFileStateByLabel(String label) {
        Session session = HibernateFactory.getSession();
        return (ConfigFileState)session.getNamedQuery("ConfigFileState.findByLabel")
                                       .setString("label", label)
                                       //Retrieve from cache if there
                                       .setCacheable(true)
                                       .uniqueResult();
    }
    
    /**
     * Returns the the config file types associted to the given label 
     * @param label the filte type label
     * @return config filetype object
     */
    static ConfigFileType lookupConfigFileTypeByLabel(String label) {
        Session session = HibernateFactory.getSession();
        return (ConfigFileType)session.getNamedQuery("ConfigFileType.findByLabel")
                                       .setString("label", label)
                                       //Retrieve from cache if there
                                       .setCacheable(true)
                                       .uniqueResult();
    }

    /**
     * Return a <code>ConfigInfo</code> from the username, groupname, file mode, and
     * selinux context. If no corresponding entry exists yet in the database, one will be
     * created.
     * 
     * Uses the stored procedure <code>lookup_config_info</code> to get the id of the
     * ConfigInfo and then uses hibernate to lookup using that id.
     * 
     * Note: we should use the stored procedure because it is autonomous and avoids race
     * conditions. However, we also need to make sure that hibernate knows that the object
     * already exists in the database.  Therefore after storing it, instead of simply
     * creating the object in java, we ask hibernate to look it up (which will find the
     * correct created and modified dates as well).
     * 
     * ConfigInfo's have a unique constraint around username, groupname, and filemode
     * so we can't just create them willy nilly.
     * 
     * @param username The linux username associated with a file
     * @param groupname The linux groupname associated with a file
     * @param filemode The three digit file mode (ex: 655)
     * @param selinuxCtx The SELinux context
     * @return The ConfigInfo found or inserted.
     */
    public static ConfigInfo lookupOrInsertConfigInfo(String username,
            String groupname, Long filemode, String selinuxCtx) {
        Long id = lookupConfigInfo(username, groupname, filemode, selinuxCtx);
        return lookupConfigInfoById(id);
    }
    
    /**
     * Using a stored procedure that looks up the config info and will
     * create one if it does not exist.
     * @param user The linux username associated with a file
     * @param group The linux groupname associated with a file
     * @param filemode The three digit file mode (ex: 655)
     * @param selinuxCtx The SELinux context
     * @return The id of the found config info
     */
    private static Long lookupConfigInfo(String user, String group,
            Long filemode, String selinuxCtx) {
        CallableMode m = ModeFactory.getCallableMode("config_queries",
            "lookup_config_info");

        Map inParams = new HashMap();
        Map outParams = new HashMap();

        inParams.put("username_in", user);
        inParams.put("groupname_in", group);
        inParams.put("filemode_in", filemode);
        inParams.put("selinuxCtx_in", selinuxCtx);
        outParams.put("info_id", new Integer(Types.NUMERIC));

        Map out = m.execute(inParams, outParams);

        return (Long)out.get("info_id");
    }
    
    /**
     * Return a <code>ConfigFileName</code> for the path given. If no corresponding
     * entry exists yet in the database, one will be created.
     * 
     * Uses the stored procedure <code>lookup_config_filename</code> to get the id of the
     * ConfigFileName and then uses hibernate to lookup using that id.
     * 
     * Note: we should use the stored procedure because it is autonomous and avoids race
     * conditions. However, we also need to make sure that hibernate knows that the object
     * already exists in the database.  Therefore after storing it, instead of simply
     * creating the object in java, we ask hibernate to look it up (which will find the
     * correct created and modified dates as well).
     * 
     * ConfigFileName's have a unique constraint around path so we can't just create
     * them willy nilly.
     * 
     * @param path the path for the <code>ConfigFileName</code>
     * @return The <code>ConfigFileName</code> found
     */
    public static ConfigFileName lookupOrInsertConfigFileName(String path) {
        Long id = lookupConfigFileName(path);
        return lookupConfigFileNameById(id);
    }
    
    /**
     * Using a stored procedure that looks up the config file name and will
     * create one if it does not exist.
     * @param path the path for the <code>ConfigFileName</code>
     * @return The id of the found config file name
     */
    private static Long lookupConfigFileName(String path) {
        CallableMode m = ModeFactory.getCallableMode("config_queries",
            "lookup_config_filename");

        Map inParams = new HashMap();
        Map outParams = new HashMap();

        inParams.put("name_in", path);
        outParams.put("name_id", new Integer(Types.NUMERIC));

        Map out = m.execute(inParams, outParams);

        return (Long)out.get("name_id");
    }
    
    /**
     * Remove a ConfigChannel.
     * This uses a stored procedure and the stored procedure is required
     * as it performs logic to determine the amount of org quota is now
     * used and appropriately updates those tables.
     * @param channel Channel to remove
     */
    public static void removeConfigChannel(ConfigChannel channel) {
        CallableMode m = ModeFactory.getCallableMode("config_queries",
            "remove_config_channel");

        Map inParams = new HashMap();
        Map outParams = new HashMap();
        inParams.put("config_channel_id_in", channel.getId());
        m.execute(inParams, outParams);
    }
    
    /**
     * Remove a ConfigFile.
     * This uses a stored procedure and the stored procedure is required
     * as it performs logic to determine the amount of org quota is now
     * used and appropriately updates those tables.
     * @param file Config File to remove
     */
    public static void removeConfigFile(ConfigFile file) {
        CallableMode m = ModeFactory.getCallableMode("config_queries",
            "remove_config_file");

        Map inParams = new HashMap();
        Map outParams = new HashMap();
        inParams.put("config_file_id_in", file.getId());
        m.execute(inParams, outParams);
    }
    
    /**
     * Remove a ConfigRevision.
     * This uses a stored procedure and the stored procedure is required
     * as it performs logic to determine the amount of org quota is now
     * used and appropriately updates those tables.
     * @param revision Revision to remove
     * @param orgId The id for the org in which this revision is located.
     * @return whether the parent file was deleted too.
     */
    public static boolean removeConfigRevision(ConfigRevision revision, Long orgId) {
        boolean latest = false;
        ConfigFile file = revision.getConfigFile();
        //is this revision the latest revision?
        if (file.getLatestConfigRevision().getId()
                .equals(revision.getId())) {
            latest = true;
        }
        
        CallableMode m = ModeFactory.getCallableMode("config_queries",
            "remove_config_revision");

        Map inParams = new HashMap();
        Map outParams = new HashMap();
        inParams.put("config_revision_id_in", revision.getId());
        inParams.put("org_id", orgId);
        m.execute(inParams, outParams);
        
        if (latest) {
            //We just deleted the latest revision and now the config file has no idea
            //what its latest revision is, so we will find out.
            Map map = getMaxRevisionForFile(file);
            if (map != null) {
                Long id = (Long)map.get("id");
                file.setLatestConfigRevision(lookupConfigRevisionById(id));
                commit(file);
            }
            else {
                //there are no revisions in this file, delete the file.
                removeConfigFile(file);
                return true;
            }
        }
        return false;
    }
    
    /**
     * Create a local config channel for the given server. Fills in the necessary
     * fields with standard information.
     * @param server The server used to help populate required fields
     * @param type The type of the config channel. Either sandbox or local override.
     * @return The new local config channel.
     */
    public static ConfigChannel createNewLocalChannel(Server server,
            ConfigChannelType type) {
        ConfigChannel retval = newConfigChannel();
        retval.setOrg(server.getOrg());
        retval.setConfigChannelType(type);
        retval.setCreated(new Date());
        retval.setModified(new Date());
        
        //The name of the channel should always be the server name for
        //local config channels.  See bug #203406
        retval.setName(server.getName());
        retval.setLabel(server.getId().toString());
        
        //This is an english string. However, users should never see a description of
        //a local config channel. For all purposes, this is a useless field that only
        //exists because we currently treat local config channels exactly the same as
        //global config channels.
        retval.setDescription("Auto-generated " + type.getLabel() + " config channel");
        
        //TODO: put the following line back. It is not here now because Server.findLocal
        //      does this task for us. It belongs here, but this would currently cause
        //      an infinite loop based on how setSandboxOverride works.
        //server.setSandboxOverride(retval);
        commit(retval);
        
        return retval;
    }
    
    /**
     * Creates a new revision object from the give input stream.  The size is set to
     * be the given size.  The revision object is placed into the given config file
     * and uses the meta-data from the latest revision in that file.
     * @param usr The user that is making the new revision
     * @param stream The input stream containing the content for this revision.
     * @param size The size of the input stream to be read.
     * @param file The parent object for this config revision.
     * @return The newly created config revision.
     */
    public static ConfigRevision createNewRevisionFromStream(
            User usr, InputStream stream, Long size, ConfigFile file) {
        //get a copy of the latest revision (to copy meta-data)
        ConfigRevision revision = file.getLatestConfigRevision().copy();
        
        /*
         * We need to make five changes to the current revision.
         * 1. increment the revision number
         * 2. replace the content
         * 3. magic-decide whether this revision is binary
         * 4. compute the md5sum
         * 5. give it a new id
         */
        
        //Step 1
        //For database integrity, we won't just increment the latest revision number and
        //hope that nobody has futzed around.  We will get the max revision and increment.
        Long next = getNextRevisionForFile(file);
        revision.setRevision(next);
        revision.setChangedById(usr.getId());
        
        //Steps 2-4
        if (!revision.isDirectory()) {
            revision.setConfigContent(
                    createNewContentFromStream(stream, size, 
                            revision.getConfigContent().isBinary()));
        }
        
        //Step 5
        revision.setId(null);
        commit(revision);
        
        file.setLatestConfigRevision(revision);
        commit(file);
        
        return revision;
    }
    
    /**
     * Creates a ConfigContent object whose BLOB is filled with the bytes from the 
     * specified stream
     * @param stream stream containing the content
     * @param size number of bytes to read
     * @param isBinary true if the content is to be treated as binary (which means we 
     * won't expand macros, morph EOL, or let you edit it from the web UI)
     * @return filled-in ConfigContent
     */
    public static ConfigContent createNewContentFromStream(
            InputStream stream, Long size, boolean isBinary) {
        ConfigContent content = ConfigurationFactory.newConfigContent();
        content.setCreated(new Date());
        content.setModified(new Date());
        content.setFileSize(size);
        
        byte[] foo = new byte[size.intValue()];
        try {
            //this silly bit of logic is to ensure that we read as much from the file
            //as we possibly can.  Most likely, stream.read(foo) would do the exact same
            //thing, but according to the javadoc, that may not always be the case.
            
            int offset = 0;
            int read = 0;
            do {
                read = stream.read(foo, offset, (foo.length - offset));
                offset += read;
            } while (read > 0 && offset < foo.length);
        }
        catch (IOException e) {
            log.error("IOException while reading config content from input stream!", e);
            throw new RuntimeException("IOException while reading config content from" +
                    " input stream!");
        }
        
        content.setContents(foo);
        Checksum newChecksum = ChecksumFactory.safeCreate(MD5Crypt.md5Hex(foo), "md5");
        content.setChecksum(newChecksum);
        content.setBinary(isBinary);
        return content;
    }
    
    private static Map getMaxRevisionForFile(ConfigFile file) {
        Map params = new HashMap();
        params.put("cfid", file.getId());
        SelectMode m = ModeFactory.getMode("config_queries", "max_revision_for_file");
        DataResult dr = m.execute(params);
        if (dr.isEmpty()) {
            return null; //no revisions left.
        }
        return (Map)dr.get(0);
    }
    
    private static Long getNextRevisionForFile(ConfigFile file) {
        Map results = getMaxRevisionForFile(file);
        Long next = new Long(((Long) results.get("revision")).longValue() + 1);
        return next;
    }
    
    /**
     * Copies the given config revision to the given channel.
     * If there is a candidate config file that exists in that channel, this
     * revision gets set as the newest revision there.
     * Otherwise, a new config file is created with this as its only revision.
     * @param usr The user asking for the new revision
     * @param revision The revision to be copied
     * @param channel The channel to be copied into
     */
    public static void copyRevisionToChannel(
            User usr, ConfigRevision revision, ConfigChannel channel) {
        /*
         * 1. Find any candidate config files already in the channel.
         * 2. Make a copy of the revision
         * 3. Associate the revision and the file
         * 4. save
         */
        
        //Step 1.
        ConfigFileName name = revision.getConfigFile().getConfigFileName();
        ConfigFile file = lookupConfigFileByChannelAndName(channel.getId(), name.getId());
        Long rev = null;
        if (file == null) { //if a candidate does not exist, create one.
            rev = new Long(1);
            file = ConfigurationFactory.newConfigFile();
            file.setConfigChannel(channel);
            file.setConfigFileName(name);
            file.setConfigFileState(ConfigFileState.normal());
            file.setCreated(new Date());
            file.setModified(new Date());
        }
        else {
            rev = getNextRevisionForFile(file);
        }
        
        //Step 2
        ConfigRevision newRevision = revision.copy();
        newRevision.setRevision(rev);
        newRevision.setChangedById(usr.getId());
        newRevision.setId(null);
        
        //Step 3
        newRevision.setConfigFile(file);
        
        //Step 4
        commit(newRevision);
        file.setLatestConfigRevision(newRevision);
        commit(file);
    }
    
    /**
     * Returns a localized string for the name of a config channel.  This is here
     * because local and sandbox config channels are created automatically and therefore
     * have english names.  This is located in this file to be a central location for
     * the logic.
     * @param type The type of the channel (one of the labels for 
     *             CONFIG_CHANNEL_TYPE_* constants)
     * @param channel The name of the channel, the system name for local channels.
     * @return A localized string for channel name
     */
    public static String getChannelNameDisplay(String type, String channel) {
        if (type == null) {
            throw new IllegalArgumentException("Error: channel type cannot be null");
        }
        
        if (ConfigChannelType.global().getLabel().equals(type)) {
            return channel; //for global channels, there name is the channel name.
        }
        else if (ConfigChannelType.local().getLabel().equals(type)) {
            return LocalizationService.getInstance()
                    .getMessage("config_channel_name.local", channel);
        }
        else if (ConfigChannelType.sandbox().getLabel().equals(type)) {
            return LocalizationService.getInstance()
                    .getMessage("config_channel_name.sandbox", channel);
        }
        else {
            throw new IllegalArgumentException("Error getting channel name display." +
                    " Invalid channel type given.");
        }
    }
    
}
