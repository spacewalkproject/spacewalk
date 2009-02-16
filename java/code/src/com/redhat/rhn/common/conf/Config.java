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

package com.redhat.rhn.common.conf;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;
import java.util.TreeSet;

/**
 * The Config class acts as an abstraction layer between our configuration
 * system, and the actual implementation. The basic idea is that there is a
 * global config, but you can instantiate one of your own if you want. This
 * layer insulates us from changing the underlying implementation.
 * <p>
 * Config files are properties, with /etc/rhn/default/rhn.conf setting defaults
 * that can be overridden /etc/rhn/rhn.conf.
 *
 * @version $Rev$
 */
public class Config {


    private static Logger logger = Logger.getLogger(Config.class);

    public static final String SPACEWALK = "Spacewalk";

    //
    // Location of config files
    //

    /**
     * The default directory in which to look for config files
     */
    public static final String DEFAULT_CONF_DIR = "/etc/rhn";

    /**
     * The system property containing the configuration directory.
     * If the property is not set, config files are read
     * from {@link #DEFAULT_CONF_DIR}
     */
    private static final String CONF_DIR_PROPERTY = "rhn.config.dir";

    /**
     * List of values that are considered true, ignoring case.
     */
    private static final String[] TRUE_VALUES = {"1", "y", "true", "yes", "on"};
    //
    // Names of the configuration parameters
    //

    public static final String SSL_AVAILABLE = "ssl_available";
    
    //TODO: was private.  Made public for AccessTest
    public static final String WEB_SATELLITE = "web.satellite";

    public static final String ENABLE_OAI_SYNC = "enable_oai_sync";
    public static final String SYSTEM_CHECKIN_THRESHOLD = "web.system_checkin_threshold";
    public static final String WEB_ALLOW_PXT_PERSONALITIES = "web.allow_pxt_personalities";
    public static final String WEB_DEFAULT_MAIL_FROM = "web.default_mail_from";
    public static final String WEB_ENCRYPTED_PASSWORDS = "web.encrypted_passwords";
    public static final String WEB_L10N_RESOURCEBUNDLES = "web.l10n_resourcebundles";
    public static final String WEB_PAM_AUTH_SERVICE = "web.pam_auth_service";
    public static final String WEB_SESSION_DATABASE_LIFETIME =
        "web.session_database_lifetime";

    public static final String WEB_SESSION_SECRET_1 = "web.session_secret_1";
    public static final String WEB_SESSION_SECRET_2 = "web.session_secret_2";
    public static final String WEB_SESSION_SECRET_3 = "web.session_secret_3";
    public static final String WEB_SESSION_SECRET_4 = "web.session_secret_4";

    public static final String WEB_SESSION_SWAP_SECRET_1 = "web.session_swap_secret_1";
    public static final String WEB_SESSION_SWAP_SECRET_2 = "web.session_swap_secret_2";
    public static final String WEB_SESSION_SWAP_SECRET_3 = "web.session_swap_secret_3";
    public static final String WEB_SESSION_SWAP_SECRET_4 = "web.session_swap_secret_4";

    public static final String WEB_SMTP_SERVER = "web.smtp_server";
    public static final String TASKOMATIC_TASKS = "taskomatic.tasks";
    public static final String TASKOMATIC_DEFAULT_TASKS = "taskomatic.default_tasks";
    public static final String ERRATA_CACHE_COMPUTE_THRESHOLD
                            = "errata_cache_compute_threshold";

    public static final String DOWNLOAD_URL_LIFETIME = "download_url_lifetime";
    
    public static final String WEB_IS_MONITORING_SCOUT = "web.is_monitoring_scout";

    public static final String WEB_IS_MONITORING_BACKEND = "web.is_monitoring_backend";

    public static final String SATELLITE_PARENT = "server.satellite.rhn_parent";

    public static final String JABBER_SERVER = "server.jabber_server";

    public static final String WEB_SCOUT_SHARED_KEY = "monitoring.scout_shared_key";

