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
package com.redhat.rhn.common.util;

import org.apache.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Builds a single OVAL XML file out of individual OVAL files
 * 
 * @version $Rev$
 */
public class OvalFileAggregator {
    
    private static final Logger LOGGER = Logger.getLogger(OvalFileAggregator.class);
    
    private Document aggregate;
    private boolean isFinished;
    private Map defs;
    private Map tests;
    private Map objects;
    private Map states;
   
    /**
     * No-arg constructor
     * @throws JDOMException if XML document initialization fails
     */
    public OvalFileAggregator() throws JDOMException {
        reset();
    }
    
    /**
     * Adds a OVAL file to the aggregate
     * @param f file to add
     * @throws JDOMException XML parsing failed
     * @throws IOException file IO failed
     */
    public void add(File f) throws JDOMException, IOException {
        if (f == null) {
            return;
        }
        try {
            SAXBuilder builder = new SAXBuilder();
            builder.setValidation(false);
            add(builder.build(f));
        }
        catch (JDOMException e) {
            LOGGER.error(e.getMessage(), e);
            throw e;
        }
        catch (IOException e) {
            LOGGER.error(e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Adds a parsed OVAL file to the aggregate
     * @param doc parsed OVAL file
     * @throws JDOMException XMl parsing failed
     */
    public void add(Document doc) throws JDOMException {
       if (isFinished) {
           throw new IllegalStateException();
       }
       storeDefinitions(doc);
       storeTests(doc);
       storeObjects(doc);
       storeStates(doc);
    }
    
    /**
     * Finalizes processing and builds the aggregated document
     * @param prettyPrint pretty print XML or not
     * @return XML in string form
     * @throws IOException document output failed
     */
    public String finish(boolean prettyPrint) throws IOException {
        if (!isFinished && !isEmpty()) {
            buildDocument();
            isFinished = true;
        }
        if (isEmpty()) {
            return "";
        }
        XMLOutputter out = new XMLOutputter();
        if (prettyPrint) {
            out.setFormat(Format.getPrettyFormat());
        }
        else {
            out.setFormat(Format.getCompactFormat());
        }
        StringWriter buffer = new StringWriter();
        out.output(aggregate, buffer);
        String retval = buffer.toString();
        retval = retval.replaceAll(" xmlns:oval=\"removeme\"", "");
        return retval.replaceAll(" xmlns:redhat=\"removeme\"", "");
    }
    
    private void buildDocument() {
        Element defsElement = new Element("definitions");
        attachChildren(defsElement, defs);
        Element testsElement = new Element("tests");
        attachChildren(testsElement, tests);
        Element objectsElement = new Element("objects");
        attachChildren(objectsElement, objects);
        Element statesElement = new Element("states");
        attachChildren(statesElement, states);
        List children = aggregate.getRootElement().getChildren();
        children.add(defsElement);
        children.add(testsElement);
        children.add(objectsElement);
        children.add(statesElement);
    }
    
    private boolean isEmpty() {
        return defs.size() == 0 && tests.size() == 0 && states.size() == 0;
    }
    
    private void attachChildren(Element parent, Map children) {
        for (Iterator iter = children.keySet().iterator(); iter.hasNext();) {
            String key = (String) iter.next();
            Element child = (Element) children.get(key);
            parent.getChildren().add(child);
        }
    }
    
    private void storeStates(Document doc) {
        XPathLite xpl = new XPathLite("states");
        storeChildren(xpl, doc, states);
    }
    
    private void storeObjects(Document doc) {
        XPathLite xpl = new XPathLite("objects");
        storeChildren(xpl, doc, objects);
    }
    
    private void storeTests(Document doc) {
        XPathLite xpl = new XPathLite("tests");
        storeChildren(xpl, doc, tests);
    }
    
    private void storeDefinitions(Document doc) {
        XPathLite xpl = new XPathLite("definitions");
        storeChildren(xpl, doc, defs);
    }
    
    private void storeChildren(XPathLite xpl, Document doc, Map container) {
        for (Iterator iter = xpl.selectChildren(doc).iterator(); iter.hasNext();) {
            Element child = (Element) iter.next();
            String key = child.getAttributeValue("id");
            if (key == null) {
                continue;
            }
            else {
                if (container.containsKey(key)) {
                    continue;
                }
                else {
                    container.put(key, child.clone());
                }
            }
        }        
    }

    
    
    private void reset() {
        Namespace schema = Namespace.getNamespace(
                "xsi", "http://www.w3.org/2000/10/XMLSchema-instance");
        Namespace oval = Namespace.getNamespace("oval", "removeme");
        aggregate = new Document();
        Element root = new Element("oval_definitions");
        root.setAttribute("schemaLocation", 
                "http://oval.mitre.org/XMLSchema/oval-common-5 " + 
                "oval-common-schema.xsd " + 
                "http://oval.mitre.org/XMLSchema/oval-definitions-5 " + 
                "oval-definitions-schema.xsd " + 
                "http://oval.mitre.org/XMLSchema/oval-definitions-5#unix " + 
                "unix-definitions-schema.xsd " + 
                "http://oval.mitre.org/XMLSchema/oval-definitions-5#redhat " + 
                "redhat-definitions-schema.xsd", schema);
        aggregate.setRootElement(root);
        Element generator = new Element("generator");
        Element prodName = new Element("product_name", oval);
        prodName.setText("Spacewalk");
        Element schemaVersion = new Element("schema_version", oval);
        schemaVersion.addNamespaceDeclaration(oval);
        schemaVersion.setText("5.0");
        Element timestamp = new Element("timestamp", oval);
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        StringBuffer date = new StringBuffer();
        date.append(cal.get(Calendar.YEAR));
        date.append("-");
        int month = cal.get(Calendar.MONTH);
        if (month < 10) {
            date.append("0");
        }
        date.append(month);
        date.append("-");
        int day = cal.get(Calendar.DATE);
        if (day < 10) {
            date.append("0");
        }
        date.append(day);
        date.append("T").append(cal.get(Calendar.HOUR_OF_DAY));
        date.append(":").append(cal.get(Calendar.MINUTE));
        date.append(":").append(cal.get(Calendar.SECOND));
        timestamp.setText(date.toString());
        root.getChildren().add(generator);
        generator.getChildren().add(prodName);
        generator.getChildren().add(schemaVersion);
        generator.getChildren().add(timestamp);
        
        defs = new LinkedHashMap();
        tests = new LinkedHashMap();
        objects = new LinkedHashMap();
        states = new LinkedHashMap();
    }
}
