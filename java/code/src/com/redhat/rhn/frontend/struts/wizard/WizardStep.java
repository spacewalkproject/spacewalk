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
package com.redhat.rhn.frontend.struts.wizard;


import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.lang.reflect.Method;

import javax.servlet.http.HttpServletResponse;

/**
 * Represents a single step in a multi-step wizard
 *
 * @version $Rev $
 */
public class WizardStep {

    private String previous;

    private String next;

    private Method wizardMethod;

    /**
     * Name of the previous step
     * @param prev previous step name
     */
    public void setPrevious(String prev) {
        this.previous = prev;
    }

    /**
     * Name of the previous step
     * @return previous step name if set, otherwise null
     */
    public String getPrevious() {
        return this.previous;
    }

    /**
     * Name of the next step
     * @param nextStep next step name
     */
    public void setNext(String nextStep) {
        this.next = nextStep;
    }

    /**
     * Name of the next step
     * @return next step name if set, otherwise null
     */
    public String getNext() {
        return this.next;
    }

    /**
     * Method to invoke for this step
     * The method must have the following signature
     * <code>
     * ActionForward runFirst(ActionMapping mapping, DynaActionForm form,
     *      RequestContext ctx, HttpServletResponse response,
     *      WizardStep step) throws Exception
     * </code>
     * @param method method to invoke for this step
     */
    public void setWizardMethod(Method method) {
        method.setAccessible(true);
        this.wizardMethod = method;
    }

    /**
     * Method to invoke for this step
     * @return the Java method if set, otherwise null
     */
    public Method getWizardMethod() {
        return this.wizardMethod;
    }

    /**
     * Invoke the corresponding Java method for this step
     * @param mapping from current request
     * @param form from current request
     * @param ctx from current request
     * @param response from current request
     * @param target enclosing Struts action
     * @return Struts forward corresponding to this wizard step
     * @throws Exception something bad happened hopefully handled upstream
     */
    public final ActionForward invoke(ActionMapping mapping, ActionForm form,
            RequestContext ctx, HttpServletResponse response,
            Action target) throws Exception {
        Object[] args = new Object[5];
        args[0] = mapping;
        args[1] = form;
        args[2] = ctx;
        args[3] = response;
        args[4] = this;
        return (ActionForward) this.wizardMethod.invoke(target, args);
    }
}
