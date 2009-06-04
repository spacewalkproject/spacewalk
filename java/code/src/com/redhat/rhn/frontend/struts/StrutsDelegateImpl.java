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
 * StrutsDelegateImpl
 * @version $Rev$
 */
public class StrutsDelegateImpl implements StrutsDelegate {
    
    private static final Logger  LOG = Logger.getLogger(StrutsDelegateImpl.class);
    
    protected StrutsDelegateImpl() {
    }

    /**
     * {@inheritDoc}
     */
    public ActionForward forwardParam(ActionForward base, String param, String value) {
        Map params = new HashMap();
        params.put(param, value);
        return forwardParams(base, params);
    }

    /**
     * {@inheritDoc}
     */
    public ActionForward forwardParams(ActionForward base, Map params) {
        Asserts.assertNotNull(base, "base");
        String newPath = ServletUtils.pathWithParams(base.getPath(), params);

        ActionForward af = new ActionForward(newPath, base.getRedirect());
        af.setName(base.getName());
        return af;
    }
    
    /**
     * {@inheritDoc}
     */
    // TODO Write unit tests for addError(String, ActionErrors)
    public void addError(String msgKey, ActionErrors errors) {
        addError(errors, msgKey, new Object[0]);
    }
    
    /**
     * {@inheritDoc}
     */
    // TODO Write unit tests for addError(String, ActionErrors)
    public void addError(ActionErrors errors, String msgKey, Object...params) {
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(msgKey,
                params));
        errors.add(msg);
    }    
    
    /**
     * {@inheritDoc}
     */
    public void saveMessage(String msgKey, HttpServletRequest req) {
        saveMessage(msgKey, null, req); 
    }
    
    /**
     * {@inheritDoc}
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
     * {@inheritDoc}
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
     * 
     * {@inheritDoc}
     */
    public void saveMessages(HttpServletRequest request,
            List<ValidatorError> errors, 
            List<ValidatorWarning> warnings) {
        
        bindMessage(request, Globals.ERROR_KEY, errors, new ActionErrors());
        bindMessage(request, Globals.MESSAGE_KEY, warnings, new ActionMessages());
    }

    /**
     * 
     * {@inheritDoc}
     */
    public void saveMessages(HttpServletRequest request, ValidatorResult result) {
        saveMessages(request, result.getErrors(), result.getWarnings());
    }    
    
    /**
     * {@inheritDoc}
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
     * 
     * {@inheritDoc}
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
     * {@inheritDoc}
     */
    public String getTextAreaValue(DynaActionForm form, String name) {
        String value = form.getString(name);
        return StringUtils.replaceChars(value, "\r", "");
    }
    
    /**
     * {@inheritDoc}
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
     * {@inheritDoc}
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
     * {@inheritDoc}
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
