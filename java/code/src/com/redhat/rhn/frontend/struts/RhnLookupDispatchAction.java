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

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.actions.LookupDispatchAction;
import org.apache.struts.util.LabelValueBean;

import java.util.Iterator;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RhnLookupDispatchAction
 * This is our own implementation of LookupDispatchAction
 * @version $Rev$
 */
public abstract class RhnLookupDispatchAction extends LookupDispatchAction {
    
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
     * {@inheritDoc}
     */
    protected String getMethodName(ActionMapping mapping,
                                   ActionForm form,
                                   HttpServletRequest request,
                                   HttpServletResponse response,
                                   String parameter) throws Exception {
        /*
         * Reasoning behind this:
         * For form elements of the form <input type="image" name="foo" value="bar" />, 
         * Internet Explorer submits foo.x and foo.y with the respective x and y coords of
         * the image, but no foo=bar. This is stupid since who the hell cares about the 
         * x and y coordinates of an image, but it is according to spec. 
         * Since we rely on the dispatch parameter to be set, we need to fudge this a bit 
         * here and translate methodname.dispatch.x to just methodname.
         */

        // The method name of the method we want to execute.
        String methodName = null;
        // Use the parameter here so incase we ever want to use something other than
        // "dispatch" in struts-config.xml this code will still work.
        String keyName = request.getParameter(parameter);

        if (StringUtils.isEmpty(keyName)) {

            // Set alternateParameter to something like "dispatch.x" 
            String alternateParameter = parameter + ".x";
            Set keyset = request.getParameterMap().keySet();
            /*
             * We need to loop throug the request parameters and look for a key in the form
             * of <method-to-execute>.alternateParameter 
             * ex: selectall.dispatch.x
             */
            for (Iterator itr = keyset.iterator(); itr.hasNext();) {
                String key = (String) itr.next();
                // Look for the alternateParameter portion in the key
                if (key.indexOf(alternateParameter) > 0) {
                    // if we find alternateParameter in the key, set the method name
                    methodName = key.substring(0, key.indexOf(alternateParameter) - 1);
                }
            }

            return methodName;
        }
        
        // user was not using internet explorer and the parameter was found.
        methodName = getLookupMapName(request, keyName, mapping);
        return methodName;
    }

    /** 
     * Simple util to check if the Form was submitted
     * @param form to check
     * @return if or not it was submitted.
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
        else {
            return false;
        }
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
     * Take a key and return a localized (l10n) String
     * @param key to lookup
     * @return String that is localized
     */
    protected String l10n(String key) {
        return LocalizationService.getInstance().getMessage(key);
    }
}
