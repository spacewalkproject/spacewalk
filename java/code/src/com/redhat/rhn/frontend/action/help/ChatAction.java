package com.redhat.rhn.frontend.action.help;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * Static action page.
 *
 * @author Lukas Zapletal
 */
public class ChatAction extends org.apache.struts.action.Action {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        return mapping.findForward("default");
    }
}
