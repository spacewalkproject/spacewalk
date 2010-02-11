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
package com.redhat.rhn.domain.monitoring.config;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.monitoring.notification.ContactGroup;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.StringTokenizer;

/**
 * MonitoringConfigFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.monitoring.config.* objects from the
 * database.
 * @version $Rev: 51602 $ 
 */
public class MonitoringConfigFactory extends HibernateFactory {

    private static MonitoringConfigFactory singleton = new MonitoringConfigFactory();
    private static Logger log = Logger.getLogger(MonitoringConfigFactory.class);
    
    private MonitoringConfigFactory() {
        super();
    }
    
    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    protected Logger getLogger() {
        return log;
    }
    
    /**
     * Get the list of com.redhat.rhn.domain.monitoring.config.ConfigMacro 
     * objects from the DB.  The editable param indicates if you want the 
     * editable or non editable items.
     * @param editable if you want editable ConfigMacro items or not
     * @return List of ConfigMacro objects
     */
    public static List lookupConfigMacros(boolean editable) {
        Map params = new HashMap();
        if (editable) {
            params.put("editable", "1");
        }
        else {
            params.put("editable", "0");    
        }
        return singleton.listObjectsByNamedQuery(
                "ConfigMacro.loadAllByEditable", params);
    }
    
    /**
     * Lookup a ConfigMacro by its name
     * @param name of ConfigMacro to lookup
     * @return ConfigMacro if found.
     */
    public static ConfigMacro lookupConfigMacroByName(String name) {
        Map params = new HashMap();
        params.put("name", name);
        return (ConfigMacro) singleton.lookupObjectByNamedQuery(
                "ConfigMacro.lookupByName", params);
    }
    
    
    /** 
     * Commit a ConfigMacro to the DB
     * @param cIn ConfigMacro to be saved
     */
    public static void saveConfigMacro(ConfigMacro cIn) {
        singleton.saveObject(cIn);
    }

    /**
     * 
     * @return The Panic Destination for this Sat
     */
    public static ContactGroup lookupPanicDestination() {
        return null;
    }
    
    /**
     * Get the database name being used by Hibernate.
     * @return String db name
     */
    public static String getDatabaseName() {
        String url = Config.get().getString("hibernate.connection.url");

        // jdbc:oracle.jdbc.driver.OracleDriver:oracle:thin:
        // @sputnik.sfbay.redhat.com:1521:rhnsat
        StringTokenizer st = new StringTokenizer(url, ":");
        String dbName = null;
        // We want the last token so we just loop
        // through and its left with the last when 
        // its done.
        while (st.hasMoreTokens()) {
            dbName = st.nextToken();
        }
        // This must be hard coded to english since the 
        // monitoring backend isn't localized
        
        return dbName.toUpperCase(Locale.ENGLISH);
        
    }
    

    /**
     * Get the database username being used by Hibernate.
     * @return String username
     */
    public static String getDatabaseUsername() {
        return Config.get().getString("hibernate.connection.username");
    }
    
    
    /**
     * Get the database password being used by Hibernate.
     * @return String password
     */
    public static String getDatabasePassword() {
        return Config.get().getString("hibernate.connection.password");
    }
    
}

