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
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Base class designed to make writing wizard-type interfaces easier.
 *
 * The responsibilities of a class extending this one are:
 *
 * <ul>
 *
 * <li>Implement the <code>generateWizardSteps</code> method. This method should create
 * instances of <code>WizardStep</code> objects and place them in the provided map under
 * a key which corresponds to the step name. The first, or starting, wizard step should
 * be associated with two keys: the desired step name and the constant
 * <code>RhnWizardAction.STEP_START</code>. The constant is used as a fallback when no
 * step name is provided by the UI.</li>
 *
 * <li>Implement a <code>DynaActionForm</code> which contains a field named "wizardStep".
 * This form field must contain the name of the submitted form action. This can be tricky
 * since the field should normally point to the <em>next</em> step not the current
 * step.</li>
 *
 * </ul>
 *
 * @version $Rev $
 */
public abstract class RhnWizardAction extends RhnAction {

    /**
     * Logger for this class
     */
    private static Logger log = Logger.getLogger(RhnWizardAction.class);

    public static final String STEP_START = "start";
    public static final String STEP_PARAM = "wizardStep";

    private Map steps = new HashMap();


    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        synchronized (this) {
            if (this.steps.size() == 0) {
                generateWizardSteps(steps);
            }
        }
        RequestContext ctx = new RequestContext(request);
        DynaActionForm dynaForm = (DynaActionForm) form;
        String step = dynaForm.getString(STEP_PARAM);
        ActionForward retval = null;

        if (step != null) {
            log.debug("Step selected: " + step);
            retval = dispatch(step, mapping, form, ctx, response);
        }
        return retval;
    }

    protected  abstract void generateWizardSteps(Map wizardSteps);

    protected ActionForward dispatch(String step, ActionMapping mapping, ActionForm form,
            RequestContext ctx, HttpServletResponse response) throws Exception {
        WizardStep wizardStep = (WizardStep) steps.get(step);
        if (wizardStep == null) {
            wizardStep = (WizardStep) steps.get(STEP_START);
        }
        if (wizardStep != null) {
            return wizardStep.invoke(mapping, form, ctx, response, this);
        }
        else {
            return null;
        }
    }

    protected List findMethods(String methodPrefix) {
        List retval = new LinkedList();
        Method[] methods = this.getClass().getDeclaredMethods();
        if (methods != null && methods.length > 0) {
            for (int x = 0; x < methods.length; x++) {
                if (methods[x].getName().startsWith(methodPrefix)) {
                    retval.add(methods[x]);
                }
            }
        }
        return retval;
    }
}
