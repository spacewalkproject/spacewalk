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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
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
public class ChannelFilesListSubmit extends BaseSetOperateOnSelectedItemsAction {
    public static final String KEY_REMOVE = "channelfiles.jsp.removeselected";
    public static final String KEY_COPY_TO_SYSTEMS = "channelfiles.jsp.copy2systems";
    public static final String KEY_COPY_TO_CHANNELS = "channelfiles.jsp.copy2channels";

    protected void processMethodKeys(Map map) {
        map.put(KEY_REMOVE, "processRemove");
        map.put(KEY_COPY_TO_SYSTEMS, "processCopyToSystems");
        map.put(KEY_COPY_TO_CHANNELS, "processCopyToChannels");
    }

    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest request,
                                   Map params) {

        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        ConfigActionHelper.processParamMap(cc, params);
    }

    /**
     * Remove selected files from the channel
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processRemove(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        ActionForward retval = operateOnSelectedSet(mapping, formIn, request,
                response, "setFilesToRemove");
        ConfigActionHelper.clearRhnSets(new RequestContext(request).getLoggedInUser());
        return retval;
    }
    /**
     * This method is called when the &quot;Remove from Channel&quot;
     * button is clicked in the Channel Files page.
     * removes the specified files from the channel.
     * @param form Action form object.
     * @param req The servlet request object
     * @param elementIn The checked element in the set
     * @param userIn logged in user
     * @return true
     */
    public Boolean setFilesToRemove(ActionForm form,
                                            HttpServletRequest req,
                                            RhnSetElement elementIn,
                                            User userIn) {
        ConfigFile file = ConfigurationManager.getInstance()
            .lookupConfigFile(userIn, elementIn.getElement());
        //couldn't find it, skip over this element.
        if (file == null) {
            return Boolean.FALSE;
        }

        //try to delete the file
        try {
            ConfigurationManager.getInstance().deleteConfigFile(userIn, file);
        }
        catch (IllegalArgumentException e) {
            //Log the error and go on with life.
            log.error("IllegalArgumentException deleting config file " +
                    file.getId(), e);
            return Boolean.FALSE;
        }
        //yay, it is deleted.
        return Boolean.TRUE;
    }

    private ActionForward processCopy(String forward, ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        RhnSet set = updateSet(request);
        if (set == null || set.isEmpty()) {
            RhnHelper.handleEmptySelection(request);
            return getStrutsDelegate().forwardParams(mapping.findForward(
                    RhnHelper.DEFAULT_FORWARD), makeParamMap(formIn, request));
        }
        else {
            return getStrutsDelegate().forwardParams(mapping.findForward(forward),
                    makeParamMap(formIn, request));
        }
    }
    /**
     * Copy selected files to systems - forward to a system-selection-page
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processCopyToSystems(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        return processCopy("copy2systems", mapping, formIn, request, response);
    }



    /**
     * Copy files to channels - forward to a channel-selection-page
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processCopyToChannels(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        return processCopy("copy2channels", mapping, formIn, request, response);
    }

    protected DataResult getDataResult(User u,
                                       ActionForm formIn,
                                       HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        ConfigActionHelper.setupRequestAttributes(ctx, cc);

        DataResult dr = ConfigurationManager.getInstance().
            listCurrentFiles(u, cc, null);

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
