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
package com.redhat.rhn.frontend.action.help;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * HelpAction extends RhnAction
 * @version $Rev: 1 $
 */
public class HelpAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();

        String doc = Config.get().getString(ConfigDefaults.DOC_REFERENCE_GUIDE);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("reference_guide", doc);
        }

        doc = Config.get().getString(ConfigDefaults.DOC_INSTALL_GUIDE);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("install_guide", doc);
        }

        doc = Config.get().getString(ConfigDefaults.DOC_PROXY_GUIDE);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("proxy_guide", doc);
        }

        doc = Config.get().getString(ConfigDefaults.DOC_CLIENT_CONFIG_GUIDE);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("client_config_guide", doc);
        }

        doc = Config.get().getString(ConfigDefaults.DOC_CHANNEL_MGMT_GUIDE);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("channel_mgmt_guide", doc);
        }

        doc = Config.get().getString(ConfigDefaults.DOC_RELEASE_NOTES);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("release_notes", doc);
        }

        doc = Config.get().getString(ConfigDefaults.DOC_PROXY_RELEASE_NOTES);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("proxy_release_notes", doc);
        }

        return mapping.findForward("default");
    }
}
