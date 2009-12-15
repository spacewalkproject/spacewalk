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
package com.redhat.rhn.manager.satellite;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.monitoring.config.ConfigMacro;
import com.redhat.rhn.domain.monitoring.config.MonitoringConfigFactory;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.satcluster.SatClusterFactory;
import com.redhat.rhn.domain.monitoring.satcluster.SatNode;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.monitoring.ModifyMethodCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ConfigureSatelliteCommand
 * @version $Rev$
 */
public class ConfigureSatelliteCommand extends BaseConfigureCommand 
    implements SatelliteConfigurator {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.
        getLogger(ConfigureSatelliteCommand.class);
    
    private List keysToBeUpdated;
    
    /**
     * Create a new ConfigureSatelliteCommand class with the 
     * user requesting the config.
     * @param userIn who wants to config the sat.
     */
    public ConfigureSatelliteCommand(User userIn) {
        super(userIn);
        this.keysToBeUpdated = new LinkedList();
    }

    /**
     * Get the formatted String array of command line arguments to execute 
     * when we call out to the system utility to store the config.
     * @param configFilePath path to config file to update
     * @param optionMap Map of key/value pairs to update local config with.
     * @return String[] array of arguments.
     */
    public String[] getCommandArguments(String configFilePath, Map optionMap) {
        if (logger.isDebugEnabled()) {
            logger.debug("getCommandArguments(String configFilePath=" + 
                    configFilePath + ", Iterator keyIterator=" + optionMap +
                    ") - start");
        }

        List argList = new LinkedList();
        argList.add("/usr/bin/sudo");
        argList.add("/usr/bin/rhn-config-satellite.pl");
        argList.add("--target=" + configFilePath);
        Iterator keyIterator = optionMap.keySet().iterator();
        while (keyIterator.hasNext()) {
            String key = (String) keyIterator.next();
            StringBuffer sb = new StringBuffer();
            sb.append("--option=");
            sb.append(key);
            sb.append("=");
            String val = (String) optionMap.get(key);
            // We don't want to put the actual string 'null'
            // in rhn.conf.  See bz: 189600
            if (StringUtils.isEmpty(val)) {
                sb.append("");
            }
            else {
                sb.append(val);
            }
            
            argList.add(sb.toString());
        }
        
        argList.add("2>&1");
        argList.add(">");
        argList.add("/dev/null");
        String[] returnStringArray = (String[]) argList.toArray(new String[0]);
        if (logger.isDebugEnabled()) {
            logger.debug("getCommandArguments(String, Iterator) - end - return value=" +
                    returnStringArray);
        }
        return returnStringArray;
    }
    
    /**
     * Store the Configuration to the filesystem 
     * @return ValidatorError   
     */
    public ValidatorError[] storeConfiguration() {
        if (logger.isDebugEnabled()) {
            logger.debug("storeConfiguration() - start");
        }

        Executor e = getExecutor();
        if (keysToBeUpdated.contains(ConfigDefaults.WEB_IS_MONITORING_BACKEND)) {
            boolean backend = Config.get().getBoolean(
                    ConfigDefaults.WEB_IS_MONITORING_BACKEND);
            if (backend) {
                enableMonitoring();
            } 
        }
        if (keysToBeUpdated.contains(ConfigDefaults.WEB_IS_MONITORING_SCOUT)) {
            boolean scout = Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_SCOUT);
            if (scout) {
                enableMonitoringScout();
            }
        }
        
        if (keysToBeUpdated.contains(ConfigDefaults.JABBER_SERVER)) {
            updateHostname();
            
            // if hostname changes, we must update
            // osa-dispatcher.server_jabber as well
            this.updateString("osa-dispatcher.jabber_server", 
                    ConfigDefaults.get().getHostname());
        }
        
        if (keysToBeUpdated.contains(ConfigDefaults.MOUNT_POINT)) {
            this.updateString(ConfigDefaults.KICKSTART_MOUNT_POINT, 
                    Config.get().getString(ConfigDefaults.MOUNT_POINT));
        }
        
        if (keysToBeUpdated.contains(ConfigDefaults.DISCONNECTED) && 
                !Config.get().getBoolean(ConfigDefaults.DISCONNECTED)) {
            //if there isn't already a value set for the satellite parent (We don't want to 
            // overwrite a custom value.)
            if (Config.get().getString(ConfigDefaults.SATELLITE_PARENT) == null || 
                    Config.get().getString(ConfigDefaults.SATELLITE_PARENT).length() == 0) {
                this.updateString(ConfigDefaults.SATELLITE_PARENT, 
                        ConfigDefaults.DEFAULT_SAT_PARENT);
            }
        }
        
        Map optionMap = new HashMap();
        Iterator i = getKeysToBeUpdated().iterator();
        while (i.hasNext()) {
            String key = (String) i.next();
            optionMap.put(key, Config.get().getString(key));
        }
        
        int exitcode = e.execute(getCommandArguments(Config.getDefaultConfigFilePath(), 
                optionMap));
        if (exitcode != 0) {
            ValidatorError[] retval = new ValidatorError[1];
            retval[0] = new ValidatorError("config.storeconfig.error", 
                    new Integer(exitcode).toString());

            if (logger.isDebugEnabled()) {
                logger.debug("storeConfiguration() - end - return value="  + retval);
            }
            return retval;
        }
        else {
            this.keysToBeUpdated.clear();

            if (logger.isDebugEnabled()) {
                logger.debug("storeConfiguration() - end - return value="  + null);
            }
            return null;
        }
        
    }
    
    

    private void enableMonitoringScout() {
        // Enable monitoring cron
        Executor e = getExecutor();
        List args = new LinkedList();
        args.add("/usr/bin/sudo");
        args.add("/etc/rc.d/np.d/step");
        args.add("MonitoringScout");
        args.add("install");
        int exitcode = e.execute((String[]) args.toArray(new String[0]));
        if (exitcode != 0) {
            String message = "Not able to execute: [" + 
                args.toString() + "] got back exit code: " + exitcode;
            logger.error(message);
            throw new RuntimeException(message);
        }
    }

    /**
     * Logic for enabling Monitoring
     */
    protected void enableMonitoring() {
        if (logger.isDebugEnabled()) {
            logger.debug("enableMonitoring() - start");
        }

        // Add the MONITORING_ADMIN role
        this.getUser().getOrg().addRole(RoleFactory.MONITORING_ADMIN);
        
        Set scouts = this.getUser().getOrg().getMonitoringScouts();
        //We need to create the SatCluster (the Scout)
        if (scouts == null || scouts.size() == 0) {
            SatCluster scout = SatClusterFactory.createSatCluster(getUser());
            scout.setDescription(LocalizationService.getInstance().
                    getMessage("scout.default.name"));
            SatNode node =  SatClusterFactory.createSatNode(getUser(), scout);
            SatClusterFactory.saveSatCluster(scout);
            SatClusterFactory.saveSatNode(node);
            
            // Set the scout shared key so it can be stored out to disk.
            Config.get().setString(ConfigDefaults.WEB_SCOUT_SHARED_KEY, 
                    node.getScoutSharedKey());
            ModifyMethodCommand mmc = new ModifyMethodCommand(getUser());
            mmc.setType(NotificationFactory.TYPE_EMAIL);
            mmc.setEmail(getUser().getEmail());
            // This has to be hard coded to en_US because the backend
            // looks for a method with this name.
            mmc.setMethodName("Panic Destination");
            mmc.storeMethod(getUser());
            //HibernateFactory.getSession().evict(scout);
            scouts.add(scout);
        } 
        
        
        Executor e = getExecutor();
        List args = new LinkedList();
        
        // Write the scout shared key to cluster.ini
        Map optionMap = new HashMap();
        optionMap.put("LocalConfig.0.dbd", "Oracle");
        optionMap.put("LocalConfig.0.orahome", "/opt/oracle");
        optionMap.put("LocalConfig.0.dbname", 
                MonitoringConfigFactory.getDatabaseName());
        optionMap.put("LocalConfig.0.username", 
                MonitoringConfigFactory.getDatabaseUsername());
        optionMap.put("LocalConfig.0.password", 
                MonitoringConfigFactory.getDatabasePassword());
        optionMap.put("smonaddr", "127.0.0.1");
        optionMap.put("smonfqdn", "localhost");
        optionMap.put("smontestaddr", "127.0.0.1");
        optionMap.put("smontestfqdn", "localhost");
        
        SatCluster c = (SatCluster) scouts.iterator().next();
        optionMap.put("scoutsharedkey", 
                SatClusterFactory.lookupSatNodeByCluster(c).getScoutSharedKey());
        
        
        int exitcode = e.execute(getCommandArguments("/etc/rhn/cluster.ini", optionMap));
        if (exitcode != 0) {
            String message = "Not able to write to /etc/rhn/cluster.ini, " +
                "got exit code: " + exitcode + 
                ".  Check that /etc/rhn/cluster.ini exists";
            logger.error(message);
            throw new RuntimeException(message);
        }

        // Setup sensible defaults for the ConfigMacro settings.
        ConfigMacro cmadmin = MonitoringConfigFactory.
            lookupConfigMacroByName("RHN_ADMIN_EMAIL");
        setConfigMacroDefault(cmadmin, getUser().getEmail());
        ConfigMacro cmmail = MonitoringConfigFactory.
            lookupConfigMacroByName("MAIL_MX");
        setConfigMacroDefault(cmmail, "localhost");
        ConfigMacro cmdom = MonitoringConfigFactory.
            lookupConfigMacroByName("MDOM");
        setConfigMacroDefault(cmdom, ConfigDefaults.get().getHostname());
        ConfigMacro dbname = MonitoringConfigFactory.
            lookupConfigMacroByName("RHN_DB_NAME");
        setConfigMacroDefault(dbname, MonitoringConfigFactory.getDatabaseName());
        ConfigMacro dbuname = MonitoringConfigFactory.
            lookupConfigMacroByName("RHN_DB_USERNAME");
        setConfigMacroDefault(dbuname, MonitoringConfigFactory.getDatabaseUsername());
        ConfigMacro dbpass = MonitoringConfigFactory.
            lookupConfigMacroByName("RHN_DB_PASSWD");
        setConfigMacroDefault(dbpass, MonitoringConfigFactory.getDatabasePassword());
        ConfigMacro dbowner = MonitoringConfigFactory.
            lookupConfigMacroByName("RHN_DB_TABLE_OWNER");
        setConfigMacroDefault(dbowner, MonitoringConfigFactory.getDatabaseUsername());
        ConfigMacro sathostname = MonitoringConfigFactory.
            lookupConfigMacroByName("RHN_SAT_HOSTNAME");
        setConfigMacroDefault(sathostname, ConfigDefaults.get().getHostname());
        ConfigMacro xproto = MonitoringConfigFactory.
            lookupConfigMacroByName("XPROTO");
        setConfigMacroDefault(xproto, "https");
        ConfigMacro port = MonitoringConfigFactory.
            lookupConfigMacroByName("RHN_SAT_WEB_PORT");
        setConfigMacroDefault(port, "443");
        
        if (logger.isDebugEnabled()) {
            logger.debug("enableMonitoring() - end");
        }
    }
    
    
    // Util to set the ConfigMacro.definition field to a default value
    // if its set to the **DEFAULT** value that the records start
    // out in when the schema is initialized.
    private void setConfigMacroDefault(ConfigMacro cm, String value) {
        if (cm.getDefinition().startsWith("**") && 
                cm.getDefinition().endsWith("**")) {
            setConfigMacro(cm, value);
        }
    }

    // Util that actually sets the definition of the ConfigMacro
    // and stores it
    private void setConfigMacro(ConfigMacro cm, String value) {
        cm.setDefinition(value);
        MonitoringConfigFactory.saveConfigMacro(cm);
    }
    
    
    // Update hostname when modified in the UI
    private void updateHostname() {
        ConfigMacro sathostname = MonitoringConfigFactory.
                           lookupConfigMacroByName("RHN_SAT_HOSTNAME");
        setConfigMacro(sathostname, ConfigDefaults.get().getHostname());
    }
    
    /**
     * Update a configuration value for this satellite.  This tracks
     * the values that are actually changed.
     * @param configKey key to the Config value you want to set
     * @param newValue you want to set
     */
    public void updateBoolean(String configKey, Boolean newValue) {
        if (logger.isDebugEnabled()) {
            logger.debug("updateBoolean(String configKey=" + configKey  +
                    ", Boolean newValue=" + newValue + ") - start");
        }

        if (newValue == null) {
            // If its true we are changing the value
            if (Config.get().getBoolean(configKey)) {
                Config.get().setBoolean(configKey, Boolean.FALSE.toString());
                keysToBeUpdated.add(configKey);
            }
        } 
        else {
            if (Config.get().getBoolean(configKey) != newValue.booleanValue()) {
                Config.get().setBoolean(configKey, newValue.toString());
                keysToBeUpdated.add(configKey);
            }
        }

        if (logger.isDebugEnabled()) {
            logger.debug("updateBoolean(String, Boolean) - end");
        }
    }

    /**
     * Update a String config
     * @param configKey to the value
     * @param newValue to set
     */
    public void updateString(String configKey, String newValue) {
        if (logger.isDebugEnabled()) {
            logger.debug("updateString(String configKey=" + configKey  +
                    ", String newValue=" + newValue + ") - start");
        }

        if (Config.get().getString(configKey) == null || 
                !Config.get().getString(configKey).equals(newValue)) {
            keysToBeUpdated.add(configKey);    
            Config.get().setString(configKey, newValue);
        }

        if (logger.isDebugEnabled()) {
            logger.debug("updateString(String, String) - end");
        }
    }
    
    /**
     * Get the list of configuration values that need to be written out
     * to the persistence mechanism.
     * @return List of String values of to the keys to be written.
     */
    public List getKeysToBeUpdated() {
        return keysToBeUpdated;
    }
    
    /**
     * Clear the set of configuration changes from the Command.
     */
    public void clearUpdates() {
        if (logger.isDebugEnabled()) {
            logger.debug("clearUpdates() - start");
        }

        this.keysToBeUpdated.clear();

        if (logger.isDebugEnabled()) {
            logger.debug("clearUpdates() - end");
        }
    }

}
