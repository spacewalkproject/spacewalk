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

import org.apache.commons.beanutils.PropertyUtils;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * 
 * RequiredIf constraint checks the value of an associated field in the object
 * to check to see if it is a specific value.  If it is, then the field associated
 * with this constraint is required.
 * 
 * This constraint extends LengthConstraint so it can include min/max lengths. 
 * 
 * @version $Rev$
 */
public class RequiredIfConstraint extends RequiredConstraint {

    private static Logger log = Logger.getLogger(RequiredIfConstraint.class);

    private List fieldValueList;
    
    /**
     * <p>
     *  This will create a new <code>Constraints</code> with the specified
     *    identifier as the "name".
     * </p>
     * 
     * @param identifierIn <code>String</code> identifier for <code>Constraint</code>.
     */
    public RequiredIfConstraint(String identifierIn) {
        super(identifierIn);
        fieldValueList = new LinkedList();
       
    }
    
    /** 
    * Check the constraint against the value passed in as well as check the 
    * objectToCheck's referenced field that is 'requiredIf'.  
    * @param value the value we want to check to see if its valid or not only 
    *        if the objectToCheck's referenced requiredIf field is set to the 
    *        proper value.
    * @param objectToCheck the Object we will query to find the associated field
    * @return if the field is required or not.
    */
    public boolean isRequired(Object value, Object objectToCheck) {
        
        String strValue = (String) value;
        Iterator i = fieldValueList.iterator();
        // Default to true, the 
        boolean required = true;
        while (i.hasNext()) {
            // We have requiredIf fields defined, so now 
            // we need to switch required to false unless
            // the below code changes that fact
            required = false;
            Map field = (Map) i.next();
            // The fieldValueList contains name/value pairs
            String fieldName = (String) field.keySet().toArray()[0];
            String fieldValue = (String) field.get(fieldName);
            // Get the field we want to check against
            String requiredIfValue = null;
            try {
                requiredIfValue = PropertyUtils.getProperty(
                        objectToCheck, fieldName).toString();
                /*
                 * Check for requiredIf tag without a value. This is the
                 * equivalent of saying that this field is required if this
                 * other field is not null.
                 */
                // required tag doesn't contain a value
                if ((fieldValue == null || fieldValue.length() == 0) &&
                        // this field doesn't have anything
                        (strValue == null || strValue.length() == 0) &&
                            // but something is in the required field
                            (requiredIfValue != null && requiredIfValue.length() > 0)) {
                    required = true; // set this required = true
                }
                else if (requiredIfValue.equals(fieldValue)) {
                    log.debug("RequiredIf actual Value: " + requiredIfValue);
                    log.debug("Requiredvalue: " + fieldValue);
                    log.debug("Actual fieldvalue: " + value);
                    required = true;
                }
                // If any of the fields match, we return true immediately
                if (required) {
                    return required;
                }
            } 
            catch (Exception e) {
                String errorMessage = "Exception trying to get bean property: " + 
                                        e.toString();
                log.error(errorMessage, e);
                throw new ValidatorException(errorMessage, e);
            }
        }
       return required;
    }
    
    /** 
    * Set the name of the field to check against to see if *this* field
    * is required.  So if the constraint is a "requiredIf field FOO == 'BAR'" then we
    * want to call addField("FOO", "BAR");
    *
    * @param fieldNameIn the name of the field
    * @param fieldValueIn the value of the field
    */
    public void addField(String fieldNameIn, String fieldValueIn) {
        Map fieldAndValue = new HashMap();
        fieldAndValue.put(fieldNameIn, fieldValueIn);
        fieldValueList.add(fieldAndValue);
    }
    
    
}
