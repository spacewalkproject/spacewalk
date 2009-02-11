package com.redhat.rhn.taskomatic.task.repomd;

import org.xml.sax.ContentHandler;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;

public class SimpleContentHandler {
	
    private ContentHandler handler;
    /**
     *  Constructor takes in handler
     * @param handler
     */
    public SimpleContentHandler(ContentHandler handler) {
        this.handler = handler;
    }
    /**
     * Ends the xml document
     * @throws SAXException
     */
    public void endDocument() throws SAXException {
        handler.endDocument();
    }
    /**
     * start of xml document
     * @throws SAXException
     */
    public void startDocument() throws SAXException {
        handler.startDocument();
    }
    /**
     * start of xml element
     * @param name element name
     * @throws SAXException
     */
    public void startElement(String name) throws SAXException {
        handler.startElement("", "", name, null);
    }
    /**
     * start element takes in name with attributes
     * @param name element name
     * @param attrs attributes
     * @throws SAXException
     */
    public void startElement(String name, AttributesImpl attrs) throws SAXException {
        handler.startElement("", "", name, attrs);
    }
    /**
     * End of xml element
     * @param name element name
     * @throws SAXException
     */
    public void endElement(String name) throws SAXException {
        handler.endElement("", "", name);
    }
    /**
     * Adds empty elements to xml tree
     * @param name element name
     * @throws SAXException
     */
    public void addEmptyElement(String name) throws SAXException {
        handler.startElement("", "", name, null);
        handler.endElement("", "", name);
    }
    /**
     * Adds characters to the xml handler
     * @param text
     * @throws SAXException
     */
    public void addCharacters(String text) throws SAXException {
        handler.characters(text.toCharArray(), 0, text.length());
    }
    /**
     * Adds elements with characters
     * @param name element name
     * @param text character text
     * @throws SAXException
     */
    public void addElementWithCharacters(String name, String text) throws SAXException {
        startElement(name);
                if (text != null) {
                    addCharacters(text);
                }
        endElement(name);
    }
}
