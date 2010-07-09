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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.MethodUtil;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * RhnAction base class for all RHN Struts Actions.
 * Used to override Struts functionality as well as
 * add common features to the RHN Struts Actions.
 *
 * <br/><br/>
 *
 * <strong>NOTE:</strong> RhnSetAction and RhnAction contain two duplicate methods -
 * <code>getStrutsDelegate()</code> and <code>createSuccessMessage()</code>. If another
 * method is added to these classes that is common to both we need to refactor the common
 * methods into a new class maybe called <code>RhnActionDelegate</code>.
 *
 * <br/><br/>
 *
 * We cannot introduce a common base class because RhnSetAction and RhnAction fall into
 * different inheritance hierarchies.
 *
 * @version $Rev$
 * @see com.redhat.rhn.frontend.action.common.RhnSetAction
 */

public abstract class RhnAction extends Action {

    public static final String SUBMITTED = "submitted";
    /**
     * Returns a StrutsDelegate object.
     *
     * @return A StrutsDelegate object.
     * @see StrutsDelegate
     * @see StrutsDelegateFactory
     */
    protected StrutsDelegate getStrutsDelegate() {
        return StrutsDelegate.getInstance();
    }

    /**
     * Util method to use some reflection to invoke a method on a Iterator's
     * items to produce a List of LabelValue beans
     * @param i Iterator that contains the items you want to convert into label value bean
     * @param nameMethod to call on each object, something like 'Channel.getName()'.  Must
     * return a String or will throw ClassCastException
     * @param valueMethod
     * @return List of LabelValue beans
     */
    protected List createLabelValueList(Iterator i, String nameMethod, String valueMethod) {
        List retval = new LinkedList();
        while (i.hasNext()) {
            Object o = i.next();
            String name = (String) MethodUtil.callMethod(o, nameMethod, new Object[0]);
            Object value = MethodUtil.callMethod(o, valueMethod, new Object[0]);
            LabelValueBean lb = lv(name, value.toString());
            if (!retval.contains(lb)) {
                retval.add(lb);
            }
        }
        return retval;
    }


    /**
     * Construct a LabelValueBean with specified label and value
     * @param label to use
     * @param value value of selection
     * @return LabelValueBean instance
     */
    protected static LabelValueBean lv(String label, String value) {
        return new LabelValueBean(label, value);
    }

    /**
     * Construct a LabelValueBean instance where the label is localized
     * using the LocalizationService.getMessage() method.
     * @param label to localize
     * @param value value of selection
     * @return LabelValueBean instance
     */
    protected static LabelValueBean lvl10n(String label, String value) {
        return new LabelValueBean(
                LocalizationService.getInstance().
                    getMessage(label), value);
    }

    /**
     * Construct a LabelValueEnabledBean instance where the label is localized
     * using the LocalizationService.getMessage() method.
     * @param label to localize
     * @param value value of selection
     * @param disabled true if the bean renderer
     *              should render as disabled, false otherwise
     * @return LabelValueBean instance
     */
    protected static LabelValueEnabledBean lve(String label, String value,
                                                        boolean disabled) {
        return new LabelValueEnabledBean(label, value, disabled);
    }


    /**
     * Construct a LabelValueEnabledBean instance where the label is localized
     * using the LocalizationService.getMessage() method.
     * @param label to localize
     * @param value value of selection
     * @param disabled true if the bean renderer
     *              should render as disabled, false otherwise
     * @return LabelValueBean instance
     */
    protected static LabelValueEnabledBean lvel10n(String label, String value,
                                                        boolean disabled) {
        return new LabelValueEnabledBean(
                LocalizationService.getInstance().
                    getMessage(label), value, disabled);
    }

    /** {@inheritDoc} */
    public void saveMessages(HttpServletRequest request, ActionMessages messages) {
        getStrutsDelegate().saveMessages(request, messages);
     }


