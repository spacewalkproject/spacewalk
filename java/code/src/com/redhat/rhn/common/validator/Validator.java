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

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.commons.beanutils.PropertyUtils;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
/**
 * <p>
 * The <code>Validator</code> class allows an application component or client
 * to provide data, and determine if the data is valid for the requested type.
 * </p>
 * 
 * This code was copied from:
 * 
 * http://www.javaworld.com/javaworld/jw-09-2000/jw-0908-validation.html
 * 
 * There were no appearent license restrictions on this code, the Author 
 * indicated it was free and available to be used by readers of the article.
 * 
 * @version $Rev$ 
 */
public class Validator {

    private static Logger log = Logger.getLogger(Validator.class);
    
    /** The instances of this class for use (singleton design pattern) */
    private static Map instances = null;

    /** The URL of the XML Schema for this <code>Validator</code> */
    private URL schemaURL;

    /** The constraints for this XML Schema */
    private Map constraints;

    /**
     * <p>
     * This constructor is private so that the class cannot be instantiated
     * directly, but instead only through <code>{@link #getInstance()}</code>.
     * </p>
     * 
     * @param schemaURLIn <code>URL</code> to parse the schema at.
     * @throws IOException - when errors in parsing occur.
     */
    private Validator(URL schemaURLIn) throws IOException {
        this.schemaURL = schemaURLIn;

        // parse the XML Schema and create the constraints
        SchemaParser parser = new SchemaParser(schemaURL);
        constraints = parser.getConstraints();
    }

    /**
     * <p>
     * This will return the instance for the specific XML Schema URL. If a
     * schema exists, it is returned (as parsing will already be done);
     * otherwise, a new instance is created, and then returned.
     * </p>
     * 
     * @param schemaURL <code>URL</code> of schema to validate against.
     * @return <code>Validator</code>- the instance, ready to use.
     * @throws IOException when errors in parsing occur.
     */
    public static synchronized Validator getInstance(URL schemaURL)
        throws IOException {
        if (instances != null) {
            if (instances.containsKey(schemaURL.toString())) {
                return (Validator) instances.get(schemaURL.toString());
            }
            Validator validator = new Validator(schemaURL);
            instances.put(schemaURL.toString(), validator);
            return validator;
        }
        instances = new HashMap();
        Validator validator = new Validator(schemaURL);
        instances.put(schemaURL.toString(), validator);
        return validator;
    }
    
    /**
     * <p>
     * This will validate a data value (in <code>String</code> format) against
     * a specific constraint, and return <code>true</code> if that value is
     * valid for the constraint.
     * </p>
     * 
     * @param constraintName the identifier in the constraints to validate this
     * data against.
     * @param objToValidate <code>String</code> data to validate.
     * @return ValidatorError whether the data is valid or not.
     * TODO: rename this method to something other than isValid()
     */
    public ValidatorError isValid(String constraintName, Object objToValidate) {
        // Validate against the correct constraint
        Object o = constraints.get(constraintName);
        
        log.debug("Validating: " + constraintName);
        
        // If no constraint, then everything is valid
        if (o == null) {
            log.debug("No constraint found for " + constraintName);
            return null;
        }
        
        Constraint constraint = (Constraint) o;
        // Get the field we want to check
        Object value = null;
        try {
            value = PropertyUtils.getProperty(objToValidate, 
                                    constraint.getIdentifier());
        } 
        catch (Exception e) {
            String errorMessage = "Exception trying to get bean property: " + 
                                    e.toString();
            log.error(errorMessage, e);
            throw new ValidatorException(errorMessage, e);
        }
        // TODO: Get rid of the toString and determine the type
        String data = (value == null) ? null : value.toString();

        ValidatorError validationMessage = null;
        
        log.debug("Data: " + data);
        log.debug("Constraint: " + constraint);
        
        // Validate data type
        if (value != null && !value.equals("")) {
            validationMessage = correctDataType(data, constraint);
            if (validationMessage != null) {
                log.debug("Not the right datatype.. " + validationMessage);
                return validationMessage;
            }
        }
        
        // Execute the actual Constraint logic
        boolean required = true;
        // First we have to check to see if this is a RequiredIfConstraint
        // since it has a different method signature.  Not so pretty but its 
        // got a completely different way of checking constraints (references
        // multiple fields) so it has to be separate.
        if (constraint instanceof RequiredIfConstraint) {
            required = ((RequiredIfConstraint) constraint).
                isRequired(data, objToValidate);
        }
        log.debug("RequiredIf indicates:" + required);
        
        if (required) {
            validationMessage = constraint.checkConstraint(data);    
        }
        
        if (validationMessage != null) {
            log.debug("Failed: " + validationMessage);
            return validationMessage;
        }
        log.debug("All is OK, returning true ...");
        return null;
    }

    /** 
     * Get the list of Contraints associated with this Validator
     *
     * @return List of Constraint objects
     */
    public List getConstraints() {
        return new LinkedList(constraints.values());
    }
    
    /**
     * <p>
     * This will test the supplied data to see if it can be converted to the
     * Java data type given in <code>Constraint.dataType</code>.
     * </p>
     * 
     * @param data <code>String</code> to test data type of.
     * @param constraint <code>Constraint</code> Constraint to be checked.
     * @return <code>ValidatorError</code>- or null, if there are no errors.
     */
    private ValidatorError correctDataType(String data, Constraint constraint) {
        
        ValidatorError validationMessage = null;
        String dataType = constraint.getDataType();
        String identifier = 
            LocalizationService.getInstance().getMessage(constraint.getIdentifier());
        
        if ((dataType.equals("String")) || (dataType.equals("java.lang.String"))) {
            validationMessage = null;
        }

        else if ((dataType.equals("int")) || (dataType.equals("java.lang.Integer"))) {
            try {
                Integer.parseInt(data);
            }
            catch (NumberFormatException e) {
                validationMessage = new ValidatorError("errors.integer", identifier);
            }
        }
        else if ((dataType.equals("long")) || (dataType.equals("java.lang.Long"))) {
            try {
                Long.parseLong(data);
            }
            catch (NumberFormatException e) {
                validationMessage = new ValidatorError("errors.long", identifier);
            }
        }
        else if ((dataType.equals("float")) || (dataType.equals("java.lang.Float"))) {
            try {
                Float.parseFloat(data);
            }
            catch (NumberFormatException e) {
                validationMessage = new ValidatorError("errors.float", identifier);
            }
        }
        else if ((dataType.equals("double")) || (dataType.equals("java.lang.Double"))) {
            try {
                Double.parseDouble(data);
            }
            catch (NumberFormatException e) {
                validationMessage = new ValidatorError("errors.double", identifier);
            }
        }

        else if (dataType.equals("java.lang.Boolean")) {
            if ((data.equalsIgnoreCase("true")) ||
                (data.equalsIgnoreCase("false")) ||
                (data.equalsIgnoreCase("yes")) ||
                (data.equalsIgnoreCase("no"))) {
                validationMessage = null;
            }
            else {
                validationMessage = new ValidatorError("errors.invalid", identifier);
            }
        }

        return validationMessage;
    }

}
