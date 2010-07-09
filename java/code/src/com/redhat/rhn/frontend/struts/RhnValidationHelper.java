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

package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.common.validator.Validator;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.common.validator.ValidatorService;
import com.redhat.rhn.common.validator.ValidatorWarning;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.net.URL;
import java.util.List;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.servlet.http.HttpServletRequest;

/**
 * RhnValidationHelper contains helpful to be used by Struts actions to interact
 * with the ValidationService
 *
 * @version $Rev$
 */
public class RhnValidationHelper {

    private static final String FAILED_KEY = "rhn_validation_failed";

    /** utility class */
    private RhnValidationHelper() {
    }

    /**
     * Converts an array of Strings into a set of ActionError messages
     *
     * @param errors Array of ValidatorErrors you want to convert
     * @return ActionErrors object with set of messages
     */
    public static ActionErrors validatorErrorToActionErrors(
            ValidatorError... errors) {
        ActionErrors messages = new ActionErrors();

        for (int i = 0; i < errors.length; i++) {
            messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    errors[i].getKey(), errors[i].getValues()));
        }
        return messages;
    }

    /**
     * Converts an array of ValidatorWarnings into a set of ActionMessages.
     *
     * @param warnings Array of ValidatorWarnings you want to convert
     * @return ActionMessages object with set of messages
     */
    public static ActionMessages validatorWarningToActionMessages(
            ValidatorWarning... warnings) {
        ActionMessages messages = new ActionMessages();

        for (int i = 0; i < warnings.length; i++) {
            messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    warnings[i].getKey(), warnings[i].getValues()));
        }
        return messages;
    }

    /**
     * Validate a DynaActionForm from an Action and get back the set of
     * ActionErrors This method expects there to be an XSD file to use to
     * validate the Form with located in the same package as the Action under a
     * subdir named: validation/
     *
     * For example, com.redhat.rhn.frontend.action.LoginAction has an associated
     * loginForm in Struts, so you would need a:
     *
     * com/redhat/rhn/frontend/action/validation/loginForm.xsd
     *
     * @param action The action associated with the form
     * @param form The form to validate
     * @return ActionErrors if there were validation errors, otherwise its null
     */
    public static ActionErrors validateDynaActionForm(Action action,
            DynaActionForm form) {
        return validateDynaActionForm(action.getClass(), form, null);
    }

    /**
     * Validate a DynaActionForm from an Action and get back the set of
     * ActionErrors This method expects there to be an XSD file to use to
     * validate the Form with located in the same package as the Action under a
     * subdir named: validation/
     *
     * For example, com.redhat.rhn.frontend.action.LoginAction has an associated
     * loginForm in Struts, so you would need a:
     *
     * com/redhat/rhn.frontend/action/validation/loginForm.xsd
     *
     * @param action The action associated with the form
     * @param form The form to validate
     * @param fieldNames List of form field names to validate
     * @return ActionErrors if there were validation errors, otherwise its null
     */
    public static ActionErrors validateDynaActionForm(Action action,
            DynaActionForm form, List fieldNames) {
        return validateDynaActionForm(action.getClass(), form, fieldNames);
    }

    /**
     * Validate a DynaActionForm from an class and get back the set of
     * ActionErrors This method expects there to be an XSD file to use to
     * validate the Form with located in the same package as the class under a
     * subdir named: validation/
     *
     * For example, com.redhat.rhn.frontend.action.LoginAction has an associated
     * loginForm in Struts, so you would need a:
     *
     * com/redhat/rhn/frontend/action/validation/loginForm.xsd
     *
     * @param base the base from which to lookup the validator
     * @param form The form to validate
     * @return ActionErrors if there were validation errors, otherwise its null
     */
    public static ActionErrors validateDynaActionForm(Class base,
            DynaActionForm form) {
        return validateDynaActionForm(base, form, null);
    }

    /**
     * Validate a DynaActionForm from an class and get back the set of
     * ActionErrors This method expects there to be an XSD file to use to
     * validate the Form with located in the same package as the class under a
     * subdir named: validation/
     *
     * For example, com.redhat.rhn.frontend.action.LoginAction has an associated
     * loginForm in Struts, so you would need a:
     *
     * com/redhat/rhn/frontend/action/validation/loginForm.xsd
     *
     * Sometimes, you want to use a given form and validation for a variety of
     * actions, which may not all belong in the same package hierarchy. This
     * code checks for a "validatorPath" attribute, and if it finds it, looks
     * for the validator .xsd at that path, rather than using the 'dead
     * reckoning"approach described above.
     *
     * @param base the base from which to lookup the validator
     * @param form The form to validate
     * @param fieldNames List of field names to validate
     * @return ActionErrors if there were validation errors, otherwise its null
     */
    public static ActionErrors validateDynaActionForm(Class base,
            DynaActionForm form, List fieldNames) {
        return validateDynaActionForm(base, form, fieldNames, null);
    }

    /**
     * Validate a DynaActionForm from an class and get back the set of
     * ActionErrors This method expects there to be an XSD file to use to
     * validate the Form with located in the same package as the class under a
     * subdir named: validation/
     *
     * For example, com.redhat.rhn.frontend.action.LoginAction has an associated
     * loginForm in Struts, so you would need a:
     *
     * com/redhat/rhn/frontend/action/validation/loginForm.xsd
     *
     * Sometimes, you want to use a given form and validation for a variety of
     * actions, which may not all belong in the same package hierarchy. This
     * code will use the XSD pointed at by the slash-delimited xsdName, if one
     * is provided (eg, "") rather than using the 'dead reckoning"approach
     * described above.
     *
     * @param base the base from which to lookup the validator
     * @param form The form to validate
     * @param fieldNames List of field names to validate
     * @param xsdName the fully-qualified pathname to the XSD that we want to
     * validate against, or "null" if we want to use the dead-reckoning approach
     * @return ActionErrors if there were validation errors, otherwise its null
     */
    public static ActionErrors validateDynaActionForm(Class base,
            DynaActionForm form, List fieldNames, String xsdName) {

        String formName = form.getDynaClass().getName();

        if (xsdName == null) {
            xsdName = "validation/" + formName + ".xsd";
        }

        ValidatorResult result = validate(base, form, fieldNames, xsdName);

        if (!result.isEmpty()) {
            return validatorErrorToActionErrors((ValidatorError[])
                                            result.getErrors().toArray(new
                                            ValidatorError[0]));
        }
        return new ActionErrors();
    }

    /**
     * Validate a DynaActionForm from an class and get back the set of
     * ActionErrors This method expects there to be an XSD file to use to
     * validate the Form with located in the same package as the class under a
     * subdir named: validation/
     *
     * For example, com.redhat.rhn.frontend.action.LoginAction has an associated
     * loginForm in Struts, so you would need a:
     *
     * com/redhat/rhn/frontend/action/validation/loginForm.xsd
     *
     * Sometimes, you want to use a given form and validation for a variety of
     * actions, which may not all belong in the same package hierarchy. This
     * code will use the XSD pointed at by the slash-delimited xsdName, if one
     * is provided (eg, "") rather than using the 'dead reckoning"approach
     * described above.
     *
     * @param base the base from which to lookup the validator
     * @param toValidate The form to validate
     * @param fieldNames List of field names to validate
     * @param xsdName the fully-qualified pathname to the XSD that we want to
     * validate against.
     * @return ValidatorResult , look at the result to determine errors..
     */
    public static ValidatorResult validate(Class base, Object toValidate,
            List fieldNames, String xsdName) {
        Validator validator;

        try {

            URL xsd = base.getResource(xsdName);
            if (xsd == null) {
                throw new IllegalArgumentException(
                        "Could not find validator for " + xsdName + " and " +
                                base.getName());
            }
            validator = Validator.getInstance(xsd);

        }
        catch (java.io.IOException ioe) {
            throw new ValidatorException("Failed to instantiate Validator");
        }

        return ValidatorService.getInstance().validateObject(toValidate,
                validator, fieldNames);
    }

    /**
     * Validate a DynaActionForm from an class and get back the set of
     * ActionErrors This method expects there to be an XSD file to use to
     * validate the Form with located in the same package as the class under a
     * subdir named: validation/
     *
     * For example, com.redhat.rhn.frontend.action.LoginAction has an associated
     * loginForm in Struts, so you would need a:
     *
     * com/redhat/rhn/frontend/action/validation/loginForm.xsd
     *
     * Sometimes, you want to use a given form and validation for a variety of
     * actions, which may not all belong in the same package hierarchy. This
     * code will use the XSD pointed at by the slash-delimited xsdName, if one
     * is provided (eg, "") rather than using the 'dead reckoning"approach
     * described above.
     *
     * @param toValidate The form to validate
     * @param xsdPath the fully-qualified pathname to the XSD that we want to
     * validate against.
     * @return ValidatorResult , look at the result to determine errors..
     */
    public static ValidatorResult validate(Object toValidate, String xsdPath) {
        return validate(RhnValidationHelper.class, toValidate, null, xsdPath);
    }

    /**
     * Place a flag in the request to indicate that the form failed its
     * validation This can be used by SetupActions to determine if they should
     * fill out the form with default values or not.
     * @param request Set the attribute on this request
     */
    public static void setFailedValidation(HttpServletRequest request) {
        request.setAttribute(FAILED_KEY, "true");
    }

    /**
     * Check the request to see if an Action indicated that a form failed its
     * validation process.
     * @param request to check to see if validation failed
     * @return boolean if the validation failed or not
     */
    public static boolean getFailedValidation(HttpServletRequest request) {
        String failed = (String) request.getAttribute(FAILED_KEY);
        return (failed != null && failed.equals("true"));
    }

    /**
     * Return <code>true</code> if <code>email</code> is a valid email
     * address
     * @param email the email to validate
     * @return <code>true</code> if <code>email</code> is a valid email
     * address
     * @see InternetAddress#validate
     */
    public static boolean isValidEmailAddress(String email) {
        try {
            new InternetAddress(email).validate();
            return true;
        }
        catch (AddressException e) {
            return false;
        }
    }

    /**
     * Converts an single instance of a ValidatorError to an ActionErrors class
     * for use in Struts.
     *
     * @param ve Single instance of a ValidatorError
     * @return ActionErrors object with set of messages
     *
    public static ActionErrors validatorErrorToActionErrors(ValidatorError ve) {
        ValidatorError[] varray = new ValidatorError[1];
        varray[0] = ve;
        return validatorErrorToActionErrors(varray);
    }*/
}