    public static final String GPG_KEYRING = "web.gpg_keyring";

    public static final String MOUNT_POINT = "mount_point";

    public static final String KICKSTART_MOUNT_POINT = "kickstart_mount_point";
    
    public static final String KICKSTART_PACKAGE_NAME = "kickstart_packaget";
    
    public static final String DEFAULT_KICKSTART_PACKAGE_NAME = "spacewalk-koan";
    
    public static final String OVAL_MOUNT_POINT = "web.oval_mount_point";

    public static final String KICKSTART_HOST = "kickstart_host";
 
    public static final String CONFIG_REVISION_MAX_SIZE = "web.maximum_config_file_size";

    public static final String WEB_EXCLUDED_COUNTRIES = "web.excluded_countries";
    
    public static final String DISCONNECTED = "disconnected";
    
    public static final String DEFAULT_SAT_PARENT = "satellite.rhn.redhat.com";

    public static final String TINY_URL_TIMEOUT = "server.satellite.tiny_url_timeout";
    
    public static final String FORCE_UNENTITLEMENT = "web.force_unentitlement";

    public static final String PRODUCT_NAME = "web.product_name";
    
    public static final String COBBLER_AUTOMATED_USER = "web.taskomatic_cobbler_user";

    public static final String WEB_SUBSCRIBE_PROXY_CHANNEL = "web.subscribe_proxy_channel";
    

    /**
     * The default maximum size for config revisions,  (128 K)
     */
    public static final int DEFAULT_CONFIG_REVISION_MAX_SIZE = 131072;
    
    public static final String REPOMD_PATH_PREFIX = "taskomatic.repomd_path_prefix";
    
    public static final String REPOMD_CACHE_MOUNT_POINT = "repomd_cache_mount_point";

    /**
     * array of prefix in the order they should be search
     * if the given lookup string is without a namespace.
     */
    private String[] prefixOrder = new String[] {"web", "server"};
    private static Config singletonConfig = null;
    /** hash of configuration properties */
    private Properties configValues = new Properties();
    /** set of configuration file names */
    private TreeSet fileList = new TreeSet(new Comparator() {

        /** {inheritDoc} */
    public int compare(Object o1, Object o2) {
            // Need to make sure we read the child namespace before the base
            // namespace.  To do that, we sort the list in reverse order based
            // on the length of the file name.  If two filenames have the same
            // length, then we need to do a lexigraphical comparison to make
            // sure that the filenames themselves are different.

            File f1 = (File) o1;
            File f2 = (File) o2;
            int lenDif = f2.getAbsolutePath().length() - f1.getAbsolutePath().length();

            if (lenDif != 0) {
                return lenDif;
            }
            return f2.compareTo(f1);
        }
    });

    /**
     * public constructor. Rereads config entries every time it is called.
     *
     * @throws ConfigException error from the Configuration layers. the jakarta
     * commons conf system just throws Exception, which makes it hard to react.
     * sometioes it is an IOExceptions, sometimes a SAXParserException,
     * sometimes a VindictiveException. so we just turn them into our own
     * exception type and toss them up. as we discover ones we might
     * meaningfully want to react to, we can specilize ConfigException and catch
     * those
     */
    public Config() throws ConfigException {
        addPath(getDefaultConfigDir() + "/default");
        addPath(getDefaultConfigFilePath());
        parseFiles();
    }

    /**
     * Add a path to the config object for parsing
     * @param path The path to add
     */
    public void addPath(String path) {
        getFiles(path);
    }

    /**
     * static method to get the singleton Config option
     *
     * @return the config option
     */
    public static synchronized Config get() {
        if (singletonConfig == null) {
            singletonConfig = new Config();
        }
        return singletonConfig;
    }

    private static String getDefaultConfigDir() {
        String confDir = System.getProperty(CONF_DIR_PROPERTY);

        if (StringUtils.isBlank(confDir)) {
            confDir = DEFAULT_CONF_DIR;
        }
        return confDir;
    }

