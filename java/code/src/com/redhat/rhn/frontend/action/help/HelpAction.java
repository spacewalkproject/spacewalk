/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;


/**
 * HelpAction extends RhnAction
 * @version $Rev: 1 $
 */
public class HelpAction extends RhnAction {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();

        String doc = Config.get().getString(ConfigDefaults.DOC_INSTALL_GUIDE);
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

        doc = Config.get().getString(ConfigDefaults.DOC_USER_GUIDE);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("user_guide", doc);
        }

        doc = Config.get().getString(ConfigDefaults.DOC_GETTING_STARTED_GUIDE);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("getting_started_guide", doc);
        }

        doc = Config.get().getString(ConfigDefaults.DOC_RELEASE_NOTES);
        if (doc != null && doc.trim().length() > 0) {
            request.setAttribute("release_notes", doc);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
