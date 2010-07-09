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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.action.configuration.ConfigFileForm;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * FileDetailsAction
 * @version $Rev$
 */
public class DeleteRevisionAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {

        Map params = makeParamMap(request);
        ConfigFileForm cff = (ConfigFileForm)form;

        ConfigRevision cr = ConfigActionHelper.findRevision(request);
        ConfigFile cf = ConfigActionHelper.getFile(request);

        ActionMessages msgs = new ActionMessages();

        RequestContext ctx = new RequestContext(request);

        try {
            if (cr != null) {
                if (isSubmitted(cff)) {
                    User u = ctx.getLoggedInUser();
                    boolean deletedFile =
                        ConfigurationManager.getInstance().deleteConfigRevision(u, cr);
                    //now that the config revision is gone, some of the sets may no
                    //longer be valid, so clear them.
                    ConfigActionHelper.clearRhnSets(u);

                    if (!deletedFile) {
                        String path = cr.getConfigFile().getConfigFileName().getPath();
                        String revision = cr.getRevision().toString();
                        ActionMessage am = new ActionMessage("deleterev.jsp.deleted",
                                path, revision);
                        msgs.add(ActionMessages.GLOBAL_MESSAGE, am);
                        /*
                         * Although I would like to just do:
                         * ConfigActionHelper.processParamMap(request, params);
                         * The revision from the request is the one we just deleted,
                         * so this would cause a LookupException.
                         */
                        params.put("cfid", cf.getId().toString());
                        params.put("crid", cf.getLatestConfigRevision().getId().toString());
                        return getStrutsDelegate().forwardParams(
                                mapping.findForward("success"), params);
                    }
                    else {
                        ActionMessage am = new ActionMessage("deleterev.jsp.deletedfile",
                                cr.getConfigFile().getConfigFileName().getPath());
                        msgs.add(ActionMessages.GLOBAL_MESSAGE, am);
                        ConfigActionHelper.processParamMap(cf.getConfigChannel(), params);
                        return getStrutsDelegate().forwardParams(
                                mapping.findForward("deletedfile"), params);
                    }
                }
                else {
                    cff.updateFromRevision(request, cr);
                    request.setAttribute("deleting", Boolean.TRUE);
                    return getStrutsDelegate().forwardParams(
                            mapping.findForward("default"), params);
                }
            }
            else { // Can't find the revision?!?
                ActionMessage am = new ActionMessage("deleterev.jsp.unknown");
                msgs.add(ActionMessages.GLOBAL_MESSAGE, am);
                return getStrutsDelegate().forwardParams(
                        mapping.findForward("default"), params);
            }
        }
        finally {
            if (!msgs.isEmpty()) {
                saveMessages(request, msgs);
            }
        }
    }
}