    /**
     * Get the path to the rhn.conf file we use.
     *
     * @return String path.
     */
    public static String getDefaultConfigFilePath() {
        return getDefaultConfigDir() + "/rhn.conf";
    }

    /**
     * Get the configuration entry for the given string name.  If the value
     * is null, then return the given defValue.  defValue can be null as well.
     * @param name name of property
     * @param defValue default value for property if it is null.
     * @return the value of the property with the given name, or defValue.
     */
    public String getString(String name, String defValue) {
        String ret = getString(name);
        if (ret == null) {
            if (logger.isDebugEnabled()) {
                logger.debug("getString() - returning default value");
            }
            ret = defValue;
        }
        return ret;
    }

    /**
     * get the config entry for string s
     *
     * @param value string to get the value of
     * @return the value
     */
    public String getString(String value) {
        if (logger.isDebugEnabled()) {
            logger.debug("getString() -     getString() called with: " + value);
        }
        if (value == null) {
            return null;
        }

        int lastDot = value.lastIndexOf(".");
        String ns = "";
        String property = value;
        if (lastDot > 0) {
            property = value.substring(lastDot + 1);
            ns = value.substring(0, lastDot);
        }
        if (logger.isDebugEnabled()) {
            logger.debug("getString() -     getString() -> Getting property: " +
                    property);
        }
        String result = configValues.getProperty(property);
        if (logger.isDebugEnabled()) {
            logger.debug("getString() -     getString() -> result: " + result);
        }
        if (result == null) {
            if (!"".equals(ns)) {
                result = configValues.getProperty(ns + "." + property);
            }
            else {
                for (int i = 0; i < prefixOrder.length; i++) {
                    result = configValues.getProperty(prefixOrder[i] + "." + property);
                    if (result != null) {
                        break;
                    }
                 }
            }
        }
        if (logger.isDebugEnabled()) {
            logger.debug("getString() -     getString() -> returning: " + result);
        }
        
        if (result == null || result.equals("")) {
            return null;
        }

        return stripComments(result);
    }

    private String stripComments(String string) {
        // check for null
        if (string == null) {
            return null;
        }

        int breakpos = string.indexOf('#');
        
        // check for comment in value
        if (breakpos < 0) {
            return StringUtils.trim(string);
        }
        
        while (breakpos > -1) {
            if (breakpos == 0) {
                string = "";
                break;
            }
            else if (string.charAt(breakpos - 1) == '\\') {
                breakpos = string.indexOf('#', breakpos + 1);
            }
            else {
                string = string.substring(0, breakpos);
                break;
            }
        }

        if (string.length() == 0) {
            return string;
        }
        
        return StringUtils.trim(string.replaceAll("\\\\#", "#"));
    }

    /**
     * get the config entry for string s
     *
     * @param s string to get the value of
     * @return the value
     */
    public int getInt(String s) {
        return getInt(s, 0);
    }
    
    /**
     * get the config entry for string s, if no value is found
     * return the defaultValue specified.
     *
     * @param s string to get the value of
     * @param defaultValue Default value if entry is not found.
     * @return the value
     */
    public int getInt(String s, int defaultValue) {
        Integer val = getInteger(s);
        if (val == null) {
            return defaultValue;
        }
        return val.intValue();
    }
    
    /**
     * get the config entry for string s
     *
     * @param s string to get the value of
     * @return the value
     */
    public Integer getInteger(String s) {
        String val = getString(s);
        if (val == null) {
            return null;
        }
        return new Integer(val);
    }
    
    /**
     * Parses a comma-delimited list of values as a java.util.List
     * @param name config entry name
     * @return instance of java.util.List populated with config values
     */
    public List getList(String name) {
        List retval = new LinkedList();
        String[] vals = getStringArray(name);
        if (vals != null) {
            retval.addAll(Arrays.asList(vals));
        }
        return retval;
    }

    /**
     * get the config entry for string s
     *
     * @param s string to get the value of
     * @return the value
     */
    public String[] getStringArray(String s) {
        if (s == null) {
            return null;
        }
        String value = getString(s);

        if (value == null) {
            return null;
        }

        return value.split(",");
    }

