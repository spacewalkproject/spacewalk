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

package com.redhat.rhn.common.localization;

import com.redhat.rhn.common.conf.Config;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.text.MessageFormat;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;

/**
 * Utility (Singleton) class to get and format messages centralized by package.
 * Messages are assumed to be in a {@link ResourceBundle} called
 * <code>StringResource</code>
 * in a given class' package.
 * ie, If the class is <code>my.package.foo.Bar</code>, the
 * methods will look for the ResourceBundle
 * <code>my.package.foo.StringResource</code>. (The actual file can be
 * a subclass of ResourceBundle or a properties file.)
 * The ResourceBundle keys are assumed to be prefixed with the class name.
 * ie, if the class is <code>my.package.foo.Bar</code> and the key is
 * <code>msg</code>, the methods will then
 * look for the key <code>Bar.msg</code>.
 *
 *
 * @version $Rev$
 */
public final class XmlMessages {

    /** The error warning message in case we don't find a message.
     */
    public static final String MESSAGE_NOT_FOUND = "*** MESSAGE NOT FOUND ***";

    /** Set to "StringResource"
      */
    protected static final String RESOURCE_BUNDLE_CLASSNAME = "StringResource";

    public static final String PRODUCT_NAME_MACRO = "@@PRODUCT_NAME@@";

    private static final Logger LOG = Logger.getLogger(XmlMessages.class);

    private static XmlMessages instance = new XmlMessages();


    // Store the bundles in memory so we don't load it off disk
    // each time.
    private Map bundles;


    /** Private constructor, since this is a singleton
     */
    private XmlMessages() {
        initBundleCache();
    }

    private void initBundleCache() {
        bundles = new HashMap();
    }

    /**
     * Get the instance of the singleton class
     * @return The instance
     */
    public static XmlMessages getInstance() {
        return instance;
    }

    /**
     * Reload the XML Messages off the disk.
     */
    public void resetBundleCache() {
        initBundleCache();
    }

   /** Gets the resource bundle, first checking our internal cache
      * @param bundleName name of the resource bundle
      * @param locale locale used to retrieve the resource bundle
      * @return the resource bundle for the given bundleName and locale,
      * always non-null. (An exception is thrown if the bundle can't be found.)
      */
    protected ResourceBundle getBundle(final String bundleName,
                                       final Locale locale) {


        // Construct the key to the Map of Bundles
        // that is a combination of the bundlename
        // plus the locale
        StringBuffer bundleBuff = new StringBuffer(bundleName);
        if (locale != null) {
            bundleBuff.append(".");
            bundleBuff.append(locale.toString());
        }
        String bundleKey = bundleBuff.toString();
        // Check the local in memory cache of the bundles
        // to see if it has been loaded already.
        ResourceBundle retval = (ResourceBundle) bundles.get(bundleKey);

        if (retval != null) {
            // System.out.println("Got bundle from cache, returning : " + bundleKey);
            return retval;
        }
        // System.out.println("Reloading BUNDLE : " + bundleKey);

        StringBuffer urlName = new StringBuffer("/" + bundleName.replace('.', '/'));

        // if we specified a locale
        // then make sure we tack it on to the filename
        // to be loaded.
        if (locale != null) {
            urlName.append("_");
            urlName.append(locale.toString());
        }
        urlName.append(".xml");

        try {
            synchronized (this) {
                retval =
                    new XmlResourceBundle(urlName.toString());
                bundles.put(bundleKey, retval);
            }

        }
        catch (IOException ioe) {
            if (LOG.isDebugEnabled()) {
                LOG.debug("Resource bundle not found: " +
                        ioe.toString() + ", url: " + urlName);
            }
            throw new java.util.MissingResourceException(
                    "Resource bundle not found", bundleName, "");
        }
        return retval;

    }

    /**
    * Obtain a string from the resource file that doesn't require formatting.
    * See the format() methods for obtaining strings that require formatting.
     * @param clazz the class to which the string belongs
     * @param locale the locale used to find the resource bundle
     * @param key the key for the string to be obtained from the resource bundle
    * @return the message for the given key
    */
    public String getMessage(final Class clazz,
                                    final Locale locale,
                                    final String key) {
        return format(clazz, locale, key, (Object[]) null);
    }

