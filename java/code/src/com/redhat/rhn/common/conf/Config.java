/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
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
 * Config files are properties, with /usr/share/rhn/config-defaults/rhn.conf
 * setting defaults that can be overridden by /etc/rhn/rhn.conf.
 *
 * @version $Rev$
 */
public class Config {


    private static Logger logger = Logger.getLogger(Config.class);



    //
    // Location of config files
    //

    /**
     * The default directory in which to look for config files
     */
    public static final String DEFAULT_CONF_DIR = "/etc/rhn";

    /**
     * The directory in which to look for default config values
     */
    public static final String DEFAULT_DEFAULT_CONF_DIR = "/usr/share/rhn/config-defaults";

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

    /**
     * array of prefix in the order they should be search
     * if the given lookup string is without a namespace.
     */
    private final String[] prefixOrder = new String[] {"web", "server"};
    private static Config singletonConfig = null;
    /** hash of configuration properties */
    private final Properties configValues = new Properties();
    /** set of configuration file names */
    private final TreeSet<File> fileList = new TreeSet<File>(new Comparator<File>() {

        /** {inheritDoc} */
        public int compare(File f1, File f2) {
            // Need to make sure we read the child namespace before the base
            // namespace.  To do that, we sort the list in reverse order based
            // on the length of the file name.  If two filenames have the same
            // length, then we need to do a lexigraphical comparison to make
            // sure that the filenames themselves are different.

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
        addPath(DEFAULT_DEFAULT_CONF_DIR);
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
     * @param name Key to check for
     * @return true if the config contains key
     */
    public boolean containsKey(String name) {
        return configValues.containsKey(name);
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

        int lastDot = value.lastIndexOf('.');
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

        return StringUtils.trim(result);
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
    public List<String> getList(String name) {
        List<String> retval = new LinkedList<String>();
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
     * remove the config entry for key
     * @param name key to remove
     */
    public void remove(String name) {
        configValues.remove(name);
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
            if (files == null) {
                logger.error("Unable to list files in path : " + path);
                return;
            }
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
        int lastDotindex = ns.lastIndexOf('.');
        if (lastDotindex != -1) {
            ns = ns.substring(0, ns.lastIndexOf('.'));
        }
        ns = ns.replaceAll("_", ".");
        return ns;
    }

    /**
     * Parse all of the added files.
     */
    public void parseFiles() {
        for (Iterator<File> i = fileList.iterator(); i.hasNext();) {
            File curr = i.next();

            Properties props = new Properties();
            try {
                String configString = FileUtils.readFileToString(curr, "UTF-8");
                props.load(new StringReader(configString.replace("\\", "\\\\")));
            }
            catch (IOException e) {
                logger.error("Could not parse file " + curr, e);
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
}
