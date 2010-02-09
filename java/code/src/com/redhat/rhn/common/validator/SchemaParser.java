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
package com.redhat.rhn.common.validator;

import org.apache.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.input.SAXBuilder;

import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * <p>
 *  The <code>SchemaParser</code> class parses an XML Schema and creates
 *    <code>{@link Constraint}</code> objects from it.
 * </p>
 * @version $Rev$ 
 */
public class SchemaParser {
    
    private static Logger log = Logger.getLogger(SchemaParser.class);
    
    /** The URL of the schema to parse */
    private URL schemaURL;

    /** The constraints from the schema */
    private Map constraints;

    /** XML Schema Namespace */
    private Namespace schemaNamespace;

    /** XML Schema Namespace URI */
    private static final String SCHEMA_NAMESPACE_URI =
        "http://www.w3.org/1999/XMLSchema";

    /**
     * <p>
     *  This will create a new <code>SchemaParser</code>, given
     *    the URL of the schema to parse.
     * </p>
     *
     * @param schemaURLIn the <code>URL</code> of the schema to parse.
     * @throws IOException when parsing errors occur.
     */
    public SchemaParser(URL schemaURLIn) throws IOException {
        this.schemaURL = schemaURLIn;
        constraints = new HashMap();
        schemaNamespace = 
            Namespace.getNamespace(SCHEMA_NAMESPACE_URI);

        // Parse the schema and prepare constraints
        parseSchema();
    }

    /**
     * <p>
     *  This will return constraints found within the document.
     * </p>
     *
     * @return <code>Map</code> - the schema-defined constraints.
     */
    public Map getConstraints() {
        return constraints;
    }

    /**
     * <p>
     *  This will get the <code>Constraint</code> object for
     *    a specific constraint name. If none is found, this
     *    will return <code>null</code>.
     * </p>
     *
     * @param constraintName name of constraint to look up.
     * @return <code>Constraint</code> - constraints for
     *         supplied name.
     */
    public Constraint getConstraint(String constraintName) {
        Object o = constraints.get(constraintName);
        if (o != null) {
            return (Constraint)o;
        } 
        else {
            return null;
        }
    }

    /**
     * <p>
     *  This will do the work of parsing the schema.
     * </p>
     *
     * @throws IOException - when parsing errors occur.
     */
    private void parseSchema() throws IOException {
        /**
         * Create builder to generate JDOM representation of XML Schema,
         *   without validation and using Apache Xerces.
         */ 
        // XXX: Allow validation, and allow alternate parsers
        SAXBuilder builder = new SAXBuilder();

        try {
            Document schemaDoc = builder.build(schemaURL);

            // Handle attributes
            List attributes = schemaDoc.getRootElement()
                                         .getChildren("attribute", 
                                                      schemaNamespace);
            for (Iterator i = attributes.iterator(); i.hasNext();) {
                // Iterate and handle
                Element attribute = (Element)i.next();
                handleAttribute(attribute);
            }
            // Handle attributes nested within complex types

        } 
        catch (JDOMException e) {
            throw new IOException(e.getMessage());
        }
    }

    /**
     * <p>
     *  This will convert an attribute into constraints.
     *  TODO: make everyone happy: replace this with Digester
     * </p>
     *
     * @throws IOException - when parsing errors occur.
     */
    private void handleAttribute(Element attribute) 
        throws IOException {

        // Get the attribute name and create a Constraint
        String name = attribute.getAttributeValue("name");
        if (name == null) {
            throw new IOException("All schema attributes must have names.");
        }
        
        

        // Get the simpleType - if none, we are done with this attribute
        Element simpleType = attribute.getChild("simpleType", schemaNamespace);
        if (simpleType == null) {
            return;
        }
        
        // Handle the data type
        String schemaType = simpleType.getAttributeValue("baseType");
        if (schemaType == null) {
            throw new IOException("No data type specified for constraint " + name);
        }
        
        Constraint constraint; // = new Constraint(name);
        
        Element child;
        
        if (schemaType.equals("long")) { 
            NumericConstraint nc = new NumericConstraint(name);
            
            processRequiredIfConstraint(simpleType, nc);
            
            // Handle ranges
            child = simpleType.getChild("minInclusive", schemaNamespace);
            if (child != null) {
                Double value = new Double(child.getAttributeValue("value"));
                nc.setMinInclusive(value);
            }
            child = simpleType.getChild("maxInclusive", schemaNamespace);
            if (child != null) {
                Double value = new Double(child.getAttributeValue("value"));
                nc.setMaxInclusive(value);
            }
            constraint = nc;
        }
        else if (schemaType.equals("string")) { 
            StringConstraint lc = new StringConstraint(name); 
            
            processRequiredIfConstraint(simpleType, lc);
            child = simpleType.getChild("ascii", schemaNamespace);
            if (child != null) {
                lc.setASCII(true); 
            }

            child = simpleType.getChild("username", schemaNamespace);
            if (child != null) {
                lc.setUserName(true); 
            }
            
            child = simpleType.getChild("posix", schemaNamespace);
            if (child != null) {
                lc.setPosix(true); 
            }
            
            child = simpleType.getChild("maxLength", schemaNamespace);
            if (child != null) {
                Double value = new Double(child.getAttributeValue("value"));
                lc.setMaxLength(value);
            }
            child = simpleType.getChild("minLength", schemaNamespace);
            if (child != null) {
                Double value = new Double(child.getAttributeValue("value"));
                lc.setMinLength(value);
            }
            
            child = simpleType.getChild("matchesExpression", schemaNamespace);
            if (child != null) {
                String value = new String(child.getAttributeValue("value"));
                lc.setRegEx(value);
            }
            constraint = lc;            
        }
        else {
            constraint = new RequiredConstraint(name);
        }
        
        constraint.setDataType(DataConverter.getInstance().getJavaType(schemaType));
        
        // Store this constraint
        log.debug("Adding: constraint name: " + name + 
                " datatype: " + constraint.getDataType());
        constraints.put(name, constraint);
    }

    private void processRequiredIfConstraint(Element simpleType, RequiredIfConstraint lc) {
        List requiredIfFields =
             simpleType.getChildren("requiredIf", schemaNamespace);
        if (requiredIfFields != null && requiredIfFields.size() > 0) {
            for (Iterator i = requiredIfFields.iterator(); i.hasNext();) {
                Element requiredIf = (Element)i.next();
                String fieldName = requiredIf.getAttributeValue("field");
                String fieldValue = requiredIf.getAttributeValue("value");
                lc.addField(fieldName, fieldValue);
            }
        }
    }
    
    
}
