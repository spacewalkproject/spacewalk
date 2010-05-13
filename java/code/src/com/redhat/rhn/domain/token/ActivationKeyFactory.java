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
package com.redhat.rhn.domain.token;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.RandomStringUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * ActivationKeyFactory
 * @version $Rev$
 */
public class ActivationKeyFactory extends HibernateFactory {

    public static final String DEFAULT_DESCRIPTION = "None"; 
    private static ActivationKeyFactory singleton = new ActivationKeyFactory();
    private static Logger log = Logger.getLogger(ActivationKeyFactory.class);
    
    /**
     * Lookup an ActivationKey by it's key string.
     * @param key The key for the ActivationKey
     * @return Returns the corresponding ActivationKey or null if not found.
     */
    public static ActivationKey lookupByKey(String key) {
        if (key == null) {
            return null;
        }
       
        return (ActivationKey) HibernateFactory.getSession()
            .getNamedQuery("ActivationKey.findByKey")
                                      .setString("key", key)
                                      .uniqueResult();
    }
    
    /**
     * Lookup the root ActivationKey based on the token.  Looks up by the 
     * token and where the KickstartSession is null. 
     * @param tokenIn token coming in
     * @return activation key for this token
     */    
    public static ActivationKey lookupByToken(Token tokenIn) {
        if (tokenIn == null) {
            return null;
        }
        return (ActivationKey) HibernateFactory.getSession()
            .getNamedQuery("ActivationKey.findByToken")
                                      .setEntity("token", tokenIn)
                                      .uniqueResult();
    }

    
    /**
     * Creates and fills out a new Activation Key (Including generating a key/token). 
     * Sets deployConfigs to false, disabled to 0, and usage limit to null. 
     * @param user The user for the key
     * @param note The note to attach to the key
     * @return Returns the newly created ActivationKey.
     */
    public static ActivationKey createNewKey(User user, String note) {
        return createNewKey(user, null, "", note, new Long(0), null, false);
    }

    /**
     * Creates and fills out a new Activation Key (Including generating a key/token). 
     * Sets deployConfigs to false, disabled to 0, and usage limit to null. 
     * Sets the 'server' to the server param, and the groups to the
     * system groups the server is subscribed to.
     * @param user The user for the key
     * @param server The server for the key
     * @param key Key to use, blank to have one auto-generated
     * @param note The note to attach to the key
     * @param usageLimit Usage limit for the activation key
     * @param baseChannel Base channel for the activation key
     * @param universalDefault Whether or not this key should be set as the universal 
     *        default.
     * @return Returns the newly created ActivationKey.
     */
    public static ActivationKey createNewKey(User user, Server server, String key,  
            String note, Long usageLimit, Channel baseChannel, boolean universalDefault) {
        
        ActivationKey newKey = new ActivationKey();
        
        String keyToUse = key;
        if (keyToUse == null || keyToUse.equals("")) {
            keyToUse = generateKey();
        }
        else {
            validateKeyName(key.trim().replace(" ", ""));
        }

        keyToUse = ActivationKey.makePrefix(user.getOrg()) +
                                            keyToUse.trim().replace(" ", "");
        
        if (server != null) {
            keyToUse = "re-" + keyToUse;
        }

        newKey.setKey(keyToUse);
        newKey.setCreator(user);
        newKey.setOrg(user.getOrg());
        newKey.setServer(server);

        if (StringUtils.isBlank(note)) {
            note = DEFAULT_DESCRIPTION;
        }
        newKey.setNote(note);
        newKey.getToken().setDeployConfigs(false); // Don't deploy configs by default
        newKey.setDisabled(new Long(0)); // Enable by default
        newKey.setUsageLimit(usageLimit);
        
        if (baseChannel != null) {
            newKey.getToken().addChannel(baseChannel);
        }
        
        // Set the entitlements equal to what the server has by default
        if (server != null) {
            List serverEntitlements = server.getEntitledGroups();
            for (Iterator itr = serverEntitlements.iterator(); itr.hasNext();) {
                ServerGroup group = (ServerGroup) itr.next();
                newKey.addEntitlement(group.getGroupType());
            }
        }
        else {
            newKey.addEntitlement(
                    ServerConstants.getServerGroupTypeEnterpriseEntitled());
        }
        
        save(newKey);

        if (universalDefault) {
            Token token = newKey.getToken();
            user.getOrg().setToken(token);
            OrgFactory.save(user.getOrg());
        }
        
        return newKey;
    }
    
    /**
     * Basically validates the name of key, makes sure it doesnot have invalid chars etc...
     * Also asserts that the key passed in has not been 
     * previously accounted for. This is mainly useful for validating 
     * activation key creation. Basically raises an assertion exception
     * on validation errors. 
     * @param key the name of the key.
     */
    public static void validateKeyName(String key) {
        String [] badChars = {",", "\""};
        boolean nameOk = true;
        for (String c : badChars) {
            if (key.contains(c)) {
                nameOk = false;
                break;
            }
        }
        if (!nameOk) {
            ValidatorException.raiseException("activation-key.java.invalid_chars", key, 
                                        "[" + StringUtils.join(badChars, " ") + "]");
        }
        if (lookupByKey(key) != null) {
            ValidatorException.raiseException("activation-key.java.exists", key);
        }
    }
    
    
    /**
     * Generate a random activation key string.
     * @return random string
     */
    public static String generateKey() {
        String random = RandomStringUtils.random(128);
        return MD5Crypt.md5Hex(random);
    }
    
    /**
     * Saves an ActivationKey to the database
     * @param keyIn The ActivationKey to save.
     */
    public static void save(ActivationKey keyIn) {
        singleton.saveObject(keyIn);
    }
 

    /**
     * {@inheritDoc}
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Lookup an ActivationKey by its associated KickstartSession.
     * 
     * @param sess that is associated with ActivationKey
     * @return ActivationKey associated with session
     */
    public static ActivationKey lookupByKickstartSession(KickstartSession sess) {
        return (ActivationKey) HibernateFactory.getSession()
                                      .getNamedQuery("ActivationKey.findBySession")
                                      .setEntity("session", sess)
                                      //Retrieve from cache if there
                                      .setCacheable(true)
                                      .uniqueResult();
    }

    /**
     * Lookup an ActivationKey by its associated Server.
     * 
     * @param server that is associated with ActivationKey
     * @return ActivationKey assocaited with session
     */
    public static List<ActivationKey> lookupByServer(Server server) {
        if (server == null) {
            return null;
        }
        return getSession().getNamedQuery("ActivationKey.findByServer").
            setEntity("server", server).list();
    }

    /**
     * Remove an ActivationKey
     * @param key to remove
     */
    public static void removeKey(ActivationKey key) {
        if (key != null) {
            singleton.removeObject(key);    
        }
        
    }

    /**
     * List all kickstarts associated with an activation key
     * @param key the key to look for associations with
     * @return list of kickstartData objects
     */
    public static List<KickstartData> listAssociatedKickstarts(ActivationKey key) {
        Map params = new HashMap();
        params.put("token", key.getToken());
        return singleton.listObjectsByNamedQuery("ActivationKey.listAssociatedKickstarts",
                                                                                    params);
    }


}