    /**
     * get the config entry for string name
     *
     * @param name string to set the value of
     * @param value new value
     * @return the previous value of the property
     */
    public String setString(String name, String value) {
        return (String) configValues.setProperty(name, value);
    }

    /**
     * get the config entry for string s
     *
     * @param s string to get the value of
     * @return the value
     */
    public boolean getBoolean(String s) {
        String value = getString(s);
        if (logger.isDebugEnabled()) {
            logger.debug("getBoolean() - " + s + " is : " + value);
        }
        if (value == null) {
            return false;
        }
        
        //need to check the possible true values
        // tried to use BooleanUtils, but that didn't
        // get the job done for an integer as a String.

        
        for (int i = 0; i < TRUE_VALUES.length; i++) {
            if (TRUE_VALUES[i].equalsIgnoreCase(value)) {
                if (logger.isDebugEnabled()) {
                    logger.debug("getBoolean() - Returning true: " + value);
                }
                return true;
            }
        }

        return false;
    }

    /**
     * set the config entry for string name
     * @param s string to set the value of
     * @param b new value
     */
    public void setBoolean(String s, String b) {
        // need to check the possible true values
        // tried to use BooleanUtils, but that didn't
        // get the job done for an integer as a String.
        for (int i = 0; i < TRUE_VALUES.length; i++) {
            if (TRUE_VALUES[i].equalsIgnoreCase(b)) {
                configValues.setProperty(s, "1");
                
                // get out we're done here
                return;
            }
        }
        configValues.setProperty(s, "0");
    }

    private void getFiles(String path) {
        File f = new File(path);

        if (f.isDirectory()) {
            // bugzilla: 154517; only add items that end in .conf
            File[] files = f.listFiles();
            for (int i = 0; i < files.length; i++) {
                if (files[i].getName().endsWith((".conf"))) {
                    fileList.add(files[i]);
                }
            }
        }
        else {
            fileList.add(f);
        }
    }

    private String makeNamespace(File f) {
        String ns = f.getName();

        // This is really hokey, but it works. Basically, rhn.conf doesn't
        // match the standard rhn_foo.conf convention. So, to create the
        // namespace, we first special case rhn.*
        if (ns.startsWith("rhn.")) {
            return "";
        }

        ns = ns.replaceFirst("rhn_", "");
        ns = ns.substring(0, ns.lastIndexOf('.'));
        ns = ns.replaceAll("_", ".");
        return ns;
    }

    /**
     * Parse all of the added files.
     */
    public void parseFiles() {
        for (Iterator i = fileList.iterator(); i.hasNext();) {
            File curr = (File) i.next();

            Properties props = new Properties();
            try {
                props.load(new FileInputStream(curr));
            }
            catch (IOException e) {
                logger.error("Could not parse file" + curr, e);
            }
            String ns = makeNamespace(curr);
            logger.debug("Adding namespace: " + ns + " for file: " +
                      curr.getAbsolutePath());

            // loop through all of the config values in the properties file
            // making sure the prefix is there.
            Properties newProps = new Properties();
            for (Iterator j = props.keySet().iterator(); j.hasNext();) {
                String key = (String) j.next();
                String newKey = key;
                if (!key.startsWith(ns)) {
                    newKey = ns + "." + key;
                }
                logger.debug("Adding: " + newKey + ": " + props.getProperty(key));
                newProps.put(newKey, props.getProperty(key));    
            }
            configValues.putAll(newProps);
        }
    }

    /**
     * Returns a subset of the properties for the given namespace. This is
     * not a particularly fast method and should be used only at startup or
     * some other discreet time.  Repeated calls to this method are guaranteed
     * to be slow.
     * @param namespace Namespace of properties to be returned.
     * @return subset of the properties that begin with the given namespace.
     */
    public Properties getNamespaceProperties(String namespace) {
        Properties prop = new Properties();
        for (Iterator i = configValues.keySet().iterator(); i.hasNext();) {
            String key = (String) i.next();
            if (key.startsWith(namespace)) {
                if (logger.isDebugEnabled()) {
                    logger.debug("Looking for key: [" + key + "]");
                }
                prop.put(key, configValues.getProperty(key));
            }
        }
        return prop;
    }

