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
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

import java.util.HashMap;
import java.util.Map;

/**
 * Internal class for SAX parsing the XML ResourceBundles.
 * See XmlResourceBundle for usage.
 * @version $Rev$
 */

class XmlResourceBundleParser  extends DefaultHandler {

    private Map messages;
    private StringBuffer thisText;
    private String currKey;
    private static Logger log = Logger.getLogger(XmlResourceBundleParser.class);
    
    /** constructor
     */
    public XmlResourceBundleParser() {
        super();
        thisText = new StringBuffer();
        messages = new HashMap();
    }


    /** {@inheritDoc} */
    public void startElement(String namespaceUri, String localName,
                             String qualifiedName, Attributes attributes) {

        thisText = new StringBuffer();
        if (qualifiedName.equals("trans-unit")) {
            currKey = attributes.getValue("id");
        }

    }

    /** {@inheritDoc} */
    public void endElement(String namespaceUri, String localName,
                           String qualifiedName) throws SAXException {

        if (thisText.length() > 0) {
            // For the en_US files we use source
            if (qualifiedName.equals("source")) {
                if (messages.containsKey(currKey)) {
                    log.warn("Duplicate message key found in XML Resource file: " + 
                        currKey);
                }
                log.debug("Adding: [" + currKey + "] value: [" + thisText.toString() + "]");
                messages.put(currKey, thisText.toString()); 
            }
            // For other languages we use target and overwrite the previously 
            // placed "source" tag.  Depends on the fact that the target tag
            // comes after the source tag.
            if (qualifiedName.equals("target")) {
                log.debug("Adding: [" + currKey + "] value: [" + thisText.toString() + "]");
                messages.put(currKey, thisText.toString()); 
            }
        }
    }
    
    /** {@inheritDoc} */
    public void warning(SAXParseException e) throws SAXException {
        log.error("SAXParseException Warning: ");
        printInfo(e);
    }

    /** {@inheritDoc} */
    public void error(SAXParseException e) throws SAXException {
        log.error("SAXParseException Error: ");
        printInfo(e);
    }

    /** {@inheritDoc} */
    public void fatalError(SAXParseException e) throws SAXException {
        log.error("SAXParseException Fatal error: ");
        printInfo(e);
    }

    private void printInfo(SAXParseException e) {
        log.error("   Message key: " + currKey);
        log.error("   Public ID: " + e.getPublicId());
        log.error("   System ID: " + e.getSystemId());
        log.error("   Line number: " + e.getLineNumber());
        log.error("   Column number: " + e.getColumnNumber());
        log.error("   Message: " + e.getMessage());
    }
    
    
    
    /** {@inheritDoc} */
    public void characters(char[] ch, int start, int length) {
        String appendme = new String(ch, start, length);
        thisText.append(appendme);
    }

    /**
     * Return the Map of the messages that was
     * produced while parsing the file
     * @return The map ..
     */
    public Map getMessages() {
        return messages;
    }

}
