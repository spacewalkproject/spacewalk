/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.common.validator.ValidatorWarning;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.upload.FormFile;

import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * StrutsDelegate defines a set of helper operations for working with the Struts API.
 * Implementations should conform to the same design as servlets an actions classes
 * in that they should be thread-safe and should not maintain client state.
 * 
 * @version $Rev$
 */
public interface StrutsDelegate {
    /**
     * Take an action forward and toss on a form variable.

     * @param base Base ActionForward
     * 
     * @param param Parameter to be added to the ActionForward url.
     * 
     * @param value Value of parameter to be added.
     * 
     * @return a new ActionForward with the path of the base appended with the
     * param and value.
     */
    ActionForward forwardParam(ActionForward base, String param, String value);
    
    /**
     * Take an action forward and toss on a set of form variables.
     * 
     * @param base Base ActionForward
     * 
     * @param params Parameters to be added to the ActionForward url.
     * 
     * @return a new ActionForward with the path of the base appended with the
     * param and value.
     */
    ActionForward forwardParams(ActionForward base, Map params);
    
    /**
     * Add a message to an existing set of ActionErrors. Useful to add stuff to
     * an already populated ActionErrors instance
     * @param msgKey to add
     * @param errors to add too
     */
    void addError(String msgKey, ActionErrors errors);
    
    /**
     * Add a message to an existing set of ActionErrors. Useful to add stuff to
     * an already populated ActionErrors instance
     * @param errors to add too
     * @param msgKey to add
     * @param params key params
     */
    void addError(ActionErrors errors, String msgKey,  Object... params);    
    
    /**
     * Add a UI message to the Request.
     * @param msgKey of the string you want to display
     * @param req used to store the message in.
     */
    void saveMessage(String msgKey, HttpServletRequest req);
    
    /**
     * Add a UI message to the Request.
     * @param msgKey of the string you want to display
     * @param params formatted params for the localized message
     * @param req used to store the message in.
     */
    void saveMessage(String msgKey, String[] params, HttpServletRequest req);
    
    /**
     * Add messages to the request
     * @param request Request where messages will be saved.
     * @param messages Messages to be saved.
     */
    void saveMessages(HttpServletRequest request, ActionMessages messages);
    
    /**
     * Add messages to the request
     * @param request Request where messages will be saved.
     * @param errors List of ValidatorError objects.
     * @param warnings List of ValidatorWarning objects.
     */
    void saveMessages(HttpServletRequest request, 
                          List<ValidatorError> errors,
                          List<ValidatorWarning> warnings);

    /**
     * Add messages to the request
     * @param request Request where messages will bed saved.
     * @param result the validator result object..
     */
    void saveMessages(HttpServletRequest request, 
                          ValidatorResult result);    
    /**
     * Util to get the String version of a file upload form. Not useful if the
     * upload is binary.
     * 
     * @param form to get the contents from
     * @param paramName of the FormFile
     * @return String version of the upload.
     */
    String getFormFileString(DynaActionForm form, String paramName);
    
    /**
     * Util to get the String version of a file upload form. Not useful if the
     * upload is binary.
     * @param f  the  formfile to extract data off....
     * @return String version of the upload.
     */
    String extractString(FormFile f);
    
    /**
     * Use this for every textarea that we use in our UI.  Otherwise you will get ^M 
     * in your file showing up.
     * @param form to fetch from
     * @param name of value in form
     * @return String without CR in them.  
     */
    String getTextAreaValue(DynaActionForm form, String name);
    
    /**
     * Reads the earliest date from a form populated by a datepicker.
     * Your dyna action picker must either be a struts datePickerForm, or
     * possess all of datePickerForm's fields.
     * @param form The datePickerForm
     * @param name The prefix for the date picker form fields, usually "date"
     * @param yearDirection One of DatePicker's year range static variables.
     * @return The earliest date to schedule actions.
     * @see com.redhat.rhn.common.util.DatePicker
     */
    Date readDatePicker(DynaActionForm form, String name, int yearDirection);
    
    /**
     * Writes the values of a date picker form to the <code>requestParams</code>
     * for remembering form values across requests.
     * Your dyna action picker must either be a struts datePickerForm, or
     * possess all of datePickerForm's fields.
     * @param requestParams The map to which to copy form fields
     * @param form The datePickerForm
     * @param name The prefix for the date picker form fields, usually "date"
     * @param yearDirection One of DatePicker's year range static variables.
     * @see com.redhat.rhn.common.util.DatePicker
     */
    void rememberDatePicker(Map requestParams, DynaActionForm form, String name, 
            int yearDirection);
    
    /**
     * Creates a date picker object with the given name and prepopulates the date
     * with values from the given request's parameters. Prepopulates the form with
     * these values as well.
     * Your dyna action picker must either be a struts datePickerForm, or
     * possess all of datePickerForm's fields.
     * @param request The request from which to get initial form field values.
     * @param form The datePickerForm
     * @param name The prefix for the date picker form fields, usually "date"
     * @param yearDirection One of DatePicker's year range static variables.
     * @return The created and prepopulated date picker object
     * @see com.redhat.rhn.common.util.DatePicker
     */
    DatePicker prepopulateDatePicker(HttpServletRequest request, DynaActionForm form,
            String name, int yearDirection);
}
