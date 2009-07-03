
package com.redhat.rhn.frontend.action.audit;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.audit.AuditManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Enumeration;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AuditAction
 * @version $Rev$
 */
public class AuditAction extends RhnAction implements Listable {

    private static Logger log = Logger.getLogger(AuditAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        Enumeration paramNames;
        ListHelper helper = new ListHelper(this, request);
        Map forwardParams = makeParamMap(request);
        String str;

        helper.execute();

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        // set up parameters to forward
        paramNames = request.getParameterNames();

        while (paramNames.hasMoreElements()) {
            str = (String) paramNames.nextElement();
            forwardParams.put(str, request.getParameter(str));
        }

        return getStrutsDelegate().forwardParams(
            mapping.findForward("default"),
            forwardParams);
    }

    /** {@inheritDoc} */
    public DataResult getResult(RequestContext context) {
        return AuditManager.getMachines();
    }
}

// vim: ts=4:expandtab
