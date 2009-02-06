package com.redhat.rhn.taskomatic.task.repomd;

import org.xml.sax.ContentHandler;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;

public class SimpleContentHandler {
	
    private ContentHandler handler;

    public SimpleContentHandler(ContentHandler handler) {
        this.handler = handler;
    }

    public void endDocument() throws SAXException {
        handler.endDocument();
    }

    public void startDocument() throws SAXException {
        handler.startDocument();
    }

    public void startElement(String name) throws SAXException {
        handler.startElement("", "", name, null);
    }

    public void startElement(String name, AttributesImpl attrs) throws SAXException {
        handler.startElement("", "", name, attrs);
    }

    public void endElement(String name) throws SAXException {
        handler.endElement("", "", name);
    }

    public void addEmptyElement(String name) throws SAXException {
        handler.startElement("", "", name, null);
        handler.endElement("", "", name);
    }

    public void addCharacters(String text) throws SAXException {
        handler.characters(text.toCharArray(), 0, text.length());
    }

    public void addElementWithCharacters(String name, String text) throws SAXException {
        startElement(name);
                if (text != null) {
                    addCharacters(text);
                }
        endElement(name);
    }
}
