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

import com.redhat.rhn.common.util.Asserts;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.util.ServletUtils;
import com.redhat.rhn.common.validator.ValidationMessage;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.common.validator.ValidatorWarning;
import com.redhat.rhn.frontend.context.Context;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.Globals;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.upload.FormFile;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * StrutsDelegate defines a set of helper operations for working with the Struts API.
 * Implementations should conform to the same design as servlets an actions classes
 * in that they should be thread-safe and should not maintain client state.
 *
 * @version $Rev$
 */
public class StrutsDelegate {

    private static final Logger  LOG = Logger.getLogger(StrutsDelegate.class);
    private static final StrutsDelegate INSTANCE = new StrutsDelegate();

    /**
     * Retuns an instance of the struts delegate factory
     * @return an instance
     */
    public static StrutsDelegate getInstance() {
        return INSTANCE;
    }

    protected StrutsDelegate() {
    }

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
    public ActionForward forwardParam(ActionForward base, String param, String value) {
        Map params = new HashMap();
        params.put(param, value);
        return forwardParams(base, params);
    }

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
    public ActionForward forwardParams(ActionForward base, Map params) {
        Asserts.assertNotNull(base, "base");
        String newPath = ServletUtils.pathWithParams(base.getPath(), params);

        ActionForward af = new ActionForward(newPath, base.getRedirect());
        af.setName(base.getName());
        return af;
    }

    /**
     * Add a message to an existing set of ActionErrors. Useful to add stuff to
     * an already populated ActionErrors instance
     * @param msgKey to add
     * @param errors to add too
     */
    // TODO Write unit tests for addError(String, ActionErrors)
    public void addError(String msgKey, ActionErrors errors) {
        addError(errors, msgKey, new Object[0]);
    }

