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
package com.redhat.rhn.frontend.action.configuration.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelFilesListSubmit
 * @version $Rev$
 */
public class ChannelFilesImportSubmit extends BaseSetOperateOnSelectedItemsAction {
    public static final String KEY_IMPORT = "addfiles.jsp.import.jspf.submit";

    protected void processMethodKeys(Map map) {
        map.put(KEY_IMPORT, "processImport");
    }

    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest request,
                                   Map params) {
        RequestContext requestContext = new RequestContext(request);

        Long ccid = requestContext.getRequiredParam("ccid");
        params.put("ccid", ccid);
    }

    /**
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processImport(
            ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        ActionForward fwd = operateOnSelectedSet(mapping, formIn, request, response,
                "setFilesToImport");
        return fwd;
    }
    /**
     * This method is called when the &quot;Import Into Channel&quot;
     * button is clicked in the Channel Add-Files\Import page.
     * Copies the specified files into the channel.
     * @param form Action form object.
     * @param req The servlet request object
     * @param elementIn The checked element in the set
     * @param userIn logged in user
     * @return true
     */
    public Boolean setFilesToImport(ActionForm form,
                                    HttpServletRequest req,
                                    RhnSetElement elementIn,
                                    User userIn) {
        ConfigFile file = ConfigurationManager.getInstance()
            .lookupConfigFile(userIn, elementIn.getElement());
        //couldn't find it, skip over this element.
        if (file == null) {
            return Boolean.FALSE;
        }

        ConfigChannel cc = ConfigActionHelper.getChannel(req);

        //try to delete the file
        try {
            ConfigurationManager.getInstance().copyConfigFile(
                    file.getLatestConfigRevision(), cc, userIn);
        }
        catch (IllegalArgumentException e) {
            //Log the error and go on with life.
            log.error("IllegalArgumentException copying config file " +
                    file.getId(), e);
            return Boolean.FALSE;
        }
        //yay, it is deleted.
        return Boolean.TRUE;
    }

    protected DataResult getDataResult(User u,
                                       ActionForm formIn,
                                       HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        ConfigActionHelper.setupRequestAttributes(ctx, cc);

        DataResult dr = ConfigurationManager.getInstance().
            listFilesNotInChannel(u, cc, null);

        return dr;
    }

    /**
     * We affect the selected-files set
     * @return FILE_LISTS identifier
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_FILES;
    }
}