    /**
     * Add a success message to the request with 1 parameter:
     *
     * Your System55 has been updated
     *
     * where System55 is the value placed in param1.  param1
     *
     * @param req to add the message to
     * @param msgKey resource key to lookup
     * @param param1 String value to fill in for the first parameter.
     *               (param1 is HTML escaped as well)
     */
    protected void createSuccessMessage(HttpServletRequest req, String msgKey,
            String param1) {

        ActionMessages msg = new ActionMessages();
        Object[] args = new Object[1];
        args[0] = StringEscapeUtils.escapeHtml(param1);
        msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(msgKey, args));
        saveMessages(req, msg);
    }

    /**
     * Add a success message to the request with any parameters.
     *
     * @param req to add the message to
     * @param msgKey resource key to lookup
     * @param params String values to fill in
     */
    protected void createMessage(HttpServletRequest req, String msgKey,
            String[] params) {

        ActionMessages msg = new ActionMessages();
        for (int i = 0; i < params.length; i++) {
            params[i] = StringEscapeUtils.escapeHtml(params[i]);
        }
        msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(msgKey, params));
        saveMessages(req, msg);
    }


    /**
     * Add a success message to the request.
     *
     * @param req to add the message to
     * @param msgKey resource key to lookup
     */
    protected void addMessage(HttpServletRequest req, String msgKey) {
        createSuccessMessage(req, msgKey, (String) null);
    }

    /**
     * Add an error message to the request with 1 parameter:
     *
     * Your System55 has NOT been updated
     *
     * where System55 is the value placed in param.
     *
     * @param req to add the message to
     * @param beanKey resource key to lookup
     * @param param String value to fill in for the first parameter.
     *               (param is HTML escaped as well)
     */
    protected void createErrorMessage(HttpServletRequest req, String beanKey,
            String param) {
        ActionErrors errs = new ActionErrors();
        String escParam = StringEscapeUtils.escapeHtml(param);
        errs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(beanKey, escParam));
        saveMessages(req, errs);
    }

    /**
     * Add a message to the set of ActionMessages. Takes the key, constructs
     * a new ActionMessage object and adds it to the ActionMessages collection
     * passed in.
     *
     * @param messages set of ActionMessages we want to add an additional
     * ActionMessage to.
     * @param key to the resource bundle that we want to fetch
     * the message from.
     */
    protected void addGlobalMessage(ActionMessages messages, String key) {
        messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key));
    }

    /**
     * Add a message to the set of ActionMessages. Takes the key, constructs
     * a new ActionMessage object and adds it to the ActionMessages collection
     * passed in.
     *
     * @param messages set of ActionMessages we want to add an additional
     * ActionMessage to.
     * @param key to the resource bundle that we want to fetch
     * the message from.
     * @param param0 the first parameter to be substituted into the message
     */
    protected void addGlobalMessage(ActionMessages messages, String key, String param0) {
        messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key, param0));
    }

    /**
     * Simple util to check if the Form was submitted
     * @param form to check
     * @return True if the form was submitted, false otherwise.
     */
    protected boolean isSubmitted(DynaActionForm form) {
        if (form != null) {
            try {
                return BooleanUtils.toBoolean((Boolean)form.get(SUBMITTED));
            }
            catch (IllegalArgumentException iae) {
                throw new IllegalArgumentException("Your form-bean failed to define '" +
                        SUBMITTED + "'");
            }
        }
        return false;
    }

    protected void localize(Collection lvList) {
        for (Iterator i = lvList.iterator(); i.hasNext();) {
            LabelValueBean lv = (LabelValueBean) i.next();
            lv.setLabel(LocalizationService.getInstance().getMessage(lv.getLabel()));
        }
    }

    /**
     * Default param map for our actions. At the minimum, we want to preserve any pagination
     * variables that are in the request.
     * @param request The request containing the params we want
     * @return Returns a map containing the pagination params.
     */
    protected Map makeParamMap(HttpServletRequest request) {
        return new RequestContext(request).makeParamMapWithPagination();
    }

    /**
     * Take a key and return a localized (l10n) String
     * @param key to lookup
     * @return String that is localized
     */
    protected String l10n(String key) {
        return LocalizationService.getInstance().getMessage(key);
    }
}