    /**
     * Check to see if monitoring scout functionality is enabled
     *
     * @return true if scout is enabled
     */
    public boolean isMonitoringScout() {
        return getBoolean(WEB_IS_MONITORING_SCOUT);
    }

    /**
     * Check to see if monitoring backend functionality is enabled
     *
     * @return true if backend is enabled
     */
    public boolean isMonitoringBackend() {
        return getBoolean(WEB_IS_MONITORING_BACKEND);
    }

    /**
     * Return <code>true</code> if SSL is available for web traffic.
     *
     * @return <code>true</code> if SSL is available for web traffic.
     */
    public boolean isSSLAvailable() {
        return getBoolean(SSL_AVAILABLE);
    }
    
    /**
     * 
     * @return if we should force unentitlement of systems
     * when setting entitlements below current usage for multiorg
     */
    public boolean forceUnentitlement() {
        return getBoolean(FORCE_UNENTITLEMENT);
    }

    /**
     * Check if this Sat is disconnected or not
     * @return boolean if this sat is disconnected or not
     */
    public boolean isDisconnected() {
        return (this.getString(SATELLITE_PARENT) != null);
    }

    /**
     * Get the configured hostname for this RHN Server.
     * @return String hostname
     */
    public String getHostname() {
        return this.getString(JABBER_SERVER);
    }
    
    /**
     * Returns the URL for the search server, if not defined returns
     * http://localhost:2828/RPC2
     * @return the URL for the search server.
     */
    public String getSearchServerUrl() {
        String searchServerHost =
                getString("search_server.host", "localhost");
        int searchServerPort = getInt("search_server.port", 2828);
        return "http://" + searchServerHost + ":" + searchServerPort + "/RPC2";
    }

    /**
     * Get the URL to the cobbler server 
     * @return http url
     */
    public String getCobblerServerUrl() {
        String cobblerServer = getCobblerHost();
        int cobblerServerPort = getInt("cobbler.port", 80);
        return "http://" + cobblerServer + ":" + cobblerServerPort + "/cobbler_api_rw";
    }
    
    
    /**
     * Get just the cobbler hostname
     * @return the cobbler hostname
     */
    public String getCobblerHost() {
        return getString("cobbler.host", "localhost");
    }
    

    /**
     * Return true if this is a Spacewalk instance. (as opposed to Satellite)
     * @return true is this is a Spacewalk instance.
     */
    public boolean isSpacewalk() {
        if (getString(PRODUCT_NAME).equals(SPACEWALK)) {
            return true;
        }
        return false;
    }
    
    /**
     * Return the kickstart mount point directory
     * Note the mount point is guaranteed to have a
     * '/' at the end of the string so you can use it
     * for appending sub directories.
     * @return the ks mount point directory.
     */
    public String getKickstartMountPoint() {
        String mount =  StringUtils.defaultIfEmpty(getString(KICKSTART_MOUNT_POINT),
                                                    getString(MOUNT_POINT)).trim();
        if (!mount.endsWith("/")) {
            mount = mount + "/";
        }
        return mount;
    }
    
    
    /**
     * Returns the default kickstart package name
     * @return the default kickstart package name
     */
    public String getKickstartPackageName() {
        return StringUtils.defaultIfEmpty(getString(KICKSTART_PACKAGE_NAME),
                DEFAULT_KICKSTART_PACKAGE_NAME).trim();        
    }
    
    /**
     * Get the user string for use with authorization between Spacewalk
     * and Cobbler if there is no actual user in context.
     * 
     * @return String from our config
     */
    public String getCobblerAutomatedUser() {
        return getString(Config.COBBLER_AUTOMATED_USER, "taskomatic_user");
    }
}

