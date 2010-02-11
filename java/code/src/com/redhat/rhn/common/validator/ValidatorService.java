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

import com.redhat.rhn.common.util.StringUtil;

import org.apache.log4j.Logger;

import java.util.Iterator;
import java.util.List;

/**
 * <p>
 *  The <code>ValidatorService</code> class provides ability 
 *  to take an object and the Validator associated with it and 
 *  validate all the fields in the object and return the list 
 *  of errors in the Object's state
 * </p>
 * @version $Rev$
 */
public class ValidatorService {

    private static Logger log = Logger.getLogger(ValidatorService.class);

    /** Singleton instance */
    private static ValidatorService instance = null;


    /**
     * <p>
     *  This (intentionally left) private constructor handles initialization.
     * </p> 
     */
    private ValidatorService() {
        log.info("Initalizing " + this.getClass().getName());
    } 

    /**
     * <p>
     *  This will retrieve the singleton instance of this class, allowing
     *    it to be used across applications.
     * </p>
     *
     * @return <code>ValidatorService</code> - the singleton instance to use.
     */
    public static ValidatorService getInstance() {
        
        if (instance == null) {
            synchronized (ValidatorService.class) {
                instance = new ValidatorService();
            }
        }
        return instance;
    }
    
    /**
     * Take an validatable object and check if its fields are in a valid
     * state or not
     * If in the future we want to remove the dependancy on Struts we 
     * need to write a class that duplicates ValidatorError.  I felt it wasn't
     * worth it at the time to copy the class directly to do exactly what 
     * it did.
     *
     * @param validateIn A validatable object to be checked
     * @param validatorIn The Validator instance to use with this object.
     * @return ValidatorError the error array
     */    
    public ValidatorResult validateObject(Object validateIn, Validator validatorIn) {
        return validateObject(validateIn, validatorIn, null);
    }


    /**
     * Take an validatable object and check if its fields are in a valid
     * state or not
     * If in the future we want to remove the dependancy on Struts we 
     * need to write a class that duplicates ValidatorError.  I felt it wasn't
     * worth it at the time to copy the class directly to do exactly what 
     * it did.
     *
     * @param validateIn A validatable object to be checked
     * @param validatorIn The Validator instance to use with this object.
     * @param constraintNames List of constraints to validate
     * @return ValidatorResult
     */
    public ValidatorResult validateObject(Object validateIn, Validator validatorIn,
            List constraintNames) {
        
        ValidatorResult result = new ValidatorResult();
        Iterator i = validatorIn.getConstraints().iterator();
        while (i.hasNext()) {
            Constraint c = (Constraint) i.next();
            if (constraintNames != null) {
                if (!constraintNames.contains(c.getIdentifier())) {
                    continue;
                }
            }
            ValidatorError error = validatorIn.isValid(c.getIdentifier(), validateIn);
            if (error != null) {
                result.addError(error);
            }
        }
        return result;
    }

    /**
     * Take an validatable object and check if its fields are in a valid
     * state or not.  This method expects the XSD associated with the 
     * validateable object to be in the same directory as the object itself.
     * 
     * @param validateIn A validatable object to be checked
     * @return ValidatorError the error result.
     */
    public ValidatorResult validateObject(Object validateIn) {
        log.debug("ValidatorService.validateObject called on object: " + 
                    validateIn.toString());
        
        Validator validator;
        try {
            StringBuffer xsdName = new StringBuffer();
            xsdName.append(StringUtil.getClassNameNoPackage(validateIn.getClass()));
            xsdName.append(".xsd");
            validator = Validator.getInstance(validateIn.getClass().
                        getResource(xsdName.toString()));
            
        } 
        catch (java.io.IOException ioe) { 
            throw new ValidatorException("Failed to instantiate Validator.  " +
                    "Check to make sure " +
                    "the XSD file is in the same directory as the Validateable Object");
        }
        return validateObject(validateIn, validator, null);
    }
    
    
}

