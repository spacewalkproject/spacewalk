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

import org.apache.log4j.Logger;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Vector;

/**
 * Class that extends the java.util.ResourceBundle class that stores
 * the strings in an XML format similar to a property file.
 * The format is as follows:
 *
 * <messages>
 *   <msg id="getMessage">Get this</msg>
 *   <msg id="oneArg">one arg: {0}</msg>
 *   <msg id="twoArg">two arg: {0} {1}</msg>
 *   <msg id="threeArg">three arg: {0} {1} {2}</msg>
 * </messages>
 *
 * Where the bundle gets built with the keys being the "id" attribute
 * of the XML tag and the values being contained within the value of the
 * <msg> tag itself.   Message substitution is supported.
 *
 * @version $Rev$
 */
public final class XmlResourceBundle extends java.util.ResourceBundle {

    private static Logger log = Logger.getLogger(XmlResourceBundle.class);

    /**
     * Map of key/value pairs
     */
    private Map strings;

    /** Constructor
     */
    public XmlResourceBundle() {
        // empty
    }

   /**
     * Creates a property resource bundle.
     * @param filelocation location of XML file to parse
     * @throws IOException if the file can't be parsed/loaded
     */
    public XmlResourceBundle(String filelocation) throws IOException {
        strings = new HashMap();
        try {
            // These are namespace URLs, and don't actually
            // resolve to real documents that get downloaded on the
            // web.
            // Turn on validation
            String validationFeature 
                = "http://xml.org/sax/features/validation";
            // Turn on schema validation
            String schemaFeature 
                = "http://apache.org/xml/features/validation/schema";
            // We have to store the xsd locally because we may not have
            // access to it over the web when starting up the service.
            String xsdLocation = 
                this.getClass().getResource("/xliff-core-1.1.xsd").toString(); 
            XMLReader parser = XMLReaderFactory.
                createXMLReader("org.apache.xerces.parsers.SAXParser");
            parser.setFeature(validationFeature, false);
            parser.setFeature(schemaFeature, false);
            parser.setProperty("http://apache.org/xml/properties/schema/" +
                    "external-noNamespaceSchemaLocation", xsdLocation);
            XmlResourceBundleParser handler = new XmlResourceBundleParser();
            parser.setContentHandler(handler);
            parser.parse(new InputSource(this.getClass().
                                         getResourceAsStream(filelocation)));
            strings = handler.getMessages();
        }
        catch (SAXException e) {
            // This really should never happen, because without this file,
            // the whole UI stops working.
            log.error("Could not setup parser");
            throw new IOException("Could not load XML bundle: " + filelocation);
        }
        // TODO: put the xml strings in the Map

    }
    
    /**
     * Overrides the java.util.ResourceBundle.handleGetObject.
     * @param key the key to lookup out of the bundle
     * @return The value found. This will be a java.lang.String and can be cased
     * accordingly.
     */
    public Object handleGetObject(String key) {
        return strings.get(key);
    }

    /**
     * ResourceBundle.getKeys() implemenatation
     * @return Enumeration of the keys contained in this bundle.
     *         Useful for searching for a partial match.
     */
    public Enumeration getKeys() {
        List keys = new LinkedList();

        if (parent != null) {
            Enumeration e = parent.getKeys();
            while (e.hasMoreElements()) {
                keys.add(e.nextElement());
            }
        }

        Iterator itr = strings.keySet().iterator();
        while (itr.hasNext()) {
            keys.add(itr.next());
        }
        // Ugh, have to convert back to the old Enumeration interface
        // This isn't pretty but it works.
        return new Vector(keys).elements();
    }

}