    /**
     * Convenience method to format a string from the resource bundle, which
     * takes a single argument.
     * @param clazz the class to which the string belongs
     * @param locale the locale used to find the resource bundle
     * @param key the key for the string to be obtained from the resource bundle
     * @param arg1 the first argument to use in the formatted text
     * @return the formatted message for the given key and argument
     */
    public String format(final Class clazz,
                                final Locale locale,
                                final String key,
                                final String arg1) {
        return format(clazz, locale, key, new Object[]{arg1});
    }

    /**
     * Convenience method to format a string from the resource bundle, which
     * takes two arguments.
     * @param clazz the class to which the string belongs
     * @param locale the locale used to find the resource bundle
     * @param key the key for the string to be obtained from the resource bundle
     * @param arg1 the first argument to use in the formatted text
     * @param arg2 the second argument to use in the formatted text
     * @return the formatted message for the given key and arguments
     */
    public String format(final Class clazz,
                                final Locale locale,
                                final String key,
                                final String arg1,
                                final String arg2) {
        return format(clazz, locale, key, new Object[]{arg1, arg2});
    }

    /**
     * Convenience method to format a string from the resource bundle, which
     * takes three arguments.
     * @param clazz the class to which the string belongs
     * @param locale the locale used to find the resource bundle
     * @param key the key for the string to be obtained from the resource bundle
     * @param arg1 the first argument to use in the formatted text
     * @param arg2 the second argument to use in the formatted text
     * @param arg3 the third argument to use in the formatted text
     * @return the formatted message for the given key and arguments
     */
    public String format(final Class clazz,
                                final Locale locale,
                                final String key,
                                final String arg1,
                                final String arg2,
                                final String arg3) {
        return format(clazz, locale, key, new Object[]{arg1, arg2, arg3});
    }

    /**
     * Method to format a string from the resource bundle.  This
     * method allows the user of this class to directly specify the
     * bundle package name to be used.  Allows us to have
     * resource bundles in packages without classes.  Eliminates
     * the need for "Dummy" classes.
     *
     * @param clazz the class to which the string belongs
     * @param locale the locale used to find the resource bundle
     * @param key the key for the string to be obtained from the resource bundle
     * @param args the arguments that should be applied to the string obtained
     * from the resource bundle. Can be null, to represent no arguments
     * @return the formatted message for the given key and arguments
     */
    public String format(final Class clazz,
                                final Locale locale,
                                final String key,
                                final Object... args) {

        // Fetch the bundle
        ResourceBundle bundle = getBundle(getBundleName(clazz), locale);
        String pattern = StringEscapeUtils.unescapeHtml(bundle.getString(key));

        pattern = pattern.replaceAll(PRODUCT_NAME_MACRO,
                Config.get().getString("web.product_name"));

        if (args == null || args.length == 0) {
            return pattern;
        }

        //MessageFormat uses single quotes to escape text. Therefore, we have to
        //escape the single quote so that MessageFormat keeps the single quote and
        //does replace all arguments after it.
        String escapedPattern = pattern.replaceAll("'", "''");
        MessageFormat mf = new MessageFormat(escapedPattern, locale);
        return mf.format(args);
    }

    private String getBundleName(final Class clazz) {
        String fullyQualifiedClassName = clazz.getName();
        int idx = fullyQualifiedClassName.lastIndexOf('.');
        String bundleName = fullyQualifiedClassName.substring(0, idx + 1) +
            RESOURCE_BUNDLE_CLASSNAME;
        return bundleName;
    }

    /**
     * Gets the keys of all the strings in the specified class and locale's
     * resource bundle.
     *
     * @param clazz Class of the resource bundle
     * @param locale locale used to retrieve the resource bundle
     * @return the Iterator of all the keys
    */
    public Enumeration getKeys(final Class clazz,
                                final Locale locale) {
        return getBundle(getBundleName(clazz), locale).getKeys();
    }

}