    /**
     * Add a message to an existing set of ActionErrors. Useful to add stuff to
     * an already populated ActionErrors instance
     * @param errors to add too
     * @param msgKey to add
     * @param params key params
     */
    // TODO Write unit tests for addError(String, ActionErrors)
    public void addError(ActionErrors errors, String msgKey, Object...params) {
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(msgKey,
                params));
        errors.add(msg);
    }

    /**
     * Add a UI message to the Request.
     * @param msgKey of the string you want to display
     * @param req used to store the message in.
     */
    public void saveMessage(String msgKey, HttpServletRequest req) {
        saveMessage(msgKey, null, req);
    }

    /**
     * Add a UI message to the Request.
     * @param msgKey of the string you want to display
     * @param params formatted params for the localized message
     * @param req used to store the message in.
     */
    // TODO Write unit tests for saveMessage(String, String[], HttpServletRequest)
    public void saveMessage(String msgKey, String[] params, HttpServletRequest req) {
        if (params == null) {
            params = new String[0];
        }
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(msgKey, params));
        saveMessages(req, msg);
    }

    /**
     * Add messages to the request
     * @param request Request where messages will be saved.
     * @param messages Messages to be saved.
     */
    // TODO Write unit tests for saveMessages(HttpServletRequest, ActionMessages)
    public void saveMessages(HttpServletRequest request, ActionMessages messages) {
        HttpSession session = request.getSession();

        if ((messages == null) || messages.isEmpty()) {
            session.removeAttribute(Globals.ERROR_KEY);
            session.removeAttribute(Globals.MESSAGE_KEY);
            return;
        }
        String key = Globals.MESSAGE_KEY;
        if (messages instanceof ActionErrors) {
            key = Globals.ERROR_KEY;
        }

        ActionMessages newMessages = new ActionMessages();

        // Check for existing messages
        ActionMessages sessionExisting =
            (ActionMessages) session.getAttribute(key);

        if (sessionExisting != null) {
            newMessages.add(sessionExisting);
        }
        newMessages.add(messages);

        session.setAttribute(key, newMessages);
        request.setAttribute(key, newMessages);
    }

    /**
     * Add messages to the request
     * @param request Request where messages will be saved.
     * @param errors List of ValidatorError objects.
     * @param warnings List of ValidatorWarning objects.
     */
    public void saveMessages(HttpServletRequest request,
            List<ValidatorError> errors,
            List<ValidatorWarning> warnings) {

        bindMessage(request, Globals.ERROR_KEY, errors, new ActionErrors());
        bindMessage(request, Globals.MESSAGE_KEY, warnings, new ActionMessages());
    }

    /**
     * Add messages to the request
     * @param request Request where messages will bed saved.
     * @param result the validator result object..
     */
    public void saveMessages(HttpServletRequest request, ValidatorResult result) {
        saveMessages(request, result.getErrors(), result.getWarnings());
    }

    /**
     * Util to get the String version of a file upload form. Not useful if the
     * upload is binary.
     *
     * @param form to get the contents from
     * @param paramName of the FormFile
     * @return String version of the upload.
     */
    // TODO Write unit tests for getFormFileString(DynaActionForm, String)
    public String getFormFileString(DynaActionForm form, String paramName) {
        if (form.getDynaClass().getDynaProperty(paramName) == null) {
            return "";
        }

        FormFile f = (FormFile)form.get(paramName);
        return extractString(f);
    }


    /**
     * Util to get the String version of a file upload form. Not useful if the
     * upload is binary.
     * @param f  the  formfile to extract data off....
     * @return String version of the upload.
     */
    public  String extractString(FormFile f) {
        String retval = null;
        try {
            if (f != null && f.getFileData() != null) {
                String fileString = new String(f.getFileData(), "UTF-8");
                if (!StringUtils.isEmpty(fileString)) {
                    retval = fileString;
                }
            }
        }
        catch (UnsupportedEncodingException e) {
            LOG.error(e);
            throw new RuntimeException(e);
        }
        catch (FileNotFoundException e) {
            LOG.error(e);
            throw new RuntimeException(e);
        }
        catch (IOException e) {
            LOG.error(e);
            throw new RuntimeException(e);
        }
        return retval;
    }

    /**
     * Use this for every textarea that we use in our UI.  Otherwise you will get ^M
     * in your file showing up.
     * @param form to fetch from
     * @param name of value in form
     * @return String without CR in them.
     */
    public String getTextAreaValue(DynaActionForm form, String name) {
        String value = form.getString(name);
        return StringUtils.replaceChars(value, "\r", "");
    }

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
    public Date readDatePicker(DynaActionForm form, String name, int yearDirection) {
        //use date is not required for date picker forms.
        //if it is not there, then that means we should always evaluate the
        //date picker.  Otherwise, we evaluate if it tells us to do so.
        if (!form.getMap().containsKey(DatePicker.USE_DATE) ||
                form.get(DatePicker.USE_DATE) == null ||
                ((Boolean)form.get(DatePicker.USE_DATE)).booleanValue()) {
            DatePicker p = getDatePicker(name, yearDirection);
            p.readForm(form);
            return p.getDate();
        }
        else {
            return new Date();
        }
    }

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
    public void rememberDatePicker(Map requestParams,
            DynaActionForm form, String name, int yearDirection) {
        //Write the option use_date field if it is there.
        if (form.get(DatePicker.USE_DATE) != null) {
            requestParams.put(DatePicker.USE_DATE,
                    form.get(DatePicker.USE_DATE));
        }

        //The datepicker itself can write the rest.
        DatePicker p = getDatePicker(name, yearDirection);
        p.readForm(form);
        p.writeToMap(requestParams);
    }

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
    public DatePicker prepopulateDatePicker(HttpServletRequest request, DynaActionForm form,
            String name, int yearDirection) {
        //Create the date picker.
        DatePicker p = getDatePicker(name, yearDirection);

        //prepopulate the date for this picker
        p.readMap(request.getParameterMap());

        //prepopulate the form for this picker
        p.writeToForm(form);
        if (!StringUtils.isEmpty(request.getParameter(DatePicker.USE_DATE))) {
            Boolean preset = Boolean.valueOf(request.getParameter(DatePicker.USE_DATE));
            form.set(DatePicker.USE_DATE, preset);
        }
        else if (form.getMap().containsKey(DatePicker.USE_DATE)) {
            form.set(DatePicker.USE_DATE, Boolean.FALSE);
        }
        request.setAttribute(name, p);
        //give back the date picker
        return p;
    }

    private DatePicker getDatePicker(String name, int yearDirection) {
        Context ctx = Context.getCurrentContext();
        if (ctx == null) {
            return new DatePicker(name, TimeZone.getDefault(), Locale.getDefault(),
                    yearDirection);
        }
        else {
            return new DatePicker(name, ctx.getTimezone(), ctx.getLocale(), yearDirection);
        }
    }


    private  void bindMessage(HttpServletRequest request, String key,
                        List<? extends ValidationMessage> messages,
                        ActionMessages actMsgs) {
        if (!messages.isEmpty()) {
            for (ValidationMessage msg : messages) {
                actMsgs.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage(msg.getKey(), msg.getValues()));
            }

            ActionMessages requestMsg = (ActionMessages)request.
                                                getAttribute(key);
            if (requestMsg == null) {
                requestMsg = new ActionMessages();
            }
            requestMsg.add(actMsgs);
            if (requestMsg.isEmpty()) {
                request.removeAttribute(key);
            }
            else {
                request.setAttribute(key, requestMsg);
            }
        }

    }
}
