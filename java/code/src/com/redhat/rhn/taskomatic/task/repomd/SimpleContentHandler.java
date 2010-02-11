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
package com.redhat.rhn.taskomatic.task.repomd;

import org.xml.sax.ContentHandler;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;

/**
 * Generic content handler for repomd
 * @version $Rev $
 * 
 */
public class SimpleContentHandler {

    private ContentHandler handler;

    /**
     * Constructor takes in handler
     * @param handlerIn content handler
     */
    public SimpleContentHandler(ContentHandler handlerIn) {
        this.handler = handlerIn;
    }

    /**
     * Ends the xml document
     * @throws SAXException sax exception
     */
    public void endDocument() throws SAXException {
        handler.endDocument();
    }

    /**
     * start of xml document
     * @throws SAXException sax exception
     */
    public void startDocument() throws SAXException {
        handler.startDocument();
    }

    /**
     * start of xml element
     * @param name element name
     * @throws SAXException sax exception
     */
    public void startElement(String name) throws SAXException {
        handler.startElement("", "", name, null);
    }

    /**
     * start element takes in name with attributes
     * @param name element name
     * @param attrs attributes
     * @throws SAXException sac exception
     */
    public void startElement(String name, AttributesImpl attrs)
        throws SAXException {
        handler.startElement("", "", name, attrs);
    }

    /**
     * End of xml element
     * @param name element name
     * @throws SAXException sax exception
     */
    public void endElement(String name) throws SAXException {
        handler.endElement("", "", name);
    }

    /**
     * Adds empty elements to xml tree
     * @param name element name
     * @throws SAXException SAX exception
     */
    public void addEmptyElement(String name) throws SAXException {
        handler.startElement("", "", name, null);
        handler.endElement("", "", name);
    }

    /**
     * Adds characters to the xml handler
     * @param text text for adding characters
     * @throws SAXException SAX exception
     */
    public void addCharacters(String text) throws SAXException {
        handler.characters(text.toCharArray(), 0, text.length());
    }

    /**
     * Adds elements with characters
     * @param name element name
     * @param text character text
     * @throws SAXException SAX exception
     */
    public void addElementWithCharacters(String name, String text)
        throws SAXException {
        startElement(name);
        if (text != null) {
            addCharacters(text);
        }
        endElement(name);
    }
}
