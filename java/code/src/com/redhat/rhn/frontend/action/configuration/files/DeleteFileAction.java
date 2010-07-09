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

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.action.configuration.ConfigFileForm;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DeleteFileAction
 * @version $Rev$
 */
public class DeleteFileAction extends RhnAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping map,
                                 ActionForm form,
                                 HttpServletRequest req,
                                 HttpServletResponse resp) throws Exception {
        RequestContext ctx = new RequestContext(req);
        User usr = ctx.getLoggedInUser();
        Map params =  makeParamMap(req);
        ConfigFileForm cff = (ConfigFileForm)form;

        ConfigFile cf = ConfigActionHelper.getFile(req);
        String filename = cf.getConfigFileName().getPath();
        ConfigChannel cc = cf.getConfigChannel();

        // If we have a file and are submitted, delete it.
        // If we're not submitted, show the "do you really want to do this?" page
        // If we have no file, tell the user "no can do" and go back to
        //   channel details
        try {
            if (cf != null) {
                if (isSubmitted(cff)) {
                    ConfigurationManager.getInstance().deleteConfigFile(usr, cf);
                    ConfigActionHelper.processParamMap(cc, params);
                    createSuccessMessage(req, "deletefile.jsp.success", filename);
                    return getStrutsDelegate().forwardParams(
                            map.findForward("success"), params);
                }
                else {
                    int storage = ConfigurationManager.getInstance().
                        getFileStorage(usr, cf);
                    ConfigActionHelper.processParamMap(req, params);
                    params.put("storage", new Integer(storage));
                    ConfigActionHelper.setupRequestAttributes(ctx, cf,
                                cf.getLatestConfigRevision());
                    req.setAttribute("storage", StringUtil.displayFileSize(storage));
                    req.setAttribute("deleting", Boolean.TRUE);

                    return getStrutsDelegate().forwardParams(
                            map.findForward("default"), params);
                }
            }
            else { // Can't find the revision?!?
                createErrorMessage(req, "deletefile.jsp.unknown", null);
                ConfigActionHelper.processParamMap(req, params);
                return getStrutsDelegate().forwardParams(
                        map.findForward("failure"), params);
            }
        }
        catch (IllegalArgumentException e) {
            //Log the error and go on with life.
            createErrorMessage(req, "delete.jsp.failure", filename);
            ConfigActionHelper.processParamMap(req, params);
            return getStrutsDelegate().forwardParams(
                    map.findForward("failure"), params);
        }
    }
}
